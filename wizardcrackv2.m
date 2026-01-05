#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// كود الدخول الخاص بك
#define TARGET_KEY @"WeekivEnZldeIn4pRd9YJ5nCbUOclX17"

@implementation NSObject (WizardHook)
- (_Bool)hooked_validation { return YES; }

// دالة فحص النصوص بشكل آمن (لا تسبب كراش)
- (BOOL)hooked_isEqualToString:(NSString *)str {
    if ([str isEqualToString:TARGET_KEY]) {
        return YES;
    }
    return [self hooked_isEqualToString:str]; // العودة للأصل لو لم يكن هو الكود
}
@end

static void ShowAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم دمج كود الدخول بنجاح\nاكتب الكود الآن وسيفتح معك" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    ShowAlert();

    // 1. هوك لمقارنة النصوص (إجبار اللعبة على قبول كودك)
    Method origString = class_getInstanceMethod([NSString class], @selector(isEqualToString:));
    Method hookString = class_getInstanceMethod([NSObject class], @selector(hooked_isEqualToString:));
    method_exchangeImplementations(origString, hookString);

    // 2. هوك لكلاسات الحماية (قبول الدخول)
    NSArray *classes = @[@"GCDWebServerConnection", @"LicenseManager", @"AuthService"];
    for (NSString *className in classes) {
        Class c = NSClassFromString(className);
        if (c) {
            NSArray *methods = @[@"_checkAuthentication", @"isAuthorized", @"isValid"];
            for (NSString *methodName in methods) {
                Method m = class_getInstanceMethod(c, NSSelectorFromString(methodName));
                if (m) method_setImplementation(m, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_validation))));
            }
        }
    }
}