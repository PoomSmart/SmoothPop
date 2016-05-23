GO_EASY_ON_ME = 1
DEBUG = 0
TARGET = iphone:latest:7.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = SmoothPop
SmoothPop_FILES = Tweak.xm
SmoothPop_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
