# STM32F429I-Disco Makefile for GNU toolchain and openocd
#
# This Makefile fetches the Cube firmware package from ST's' website.
# This includes: CMSIS, STM32 HAL, BSPs, USB drivers and examples.
#
# Usage:
#	make program		Flash the board with OpenOCD
#	make openocd		Start OpenOCD
#	make debug		Start GDB and attach to OpenOCD
#	make dirs		Create subdirs like obj, dep, ..
#
# Copyright	2015 Steffen Vogel, 2016 Roman Belkov
# License	http://www.gnu.org/licenses/gpl.txt GNU Public License
# Authors	Steffen Vogel <post@steffenvogel.de>
#           Roman Belkov  <roman.belkov@gmail.com>
# Link		http://www.steffenvogel.de
#

# A name common to all output files (elf, map, hex, bin, lst)
TARGET     = demo

# Take a look into $(CUBE_DIR)/Drivers/BSP for available BSPs
# name needed in upper case and lower case
BOARD      = STM32F429I-Discovery
BOARD_UC   = STM32F429I-Discovery
BOARD_LC   = stm32f429i_discovery
BSP_BASE   = $(BOARD_LC)

OCDFLAGS   = -f board/stm32f429discovery.cfg
GDBFLAGS   =

#EXAMPLE   = Templates
EXAMPLE    = Examples/GPIO/GPIO_EXTI

# MCU family and type in various capitalizations o_O
MCU_FAMILY = stm32f4xx
MCU_LC     = stm32f429xx
MCU_MC     = STM32F429xx
MCU_UC     = STM32F429ZI

MCU_HAL = $(MCU_FAMILY)_hal

# path of the ld-file inside the example directories
LDFILE     = SW4STM32/$(BOARD_UC)/$(MCU_UC)Tx_FLASH.ld
#LDFILE     = $(EXAMPLE)/TrueSTUDIO/$(BOARD_UC)/$(MCU_UC)_FLASH.ld

# Your C files from the /src directory
SOURCES_DIR = src
OBJECTS_DIR = obj
DEP_DIR = dep


#SOURCES = $(wildcard $(SOURCES_DIR)/*.c)
SOURCES := $(notdir $(shell find $(SOURCES_DIR) -name '*.c'))
CPP_SOURCES := $(notdir $(shell find $(SOURCES_DIR) -name '*.cpp'))
#DEPS    = $(patsubst $(SOURCES_DIR)/%.c, $(DEP_DIR)/%.d, $(SOURCES))

# Basic HAL libraries
SOURCES += $(MCU_HAL)_rcc.c $(MCU_HAL)_rcc_ex.c $(MCU_HAL).c $(MCU_HAL)_cortex.c $(MCU_HAL)_gpio.c $(MCU_HAL)_pwr_ex.c $(BSP_BASE).c

# Directories

# TODO hardcode
OCD_DIR    = ~/install/openocd-0.9.0/
OCD_SCRIPTS_DIR = $(OCD_DIR)/scripts/

CUBE_DIR   = cube

BSP_DIR    = $(CUBE_DIR)/Drivers/BSP/$(BOARD_UC)
HAL_DIR    = $(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver
CMSIS_DIR  = $(CUBE_DIR)/Drivers/CMSIS

DEV_DIR    = $(CMSIS_DIR)/Device/ST/STM32F4xx

# that's it, no need to change anything below this line!

###############################################################################
# Toolchain

PREFIX     = arm-none-eabi
CC         = $(PREFIX)-gcc
AR         = $(PREFIX)-ar
OBJCOPY    = $(PREFIX)-objcopy
OBJDUMP    = $(PREFIX)-objdump
SIZE       = $(PREFIX)-size
GDB        = $(PREFIX)-gdb

# TODO hardcode
OCD        = $(OCD_DIR)/bin-x64/openocd.exe  

###############################################################################
# Options

# Defines
DEFS       = -D$(MCU_MC) -DUSE_HAL_DRIVER

# Debug specific definitions for semihosting
DEFS       += -DUSE_DBPRINTF

# Include search paths (-I)
#INCS       = -Isrc
INCS       = -Iinc
INCS      += -I$(BSP_DIR)
INCS      += -I$(CMSIS_DIR)/Include
INCS      += -I$(DEV_DIR)/Include
INCS      += -I$(HAL_DIR)/Inc

# Library search paths
LIBS       = -L$(CMSIS_DIR)/Lib

# Compiler flags
CFLAGS     = -Wall -g -std=gnu++11 -Os
CFLAGS    += -mcpu=cortex-m4 -mthumb
CFLAGS    += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
CFLAGS    += -ffunction-sections -fdata-sections
CFLAGS    += $(INCS) $(DEFS)

# Linker flags
LDFLAGS    = -Wl,--gc-sections -Wl,-Map=$(TARGET).map $(LIBS) -T$(LDFILE)

# Enable Semihosting
LDFLAGS   += --specs=rdimon.specs -lc -lrdimon

# Source search paths
VPATH      = ./src
VPATH     += $(BSP_DIR)
VPATH     += $(HAL_DIR)/Src
VPATH     += $(DEV_DIR)/Source/

OBJECTS := $(addprefix $(OBJECTS_DIR)/,$(SOURCES:%.c=%.o))
CPP_OBJECTS := $(addprefix $(OBJECTS_DIR)/,$(CPP_SOURCES:%.cpp=%.o))

DEPS    := $(addprefix $(DEP_DIR)/,$(SOURCES:%.c=%.d))

# Prettify output
V = 0
ifeq ($V, 0)
	Q = @
	P = > /dev/null
endif

###################################################

.PHONY: all dirs program clean # debug template clean

all: $(TARGET).bin

-include $(DEPS)

dirs: dep obj
dep obj src:
	@echo "[MKDIR]   $@"
	$Qmkdir -p $@

$(OBJECTS_DIR)/%.o : %.c | dirs
	@echo "[CC]      $(notdir $<)"
	$(CC) $(CFLAGS) -c -o $@ $< -MMD -MF dep/$(*F).d

$(OBJECTS_DIR)/%.o : %.cpp | dirs
	@echo "[CC]      $(notdir $<)"
	$(CC) $(CFLAGS) -c -o $@ $< -MMD -MF dep/$(*F).d

$(TARGET).elf: $(OBJECTS) $(CPP_OBJECTS)
	@echo "[LD]      $(TARGET).elf"
	$(CC) $(CFLAGS) $(LDFLAGS) src/startup_$(MCU_LC).s $^ -o $@
	@echo "[OBJDUMP] $(TARGET).lst"
	$Q$(OBJDUMP) -St $(TARGET).elf >$(TARGET).lst
	@echo "[SIZE]    $(TARGET).elf"
	$(SIZE) $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	@echo "[OBJCOPY] $(TARGET).bin"
	$Q$(OBJCOPY) -O binary $< $@

openocd:
	$(OCD) -s $(OCD_SCRIPTS_DIR) $(OCDFLAGS)

program: #all
	$(OCD) -s $(OCD_SCRIPTS_DIR) $(OCDFLAGS) -c "program $(TARGET).elf verify reset" -c "shutdown"

debug:
	@if ! nc -z localhost 3333; then \
		echo "\n\t[Error] OpenOCD is not running! Start it with: 'make openocd'\n"; exit 1; \
	else \
		$(GDB)  -ex "target extended localhost:3333" \
			-ex "monitor arm semihosting enable" \
			-ex "monitor reset halt" \
			-ex "load" \
			-ex "monitor reset init" \
			$(GDBFLAGS) $(TARGET).elf; \
	fi

clean:
	@echo "$(SOURCES)"
	@echo "$(OBJECTS)"
	@echo "[RM]      $(TARGET).bin"; rm -f $(TARGET).bin
	@echo "[RM]      $(TARGET).elf"; rm -f $(TARGET).elf
	@echo "[RM]      $(TARGET).map"; rm -f $(TARGET).map
	@echo "[RM]      $(TARGET).lst"; rm -f $(TARGET).lst
	@echo "[RMDIR]   dep"          ; rm -rf dep
	@echo "[RMDIR]   obj"          ; rm -rf obj

