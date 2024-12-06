#include <Math/Stat/Normal.mqh>
#include "../../Lib/ArrayProcessor.mqh"


class Cluster {
private:
    float high_volatile;
    float mid_volatile;
    float low_volatile;

    int period;

    double atr;
    double upper;
    double lower;
    double volatility[];
    double prevABC[3];


    void dataClasification(double &A[], double &B[], double &C[]) {
        double hv[];
        double mv[];
        double lv[];

        for (int index = 0; index < this.period; index++) {
            if (ArrayProcessor::checkData(this.volatility[index])) {
                printf("Bad data\nSkip to calculated");
                continue;
            }

            double a = MathAbs(volatility[index] - A[0]);
            double b = MathAbs(volatility[index] - B[0]);
            double c = MathAbs(volatility[index] - C[0]);
            if (a < b && a < c) {
                ArrayProcessor::insertBegin(hv, volatility[index]);
            }

            if (b < a && b < c) {
                ArrayProcessor::insertBegin(mv, volatility[index]);
            }

            if (c < a && c < b) {
                ArrayProcessor::insertBegin(lv, volatility[index]);
            }
        }

        ArrayProcessor::insertBegin(A, MathMean(hv), sizeof(A));
        ArrayProcessor::insertBegin(B, MathMean(mv), sizeof(B));
        ArrayProcessor::insertBegin(C, MathMean(lv), sizeof(C));
    }


public:
    Cluster(int dataPeriod, double high, double mid, double low) {
        this.high_volatile = high;
        this.mid_volatile = mid;
        this.low_volatile = low;
        this.period = dataPeriod;
        ArrayResize(this.volatility, this.period);
        ArrayInitialize(this.prevABC, 0);
    }

    void setVolatility(double &inVolatile[], int currentBar) {
        int inStart = currentBar - this.period;
        if (ArrayCopy(this.volatility, inVolatile, 0, inStart, this.period) <= 0) {
            this.setVolatility(inVolatile, currentBar);
        }
    }

    double getAtr() {
        return(atr);
    }

    void clustering() {
        double distances[3];
        double centroids[3];

        this.upper = ArrayProcessor::max(volatility);
        this.lower = ArrayProcessor::min(volatility);

        double high = this.lower + (this.upper - this.lower) * this.high_volatile;
        double med = this.lower + (this.upper - this.lower) * this.mid_volatile;
        double low = this.lower + (this.upper - this.lower) * this.low_volatile;

        double A[2] = {high, 0};
        double B[2] = {med, 0};
        double C[2] = {low, 0};

        while (A[0] != A[1] || B[0] != B[1] || C[0] != C[1]) {
            if (ArrayProcessor::checkData(A[0]) &&
                    ArrayProcessor::checkData(B[0]) &&
                    ArrayProcessor::checkData(C[0])) {

                A[0] = this.prevABC[0];
                B[0] = this.prevABC[1];
                C[0] = this.prevABC[2];
                printf("Bad data.\nSkip to calculated ...");
                break;
            }

            this.dataClasification(A, B, C);
            this.prevABC[0] = A[0];
            this.prevABC[1] = B[0];
            this.prevABC[2] = C[0];
        }

        distances[0] = MathAbs(volatility[this.period] - B[0]);
        distances[1] = MathAbs(volatility[this.period] - A[0]);
        distances[2] = MathAbs(volatility[this.period] - C[0]);

        centroids[0] = A[0];
        centroids[1] = B[0];
        centroids[2] = C[0];

        int cluster = ArrayMinimum(distances);
        atr = centroids[cluster];
    }
};
