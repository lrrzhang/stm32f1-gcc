# put your *.o targets here, make should handle the rest!
SRCS = main.c
SRCS += stm32f10x_it.c

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)
PROJ_NAME=main

# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=STM32F10x_StdPeriph_Lib_V3.5.0

# Location of the linker scripts
LDSCRIPT_INC=STM32F10x_StdPeriph_Lib_V3.5.0

# location of OpenOCD Board .cfg files (only used with 'make program')
OPENOCD_BOARD_DIR=/usr/share/openocd/scripts/board

# Configuration (cfg) file containing programming directives for OpenOCD
OPENOCD_PROC_FILE=extra/stm32-openocd.cfg

# that's it, no need to change anything below this line!

###################################################

export CHIP_TYPE = STM32F10X_MD

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size

CFLAGS  = -Wall -g -std=c99 -Os -D$(CHIP_TYPE)
#CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m0 -march=armv6s-m
#CFLAGS += -mlittle-endian -mcpu=cortex-m0  -march=armv6-m -mthumb
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m3
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wl,--gc-sections -Wl,-Map=$(PROJ_NAME).map

###################################################

vpath %.c src
vpath %.a $(STD_PERIPH_LIB)

ROOT=$(shell pwd)

CFLAGS += -I inc 
CFLAGS += -I $(STD_PERIPH_LIB) 
CFLAGS += -I $(STD_PERIPH_LIB)/Libraries/CMSIS/CM3/CoreSupport
CFLAGS += -I $(STD_PERIPH_LIB)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x
CFLAGS += -I $(STD_PERIPH_LIB)/Libraries/STM32F10x_StdPeriph_Driver/inc
CFLAGS += -include $(STD_PERIPH_LIB)/stm32f10x_conf.h

SRCS += $(STD_PERIPH_LIB)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/startup_stm32f10x_md.s
# add startup file to build

# need if you want to build with -DUSE_CMSIS 
#SRCS += stm32f0_discovery.c
#SRCS += stm32f0_discovery.c stm32f0xx_it.c

OBJS = $(SRCS:.c=.o)

###################################################

.PHONY: lib proj

all: lib proj

lib:
	$(MAKE) -C $(STD_PERIPH_LIB)

proj: 	$(PROJ_NAME).elf

$(PROJ_NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ -L$(STD_PERIPH_LIB) -lstm32f10X -L$(LDSCRIPT_INC) -Tstm32_flash.ld
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin
	$(OBJDUMP) -St $(PROJ_NAME).elf >$(PROJ_NAME).lst
	$(SIZE) $(PROJ_NAME).elf
	
program: $(PROJ_NAME).bin
	openocd -f $(OPENOCD_BOARD_DIR)/stm32f0discovery.cfg -f $(OPENOCD_PROC_FILE) -c "stm_flash `pwd`/$(PROJ_NAME).bin" -c shutdown

clean:
	find ./ -name '*~' | xargs rm -f	
	rm -f *.o
	rm -f $(PROJ_NAME).elf
	rm -f $(PROJ_NAME).hex
	rm -f $(PROJ_NAME).bin
	rm -f $(PROJ_NAME).map
	rm -f $(PROJ_NAME).lst

reallyclean: clean
	$(MAKE) -C $(STD_PERIPH_LIB) clean
