class TwoLineIndicator {
public:
    virtual void getBuffer(double &inUpperLine[], double &inLowerLine[]) = 0;
    virtual void getChannel(double &inMidUpperLine[], double &inMidLowerLine[]) = 0;
    virtual int setSeries(const double &inVolatility[], const double &open[], const double &close[], const double &high[], const double &low[], int c=0) = 0;
    virtual void setBar(int bar) = 0;
    virtual int getDir() = 0;
}
