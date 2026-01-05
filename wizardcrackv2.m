#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// --- إعلان واجهة الكلاس الأصلي لضمان مطابقة الـ Symbols ---
@interface GCDWebServerConnection : NSObject
- (_Bool)_checkAuthentication; // الدالة الأصلية المسؤولة عن فحص الباسوورد
@end

// --- تنفيذ التعديل (The Bypass Implementation) ---

@implementation NSObject (WizardCrackV2Hook)

// هذه الدالة ستحل محل الدالة الأصلية في نظام التشغيل
- (_Bool)hooked_checkAuthentication {
    // طباعة رسالة في السجل للتأكد من عمل التعديل
    NSLog(@"[WizardCrackV2] 🛡️ تم رصد طلب فحص هويّة.. السماح بالدخول فوراً!");
    
    // إرجاع YES يعني أن أي يوزر وأي باسوورد مقبولين
    return YES; 
}

@end

// --- محرك الحقن التلقائي (The Injection Engine) ---

__attribute__((constructor))
static void wizard_entry_point() {
    // نستخدم GCD لضمان تشغيل الحقن بعد تحميل التطبيق بالكامل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // الوصول لكلاس GCDWebServerConnection من ملفاتك
        Class connectionClass = NSClassFromString(@"GCDWebServerConnection");
        
        if (connectionClass) {
            // الحصول على الدالة الأصلية من الهيدرز
            SEL originalSelector = @selector(_checkAuthentication);
            // الحصول على دالة التخطي التي كتبناها
            SEL hookedSelector = @selector(hooked_checkAuthentication);
            
            Method originalMethod = class_getInstanceMethod(connectionClass, originalSelector);
            Method hookedMethod = class_getInstanceMethod([NSObject class], hookedSelector);
            
            if (originalMethod && hookedMethod) {
                // عملية "تبديل الأسلاك" البرمجية (Method Swizzling)
                method_setImplementation(originalMethod, method_getImplementation(hookedMethod));
                NSLog(@"[WizardCrackV2] ✅ تم ربط التعديل طبق الأصل بنجاح.");
            }
        } else {
            NSLog(@"[WizardCrackV2] ❌ خطأ: لم يتم العثور على الكلاس المطلوب.");
        }
    });
}