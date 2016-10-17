#export TARGET = native:clang:8.1:6.1
export TARGET = native:clang:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Runtime
Runtime_FILES = $(call findfiles,sources)
#Runtime_FRAMEWORKS = CoreFoundation Foundation

TOOL_NAME = runtest
runtest_FILES = $(call findfiles,runtest_sources)
runtest_CFLAGS = -Isources

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk

test: all
	@$(or $(THEOS_OBJ_DIR),./)/$(TOOL_NAME)

internal-stage::
	#PreferenceLoader plist
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/testtweak; cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/testtweak/; fi$(ECHO_END)

remove:
	$(ECHO_NOTHING)exec ssh -p $(THEOS_DEVICE_PORT) root@$(THEOS_DEVICE_IP) "apt-get -y remove $(THEOS_PACKAGE_NAME)"$(ECHO_END)
