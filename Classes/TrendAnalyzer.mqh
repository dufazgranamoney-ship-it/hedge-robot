//+------------------------------------------------------------------+
//|                    TRENDANALYZER.MQH                             |
//|              Classe para Análise de Tendências                   |
//+------------------------------------------------------------------+

#ifndef _TRENDANALYZER_MQH_
#define _TRENDANALYZER_MQH_

#include "../Config/Settings.mqh"

class CTrendAnalyzer {
private:
    double m_maValues[];
    
public:
    CTrendAnalyzer();
    ~CTrendAnalyzer();
    
    ENUM_TREND_DIRECTION GetTrend(string symbol, int maPeriod);
    double GetMovingAverage(string symbol, int period);
    TrendData AnalyzeTrendStrength(string symbol, int maPeriod);
    bool IsTrendConfirmed(string symbol, int maPeriod, ENUM_TREND_DIRECTION trend);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+

CTrendAnalyzer::CTrendAnalyzer() {
    ArrayResize(m_maValues, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+

CTrendAnalyzer::~CTrendAnalyzer() {
    ArrayFree(m_maValues);
}

//+------------------------------------------------------------------+
//| Obter Tendência do Símbolo                                      |
//+------------------------------------------------------------------+

ENUM_TREND_DIRECTION CTrendAnalyzer::GetTrend(string symbol, int maPeriod) {
    if (maPeriod < 2) maPeriod = 2;
    
    // Obter preço atual (close)
    double close = SymbolInfoDouble(symbol, SYMBOL_LAST);
    if (close <= 0) {
        close = SymbolInfoDouble(symbol, SYMBOL_ASK);
    }
    
    // Obter Média Móvel
    double ma = GetMovingAverage(symbol, maPeriod);
    
    if (ma <= 0) {
        return TREND_NONE;
    }
    
    // Analisar tendência
    double difference = close - ma;
    double differencePercent = (difference / ma) * 100.0;
    
    // Limiar mínimo de 0.1% para considerar tendência
    if (MathAbs(differencePercent) < 0.1) {
        return TREND_NONE;
    }
    
    if (differencePercent > 0) {
        return TREND_UP;
    } else {
        return TREND_DOWN;
    }
}

//+------------------------------------------------------------------+
//| Calcular Média Móvel Simples (SMA)                              |
//+------------------------------------------------------------------+

double CTrendAnalyzer::GetMovingAverage(string symbol, int period) {
    // Criar handle para indicador de Média Móvel
    int maHandle = iMA(symbol, PERIOD_CURRENT, period, 0, MODE_SMA, PRICE_CLOSE);
    
    if (maHandle == INVALID_HANDLE) {
        PrintFormat("ERRO ao criar MA handle para %s", symbol);
        return -1.0;
    }
    
    // Copiar valor atual da MA
    double maBuffer[];
    if (CopyBuffer(maHandle, 0, 0, 1, maBuffer) <= 0) {
        PrintFormat("ERRO ao copiar buffer MA para %s", symbol);
        IndicatorRelease(maHandle);
        return -1.0;
    }
    
    IndicatorRelease(maHandle);
    return maBuffer[0];
}

//+------------------------------------------------------------------+
//| Analisar Força da Tendência                                     |
//+------------------------------------------------------------------+

TrendData CTrendAnalyzer::AnalyzeTrendStrength(string symbol, int maPeriod) {
    TrendData data;
    
    double close = SymbolInfoDouble(symbol, SYMBOL_LAST);
    if (close <= 0) {
        close = SymbolInfoDouble(symbol, SYMBOL_ASK);
    }
    
    double ma = GetMovingAverage(symbol, maPeriod);
    
    data.currentPrice = close;
    data.maValue = ma;
    data.direction = GetTrend(symbol, maPeriod);
    
    // Calcular força (0.0 a 1.0)
    if (ma > 0) {
        double difference = MathAbs(close - ma) / ma;
        data.strength = MathMin(difference * 10, 1.0); // Normalizar entre 0 e 1
    } else {
        data.strength = 0.0;
    }
    
    return data;
}

//+------------------------------------------------------------------+
//| Confirmar Tendência com Múltiplas Análises                      |
//+------------------------------------------------------------------+

bool CTrendAnalyzer::IsTrendConfirmed(string symbol, int maPeriod, ENUM_TREND_DIRECTION trend) {
    if (trend == TREND_NONE) return false;
    
    double close = SymbolInfoDouble(symbol, SYMBOL_LAST);
    if (close <= 0) {
        close = SymbolInfoDouble(symbol, SYMBOL_ASK);
    }
    
    double ma = GetMovingAverage(symbol, maPeriod);
    
    if (ma <= 0) return false;
    
    // Confirmar tendência
    if (trend == TREND_UP) {
        return close > ma;
    } else if (trend == TREND_DOWN) {
        return close < ma;
    }
    
    return false;
}

#endif
