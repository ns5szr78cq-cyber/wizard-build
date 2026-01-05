#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (WizardHook)

// 1. إعطاء إشارة "نعم" لأي فحص داخلي
- (_Bool)hooked_true { return YES; }

// 2. تزييف كود استجابة السيرفر ليكون 200 (تم بنجاح)
- (NSInteger)hooked_status { return 200; }

// 3. تزييف محتوى البيانات لتبدو كأنها رد نجاح من سيرفر حقيقي
- (NSData *)hooked_data {
    NSDictionary *dict = @{
        @"status": @"success",
        @"code": @200,
        @"valid": @YES,
        @"message": @"Authorized",
        @"expire_date": @"2099-01-01"
    };
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

@end

static void ShowAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                           message:@"تم تفعيل التخطّي العميق للبيانات\nاكتب أي كود عشوائي وجرب الآن" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor))
static void init() {
    // إظهار رسالتك المفضلة
    ShowAlert();

    // استهداف المكتبة المسؤولة عن الاتصال
    Class connClass = NSClassFromString(@"GCDWebServerConnection");
    Class respClass = NSClassFromString(@"GCDWebServerResponse");

    if (connClass) {
        // تخطي الحماية الأساسية
        NSArray *authMethods = @[@"_checkAuthentication", @"isAuthorized", @"isAuthenticated"];
        for (NSString *mName in authMethods) {
            Method orig = class_getInstanceMethod(connClass, NSSelectorFromString(mName));
            if (orig) {
                method_setImplementation(orig, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_true))));
            }
        }
    }

    if (respClass) {
        // إجبار السيرفر على إرسال حالة "نجاح"
        Method status = class_getInstanceMethod(respClass, NSSelectorFromString(@"statusCode"));
        if (status) {
            method_setImplementation(status, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_status))));
        }

        // حقن بيانات النجاح الوهمية (تاريخ انتهاء بعيد جداً)
        Method data = class_getInstanceMethod(respClass, NSSelectorFromString(@"data"));
        if (data) {
            method_setImplementation(data, method_getImplementation(class_getInstanceMethod([NSObject class], @selector(hooked_data))));
        }
    }
}