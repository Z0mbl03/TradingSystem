class TwoLineIndicator {
public:
    virtual void getBuffer(double &inUpperLine[], double &inLowerLine[]) = 0;
    virtual void getChannel(double &inMidUpperLine[], double &inMidLowerLine[]) = 0;
    virtual void setSeries(double &inVolatility[], double &open[], double &close[], double &high[], double &low[], int c=0) = 0;
    virtual void setBar(int bar) = 0;
    virtual int getDir() = 0;
}
