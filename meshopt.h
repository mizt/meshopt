#import <CoreFoundation/CoreFoundation.h>
#import <vector>

extern "C" {
    void meshopt(std::vector<float> *v, std::vector<int> *f, NSString *params);
}
    