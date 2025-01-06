class TwoLineIndicator {
public:
    virtual void getBuffer(double &inUpperLine[], double &inLowerLine[]) = 0;
    virtual void getChannel(double &inMidUpperLine[], double &inMidLowerLine[]) = 0;
    virtual void setSeries(int c=0, double &inVolatility[], double &open[], double &close[], double &high[], double &low[]) = 0;
    virtual void setBar(int bar) = 0;
    virtual int getDir() = 0;
}
