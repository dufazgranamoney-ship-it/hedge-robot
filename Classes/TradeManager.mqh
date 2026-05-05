//+------------------------------------------------------------------+
//|                    TRADEMANAGER.MQH                              |
//|              Classe para Gerenciamento de Trades                 |
//+------------------------------------------------------------------+

#ifndef _TRADEMANAGER_MQH_
#define _TRADEMANAGER_MQH_

#include "../Config/Settings.mqh"

class CTradeManager {
private:
    TradeData m_positions[];
    int m_positionCount;
    CTrade m_trade;
    
public:
    CTradeManager();
    ~CTradeManager();
    
    int OpenPosition(string symbol, ENUM_TREND_DIRECTION direction, double lot, double entryPrice, double tp, double spreadAdj);
    bool ClosePosition(int ticket);
    bool PositionExists(string symbol);
    void CloseProfiablePositions(double tpPercent);
    double GetPositionProfit(int ticket);
    int GetPositionCount();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+

CTradeManager::CTradeManager() {
    m_positionCount = 0;
    ArrayResize(m_positions, MAX_POSITIONS);
    m_trade.SetExpertMagicNumber(123456); // Magic number único
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+

CTradeManager::~CTradeManager() {
    ArrayFree(m_positions);
}

//+------------------------------------------------------------------+
//| Abrir Posição                                                   |
//+------------------------------------------------------------------+

int CTradeManager::OpenPosition(string symbol, ENUM_TREND_DIRECTION direction, double lot, double entryPrice, double tp, double spreadAdj) {
    if (lot <= 0) {
        PrintFormat("ERRO: Lote inválido para %s", symbol);
        return -1;
    }
    
    // Preparar request
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = symbol;
    request.volume = lot;
    request.magic = 123456;
    request.comment = "HedgeRobot";
    
    if (direction == TREND_UP) {
        request.type = ORDER_TYPE_BUY;
        request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    } else {
        request.type = ORDER_TYPE_SELL;
        request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
    }
    
    request.tp = tp;
    
    // Enviar ordem
    if (!OrderSend(request, result)) {
        PrintFormat("ERRO ao abrir posição em %s: %s", symbol, result.comment);
        return -1;
    }
    
    // Registrar posição
    if (m_positionCount < MAX_POSITIONS) {
        m_positions[m_positionCount].ticket = result.order;
        m_positions[m_positionCount].symbol = symbol;
        m_positions[m_positionCount].direction = direction;
        m_positions[m_positionCount].entryPrice = request.price;
        m_positions[m_positionCount].takeProfit = tp;
        m_positions[m_positionCount].lotSize = lot;
        m_positions[m_positionCount].openTime = TimeCurrent();
        m_positions[m_positionCount].isHedged = false;
        m_positionCount++;
    }
    
    return result.order;
}

//+------------------------------------------------------------------+
//| Fechar Posição                                                  |
//+------------------------------------------------------------------+

bool CTradeManager::ClosePosition(int ticket) {
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.magic = 123456;
    request.position = ticket;
    
    // Verificar posição aberta
    if (!PositionSelectByTicket(ticket)) {
        PrintFormat("AVISO: Posição %d não encontrada", ticket);
        return false;
    }
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double volume = PositionGetDouble(POSITION_VOLUME);
    
    request.symbol = symbol;
    request.volume = volume;
    
    if (posType == POSITION_TYPE_BUY) {
        request.type = ORDER_TYPE_SELL;
        request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
    } else {
        request.type = ORDER_TYPE_BUY;
        request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    }
    
    if (!OrderSend(request, result)) {
        PrintFormat("ERRO ao fechar posição %d: %s", ticket, result.comment);
        return false;
    }
    
    PrintFormat("✓ Posição %d fechada com sucesso", ticket);
    return true;
}

//+------------------------------------------------------------------+
//| Verificar se Posição Existe                                     |
//+------------------------------------------------------------------+

bool CTradeManager::PositionExists(string symbol) {
    int total = PositionsTotal();
    
    for (int i = 0; i < total; i++) {
        if (PositionGetSymbol(i) == symbol) {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Fechar Posições Lucrativas                                      |
//+------------------------------------------------------------------+

void CTradeManager::CloseProfiablePositions(double tpPercent) {
    int total = PositionsTotal();
    
    for (int i = total - 1; i >= 0; i--) {
        if (!PositionSelectByTicket(PositionGetTicket(i))) continue;
        
        if (PositionGetInteger(POSITION_MAGIC) != 123456) continue;
        
        string symbol = PositionGetString(POSITION_SYMBOL);
        double profit = PositionGetDouble(POSITION_PROFIT);
        double volume = PositionGetDouble(POSITION_VOLUME);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        
        // Calcular lucro esperado (TP de 10%)
        double expectedProfit = volume * openPrice * (tpPercent / 100.0);
        
        if (profit >= expectedProfit * 0.95) { // 95% do TP
            int ticket = PositionGetTicket(i);
            PrintFormat("Fechando posição lucrativa: %s | Lucro: %f", symbol, profit);
            ClosePosition(ticket);
        }
    }
}

//+------------------------------------------------------------------+
//| Obter Lucro da Posição                                          |
//+------------------------------------------------------------------+

double CTradeManager::GetPositionProfit(int ticket) {
    if (!PositionSelectByTicket(ticket)) {
        return 0.0;
    }
    
    return PositionGetDouble(POSITION_PROFIT);
}

//+------------------------------------------------------------------+
//| Obter Contagem de Posições                                      |
//+------------------------------------------------------------------+

int CTradeManager::GetPositionCount() {
    return PositionsTotal();
}

#endif
