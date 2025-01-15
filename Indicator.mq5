// : :                                                                      : :
// : :      ___        __               __   _                              : :
// : :     /   |  ____/ /____ _ ____   / /_ (_)_   __ ___                   : :
// : :    / /| | / __  // __ `// __ \ / __// /| | / // _ \                  : :
// : :   / ___ |/ /_/ // /_/ // /_/ // /_ / / | |/ //  __/                  : :
// : :  /_/  |_|\__,_/ \__,_// .___/ \__//_/  |___/ \___/                   : :
// : :     _____            /_/             __                          __  : :
// : :    / ___/ __  __ ____   ___   _____ / /_ _____ ___   ____   ____/ /  : :
// : :    \__ \ / / / // __ \ / _ \ / ___// __// ___// _ \ / __ \ / __  /   : :
// : :   ___/ // /_/ // /_/ //  __// /   / /_ / /   /  __// / / // /_/ /    : :
// : :  /____/ \__,_// .___/ \___//_/    \__//_/    \___//_/ /_/ \__,_/     : :
// : :              /_/                                                     : :
// : : Implement by z0mbl03                                                 : :
// '·:......................................................................:·'


#property description "Adaptive Supertrend Indicator in MQL5"
#property description "This implementation of the Adaptive Supertrend indicator was ported to MQL5 by z0mbl03."
#property description "The original code was developed by AlphaAlgo on TradingView."
#property description "Original Source:"
#property link "https://www.tradingview.com/script/CLk71Qgy-Machine-Learning-Adaptive-SuperTrend-AlgoAlpha/"



// include library
#include <Math/Stat/Normal.mqh>
#include "CustomEventHandling/AdaptiveSupertrendEventHandling.mqh";
CustomEventHandling::AdaptiveSupertrendEventHandling *supertrendEventHandling;

// define indicator propertry
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 3

// define property for upper line
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color1 clrCrimson

// define property for lower line
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_color2 clrLawnGreen

// define property for channel (here)


// take user input
input int atrLen = 10;
input float factor = 3.0;
input int trainingDataPeriod = 100;
input float highVol = 0.75;
input float midVol = 0.5;
input float lowVol = 0.25;


// initialization event handling
int OnInit() {
    ::supertrendEventHandling = CustomEventHandling::AdaptiveSupertrendEventHandling::getInstance();
    ::supertrendEventHandling.userInput(atrLen, trainingDataPeriod, factor, highVol, midVol, lowVol);
    ::supertrendEventHandling.OnInit();
    return(INIT_SUCCEEDED);
}

// calculated event handling
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[]) {
    ::supertrendEventHandling.OnCalculate(rates_total, prev_calculated, time, open, high, low, close);
    return(rates_total);
}

// de initialization event handling
int OnDeinit(const int reason) {
    ::supertrendEventHandling.OnDeinit(reason);
}
