#include "../indicator/TwoLineIndicator.mqh";
#include "../indicator/SuperTrend/Supertrend.mqh";

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
        double atrBuffer[];
        double upperLine[];
        double lowerLine[];
        double midUpperLine[];
        double midLowerLine[];
        bool chan;

        AdaptiveSupertrend();

    public:
        static AdaptiveSupertrend *getInstance();
        int OnInit();
        int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[]);
        void OnDeinit(const int reason);
        void userInput(const int inAtrLen, const int inTrainingPeriod, const float inFactor, const float inHighVol, const float inMidVol, const float inLowVol);
        void channel();
    };

    AdaptiveSupertrend::AdaptiveSupertrend() : supertrend(NULL) {
        this.atrLen = 0;
        this.trainingPeriod = 0;
        this.factor = 0;
        this.highVol = 0;
        this.midVol = 0;
        this.lowVol = 0;
        this.handle = 0;
        this.chan = false;

        ArrayResize(this.atrBuffer, this.trainingPeriod);
        ArrayInitialize(this.atrBuffer, 0);
        ArrayInitialize(this.upperLine, 0);
        ArrayInitialize(this.lowerLine, 0);
        ArrayInitialize(this.midUpperLine, 0);
        ArrayInitialize(this.midLowerLine, 0);
    }

    // Initialized static member
    AdaptiveSupertrend *AdaptiveSupertrend::instance = NULL;

    AdaptiveSupertrend *AdaptiveSupertrend::getInstance() {
        if (AdaptiveSupertrend::instance == NULL) {
            AdaptiveSupertrend::instance = new AdaptiveSupertrend();
        }

        return(AdaptiveSupertrend::instance);
    }

    int AdaptiveSupertrend::OnInit() {
        this.supertrend = new SuperTrend::Supertrend(this.trainingPeriod, this.highVol, this.midVol, this.lowVol, this.factor);

        this.handle = iATR(_Symbol, _Period, this.atrLen);

        // set index to each buffer
        SetIndexBuffer(0, this.upperLine, INDICATOR_DATA);
        SetIndexBuffer(1, this.lowerLine, INDICATOR_DATA);

        // set dont draw indicator if the value 0 to each buffer
        PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
        PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);

        // set label to each indicator drawed
        PlotIndexSetString(0, PLOT_LABEL, "UPPER LINE");
        PlotIndexSetString(0, PLOT_LABEL, "LOWER LINE");
        return(INIT_SUCCEEDED);
    }

    int AdaptiveSupertrend::OnCalculate(const int rates_total, const int prev_calculated,
    const datetime &time[], const double &open[], const double &high[],
    const double &low[], const double &close[]) {
        int copyAtr;
        int current = prev_calculated;
        for (;current < rates_total-2; current++) {
            if (current > rates_total*90/100) {
                // copy atr from current position to the previous 100
                copyAtr = CopyBuffer(this.handle, 0, rates_total - current, this.trainingPeriod, this.atrBuffer);
                if (copyAtr <= 0) {
                    printf("Failed to copy ATR Buffer. Error Code : %d", GetLastError());
                    return(current);
                }

                this.supertrend.setBar(current);
                // if set series failed, stop the whole script
                if (this.supertrend.setSeries(this.atrBuffer, open, close, high, low) <= 0) {
                    printf("Failed copy all series, script abort. ErrCode : %d", GetLastError());
                    ExpertRemove();
                }

                dynamic_cast<SuperTrend::Supertrend*>(this.supertrend).identifyngTrend();
                this.supertrend.getBuffer(this.upperLine, this.lowerLine);
                this.channel();
            }
        }

        copyAtr = CopyBuffer(this.handle, 0, rates_total - current, this.trainingPeriod, this.atrBuffer);
        if (copyAtr <= 0) {
            printf("Failed to copy ATR Buffer. Error Code : %d", GetLastError());
            // printf("current : %d", current);
            return(current);
        }

        this.supertrend.setBar(current);
        if (this.supertrend.setSeries(this.atrBuffer, open, close, high, low) <= 0) {
            printf("Failed copy all series, script abort. ErrCode : %d", GetLastError());
            ExpertRemove();
        }

        dynamic_cast<SuperTrend::Supertrend*>(this.supertrend).identifyngTrend();
        this.supertrend.getBuffer(this.upperLine, this.lowerLine);
        this.channel();
        return(rates_total-1);
    }

    void AdaptiveSupertrend::OnDeinit(const int reason) {
        if (reason >= 0 && reason <= 9 ) {
            bool handleRemove = IndicatorRelease(handle);
            ArrayFree(atrBuffer);
            ArrayFree(upperLine);
            ArrayFree(lowerLine);
            ArrayFree(midUpperLine);
            ArrayFree(midLowerLine);

            bool checkBuffer = (ArraySize(atrBuffer) == 0 && ArraySize(upperLine) == 0 &&
                                    ArraySize(lowerLine) == 0 && ArraySize(midUpperLine) == 0 &&
                                    ArraySize(midLowerLine) == 0) ? 1 : 0;
            if (handleRemove == 1 && checkBuffer == 1) {
                printf("Buffer succesfully clearing !!");
                ExpertRemove();
            } else {
                printf("We'll try again !");
                this.OnDeinit(reason);
            }
        }
    }

    void AdaptiveSupertrend::userInput(const int inAtrLen, const int inTrainingPeriod,
    const float inFactor, const float inHighVol, const float inMidVol, const float inLowVol) {
        this.trainingPeriod = inTrainingPeriod;
        this.atrLen = inAtrLen;
        this.factor = inFactor;
        this.highVol = inHighVol;
        this.midVol = inMidVol;
        this.lowVol = inLowVol;
    }

    void AdaptiveSupertrend::channel() {
        if (this.chan == 1) {
            SetIndexBuffer(2, midUpperLine, INDICATOR_DATA);
            SetIndexBuffer(3, midLowerLine, INDICATOR_DATA);
            PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
            PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
            PlotIndexSetString(2, PLOT_LABEL, "MID UPPER LINE");
            PlotIndexSetString(2, PLOT_LABEL, "MID LOWER LINE");
            this.supertrend.getChannel(midUpperLine, midLowerLine);
        }
    }
};
