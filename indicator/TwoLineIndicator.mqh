class TwoLineIndicator {
public:
    virtual void getBuffer(double &inUpperLine[], double &inLowerLine[]);
    virtual void getChannel(double &inMidUpperLine[], double &inMidLowerLine[]);
    virtual void setSeries(int c=0, double &inVolatility[], double &open[], double &close[], double &high[], double &low[]);
}
