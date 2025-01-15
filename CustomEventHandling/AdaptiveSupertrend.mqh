#include "../indicator/TwoLineIndicator.mqh"
#include "../indicator/SuperTrend/Supertrend.mqh"

namespace CustomEventHandling {
    class AdaptiveSupertrend {
        static AdaptiveSupertrend *instance;
        TwoLineIndicator *supertrend;

        // data from user input
        int atrLen;
        int trainingPeriod;
        float factor;
        float highVol;
        float midVol;
        float lowVol;

        // buffer data
        int handle;
        double atrBuffer;
        double upperLine;
        double lowerLine;
        double midUpperLine;
        double midLowerLine;
        bool channel;

        AdaptiveSupertrend() : supertrend(NULL, NULL, NULL, NULL, NULL) {};

    public:
        static AdaptiveSupertrend *getInstance();
        int OnInit();
        int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[]. const double &open[], const double &high[], const double &low[], const double &close[]);
        int OnDeinit(const int reason);
        void userInput(const int atrLen, const int trainingPeriod, const float factor, const float highVol, const float midVol, const float lowVol);
        void channel();
    };
};

// Initialized static member
CustomEventHandling::AdaptiveSupertrend *CustomEventHandling::AdaptiveSupertrend::instance = NULL;

CustomEventHandling::AdaptiveSupertrend *AdaptiveSupertrend::getInstance() {
    if (CustomEventHandling::AdaptiveSupertrend::instance == NULL) {
        CustomEventHandling::AdaptiveSupertrend::instance = new CustomEventHandling::AdaptiveSupertrend();
    }

    return(CustomEventHandling::AdaptiveSupertrend::instance);
}

int CustomEventHandling::AdaptiveSupertrend::OnInit() {
    this->supertrend = new Supertrend(this.trainingPeriod, this.highVol, this.midVol, this.lowVol);

    handle = iATR(_Symbol, _Period, this->atrLen);

    // set index to each buffer
    SetIndexBuffer(0, this->upperLine, INDICATOR_DATA);
    SetIndexBuffer(1, this->lowerLine, INDICATOR_DATA);

    // set dont draw indicator if the value 0 to each buffer
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);

    // set label to each indicator drawed
    PlotIndexSetString(0, PLOT_LABEL, "UPPER LINE");
    PlotIndexSetString(0, PLOT_LABEL, "LOWER LINE");
    return(INIT_SUCCEEDED);
}

int CustomEventHandling::AdaptiveSupertrend::OnCalculate(const int rates_total, const int prev_calculated,
const datetime &time[], const double &open[], const double &high[],
const double &low[], const double &close[]) {
    int copyAtr;
    int current = prev_calculated;
    for (;current < rates_total-2; current++) {
        copyAtr = copyBuffer(handle, 0, 0, rates_total, atrBuffer);
        if (copyAtr <= 0) {
            printf("Failed to copy ATR Buffer. Error Code : %d", GetLastError());
            return(prev_calculated);
        }

        if (this->supertrend->setSeries(atrBuffer, open, close, high, low) <= 0) {
            printf("Failed copy all series, script abort. ErrCode : %d" GetLastError());
            ExpertRemove();
        }

        this->supertrend->setBar(current);
        dynamic_cast<Supertrend*>(this->supertrend)->identifyngTrend();
        this->supertrend->getBuffer(this->upperLine, this->lowerLine);
        this->supertrend->channel();
    }

    copyAtr = copyBuffer(handle, 0, 0, rates_total, atrBuffer);
    if (copyAtr <= 0) {
        printf("Failed to copy ATR Buffer. Error Code : %d", GetLastError());
        return(prev_calculated);
    }

    if (this->supertrend->setSeries(atrBuffer, open, close, high, low) <= 0) {
        printf("Failed copy all series, script abort. ErrCode : %d" GetLastError());
        ExpertRemove();
    }

    this->supertrend->setBar(current);
    dynamic_cast<Supertrend*>(this->supertrend)->identifyngTrend();
    this->supertrend->getBuffer(this->upperLine, this->lowerLine);
    this->supertrend->channel()
    return(rates_total-1);
}

void CustomEventHandling::AdaptiveSupertrend::OnDeinit(const int reason) {
    if (reason >= 0 && reason <= 9 ) {
        bool handleRemove = IndicatorRelease(handle);
        ArrayFree(atrBuffer);
        ArrayFree(upperLine);
        ArrayFree(lowerLine);
        ArrayFree(midUpperLine);
        ArrayFree(midLowerLine);

        bool checkBuffer = if (ArraySize(atrBuffer) == 0 && ArraySize(upperLine) == 0 &&
                                ArraySize(lowerLine) == 0 && ArraySize(midUpperLine) == 0 &&
                                ArraySize(midLowerLine) == 0) ? 1 : 0;
        if (handleRemove == 1 && checkBuffer == 1) {
            printf("Buffer succesfully clearing !!");
            ExpertRemove();
        } else {
            printf("We'll try again !");
            this->OnDeinit(reason);
        }
    }
}

void CustomEventHandling::AdaptiveSupertrend::userInput(const int atrLen, const int trainingPeriod,
const float factor, const float highVol, const float midVol, const float lowVol) {
    this->atrLen = atrLen;
    this->factor = factor;
    this->highVol = highVol;
    this->midVol = midVol;
    this->lowVol = lowVol;
}

void CustomEventHandling::AdaptiveSupertrend::channel() {
    if (this->channel == 1) {
        SetIndexBuffer(2, midUpperLine, INDICATOR_DATA);
        SetIndexBuffer(3, midLowerLine, INDICATOR_DATA);
        PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
        PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
        PlotIndexSetString(2, PLOT_LABEL, "MID UPPER LINE");
        PlotIndexSetString(2, PLOT_LABEL, "MID LOWER LINE");
        this->supertrend->getChannel(midUpperLine, midLowerLine);
    }
}
