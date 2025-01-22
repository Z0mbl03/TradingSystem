#include <Math/Stat/Normal.mqh>
#include "../../Lib/ArrayProcessor.mqh"

namespace SuperTrend {
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

        // Data clasification based on high, medium and low volatility
        void dataClasification(double &A[], double &B[], double &C[]) {
            double hv[];
            double mv[];
            double lv[];

            ArrayResize(hv, 1);
            ArrayResize(mv, 1);
            ArrayResize(lv, 1);

            ArrayInitialize(hv, 0);
            ArrayInitialize(mv, 0);
            ArrayInitialize(lv, 0);

            for (int index = this.period-1; index >= 0; index--) {
                if (ArrayProcessor::checkData(this.volatility[index])) {
                    printf("Bad data\nSkip to calculated");
                    continue;
                }

                double a = MathAbs(this.volatility[index] - A[0]);
                double b = MathAbs(this.volatility[index] - B[0]);
                double c = MathAbs(this.volatility[index] - C[0]);
                if (a < b && a < c) {
                    ArrayProcessor::insertBegin(hv, this.volatility[index]);
                }

                if (b < a && b < c) {
                    ArrayProcessor::insertBegin(mv, this.volatility[index]);
                }

                if (c < a && c < b) {
                    ArrayProcessor::insertBegin(lv, this.volatility[index]);
                }
            }

            ArrayProcessor::insertBegin(A, MathMean(hv), ArraySize(A));
            ArrayProcessor::insertBegin(B, MathMean(mv), ArraySize(B));
            ArrayProcessor::insertBegin(C, MathMean(lv), ArraySize(C));
        }


    public:
        Cluster(int inPeriod, float inHigh, float inMid, float inLow) {
            this.high_volatile = inHigh;
            this.mid_volatile = inMid;
            this.low_volatile = inLow;
            this.period = inPeriod;
            this.atr = 0;
            ArrayResize(this.volatility, this.period);

            ArrayInitialize(this.volatility, 0);
            ArrayInitialize(this.prevABC, 0);
        }

        int setVolatility(const double &inVolatile[], int count=0) {
            int copy = ArrayCopy(this.volatility, inVolatile);
            if(copy <= 0) {
                printf("Failed to copy volatility. ErrCode : %d", GetLastError());
                Sleep(500);
                printf("Try to do it again");
                if(count > 5) {
                    printf("Still failed, even if 5 time tries. ErrCode : %d", GetLastError());
                    return(0);
                }
                this.setVolatility(inVolatile, count+1);
            }
            return(copy);
        }

        double getAtr() {
            return(atr);
        }

        void clustering() {
            double distances[3];
            double centroids[3];

            this.upper = ArrayProcessor::max(volatility);
            this.lower = ArrayProcessor::min(volatility);

            double high = this.lower + (this.upper - this.lower) * (double)this.high_volatile;
            double med = this.lower + (this.upper - this.lower) * (double)this.mid_volatile;
            double low = this.lower + (this.upper - this.lower) * (double)this.low_volatile;

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

            distances[0] = MathAbs(volatility[this.period-1] - A[0]);
            distances[1] = MathAbs(volatility[this.period-1] - B[0]);
            distances[2] = MathAbs(volatility[this.period-1] - C[0]);

            centroids[0] = A[0];
            centroids[1] = B[0];
            centroids[2] = C[0];

            int cluster = ArrayMinimum(distances);
            atr = centroids[cluster];
        }
    };
};
