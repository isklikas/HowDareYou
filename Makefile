INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HowDareYou
BUNDLE_NAME = com.isklikas.HowDareYou-resources

HowDareYou_FILES = Tweak.x
HowDareYou_FRAMEWORKS = UIKit AudioToolbox
HowDareYou_CFLAGS = -fobjc-arc -Wno-arc-performSelector-leaks
com.isklikas.HowDareYou-resources_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
