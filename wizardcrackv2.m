#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// الكود الخاص بك
#define MY_KEY @"WeekivEnZldeIn4pRd9YJ5nCbUOclX17"

@implementation NSObject (WizardHook)
- (NSInteger)hooked_statusCode { return 200; }
- (NSData *)hooked_data {
    NSDictionary *dict = @{@"status":@"success", @"valid":@YES, @"license":MY_KEY, @"expiry":@"2099-01-01"};
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}
- (_Bool)hooked_bool { return YES; }
@end

static void ShowDoonAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم إصلاح الكراش بنجاح\nاستخدم كودك الآن" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    ShowDoonAlert();
    Class respClass = NSClassFromString(@"GCDWebServerResponse");
    if (respClass) {
        method_setImplementation(class_getInstanceMethod(respClass, @selector(statusCode)), method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_statusCode))));
        method_setImplementation(class_getInstanceMethod(respClass, @selector(data)), method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_data))));
    }
    NSArray *classes = @[@"GCDWebServerConnection", @"LicenseManager", @"AuthService"];
    for (NSString *name in classes) {
        Class c = NSClassFromString(name);
        if (c) {
            SEL selectors[] = {@selector(_checkAuthentication), NSSelectorFromString(@"isAuthorized"), NSSelectorFromString(@"isValid")};
            for (int i = 0; i < 3; i++) {
                Method m = class_getInstanceMethod(c, selectors[i]);
                if (m) method_setImplementation(m, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_bool))));
            }
        }
    }
}