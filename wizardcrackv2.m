#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// دوال لتثبيت التاريخ والنجاح
static _Bool returnYes() { return YES; }
static id fixedDate() { return [NSDate dateWithTimeIntervalSince1970:1893456000]; } // تاريخ في 2030

__attribute__((constructor))
static void init() {
    // 1. منع الكراش الناتج عن اختلاف الوقت أو اكتشاف التلاعب
    Method exitM = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
    if (exitM) method_setImplementation(exitM, imp_implementationWithBlock(^{}));

    // 2. تزييف التاريخ والوقت داخل ذاكرة المنيو (Wizard)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int numClasses = objc_getClassList(NULL, 0);
        if (numClasses > 0) {
            Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                NSString *cName = NSStringFromClass(classes[i]);
                if ([cName containsString:@"Wizard"] || [cName containsString:@"Auth"]) {
                    unsigned int mCount;
                    Method *methods = class_copyMethodList(classes[i], &mCount);
                    for (unsigned int j = 0; j < mCount; j++) {
                        NSString *mName = NSStringFromSelector(method_getName(methods[j]));
                        // تثبيت تاريخ الانتهاء (Expiry Date)
                        if ([mName containsString:@"Date"] || [mName containsString:@"Time"]) {
                            class_replaceMethod(classes[i], method_getName(methods[j]), (IMP)fixedDate, "@@:");
                        }
                        // تخطي فحص الصلاحية
                        if ([mName hasPrefix:@"is"] || [mName containsString:@"Valid"]) {
                            class_replaceMethod(classes[i], method_getName(methods[j]), (IMP)returnYes, "B@:");
                        }
                    }
                    free(methods);
                }
            }
            free(classes);
        }
    });

    // 3. حذف واجهة التحقق فور ظهورها
    NSTimer *uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *root = window.rootViewController;
        
        // إذا ظهرت أي شاشة تحتوي على كلمة Wizard أو Auth يتم إخفاؤها فوراً
        if ([NSStringFromClass([root class]) containsString:@"Wizard"] || [NSStringFromClass([root class]) containsString:@"Auth"]) {
            root.view.hidden = YES;
            [root.view removeFromSuperview];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:uiTimer forMode:NSDefaultRunLoopMode];

    // 4. رسالة DooN UP النهائية
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP" 
                                       message:@"تم التفعيل وتثبيت التاريخ ✅\nجاهز للاستخدام" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"دخول" style:UIAlertActionStyleDefault handler:nil]];
        [win.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}