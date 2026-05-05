//+------------------------------------------------------------------+
//|                      SETTINGS.MQH                                |
//|                   Arquivo de Configurações                       |
//+------------------------------------------------------------------+

#ifndef _SETTINGS_MQH_
#define _SETTINGS_MQH_

// Enums para Tendência
enum ENUM_TREND_DIRECTION {
    TREND_UP = 1,
    TREND_DOWN = -1,
    TREND_NONE = 0
};

// Estrutura para armazenar dados de operação
struct TradeData {
    int ticket;
    string symbol;
    ENUM_TREND_DIRECTION direction;
    double entryPrice;
    double stopLoss;
    double takeProfit;
    double lotSize;
    datetime openTime;
    bool isHedged;
    int hedgeTicket;
};

// Estrutura para análise de tendência
struct TrendData {
    ENUM_TREND_DIRECTION direction;
    double strength;  // 0.0 a 1.0
    double maValue;
    double currentPrice;
};

// Constantes
#define MAX_POSITIONS 100
#define MAX_SYMBOLS 20
#define MIN_SPREAD 0.5
#define MAX_SPREAD 50.0

#endif
