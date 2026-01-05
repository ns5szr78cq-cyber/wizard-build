#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// إجابات إجبارية لأي سؤال من الحماية
static _Bool returnYes() { return YES; }
static id returnKey() { return @"WeekivEnZldeIn4pRd9YJ5nCbUOclX17"; }

__attribute__((constructor))
static void init() {
    // 1. منع الكراش فوراً
    Method exitM = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
    if (exitM) method_setImplementation(exitM, imp_implementationWithBlock(^{}));

    // 2. هجوم متكرر على الذاكرة لضمان صيد ملف الـ 80 ميجا (Core)
    for (float d = 1.0; d <= 7.0; d += 2.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(d * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            int numClasses = objc_getClassList(NULL, 0);
            if (numClasses > 0) {
                Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
                numClasses = objc_getClassList(classes, numClasses);
                for (int i = 0; i < numClasses; i++) {
                    NSString *cName = NSStringFromClass(classes[i]);
                    // استهداف كل كلاسات Wizard و Core
                    if ([cName containsString:@"Wizard"] || [cName containsString:@"Core"] || [cName containsString:@"Sentry"]) {
                        unsigned int mCount;
                        Method *methods = class_copyMethodList(classes[i], &mCount);
                        for (unsigned int j = 0; j < mCount; j++) {
                            SEL sel = method_getName(methods[j]);
                            NSString *mName = NSStringFromSelector(sel);
                            // كسر دوال التحقق بجميع أنواعها
                            if ([mName hasPrefix:@"is"] || [mName containsString:@"Valid"] || [mName containsString:@"Auth"]) {
                                class_replaceMethod(classes[i], sel, (IMP)returnYes, "B@:");
                            }
                            // حقن كود تفعيل افتراضي في حال طلبه
                            if ([mName containsString:@"Key"] || [mName containsString:@"Code"]) {
                                class_replaceMethod(classes[i], sel, (IMP)returnKey, "@@:");
                            }
                        }
                        free(methods);
                    }
                }
                free(classes);
            }
        });
    }

    // 3. رسالة DooN UP النهائية وإجبار المنيو على الظهور
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP" 
                                       message:@"تم التفعيل بنجاح ✅\nالمنيو جاهز الآن" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // محاولة إظهار أي واجهة مخفية تابعة للمنيو
            for (UIView *v in window.subviews) {
                v.hidden = NO; 
                v.alpha = 1.0;
                if ([NSStringFromClass([v class]) containsString:@"Wizard"]) [window bringSubviewToFront:v];
            }
            // إرسال إشارات برمجية لإظهار المنيو
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WizardShowMenu" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMenu" object:nil];
        }]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}