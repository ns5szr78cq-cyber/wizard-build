#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (WizardUltimateBypass)
// دوال ثابتة لضمان التفعيل التلقائي
- (_Bool)isWizardActive { return YES; }
- (NSString *)wizardExpiryDate { return @"2030-01-01"; }
@end

__attribute__((constructor))
static void init() {
    // 1. منع أي محاولة إغلاق للعبة (Anti-Crash)
    Method terminate = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
    if (terminate) method_setImplementation(terminate, imp_implementationWithBlock(^{}));

    // 2. تفعيل المنيو تلقائياً بمجرد التشغيل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // مسح الذاكرة بحثاً عن كلاسات Wizard وتعديلها فوراً
        int numClasses = objc_getClassList(NULL, 0);
        if (numClasses > 0) {
            Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                NSString *cName = NSStringFromClass(classes[i]);
                
                // استهداف كلاسات المنيو بناءً على ما وجدناه في الـ Info.plist
                if ([cName containsString:@"Wizard"] || [cName containsString:@"Auth"]) {
                    unsigned int mCount;
                    Method *methods = class_copyMethodList(classes[i], &mCount);
                    for (unsigned int j = 0; j < mCount; j++) {
                        SEL sel = method_getName(methods[j]);
                        NSString *mName = NSStringFromSelector(sel);
                        
                        // كسر كل شاشات التحقق والكود
                        if ([mName hasPrefix:@"is"] || [mName containsString:@"Valid"] || [mName containsString:@"check"]) {
                            method_setImplementation(methods[j], method_getImplementation(class_getInstanceMethod([NSObject class], @selector(isWizardActive))));
                        }
                    }
                    free(methods);
                }
            }
            free(classes);
        }
        
        // 3. إظهار رسالة النجاح التي طلبتها
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP" 
                                           message:@"تم التفعيل بنجاح" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"دخول" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}