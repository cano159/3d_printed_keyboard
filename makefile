# Run "make help" for target help.

MCU          = at90usb1286
ARCH         = AVR8
F_CPU        = 16000000
F_USB        = $(F_CPU)
OPTIMIZATION = s
TARGET       = Keyboard
LUFA_PATH    = lufa/LUFA
U8GLIB_CSRC_PATH  = u8glib/csrc
U8GLIB_SFNTSRC_PATH  = u8glib/sfntsrc
SRC          = \
	$(TARGET).c \
	Counter.c \
	Descriptors.c \
	Display.c \
	KeyboardReport.c \
	Keymap.c \
	LayerState.c \
	ScanKeys.c \
	Sequence.c \
	Timer.c \
	$(wildcard $(U8GLIB_CSRC_PATH)/*.c) \
	$(wildcard $(U8GLIB_SFNTSRC_PATH)/*.c) \
	$(LUFA_SRC_USB) \
	$(LUFA_SRC_USBCLASS) \
	$(LUFA_SRC_TWI)
TEENSY_LOADER_PATH = teensy_loader_cli
TEENSY_LOADER = ./$(TEENSY_LOADER_PATH)/teensy_loader_cli
BASE_CC_FLAGS     =  \
	-DUSE_LUFA_CONFIG_HEADER \
	-IConfig/ \
	-I$(U8GLIB_CSRC_PATH) \
	-I$(U8GLIB_SFNTSRC_PATH) \
	-Werror
ifdef SERIAL_DEBUG
CC_FLAGS := -DSERIAL_DEBUG $(BASE_CC_FLAGS)
else
CC_FLAGS := $(BASE_CC_FLAGS)
endif
LD_FLAGS     =

# Default target
all:

# Include LUFA-specific DMBS extension modules
DMBS_LUFA_PATH ?= $(LUFA_PATH)/Build/LUFA
include $(DMBS_LUFA_PATH)/lufa-sources.mk
include $(DMBS_LUFA_PATH)/lufa-gcc.mk

# Include common DMBS build system modules
DMBS_PATH      ?= $(LUFA_PATH)/Build/DMBS/DMBS
include $(DMBS_PATH)/core.mk
include $(DMBS_PATH)/cppcheck.mk
include $(DMBS_PATH)/doxygen.mk
include $(DMBS_PATH)/dfu.mk
include $(DMBS_PATH)/gcc.mk
include $(DMBS_PATH)/hid.mk
include $(DMBS_PATH)/avrdude.mk
include $(DMBS_PATH)/atprogram.mk

# Teensy Loader CLI
$(TEENSY_LOADER):
	cd $(TEENSY_LOADER_PATH) && make

all: $(TEENSY_LOADER)

clean_teensy_loader:
	cd $(TEENSY_LOADER_PATH) && make clean

clean: clean_teensy_loader

# Load Hex to Teensy
load: $(TARGET).hex $(TEENSY_LOADER)
	$(TEENSY_LOADER) -mmcu=$(MCU) -w -v $(TARGET).hex
