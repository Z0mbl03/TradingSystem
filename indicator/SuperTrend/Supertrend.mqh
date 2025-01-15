#include "Cluster.mqh"
#include "../TwoLineIndicator.mqh"
#include "../../Lib/ArrayProcessor.mqh"

namespace SuperTrend {
    enum Band {
        UPPER,
        LOWER
    };

    class Supertrend : public TwoLineIndicator {
        // constant value
        const int SERIES_SIZE;

        // User define type
        Band band;
        Cluster cluster;

        float factor;
        int direction[2];
        double Open[];
        double Close[];
        double High[];
        double Low[];
        double supertrend[2][2];
        int current; // this refer to the current bar, the current bar should be the last closed bar not on going bar
        double src;
        double midUpperLine;
        double midLowerLine;

        void clasificationTrend();
        void checkDirection();
        void thresholdBandCheck();

    public:
        // initialized parameter constructor
        Supertrend(int dataPeriod, float high, float mid, float low);

        void setBar(int bar);
        int setSeries(int c=0, const double &inVolatility[], const double &open[], const double &close[], const double &high[], const double &low[]);
        void identifyngTrend();
        int getDir();
        void getBuffer(double &inUpperLine[], double &inLowerLine[]);
        void getChannel(double &inMidUpperLine[], double &inMidLowerLine[]);
    };


    Supertrend::Supertrend(int dataPeriod, float high, float mid, float low) : cluster(datePeriod, high, mid, low), SERIES_SIZE(10){
        ArrayResize(this.Open, this.SERIES_SIZE);
        ArrayResize(this.Close, this.SERIES_SIZE);
        ArrayResize(this.High, this.SERIES_SIZE);
        ArrayResize(this.Low, this.SERIES_SIZE);

        ArrayInitialize(this.supertrend, 0);
        ArrayInitialize(this.direction, 0);
        ArrayInitialize(this.Open, 0);
        ArrayInitialize(this.Close, 0);
        ArrayInitialize(this.High, 0);
        ArrayInitialize(this.Low, 0);

    }

    void Supertrend::clasificationTrend() {
        if (this.direction > -1 && this.direction < 1) {
            if (this.direction == 1) {
                this.midUpperLine = 0;
                this.midUpperline = this.src;
                this.supertrend[UPPER] = 0;
            }else if (direction == -1) {
                this.midLowerLine = 0;
                this.midUpperLine = this.src;
                this.supertrend[LOWER] = 0;
            }
        }
    }

    void Supertrend::checkDirection() {
        if (this.Close[this.SERIES_SIZE-1] > this.supertrend[UPPER][1]) {
            ArrayProcessor::insertBegin(this.direction, 1, 2);
        } else if (this.Close[this.SERIES_SIZE-1] < this.supertrend[LOWER][0]) {
            ArrayProcessor::insertBegin(this.direction, -1, 2);
        }
    }

    void Supertrend::thresholdBandCheck() {
        double Max = this.High[this.SERIES_SIZE-1] + ((this.High[this.SERIES_SIZE-1]*95)/100);
        double Min = this.Low[this.SERIES_SIZE-1] - ((this.Low[this.SERIES_SIZE-1]*95)/100);

        if (this.supertrend[UPPER][0] > this.supertrend[UPPER][1]) {
            if (this.Close[0] < this.supertrend[UPPER][0]) {
                if (Max > this.supertrend[UPPER][0]) {
                    this.supertrend[UPPER][0] = this.supertrend[UPPER][1];
                }
            }
        } else if (this.supertrend[LOWER][0] < this.supertrend[LOWER][1]) {
            if (this.Close > this.supertrend[LOWER][0]) {
                if (Min > this.supertrend[LOWER][0]) {
                    this.supertrend[LOWER][0] = this.supertrend[LOWER][1]
                }
            }
        }
    }

    void Supertrend::setBar(int bar) {
        this.current = bar;
    }

    int Supertrend::setSeries(int c, const double& inVolatility[],
                                const double& open[], const double& close[],
                                const double& high[], const double& low[]) {

        // call the cluster method to set volatility in cluster class
        cluster.setVolatility(inVolatility, this.current);

        // copying all the necessary
        int startCopy = this.current - this.SERIES_SIZE;
        int copyOpen = ArrayCopy(this.Open, open, startCopy, 0, count=this.SERIES_SIZE)
        int copyClose = ArrayCopy(this.Close, close, startCopy, 0, count=this.SERIES_SIZE)
        int copyHigh = ArrayCopy(this.High, high, startCopy, 0, count=this.SERIES_SIZE)
        int copyLow = ArrayCopy(this.Low, low, startCopy, 0, count=this.SERIES_SIZE)

        if ((copyOpen*copyClose*copyHigh*copyLow) <= 0) {
            printf("Failed to copy series !!");
            printf("Wait for a second")
            sleep(500);
            if (c > 5) {
                printf("Failed to copy. ErrCode : %d", GetLastError());
                printf("Exited !!.");
                return(0);
            } else {
                setSeires(c+1, inVolatility, open, close, high, low);
            }
        } else {
            int amountCopy = copyOpen+copyClose+copyHigh+copyLow;
            printf("Succesfully copy series. %d copied", amountCopy);
        }
    }

    void Supertrend::identifyngTrend() {
        double atr = cluster.clustering();
        this.src = (this.High[this.SERIES_SIZE-1] + this.Low[this.SERIES_SIZE-1])/2;
        ArrayProcessor::insertBegin(this.supertrend[UPPER], src + (this.factor*atr), 2);
        ArrayProcessor::insertBegin(this.supertrend[UPPER], src - (this.factor*atr), 2);
        this.thresholdBandCheck();
        this.checkDirection();
        this.clasificationTrend();
    }

    void Supertrend::getbuffer(double &inUpperLine[], double &inLowerLine[]) {
        inUpperLine[this.current] = this.supertrend[UPPER][0];
        inLowerLine[this.current] = this.supertrend[LOWER][0];
    }

    void Supertrend::getChannel(double &inMidUpperLine[], double &inMidLowerLine[]) {
        inMidUpperLine[this.current] = midUpperLine;
        inMidLowerLine[this.current] = midLowerLine;
    }

    int Supertrend::getDir() {
        return(this.direction);
    }
};
