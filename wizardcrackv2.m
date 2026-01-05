#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (WizardHook)
// دالة لرد بـ "نعم"
- (_Bool)hooked_true { return YES; }
// دالة لرد برمز النجاح من السيرفر (200 تعني تم القبول)
- (NSInteger)hooked_status { return 200; }
@end

static void ShowAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم تفعيل التخطي الشامل وتزييف رد السيرفر\nاكتب أي كود وجرب الآن" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    ShowAlert();

    // 1. استهداف كلاسات الاتصال وتخطي التحقق الداخلي
    NSArray *classes = @[@"GCDWebServerConnection", @"GCDWebServer"];
    NSArray *methods = @[@"_checkAuthentication", @"isAuthorized", @"isAuthenticated", @"isValid"];
    
    for (NSString *className in classes) {
        Class c = NSClassFromString(className);
        if (c) {
            for (NSString *m in methods) {
                Method orig = class_getInstanceMethod(c, NSSelectorFromString(m));
                if (orig) {
                    method_setImplementation(orig, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_true))));
                }
            }
        }
    }

    // 2. تزييف رد السيرفر ليكون دائماً "ناجح" (Status 200)
    Class responseClass = NSClassFromString(@"GCDWebServerResponse");
    if (responseClass) {
        Method origStatus = class_getInstanceMethod(responseClass, NSSelectorFromString(@"statusCode"));
        if (origStatus) {
            method_setImplementation(origStatus, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_status))));
        }
    }
}