#import <Foundation/Foundation.h>

@interface KeyboardBrightnessClient : NSObject
- (float)brightnessForKeyboard:(unsigned long long)arg1;
- (BOOL)setBrightness:(float)arg1 forKeyboard:(unsigned long long)arg2;
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        KeyboardBrightnessClient *client = [[KeyboardBrightnessClient alloc] init];
        if (!client) { fprintf(stderr, "no keyboard backlight device\n"); return 1; }

        if (argc == 1) {
            printf("%.4f\n", [client brightnessForKeyboard:1]);
        } else {
            float val = atof(argv[1]);
            if (val < 0.0) val = 0.0;
            if (val > 1.0) val = 1.0;
            [client setBrightness:val forKeyboard:1];
            printf("%.4f\n", val);
        }
    }
    return 0;
}
