#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (DoonFix)
// 1. إجبار حالة التفعيل على "نعم"
- (_Bool)doon_true { return YES; }

// 2. إعطاء تاريخ انتهاء طويل جداً لمنع رسالة "انتهى الصلاحية" والكراش
- (NSString *)doon_date { return @"2030-01-01"; }

// 3. إعطاء رقم أيام كبير
- (int)doon_days { return 9999; }
@end

static void ShowDoonAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *root = window.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم تفعيل حماية البيانات\nالتاريخ محقن حتى 2030\nاكتب أي كود الآن" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    // إيقاف دالة "إغلاق التطبيق" الإجبارية من السيستم
    Method terminate = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
    if (terminate) method_setImplementation(terminate, imp_implementationWithBlock(^{ 
        NSLog(@"DooN UP: Blocking Exit..."); 
    }));

    // تنفيذ الحقن بعد ثانية واحدة لضمان ثبات اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *classes = @[@"LicenseManager", @"AuthService", @"AppConfig", @"GCDWebServerConnection"];
        
        for (NSString *cName in classes) {
            Class c = NSClassFromString(cName);
            if (c) {
                // تخطي الفحص المنطقي (هل الكود صح؟)
                SEL s1 = NSSelectorFromString(@"isActivated");
                SEL s2 = NSSelectorFromString(@"isValid");
                if (class_getInstanceMethod(c, s1)) class_replaceMethod(c, s1, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_true))), "B@:");
                if (class_getInstanceMethod(c, s2)) class_replaceMethod(c, s2, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_true))), "B@:");

                // حقن التاريخ (عشان يظهر جوه الهاك وما يكراشش)
                SEL sDate = NSSelectorFromString(@"getExpiryDate");
                if (class_getInstanceMethod(c, sDate)) class_replaceMethod(c, sDate, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_date))), "@@:");
            }
        }
        
        ShowDoonAlert();
    });
}