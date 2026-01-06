#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دوال الرد الذكي لتخطي الحماية
static BOOL returnTrue() { return YES; }
static id returnExp() { return @"2030-01-01"; }
static id returnValid() { return @"Verified"; }

%ctor {
    NSLog(@"--- DooN Factory: Extreme Bypass Starting ---");

    // 1. كسر حماية الـ Framework (بناءً على ملف Wizard و Info.plist)
    //
    Class wizAuth = objc_getClass("WizardFrameworkAuth");
    if (wizAuth) {
        class_replaceMethod(wizAuth, @selector(isDeviceAuthorized), (IMP)returnTrue, "B@:");
        class_replaceMethod(wizAuth, @selector(checkInternalSecurity), (IMP)returnTrue, "B@:");
    }

    // 2. كسر حماية المكتبة (بناءً على تحليل dylib القديم)
    //
    Class mainAuth = objc_getClass("WizardAuth");
    if (mainAuth) {
        class_replaceMethod(mainAuth, @selector(checkKey:), (IMP)returnTrue, "B@:@");
        class_replaceMethod(mainAuth, @selector(licenseStatus), (IMP)returnValid, "@@:");
    }

    // 3. تخطي فحص ملف الـ .dat (Force Local Activation)
    Class dataMgr = objc_getClass("WizardDataManager");
    if (dataMgr) {
        class_replaceMethod(dataMgr, @selector(isLocalDataValid), (IMP)returnTrue, "B@:");
        class_replaceMethod(dataMgr, @selector(getUserTier), (IMP)returnValid, "@@:");
    }

    // 4. كود إخفاء شاشة التسجيل فور ظهورها
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *root = window.rootViewController;
        
        if ([NSStringFromClass([root.presentedViewController class]) containsString:@"Wizard"]) {
            [root dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"--- DooN Factory: Login Screen Dismissed ---");
        }
    });
}