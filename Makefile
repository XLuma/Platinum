# Makefile
ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPro)
endif

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

TOOLCHAIN := $(DEVKITARM)

.PHONY: clean all


ifeq ($(OS),Windows_NT)
EXE := .exe
else
EXE :=
endif

default: all

ROMNAME = rom.nds
BUILDROM = test.nds
####################### Tools #########################
MSGENC = tools/msgenc$(EXE)
NITROGFX = tools/nitrogfx$(EXE)
NDSTOOL = tools/ndstool$(EXE)
JSONPROC = tools/jsonproc$(EXE)
O2NARC = tools/o2narc$(EXE)

####################### Seting ########################
PREFIX = bin/arm-none-eabi-
AS = $(DEVKITARM)/$(PREFIX)as
CC = $(DEVKITARM)/$(PREFIX)gcc
LD = $(DEVKITARM)/$(PREFIX)ld
OBJCOPY = $(DEVKITARM)/$(PREFIX)objcopy

LDFLAGS = rom.ld -T linker.ld
ASFLAGS = -mthumb -I ./data
CFLAGS = -mthumb -mno-thumb-interwork -mcpu=arm7tdmi -mtune=arm7tdmi -mno-long-calls -march=armv4t -Wall -Wextra -Os -fira-loop-pressure -fipa-pta

PYTHON = python
LINK = build/linked.o
OUTPUT = build/output.bin
####################### Build #########################
#comment thse lines or replace with your own text files 
data/msg/213.bin:data/msg/213.txt
	$(MSGENC) $< data/msg/213.key charmap.txt $@

#comment these lines or replace with your own script files
data/211.bin:data/211.s
	@echo -e "\e[32;1mAssembling data/scripts/211.s\e[37;1m"
	@$(AS) $(ASFLAGS) -c $< -o build/211.o
	@$(OBJCOPY) -O binary build/211.o data/211.bin

#comment these lines or edit to use your own code instead
build/repel.o:src/repel.c
	@mkdir -p build
	@echo -e "\e[32;1mCompiling src/repel.c\e[37;1m"
	@$(CC) $(CFLAGS) -c $< -o $@

$(LINK):build/repel.o
	@$(LD) $(LDFLAGS) -o $@ $<

$(OUTPUT):$(LINK)
	@$(OBJCOPY) -O binary $< $@

all:$(OUTPUT) data/211.bin data/msg/213.bin
	@mkdir -p base
	@rm -rf build/data/*
	@$(NDSTOOL) -x $(ROMNAME) -9 base/arm9.bin -7 base/arm7.bin -y9 base/overarm9.bin -y7 base/overarm7.bin -d base/root -y base/overlay -t base/banner.bin -h base/header.bin
	@echo -e "\e[32;1mCreated Successfully!!\e[37;1m"
	@echo -e "\e[32;1mUnpack weather_sys.narc\e[37;1m"
	@python scripts/NARCTool.py extract base/root/data/weather_sys.narc build/data/
	@echo -e "\e[32;1mInsert code\e[37;1m"
	@python scripts/insert.py
	@python scripts/NARCTool.py compile build/data/ build/
	@mv build/.narc base/root/data/weather_sys.narc
	@rm -rf build/data/*
	@echo -e "\e[32;1mUnpack scr_seq.narc\e[37;1m"
	@python scripts/NARCTool.py extract base/root/fielddata/script/scr_seq.narc build/data/
	@cp data/211.bin build/data/211.bin
	@python scripts/NARCTool.py compile build/data/ build/
	@mv build/.narc base/root/fielddata/script/scr_seq.narc
	@echo -e "\e[32;1mUnpack pl_msg.narc\e[37;1m"
	@rm -rf build/data/*
	@python scripts/NARCTool.py extract base/root/msgdata/pl_msg.narc build/data/
	@cp data/msg/213.bin build/data/213.bin
	@python scripts/NARCTool.py compile build/data/ build/
	@mv build/.narc base/root/msgdata/pl_msg.narc
	@echo -e "\e[32;1mBuild Rom\e[37;1m"
	@$(NDSTOOL) -c $(BUILDROM) -9 base/arm9.bin -7 base/arm7.bin -y9 base/overarm9.bin -y7 base/overarm7.bin -d base/root -y base/overlay -t base/banner.bin -h base/header.bin
	
clean:
	rm -rf build/

