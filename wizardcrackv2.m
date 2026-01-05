#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// كودك الخاص للاحتياط
#define MASTER_KEY @"WeekivEnZldeIn4pRd9YJ5nCbUOclX17"

@implementation NSObject (WizardFinalTouch)

// 1. ردود النجاح الشاملة
- (_Bool)doon_true { return YES; }
- (NSInteger)doon_200 { return 200; }
- (NSString *)doon_date { return @"2030-01-01"; }

// 2. رد بيانات JSON كاملة لإرضاء محرك اللعبة ومنع الكراش
- (NSData *)doon_json {
    NSDictionary *info = @{
        @"status": @"success",
        @"valid": @YES,
        @"license": MASTER_KEY,
        @"expiry": @"2030-01-01"
    };
    return [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
}
@end

// دالة منع الخروج القسري (Anti-Exit)
void disableAutoTerminate() {
    Method terminate = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
    if (terminate) {
        method_setImplementation(terminate, imp_implementationWithBlock(^{ 
            NSLog(@"DooN UP: Blocking Exit Attempt..."); 
        }));
    }
}

__attribute__((constructor))
static void init() {
    // إيقاف أي أمر إغلاق فوراً
    disableAutoTerminate();

    // تشغيل الحقن بعد 0.5 ثانية فقط لضمان استقرار الواجهة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // أ- محاكاة استجابة السيرفر (الحل الجذري للكراش عند كتابة الكود)
        Class respClass = NSClassFromString(@"GCDWebServerResponse");
        if (respClass) {
            class_replaceMethod(respClass, @selector(statusCode), method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_200))), "q@:");
            class_replaceMethod(respClass, @selector(data), method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_json))), "@@:");
        }

        // ب- تخطي كلاسات الحماية المعروفة وتثبيت التاريخ
        NSArray *classes = @[@"LicenseManager", @"AuthService", @"AppConfig", @"GCDWebServerConnection"];
        for (NSString *name in classes) {
            Class c = NSClassFromString(name);
            if (c) {
                // تفعيل الصلاحية
                SEL s1 = NSSelectorFromString(@"isActivated");
                if (class_getInstanceMethod(c, s1)) class_replaceMethod(c, s1, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_true))), "B@:");
                
                // تزييف تاريخ الانتهاء ليظهر 2030
                SEL s2 = NSSelectorFromString(@"getExpiryDate");
                if (class_getInstanceMethod(c, s2)) class_replaceMethod(c, s2, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(doon_date))), "@@:");
            }
        }

        // ج- إظهار رسالة DooN UP ✅
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم دمج نظام التخطي بنجاح\nالصلاحية محقنة حتى 2030" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}