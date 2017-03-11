CC=arm-none-eabi-gcc
AR=arm-none-eabi-ar

###########################################

#vpath %.c Libraries/STM32F10x_StdPeriph_Driver/src
SRC_PATH = Libraries/STM32F10x_StdPeriph_Driver/src
STARTUP_SRC_PATH = Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x

CFLAGS  = -g -O2 -Wall -D$(CHIP_TYPE)
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m3
CFLAGS += -ffreestanding -nostdlib
CFLAGS += -includestm32f10x_conf.h
CFLAGS += -ILibraries/CMSIS/CM3/CoreSupport
CFLAGS += -ILibraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x
CFLAGS += -ILibraries/STM32F10x_StdPeriph_Driver/inc


SRCS += $(wildcard $(SRC_PATH)/*.c)
SRCS += $(wildcard $(STARTUP_SRC_PATH)/*.c)

OBJS = $(SRCS:.c=.o)

.PHONY: libstm32f10x.a

all: libstm32f10x.a

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

libstm32f10x.a: $(OBJS)
	$(AR) -r $@ $(OBJS)

clean:
	rm -f $(OBJS) libstm32f10x.a
