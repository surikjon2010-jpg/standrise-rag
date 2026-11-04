ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StandriseRage
StandriseRage_FILES = Tweak.xm Rage.mm ESP.mm
StandriseRage_CFLAGS = -fobjc-arc -I./Dobby/include
StandriseRage_FRAMEWORKS = UIKit Foundation OpenGLES QuartzCore
StandriseRage_LDFLAGS = -L./Dobby -ldobby -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk
