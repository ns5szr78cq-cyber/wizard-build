#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (WizardHook)
// دالة موحدة لترد بـ "نعم" على أي طلب تحقق من الهوية أو الكود
- (_Bool)hooked_universal_true { return YES; }
@end

static void ShowAlert() {
    // إظهار الرسالة بعد 3 ثواني من فتح اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم تفعيل التخطي بنجاح\nاكتب أي كود وسيتم الدخول" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    ShowAlert();
    
    // قائمة الوظائف البرمجية المسؤولة عن التحقق في أغلب أنواع الحماية
    NSArray *methodsToHook = @[
        @"_checkAuthentication",
        @"isAuthorized",
        @"isAuthenticated",
        @"checkPassword:",
        @"isValid",
        @"isActivated"
    ];

    // استهداف مكتبة التوصيل الخاصة باللعبة
    Class c = NSClassFromString(@"GCDWebServerConnection");
    if (c) {
        for (NSString *methodName in methodsToHook) {
            Method orig = class_getInstanceMethod(c, NSSelectorFromString(methodName));
            Method hook = class_getInstanceMethod([NSObject class], @selector(hooked_universal_true));
            if (orig && hook) {
                method_setImplementation(orig, method_getImplementation(hook));
            }
        }
    }
}