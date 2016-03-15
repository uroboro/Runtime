export TARGET = iphone:clang:6.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Runtime
Runtime_FILES = $(call findfiles,sources)
#Runtime_FRAMEWORKS = CoreFoundation Foundation

TOOL_NAME = runtest
runtest_FILES = main.m

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk

internal-stage::
	#Filter plist
	$(ECHO_NOTHING)if [ -f Filter.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/; cp Filter.plist $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/testtweak.plist; fi$(ECHO_END)
	#PreferenceLoader plist
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/testtweak; cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/testtweak/; fi$(ECHO_END)

remove:
	$(ECHO_NOTHING)exec ssh -p $(THEOS_DEVICE_PORT) root@$(THEOS_DEVICE_IP) "apt-get -y remove $(THEOS_PACKAGE_NAME)"$(ECHO_END)

test: all
	@$(or $(THEOS_OBJ_DIR),./)/$(TOOL_NAME)
