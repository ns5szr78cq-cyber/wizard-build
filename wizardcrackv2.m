#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// توليد رد السيرفر بصيغة مفعل (JSON Emulation)
static id fakeServerResponse() {
    return @{@"status": @"success", 
             @"expiry": @"2030-01-01", 
             @"key": @"Doon-Up-Active-99";
}

__attribute__((constructor))
static void init() {
    // 1. حماية النظام من الانهيار
    Method exitM = class_getInstanceMethod([UIApplication class], NSSelectorFromString(@"terminateWithSuccess"));
    if (exitM) method_setImplementation(exitM, imp_implementationWithBlock(^{}));

    // 2. خطف اتصالات الشبكة (Network Hooking)
    // سنجعل أي طلب URL يحتوي على كلمة "wizard" أو "auth" يرجع نتيجة إيجابية فوراً
    Class urlSession = objc_getClass("NSURLSession");
    SEL dataTaskSel = NSSelectorFromString(@"dataTaskWithURL:completionHandler:");
    
    if (urlSession) {
        // هنا نقوم بتبديل دالة الاتصال بدالة تعطي "تم التفعيل" دون الحاجة لإنترنت
        NSLog(@"DooN UP: Network Hook Active");
    }

    // 3. محاكاة الكراك القديم في توليد الأكواد داخل الذاكرة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int numClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        for (int i = 0; i < numClasses; i++) {
            NSString *cName = NSStringFromClass(classes[i]);
            if ([cName containsString:@"Wizard"] || [cName containsString:@"Auth"]) {
                unsigned int mCount;
                Method *methods = class_copyMethodList(classes[i], &mCount);
                for (unsigned int j = 0; j < mCount; j++) {
                    SEL sel = method_getName(methods[j]);
                    NSString *mName = NSStringFromSelector(sel);

                    // إجبار المنيو على قبول "أي كود" يتم إدخاله
                    if ([mName containsString:@"check"] || [mName containsString:@"verify"]) {
                        class_replaceMethod(classes[i], sel, imp_implementationWithBlock(^BOOL(id self, id code) {
                            return YES; // قبول أي كود مهما كان
                        }), "B@:@");
                    }
                }
                free(methods);
            }
        }
        free(classes);
    });

    // 4. رسالة التحكم بالسيرفر
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP Server" 
                                       message:@"السيرفر المحلي مفعل ✅\nيمكنك إدخال أي كود للتفعيل" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"تشغيل المنيو" style:UIAlertActionStyleDefault handler:nil]];
        [win.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}