# Makefile

ROOT ?= $(dir $(lastword $(MAKEFILE_LIST)))

SOURCE ?= $(ROOT)source
BUILD ?= $(ROOT)build

LOG ?= $(ROOT)debug.log

BOLD := \033[1m

RED := \033[1;31m
GREEN := \033[1;32m
CYAN := \033[1;36m

DIM := \033[2m

RESET := \033[0m

ARCH ?= $(shell uname -m)
BOOT ?= UEFI

DISK_SIZE := 68223488
ESP_SIZE := 33579008
PART_SIZE := 33579008

DISK_SECTORS := $(shell echo $$(($(DISK_SIZE) / 512)))
ESP_SECTORS := $(shell echo $$(($(ESP_SIZE) / 512)))
PART_SECTORS := $(shell echo $$(($(PART_SIZE) / 512)))

PART_START := $(shell echo $$((2048 + $(ESP_SIZE) / 512)))

ifeq ($(ARCH), x86_64)
    TRIPLE = x86_64-none-elf
    LTRIPLE = elf_x86_64

    WRAPPER := pe32p
    MACHINE := 0x8664
    EFI := BOOTX64.EFI

    QCMD := qemu-system-x86_64 -M q35 -nographic -nodefaults -serial stdio -smp 1 -m 128M -drive file=$(BUILD)/built/disk.img,format=raw -net none -no-reboot -d int,cpu_reset -D "$(LOG)"
ifeq ($(BOOT), UEFI)
    QCMD := $(QCMD) -drive file="$$FD_X86_64",format=raw,readonly=true,if=pflash
else ifneq ($(BOOT), BIOS)
    $(error Unsupported boot path: $(BOOT). Supported: BIOS, UEFI.)
endif

else ifneq ($(filter i386 i486 i586 i686,$(ARCH)),)
    TRIPLE = i386-none-elf
    LTRIPLE = elf_i386

    WRAPPER := pe32
    MACHINE := 0x14C
    EFI := BOOTIA32.EFI

    QCMD := qemu-system-i386 -M q35 -nographic -nodefaults -serial stdio -smp 1 -m 128M -drive file=$(BUILD)/built/disk.img,format=raw -net none -no-reboot -d int,cpu_reset -D "$(LOG)"
ifeq ($(BOOT), UEFI)
    QCMD := $(QCMD) -drive file="$$FD_IA_32",format=raw,readonly=true,if=pflash
else ifneq ($(BOOT), BIOS)
    $(error Unsupported boot path: $(BOOT). Supported: BIOS, UEFI.)
endif

else ifeq ($(ARCH), aarch64)
    TRIPLE = aarch64-none-elf
    LTRIPLE = aarch64elf

    WRAPPER := pe32p
    MACHINE := 0xAA64
    EFI := BOOTAA64.EFI

    QCMD := qemu-system-aarch64 -M virt -nographic -nodefaults -serial stdio -cpu max -smp 1 -m 128M -drive file="$$FD_ARM64",format=raw,readonly=true,if=pflash -drive file=$(BUILD)/built/disk.img,format=raw -net none -no-reboot -d int,cpu_reset -D "$(LOG)"
ifneq ($(BOOT), UEFI)
    $(error Unsupported boot path: $(BOOT). Supported: UEFI.)
endif

else ifeq ($(ARCH), armv7l)
    TRIPLE = arm-none-elf
    LTRIPLE = armelf

    WRAPPER := pe32
    MACHINE := 0x1C2
    EFI := BOOTARM.EFI

    QCMD := qemu-system-arm -M virt -nographic -nodefaults -serial stdio -smp 1 -m 128M -drive file="$$FD_ARM",format=raw,readonly=true,if=pflash -drive file=$(BUILD)/built/disk.img,format=raw -vga none -net none -no-reboot -d int,cpu_reset -D "$(LOG)"
ifneq ($(BOOT), UEFI)
    $(error Unsupported boot path: $(BOOT). Supported: UEFI.)
endif

else ifeq ($(ARCH), riscv64)
    TRIPLE = riscv64-none-elf
    LTRIPLE = elf64lriscv

    WRAPPER := pe32p
    MACHINE := 0x5064
    EFI := BOOTRISCV64.EFI

    QCMD := qemu-system-riscv64 -M virt -nographic -nodefaults -serial stdio -smp 1 -m 128M -drive file="$$FD_RISCV",format=raw,readonly=true,if=pflash -drive file=$(BUILD)/built/disk.img,format=raw -vga none -net none -no-reboot -d int,cpu_reset -D "$(LOG)"
ifneq ($(BOOT), UEFI)
    $(error Unsupported boot path: $(BOOT). Supported: UEFI.)
endif

else ifeq ($(ARCH), loongarch64)
    TRIPLE = loongarch64-none-elf
    LTRIPLE = elf64loongarch

    WRAPPER := pe32p
    MACHINE := 0x6264
    EFI := BOOTLOONGARCH64.EFI

    QCMD := qemu-system-loongarch64 -M virt -nographic -nodefaults -serial stdio -smp 1 -m 128M -drive file="$$FD_LOONGARCH",format=raw,readonly=true,if=pflash -drive file=$(BUILD)/built/disk.img,format=raw -vga none -net none -no-reboot -d int,cpu_reset -D "$(LOG)"
ifneq ($(BOOT), UEFI)
    $(error Unsupported boot path: $(BOOT). Supported: UEFI.)
endif

else
$(error Unsupported architecture: $(ARCH). Supported: x86_64, i386/i486/i586/i686 (IA-32), aarch64 (ARM64), armv7l (ARM32), riscv64 (RISC-V64), loongarch64 (LoongArch64))
endif

CFLAGS ?= -I$(SOURCE) -std=iso9899:199409 -nostdlib -funsigned-char -fshort-wchar -fpic -fpie -fomit-frame-pointer -O3
CFLAGS := $(CFLAGS) -Weverything -Wdeprecated-non-prototype -Wno-typedef-redefinition -Wno-reserved-identifier -Wno-comment -Wno-error
LFLAGS ?= -static

.ONESHELL:
.PHONY: all clean build bootloader stage1 stage2 uefi image run

all: image

clean:
	@printf "\n$(BOLD)Cleaning..$(RESET)\n"

	@printf "    $(CYAN)→$(RESET) Removing build directory..\n"
	@rm -rf "$(BUILD)"
	@printf "    $(GREEN)✓$(RESET) Removed $(BUILD)\n"

	@printf "\n    $(CYAN)→$(RESET) Removing logs..\n"
	@rm -f "$(LOG)"
	@printf "    $(GREEN)✓$(RESET) Removed $(LOG)\n"

	@printf "\n$(GREEN)$(BOLD)Done cleaning.$(RESET)\n"

build:
	@printf "\n$(BOLD)Building.. ($(ARCH))$(RESET)\n"

	@$(MAKE) --no-print-directory clean || exit 1

	@$(MAKE) --no-print-directory bootloader || exit 1

	@$(MAKE) --no-print-directory kernel || exit 1

	@printf "\n$(GREEN)$(BOLD)Finished building.$(RESET)\n"

bootloader:
	@printf "\n$(BOLD)Building bootloader..$(RESET)\n"

ifneq ($(filter i386 i486 i586 i686 x86_64,$(ARCH)),)
	@$(MAKE) --no-print-directory stage1 || exit 1
endif
	@$(MAKE) --no-print-directory uefi || exit 1

	@printf "\n$(GREEN)$(BOLD)Finished building bootloader.$(RESET)\n"

stage2:
	@printf "\n$(BOLD)Building Stage 2..$(RESET)\n"

	@mkdir -p "$(BUILD)/bootloader/bios/stage2" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Assembling Stage 2..\n\n"

	@set -x; set -x; llvm-mc -triple i386-none-elf -filetype obj "$(SOURCE)/bootloader/bios/stage2/main.s" -o "$(BUILD)/bootloader/bios/stage2/main.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Assemble Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled Stage 2.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking Stage 2..\n\n"

	@set -x; set -x; ld.lld -m elf_i386 -T "$(SOURCE)/bootloader/bios/stage2/linker.ld" --oformat=binary "$(BUILD)/bootloader/bios/stage2/main.o" -o "$(BUILD)/bootloader/bios/stage2/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked Stage 2.\n"

	@cp "$(BUILD)/bootloader/bios/stage2/main.bin" "$(BUILD)/built/stage2.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged Stage 2.\n"

	@printf "\n$(GREEN)$(BOLD)Finished building Stage 2.$(RESET)\n"

stage1: stage2
stage1: SECTORS = $(shell echo $$(( ($(shell wc -c < "$(BUILD)/built/stage2.bin") + 511) / 512 )))
stage1:
	@printf "\n$(BOLD)Building Stage 1.. ($(SECTORS) sectors)$(RESET)\n"

	@if [ $(SECTORS) -gt 64 ]; then \
		printf "\n$(RED)✘$(RESET) $(BOLD)Stage 2 is too large ($(SECTORS) sectors, max is 64).$(RESET)\n\n";
		exit 1; \
	fi

	@mkdir -p "$(BUILD)/bootloader/bios/stage1" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Assembling Stage 1..\n\n"

	@set -x; set -x; llvm-mc -triple i386-none-elf -filetype obj -defsym SECTORS=$(SECTORS) -defsym DISK=$(DISK_SECTORS) "$(SOURCE)/bootloader/bios/stage1/main.s" -o "$(BUILD)/bootloader/bios/stage1/main.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Assemble Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled Stage 1.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking Stage 1..\n\n"

	@set -x; set -x; ld.lld -m elf_i386 -T "$(SOURCE)/bootloader/bios/stage1/linker.ld" --oformat=binary "$(BUILD)/bootloader/bios/stage1/main.o" -o "$(BUILD)/bootloader/bios/stage1/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked Stage 1.\n"

	@cp "$(BUILD)/bootloader/bios/stage1/main.bin" "$(BUILD)/built/stage1.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged Stage 1.\n"

	@printf "\n$(GREEN)$(BOLD)Finished building Stage 1.$(RESET)\n"

uefi:
	@printf "\n$(BOLD)Building UEFI Bootloader..$(RESET)\n"

	@mkdir -p "$(BUILD)/bootloader/uefi" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Compiling UEFI Bootloader..\n\n"

	@set -x; set -x; clang -target $(TRIPLE) $(CFLAGS) -c "$(SOURCE)/bootloader/uefi/main.c" -o "$(BUILD)/bootloader/uefi/main.o" -ferror-limit=0 || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to compile UEFI Bootloader. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Compiled UEFI Bootloader.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking UEFI Bootloader..\n\n"

	@set -x; set -x; ld.lld -m $(LTRIPLE) -T "$(SOURCE)/bootloader/uefi/linker.ld" --oformat=binary "$(BUILD)/bootloader/uefi/main.o" -o "$(BUILD)/bootloader/uefi/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link UEFI Bootloader. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked UEFI Bootloader.\n"

	@printf "\n    $(CYAN)→$(RESET) Assembling PE/COFF Wrapper..\n\n"

	@set -x; set -x; llvm-mc -triple x86_64-none-elf -filetype obj -defsym MACHINE=$(MACHINE) "$(SOURCE)/bootloader/uefi/$(WRAPPER).s" -o "$(BUILD)/bootloader/uefi/pecoff.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Assemble PE/COFF Wrapper. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled PE/COFF Wrapper.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking PE/COFF Wrapper..\n\n"

	@set -x; set -x; ld.lld -m elf_x86_64 --oformat=binary "$(BUILD)/bootloader/uefi/pecoff.o" -o "$(BUILD)/bootloader/uefi/main.efi" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link PE/COFF Wrapper. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked PE/COFF Wrapper.\n"

	@cp "$(BUILD)/bootloader/uefi/main.efi" "$(BUILD)/built/$(EFI)" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage UEFI Bootloader. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged UEFI Bootloader.\n"

	@printf "\n$(GREEN)$(BOLD)Finished building UEFI Bootloader.$(RESET)\n"

kernel:
	@printf "\n$(BOLD)Building Kernel..$(RESET)\n"

	@mkdir -p "$(BUILD)/kernel" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Compiling Kernel..\n\n"

	@set -x; set -x; clang -target $(TRIPLE) $(CFLAGS) -c "$(SOURCE)/kernel/main.c" -o "$(BUILD)/kernel/main.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Compile Kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Compiled Kernel.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking Kernel..\n\n"

	@set -x; set -x; ld.lld -m $(LTRIPLE) -T "$(SOURCE)/kernel/linker.ld" --oformat=binary "$(BUILD)/kernel/main.o" -o "$(BUILD)/kernel/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link Kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked Kernel.\n"

	@cp "$(BUILD)/kernel/main.bin" "$(BUILD)/built/kernel" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage Kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged Kernel.\n"

	@printf "\n$(GREEN)$(BOLD)Finished building Kernel.$(RESET)\n"

image:
	@printf "\n$(BOLD)Building image.. ($(ARCH))$(RESET)\n"

	@$(MAKE) --no-print-directory build || exit 1

	@mkdir -p "$(BUILD)/image" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating disk image..\n\n"

	@set -x; set -x; dd bs=$(DISK_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Created disk image.\n"

ifneq ($(filter i386 i486 i586 i686 x86_64,$(ARCH)),)
	@if [ ! -f "$(BUILD)/built/$(EFI)" ]; then set -e; $(MAKE) --no-print-directory uefi; fi

	@mkdir -p "$(BUILD)/esp/EFI/BOOT"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@cp "$(BUILD)/built/$(EFI)" "$(BUILD)/esp/EFI/BOOT/$(EFI)" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage EFI binary. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged EFI binary.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank ESP image..\n\n"

	@set -x; set -x; dd bs=$(ESP_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Created ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting ESP image (FAT16)..\n\n"

	@set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "EFI" "$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying filesystem..\n\n"

	@set -x; set -x; mcopy -s -i "$(BUILD)/image/esp.img" "$(BUILD)/esp"/* ::/ || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy filesystem. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied filesystem.\n"

	@cp "$(BUILD)/image/esp.img" "$(BUILD)/built/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank kernel partition image..\n\n"

	@set -x; set -x; dd bs=$(PART_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Created kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting kernel partition image (exFAT)..\n\n"

	@set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "OS" "$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying kernel..\n\n"

	@set -x; set -x; mcopy -i "$(BUILD)/image/partition.img" "$(BUILD)/built/kernel" ::/kernel || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied kernel.\n"

	@cp "$(BUILD)/image/partition.img" "$(BUILD)/built/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Partitioning disk image..\n\n"

	@set -x; set -x; printf 'label: gpt\nstart=2048, size=$(ESP_SECTORS), type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\nstart=$(PART_START), size=$(PART_SECTORS), type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7\n' | sfdisk "$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to partition disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Partitioned disk image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing ESP filesystem into image..\n\n"

	@set -x; set -x; dd bs=512 seek=2048 conv=notrunc if="$(BUILD)/image/esp.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write ESP filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Written ESP filesystem into image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing kernel filesystem into image..\n\n"

	@set -x; set -x; dd bs=512 seek=$(PART_START) conv=notrunc if="$(BUILD)/image/partition.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write kernel filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Written kernel filesystem into image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing Stage 2..\n\n"

	@set -x; set -x; dd conv=notrunc bs=512 seek=34 if="$(BUILD)/built/stage2.bin" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Written Stage 2.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing Stage 1..\n\n"

	@set -x; set -x; dd conv=notrunc bs=512 count=1 if="$(BUILD)/built/stage1.bin" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Written Stage 1.\n"

else
	@if [ ! -f "$(BUILD)/built/$(EFI)" ]; then set -e; $(MAKE) --no-print-directory uefi; fi

	@mkdir -p "$(BUILD)/esp/EFI/BOOT"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@cp "$(BUILD)/built/$(EFI)" "$(BUILD)/esp/EFI/BOOT/$(EFI)" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage EFI binary. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged EFI binary.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank ESP image..\n\n"

	@set -x; set -x; dd bs=$(ESP_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Created ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting ESP image (FAT16)..\n\n"

	@set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "EFI" "$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying filesystem..\n\n"

	@set -x; set -x; mcopy -s -i "$(BUILD)/image/esp.img" "$(BUILD)/esp"/* ::/ || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy filesystem. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied filesystem.\n"

	@cp "$(BUILD)/image/esp.img" "$(BUILD)/built/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank kernel partition image..\n\n"

	@set -x; set -x; dd bs=$(PART_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Created kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting kernel partition image..\n\n"

	@set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "OS" "$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying kernel..\n\n"

	@set -x; set -x; mcopy -i "$(BUILD)/image/partition.img" "$(BUILD)/built/kernel" ::/kernel || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied kernel.\n"

	@cp "$(BUILD)/image/partition.img" "$(BUILD)/built/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Repartitioning disk image for UEFI..\n\n"

	@set -x; set -x; printf 'label: gpt\nstart=2048, size=$(ESP_SECTORS), type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\nstart=$(PART_START), size=$(PART_SECTORS), type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7\n' | sfdisk "$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to repartition disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Repartitioned disk image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing ESP filesystem into image..\n\n"

	@set -x; set -x; dd bs=512 seek=2048 conv=notrunc if="$(BUILD)/image/esp.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write ESP filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Written ESP filesystem into image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing kernel filesystem into image..\n\n"

	@set -x; set -x; dd bs=512 seek=$(PART_START) conv=notrunc if="$(BUILD)/image/partition.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write kernel filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@set +x

	@printf "\n    $(GREEN)✓$(RESET) Written kernel filesystem into image.\n"
endif

	@cp "$(BUILD)/image/disk.img" "$(BUILD)/built/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged disk image.\n"

	@printf "\n$(GREEN)$(BOLD)Finished building image.$(RESET)\n"

run:
	@printf "\n$(BOLD)Launching..$(RESET)\n"

	@$(MAKE) --no-print-directory all || exit 1

	@printf "\n    $(CYAN)→$(RESET) Running..\n\n"

	@set -x; set -x; $(QCMD); code=$$?; set +x; \
	if [ "$$code" -ne 0 ]; then \
	    printf "\n    $(RED)✘$(RESET) Exited with error $$code.\n"; \
	else \
	    printf "\n    $(GREEN)✓$(RESET) Exited cleanly.\n"; \
	fi

	@printf "\n$(GREEN)$(BOLD)Exited.$(RESET) Debug log: $(DIM)$(LOG)$(RESET)\n"
