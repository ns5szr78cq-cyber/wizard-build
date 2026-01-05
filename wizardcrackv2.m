#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (WizardHook)
- (_Bool)hooked_auth { return YES; }
@end

static void ShowAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wizard Status" 
                                           message:@"تم تفعيل التخطي بنجاح ✅" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    ShowAlert();
    Class c = NSClassFromString(@"GCDWebServerConnection");
    if (c) {
        Method orig = class_getInstanceMethod(c, NSSelectorFromString(@"_checkAuthentication"));
        Method hook = class_getInstanceMethod([NSObject class], @selector(hooked_auth));
        if (orig && hook) {
            method_setImplementation(orig, method_getImplementation(hook));
        }
    }
}