ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StandriseRage
StandriseRage_FILES = Tweak.xm
StandriseRage_CFLAGS = -fobjc-arc
StandriseRage_FRAMEWORKS = UIKit Foundation
StandriseRage_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
