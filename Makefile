export TARGET = native
ifeq ($(shell uname -p), i386)
export ARCHS = x86_64
else
export ARCHS = armv7 arm64
endif

findfiles = $(foreach ext, c cpp m mm x xm xi xmi, $(wildcard $(1)/*.$(ext)))

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Runtime
Runtime_FILES = $(call findfiles,sources)
#Runtime_FRAMEWORKS = CoreFoundation Foundation

TWEAK_NAME = RuntimeTweak
RuntimeTweak_FILES = log.xm

TOOL_NAME = runtest
runtest_FILES = $(call findfiles,runtest_sources)
runtest_CFLAGS = -Isources

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk

test: Runtime runtest
	ls $(THEOS_OBJ_DIR)
	@$(or $(THEOS_OBJ_DIR),./)/$(TOOL_NAME) $(THEOS_OBJ_DIR)

remove:
	$(ECHO_NOTHING)exec ssh -p $(THEOS_DEVICE_PORT) root@$(THEOS_DEVICE_IP) "apt-get -y remove $(THEOS_PACKAGE_NAME)"$(ECHO_END)
