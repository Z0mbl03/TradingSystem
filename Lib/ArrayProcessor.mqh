
class ArrayProcessor {
public :
    // 3 overload for insertBegin
    // this used for dynamic array
    static void insertBegin(double &src[], double val) {
        int size = ArraySize(src)+1;
        ArrayResize(src, size);
        for (int i = size-1; i > 0; i--) {
            src[i] = src[i-1];
        }
        src[0] = val;
    }

    // this used for fixed array
    static void insertBegin(double &src[], double val, int size) {
        int i = size-1;
        for (; i > 0; i--) {
            src[i] = src[i-1];
        }
        src[0] = val;
    }

    // used for integer array
    static void insertBegin(int &src[], int val, int size) {
        int i = size-1;
        for (; i > 0; i--) {
            src[i] = src[i-1];
        }
        src[0] = val;
    }

    // find maximum value of an array
    static double max(const double &src[], int start=0, int count=0) {
        double max = src[start];
        count == 0 ? count = ArraySize(src) : NULL;
        if (start == 0) {
            for (; start < count; start++) {
                src[start] > max ? max = src[start] : NULL;
            }
        } else {
            int i = start;
            for (; i > start-count; i--) {
                src[i] > max ? max = src[i] : NULL;
            }
        }
        return(max);
    }

    // fin minimum value of an array
    static double min(const double &src[], int start=0, int count=0) {
        double min = src[start];
        count == 0 ? count = ArraySize(src) : NULL;

        if (start == 0) {
            for (; start < count; start++) {
                src[start] < min ? min = src[start] : NULL;
            }
        } else {
            int i = start;
            for (; i < start-count; i--) {
                src[i] > min ? min = src[i] : NULL;
            }
        }
        return(min);
    }

    // check data quality
    static bool checkData(const double val) {
        if (!MathIsValidNumber(val)) {
            return(true); // true stop calculated and wait for new data
        }
        return(false); // false continue calculated data
    }
};
