#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// الكود المستهدف الذي طلبته
#define MY_SPECIAL_KEY @"WeekivEnZldeIn4pRd9YJ5nCbUOclX17"

@implementation NSObject (WizardHook)

// 1. إعطاء إشارة نجاح (YES) لأي فحص منطقي
- (_Bool)hooked_success_bool { return YES; }

// 2. تزييف كود استجابة السيرفر (200 = OK)
- (NSInteger)hooked_http_200 { return 200; }

// 3. تزييف البيانات المستلمة لتبدو وكأنها ترخيص مفعل للأبد
- (NSData *)hooked_fake_data {
    NSDictionary *json = @{
        @"status": @"success",
        @"is_valid": @YES,
        @"license_key": MY_SPECIAL_KEY,
        @"expiry_date": @"2099-12-31",
        @"features": @[@"all_access", @"premium"]
    };
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

// 4. إجبار مقارنة النصوص على النجاح عند استخدام الكود الخاص بك
- (NSComparisonResult)hooked_string_compare:(NSString *)other {
    if ([other isEqualToString:MY_SPECIAL_KEY]) {
        return NSOrderedSame;
    }
    return NSOrderedSame; // لضمان أقصى درجات التخطي
}

@end

static void ShowDoonAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم إحياء الكود وتفعيل التخطي الشامل\nالكود: WeekivEn...\nالصلاحية: شهر واحد" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    // التحقق من تاريخ انتهاء "الملف" (صلاحية شهر)
    NSDateComponents *expiry = [[NSDateComponents alloc] init];
    [expiry setYear:2026]; [expiry setMonth:2]; [expiry setDay:5];
    NSDate *expiryDate = [[NSCalendar currentCalendar] dateFromComponents:expiry];
    
    if ([[NSDate date] compare:expiryDate] == NSOrderedDescending) {
        return; // توقف لو انتهى الشهر
    }

    // إظهار رسالتك المفضلة
    ShowDoonAlert();

    // تطبيق الـ Hooks على كل الثغرات المحتملة
    
    // أ- مقارنة النصوص
    method_exchangeImplementations(
        class_getInstanceMethod([NSString class], @selector(compare:)),
        class_getInstanceMethod([NSObject class], @selector(hooked_string_compare:))
    );

    // ب- كلاسات الشبكة (GCDWebServer)
    NSArray *webClasses = @[@"GCDWebServerConnection", @"GCDWebServerResponse"];
    for (NSString *className in webClasses) {
        Class c = NSClassFromString(className);
        if (c) {
            // تخطي التحقق
            SEL authSel = NSSelectorFromString(@"_checkAuthentication");
            if (class_getInstanceMethod(c, authSel)) {
                class_replaceMethod(c, authSel, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_success_bool))), "B@:");
            }
            // تزييف الحالة والبيانات
            SEL statusSel = NSSelectorFromString(@"statusCode");
            if (class_getInstanceMethod(c, statusSel)) {
                class_replaceMethod(c, statusSel, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_http_200))), "q@:");
            }
        }
    }
}