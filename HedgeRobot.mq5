//+------------------------------------------------------------------+
//|                         HEDGE ROBOT v1.0                         |
//|                   Robô de Hedge Multiativos MQL5                 |
//|              Forex, Ouro, Criptomoedas - MetaTrader 5           |
//+------------------------------------------------------------------+

#property copyright "DufazGrana Money"
#property link "https://github.com/dufazgranamoney-ship-it"
#property version "1.0"
#property strict
#property description "Robô de Hedge com múltiplos ativos, hedge automático em 10% e TP de 10%"

// Include files
#include "Config/Settings.mqh"
#include "Classes/TrendAnalyzer.mqh"
#include "Classes/TradeManager.mqh"
#include "Classes/HedgeManager.mqh"

//+------------------------------------------------------------------+
//| Input Parameters - Configurações do Usuário                     |
//+------------------------------------------------------------------+

// Geral
input string Symbols = "EURUSD,GBPUSD,USDJPY,XAUUSD,BTCUSD,ETHUSD"; // Símbolos separados por vírgula
input double LotSize = 0.1;                                           // Tamanho do lote padrão
input double SpreadAdjustment = 1.5;                                  // Ajuste de spread (%)
input double TakeProfitPercent = 10.0;                                // Take Profit (%)
input double HedgeActivationPercent = 10.0;                           // Ativa hedge em X% contra
input int MAPeriod = 20;                                              // Período da Média Móvel para Tendência
input int RiskManagement = 2;                                         // Risco máximo por operação (%)

// Padrão de entrada
input bool OnlyTrendEntries = true;                                   // Apenas entradas com tendência
input bool UseMovingAverage = true;                                   // Usar Média Móvel para confirmar tendência
input bool CloseOnProfitAndReopen = true;                             // Fechar com lucro e reabrir

// Múltiplos ativos - Pesos/Percentuais
input double ForexWeight = 30.0;                                      // % para Forex (EUR, GBP, USD, JPY)
input double GoldWeight = 30.0;                                       // % para Ouro (XAU)
input double CryptoWeight = 40.0;                                     // % para Criptomoedas (BTC, ETH)

//+------------------------------------------------------------------+
//| Variáveis Globais                                               |
//+------------------------------------------------------------------+

CTrendAnalyzer *TrendAnalyzer;
CTradeManager *TradeManager;
CHedgeManager *HedgeManager;

int OnInit() {
    // Inicializar classes
    TrendAnalyzer = new CTrendAnalyzer();
    TradeManager = new CTradeManager();
    HedgeManager = new CHedgeManager();
    
    // Validar parâmetros
    if (LotSize <= 0) {
        PrintFormat("ERRO: LotSize deve ser maior que 0. Valor recebido: %f", LotSize);
        return INIT_PARAMETERS_INCORRECT;
    }
    
    if (TakeProfitPercent <= 0) {
        PrintFormat("ERRO: TakeProfitPercent deve ser maior que 0. Valor recebido: %f", TakeProfitPercent);
        return INIT_PARAMETERS_INCORRECT;
    }
    
    PrintFormat("=== HEDGE ROBOT INICIADO ===");
    PrintFormat("Símbolos: %s", Symbols);
    PrintFormat("Lote Padrão: %f", LotSize);
    PrintFormat("TP: %f%% | Hedge: %f%%", TakeProfitPercent, HedgeActivationPercent);
    PrintFormat("Forex: %f%% | Ouro: %f%% | Crypto: %f%%", ForexWeight, GoldWeight, CryptoWeight);
    
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    if (TrendAnalyzer != NULL) delete TrendAnalyzer;
    if (TradeManager != NULL) delete TradeManager;
    if (HedgeManager != NULL) delete HedgeManager;
    
    PrintFormat("=== HEDGE ROBOT FINALIZADO (Motivo: %d) ===", reason);
}

void OnTick() {
    // Processar cada símbolo
    string SymbolArray[];
    ParseSymbols(Symbols, SymbolArray);
    
    for (int i = 0; i < ArraySize(SymbolArray); i++) {
        ProcessSymbol(SymbolArray[i]);
    }
    
    // Verificar hedge em operações abertas
    HedgeManager.CheckAndActivateHedges(HedgeActivationPercent, TakeProfitPercent);
    
    // Fechar operações com lucro
    TradeManager.CloseProfiablePositions(TakeProfitPercent);
}

//+------------------------------------------------------------------+
//| Processar Símbolo Individual                                    |
//+------------------------------------------------------------------+

void ProcessSymbol(string symbol) {
    if (!SymbolSelect(symbol, true)) {
        PrintFormat("AVISO: Símbolo %s não disponível", symbol);
        return;
    }
    
    // 1. Analisar Tendência
    ENUM_TREND_DIRECTION trend = TrendAnalyzer.GetTrend(symbol, MAPeriod);
    
    if (trend == TREND_NONE) {
        return; // Sem tendência clara
    }
    
    // 2. Verificar se já existe operação aberta
    if (TradeManager.PositionExists(symbol)) {
        return; // Já há operação, não abrir nova
    }
    
    // 3. Calcular tamanho do lote ajustado ao ativo
    double adjustedLot = CalculateAdjustedLot(symbol, LotSize);
    
    // 4. Abrir operação
    double entryPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
    double tp = CalculateTakeProfit(symbol, entryPrice, trend, TakeProfitPercent);
    
    int ticket = TradeManager.OpenPosition(
        symbol,
        trend,
        adjustedLot,
        entryPrice,
        tp,
        SpreadAdjustment
    );
    
    if (ticket > 0) {
        PrintFormat("✓ Operação aberta: %s | Lote: %f | Preço: %f | TP: %f", 
            symbol, adjustedLot, entryPrice, tp);
    }
}

//+------------------------------------------------------------------+
//| Calcular Lote Ajustado por Ativo                                |
//+------------------------------------------------------------------+

double CalculateAdjustedLot(string symbol, double baseLot) {
    double weight = 0;
    
    if (StringFind(symbol, "EUR") >= 0 || StringFind(symbol, "GBP") >= 0 || 
        StringFind(symbol, "USD") >= 0 || StringFind(symbol, "JPY") >= 0) {
        weight = ForexWeight;
    } 
    else if (StringFind(symbol, "XAU") >= 0) {
        weight = GoldWeight;
    }
    else if (StringFind(symbol, "BTC") >= 0 || StringFind(symbol, "ETH") >= 0) {
        weight = CryptoWeight;
    }
    
    double adjustedLot = baseLot * (weight / 100.0);
    return NormalizeDouble(adjustedLot, 2);
}

//+------------------------------------------------------------------+
//| Calcular Take Profit                                            |
//+------------------------------------------------------------------+

double CalculateTakeProfit(string symbol, double entryPrice, ENUM_TREND_DIRECTION trend, double tpPercent) {
    double pipValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
    double tpDistance = entryPrice * (tpPercent / 100.0);
    
    double tp;
    if (trend == TREND_UP) {
        tp = entryPrice + tpDistance;
    } else {
        tp = entryPrice - tpDistance;
    }
    
    return NormalizeDouble(tp, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Parse Símbolos da String                                        |
//+------------------------------------------------------------------+

void ParseSymbols(string symbolString, string &array[]) {
    ArrayResize(array, 0);
    
    int count = 0;
    int pos = 0;
    string symbol = "";
    
    for (int i = 0; i < StringLen(symbolString); i++) {
        if (symbolString[i] == ',') {
            if (symbol != "") {
                ArrayResize(array, count + 1);
                array[count] = symbol;
                count++;
                symbol = "";
            }
        } else {
            symbol += CharToString(symbolString[i]);
        }
    }
    
    if (symbol != "") {
        ArrayResize(array, count + 1);
        array[count] = symbol;
    }
}

//+------------------------------------------------------------------+
// FIM DO EA
//+------------------------------------------------------------------+
