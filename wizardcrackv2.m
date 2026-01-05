#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// كود الدخول الخاص بك
#define MY_DOON_KEY @"WeekivEnZldeIn4pRd9YJ5nCbUOclX17"

@implementation NSObject (DoonGuard)
- (_Bool)doon_true { return YES; }
- (NSInteger)doon_200 { return 200; }
- (NSData *)doon_data {
    NSDictionary *dict = @{@"status":@"success", @"valid":@YES, @"license":MY_DOON_KEY};
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}
@end

// إظهار رسالة DooN UP ✅
static void ShowDoonAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *root = window.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم إيقاف مؤقت الإغلاق\nتعديل الكود نشط الآن" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    // 1. التنفيذ الفوري (خلال 0.5 ثانية) لسباق عداد الإغلاق
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // أ- تعطيل أي أمر "خروج" (Exit) ترسل اللعبة لنفسها
        Method exitMethod = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
        if (exitMethod) {
            method_setImplementation(exitMethod, imp_implementationWithBlock(^{ 
                NSLog(@"DooN UP: Blocking Auto-Exit..."); 
            }));
        }

        // ب- تزييف بيانات السيرفر (رد النجاح)
        Class respClass = NSClassFromString(@"GCDWebServerResponse");
        if (respClass) {
            method_setImplementation(class_getInstanceMethod(respClass, @selector(statusCode)), method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_200))));
            method_setImplementation(class_getInstanceMethod(respClass, @selector(data)), method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_data))));
        }

        // ج- تفعيل كلاسات الحماية
        NSArray *classes = @[@"LicenseManager", @"GCDWebServerConnection", @"AuthService"];
        for (NSString *cName in classes) {
            Class c = NSClassFromString(cName);
            if (c) {
                SEL s1 = NSSelectorFromString(@"isActivated");
                SEL s2 = NSSelectorFromString(@"_checkAuthentication");
                if (class_getInstanceMethod(c, s1)) class_replaceMethod(c, s1, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_true))), "B@:");
                if (class_getInstanceMethod(c, s2)) class_replaceMethod(c, s2, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_true))), "B@:");
            }
        }
        
        ShowDoonAlert();
    });
}