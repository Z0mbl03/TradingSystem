#include "Cluster.mqh";
#include "../TwoLineIndicator.mqh";
#include "../../Lib/ArrayProcessor.mqh";

namespace SuperTrend {
    class Supertrend : public TwoLineIndicator {
        // constant value
        const int SERIES_SIZE;

        // User define type
        Cluster cluster;

        float factor;
        int direction;
        double Open[];
        double Close[];
        double High[];
        double Low[];
        double upperLine[2];
        double lowerLine[2];
        int current; // this refer to the current bar, the current bar should be the last closed bar not on going bar
        double src;
        double midUpperLine;
        double midLowerLine;

        void clasificationTrend();
        void checkDirection();
        void thresholdBandCheck();

    public:
        Supertrend(int dataPeriod, float high, float mid, float low, float inFactor);
        void setBar(int bar);
        int setSeries(const double &inVolatility[], const double &open[], const double &close[], const double &high[], const double &low[], int c=0);
        void identifyngTrend();
        void getBuffer(double &inUpperLine[], double &inLowerLine[]);
        void getChannel(double &inMidUpperLine[], double &inMidLowerLine[]);
        int getDir();
    };


    Supertrend::Supertrend(int dataPeriod, float high, float mid, float low, float inFactor) : cluster(dataPeriod, high, mid, low), SERIES_SIZE(5), factor(inFactor){
        ArrayResize(this.Open, this.SERIES_SIZE);
        ArrayResize(this.Close, this.SERIES_SIZE);
        ArrayResize(this.High, this.SERIES_SIZE);
        ArrayResize(this.Low, this.SERIES_SIZE);

        ArrayInitialize(this.Open, 0);
        ArrayInitialize(this.Close, 0);
        ArrayInitialize(this.High, 0);
        ArrayInitialize(this.Low, 0);

        ArrayInitialize(this.upperLine, 0);
        ArrayInitialize(this.lowerLine, 0);
    }

    void Supertrend::clasificationTrend() {
        ArrayProcessor::insertBegin(this.upperLine, this.upperLine[0], 2);
        ArrayProcessor::insertBegin(this.lowerLine, this.lowerLine[0], 2);

        if (this.direction == 1) {
            this.midUpperLine = 0;
            this.midUpperLine = this.src;
            this.upperLine[0] = 0;
        }else if (direction == -1) {
            this.midLowerLine = 0;
            this.midUpperLine = this.src;
            this.lowerLine[0] = 0;
        }
    }

    void Supertrend::checkDirection() {
        if (this.Close[this.SERIES_SIZE-1] > this.upperLine[1]) {
            this.direction = 1;
        } else if (this.Close[this.SERIES_SIZE-1] < this.lowerLine[0]) {
            this.direction = -1;
        }
    }

    void Supertrend::thresholdBandCheck() {
        double Max = this.High[this.SERIES_SIZE-1] + ((this.High[this.SERIES_SIZE-1]*25)/100);
        double Min = this.Low[this.SERIES_SIZE-1] - ((this.Low[this.SERIES_SIZE-1]*25)/100);

        if (this.upperLine[0] > this.upperLine[1]) {
            if (this.Close[this.SERIES_SIZE-2] < this.upperLine[1]) {
                if (Max > this.upperLine[0] && Min < this.upperLine[0]) {
                    this.upperLine[0] = this.upperLine[1];
                }
            }
        }

         if (this.lowerLine[0] < this.lowerLine[1]) {
            if (this.Close[this.SERIES_SIZE-2] > this.lowerLine[1]) {
                if (Max > this.lowerLine[0] && Min < this.upperLine[0]) {
                    this.lowerLine[0] = this.lowerLine[1];
                }
            }
        }
    }

    void Supertrend::setBar(int bar) {
        this.current = bar;
    }

    int Supertrend::setSeries(const double& inVolatility[],
                                const double& open[], const double& close[],
                                const double& high[], const double& low[], int c) {

        // call the cluster method to set volatility in cluster class
        this.cluster.setVolatility(inVolatility);

        // copying all the necessary
        int startCopy = (this.current - this.SERIES_SIZE)-1;
        int copyOpen = ArrayCopy(this.Open, open, 0, startCopy, this.SERIES_SIZE);
        int copyClose = ArrayCopy(this.Close, close, 0, startCopy, this.SERIES_SIZE);
        int copyHigh = ArrayCopy(this.High, high, 0, startCopy, this.SERIES_SIZE);
        int copyLow = ArrayCopy(this.Low, low, 0, startCopy, this.SERIES_SIZE);
        int amountCopy = copyOpen*copyClose*copyHigh*copyLow;

        if ((amountCopy) <= 0) {
            printf("Failed to copy series !!");
            printf("Wait for a second");
            Sleep(500);
            if (c > 5) {
                printf("Failed to copy. ErrCode : %d", GetLastError());
                printf("Exited !!.");
                return(0);
            } else {
                setSeries(inVolatility, open, close, high, low, c+1);
            }
        } else {
            printf("Succesfully copy series. %d copied", amountCopy);
        }
        return(amountCopy);
    }

    void Supertrend::identifyngTrend() {
        this.cluster.clustering();
        double atr = this.cluster.getAtr();
        this.src = (this.High[this.SERIES_SIZE-1] + this.Low[this.SERIES_SIZE-1])/2;
        this.upperLine[0] = this.src + (this.factor*atr);
        this.lowerLine[0] = this.src - (this.factor*atr);
        this.thresholdBandCheck();
        this.checkDirection();
        this.clasificationTrend();
    }

    void Supertrend::getBuffer(double &inUpperLine[], double &inLowerLine[]) {
        inUpperLine[this.current-1] = this.upperLine[0];
        inLowerLine[this.current-1] = this.lowerLine[0];
    }

    void Supertrend::getChannel(double &inMidUpperLine[], double &inMidLowerLine[]) {
        inMidUpperLine[this.current-1] = midUpperLine;
        inMidLowerLine[this.current-1] = midLowerLine;
    }

    int Supertrend::getDir() {
        return(this.direction);
    }
};
