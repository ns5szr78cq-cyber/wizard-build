# المعالجات المستهدفة (أجهزة أيفون الحديثة)
ARCHS = arm64 arm64e

# إصدار النظام المستهدف
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

# اسم المكتبة اللي هتطلع لك في الأخر
TWEAK_NAME = DooN_Wizard

# الملف البرمجي اللي هياخد منه الكود
DooN_Wizard_FILES = Tweak.x

# إعدادات إضافية لضمان عمل الكود بسلاسة
DooN_Wizard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk