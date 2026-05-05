//+------------------------------------------------------------------+
//|                    HEDGEMANAGER.MQH                              |
//|              Classe para Gerenciamento de Hedges                 |
//+------------------------------------------------------------------+

#ifndef _HEDGEMANAGER_MQH_
#define _HEDGEMANAGER_MQH_

#include "../Config/Settings.mqh"

class CHedgeManager {
private:
    int m_hedges[];
    int m_hedgeCount;
    
public:
    CHedgeManager();
    ~CHedgeManager();
    
    void CheckAndActivateHedges(double hedgePercent, double tpPercent);
    bool ActivateHedge(int ticket, double hedgePercent, double tpPercent);
    bool IsHedgeActive(int ticket);
    double GetDrawdown(int ticket);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+

CHedgeManager::CHedgeManager() {
    m_hedgeCount = 0;
    ArrayResize(m_hedges, MAX_POSITIONS);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+

CHedgeManager::~CHedgeManager() {
    ArrayFree(m_hedges);
}

//+------------------------------------------------------------------+
//| Verificar e Ativar Hedges                                       |
//+------------------------------------------------------------------+

void CHedgeManager::CheckAndActivateHedges(double hedgePercent, double tpPercent) {
    int total = PositionsTotal();
    
    for (int i = 0; i < total; i++) {
        if (!PositionSelectByTicket(PositionGetTicket(i))) continue;
        
        if (PositionGetInteger(POSITION_MAGIC) != 123456) continue;
        
        int ticket = PositionGetTicket(i);
        
        // Verificar se já tem hedge
        if (IsHedgeActive(ticket)) continue;
        
        double drawdown = GetDrawdown(ticket);
        
        // Se drawdown >= hedgePercent, ativar hedge
        if (drawdown >= hedgePercent) {
            PrintFormat("⚠ Drawdown em %d atingiu %.2f%%, ativando hedge", ticket, drawdown);
            ActivateHedge(ticket, hedgePercent, tpPercent);
        }
    }
}

//+------------------------------------------------------------------+
//| Ativar Hedge                                                    |
//+------------------------------------------------------------------+

bool CHedgeManager::ActivateHedge(int ticket, double hedgePercent, double tpPercent) {
    if (!PositionSelectByTicket(ticket)) {
        return false;
    }
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double volume = PositionGetDouble(POSITION_VOLUME);
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = symbol;
    request.volume = volume;
    request.magic = 123456;
    request.comment = "HedgeRobot - Hedge";
    
    // Abrir operação contrária
    if (posType == POSITION_TYPE_BUY) {
        request.type = ORDER_TYPE_SELL;
        request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
    } else {
        request.type = ORDER_TYPE_BUY;
        request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    }
    
    // TP para o hedge (fechar em breakeven ou pequeno lucro)
    double hedgeTP = openPrice; // Breakeven
    request.tp = hedgeTP;
    
    if (!OrderSend(request, result)) {
        PrintFormat("ERRO ao ativar hedge para %d: %s", ticket, result.comment);
        return false;
    }
    
    PrintFormat("✓ Hedge ativado para posição %d | Hedge Ticket: %d", ticket, result.order);
    
    // Registrar hedge
    if (m_hedgeCount < MAX_POSITIONS) {
        m_hedges[m_hedgeCount] = result.order;
        m_hedgeCount++;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Verificar se Hedge Está Ativo                                   |
//+------------------------------------------------------------------+

bool CHedgeManager::IsHedgeActive(int ticket) {
    for (int i = 0; i < m_hedgeCount; i++) {
        if (m_hedges[i] == ticket) {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Calcular Drawdown da Posição                                    |
//+------------------------------------------------------------------+

double CHedgeManager::GetDrawdown(int ticket) {
    if (!PositionSelectByTicket(ticket)) {
        return 0.0;
    }
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double drawdown = 0.0;
    
    if (posType == POSITION_TYPE_BUY) {
        drawdown = ((openPrice - currentPrice) / openPrice) * 100.0;
    } else {
        drawdown = ((currentPrice - openPrice) / openPrice) * 100.0;
    }
    
    return MathAbs(drawdown);
}

#endif
