#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (WizardHook)
- (_Bool)hooked_checkAuthentication { return YES; }
- (_Bool)hooked_isAuthorized { return YES; }
@end

static void ShowAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wizard Hook" 
                                                                       message:@"تم تفعيل التخطّي بنجاح! جرب الدخول الآن" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"تم" style:UIAlertActionStyleDefault handler:nil]];
        [root presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor))
static void init() {
    // إظهار الرسالة داخل اللعبة بعد 3 ثواني
    ShowAlert();

    // تخطي الحماية
    NSArray *classes = @[@"GCDWebServerConnection", @"GCDWebServer"];
    for (NSString *className in classes) {
        Class c = NSClassFromString(className);
        if (c) {
            Method orig = class_getInstanceMethod(c, NSSelectorFromString(@"_checkAuthentication"));
            if (orig) {
                Method hook = class_getInstanceMethod([NSObject class], @selector(hooked_checkAuthentication));
                method_setImplementation(orig, method_getImplementation(hook));
            }
        }
    }
}