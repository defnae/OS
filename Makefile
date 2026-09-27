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

UNAME_M := $(shell uname -m)
UNAME_S := $(shell uname -s)

HOST ?= $(if $(filter x86_64,$(UNAME_M)),x86_64,$(if $(filter i386 i486 i586 i686,$(UNAME_M)),IA-32,$(if $(filter aarch64,$(UNAME_M)),ARM64,$(if $(filter armv7l,$(UNAME_M)),ARM32,$(if $(filter riscv64,$(UNAME_M)),RISC-V64,$(if $(filter loongarch64,$(UNAME_M)),LoongArch64,Unknown))))))

ARCH ?= $(HOST)

ifneq ($(findstring NT,$(UNAME_S)),)
    PLATFORM ?= Windows
else ifeq ($(UNAME_S),Darwin)
    PLATFORM ?= macOS
else
    PLATFORM ?= Linux
endif

BOOT ?= UEFI

SECTOR_SIZE ?= 512

ESP_SIZE ?= 33579008
PART_SIZE ?= 33579008

DISK_SIZE := $(shell echo $$(($(ESP_SIZE) + $(PART_SIZE) + 1065472)))

DISK_SECTORS := $(shell echo $$(($(DISK_SIZE) / 512)))
ESP_SECTORS := $(shell echo $$(($(ESP_SIZE) / 512)))
PART_SECTORS := $(shell echo $$(($(PART_SIZE) / 512)))

PART_START := $(shell echo $$((2048 + $(ESP_SIZE) / 512)))

ifneq ($(HOST),$(ARCH))
ifeq ($(HOST),x86_64)
ifeq ($(ARCH),IA-32)
    ACCEL ?= yes
endif
endif
else
    ACCEL ?= yes
endif

ifeq ($(ACCEL),yes)
ifeq ($(PLATFORM),Windows)
    ACCEL := -accel whpx -cpu host
else ifeq ($(PLATFORM),macOS)
    ACCEL := -accel hvf -cpu host
else
    ACCEL := -accel kvm -cpu host,hv_passthrough
endif
endif

QFLAGS ?= -nodefaults -serial vc -monitor vc -parallel none $(ACCEL) -m 128M -drive file=$(BUILD)/built/disk.img,format=raw -net none -no-reboot -d int,cpu_reset -D "$(LOG)"

ifneq ($(ARCH),x86_64)
ifneq ($(ARCH),IA-32)
    QFLAGS += -device usb-ehci -device usb-kbd
endif
endif

ifeq ($(ARCH),x86_64)
    BOOTLOADER_TRIPLE ?= x86_64-pc-windows-msvc
    KERNEL_TRIPLE ?= x86_64-none-elf
    LLVM_TRIPLE ?= elf_x86_64

    UEFI_LINKER ?= lld-link
    UEFI_ENTRY ?= bootloader/uefi/headers/arch/x86_64/entry
    KERNEL_ENTRY ?= kernel/headers/arch/x86_64/entry
    MACHINE ?= x64
    EFI ?= BOOTX64.EFI

    QBINARY ?= qemu-system-x86_64
    QMACHINE ?= q35
    QVC ?= -vga none -device VGA

    FD ?= FD_X86_64

    BOOTS ?= BIOS UEFI

    BOOTLOADER_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fno-pic -fno-pie -Weverything -fomit-frame-pointer -O3
    KERNEL_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3
else ifeq ($(ARCH),IA-32)
    BOOTLOADER_TRIPLE ?= i386-pc-windows-msvc
    KERNEL_TRIPLE ?= i386-none-elf
    LLVM_TRIPLE ?= elf_i386

    UEFI_LINKER ?= lld-link
    UEFI_ENTRY ?= bootloader/uefi/headers/arch/ia32/entry
    KERNEL_ENTRY ?= kernel/headers/arch/ia32/entry
    # i386 COFF cdecl mangling prepends an underscore to every symbol lld-link
    # resolves via /entry:, so the unmangled name must be given here.
    UEFI_ENTRY_SYMBOL ?= start
    UEFI_LINK_FLAGS ?= /safeseh:no
    MACHINE ?= x86
    EFI ?= BOOTIA32.EFI

    QBINARY ?= qemu-system-i386
    QMACHINE ?= q35
    QVC ?= -vga none -device VGA

    FD ?= FD_IA_32

    BOOTS ?= BIOS UEFI

    BOOTLOADER_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fno-pic -fno-pie -Weverything -fomit-frame-pointer -O3
    KERNEL_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3
else ifeq ($(ARCH),ARM64)
    BOOTLOADER_TRIPLE ?= aarch64-pc-windows-msvc
    KERNEL_TRIPLE ?= aarch64-none-elf
    LLVM_TRIPLE ?= aarch64elf

    UEFI_LINKER ?= lld-link
    UEFI_ENTRY ?= bootloader/uefi/headers/arch/arm64/entry
    KERNEL_ENTRY ?= kernel/headers/arch/arm64/entry
    MACHINE ?= arm64
    EFI ?= BOOTAA64.EFI

ifeq ($(ACCEL),)
    QCPU ?= -cpu max
endif
    QBINARY ?= qemu-system-aarch64
    QMACHINE ?= virt
    QVC ?= -device ramfb

    FD ?= FD_ARM64

    BOOTS ?= UEFI

    BOOTLOADER_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fno-pic -fno-pie -Weverything -fomit-frame-pointer -O3
    KERNEL_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3


else ifeq ($(ARCH),ARM32)
    BOOTLOADER_TRIPLE ?= arm-pc-windows-msvc
    KERNEL_TRIPLE ?= arm-none-eabi
    LLVM_TRIPLE ?= armelf

    BOOTLOADER_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fno-pic -fno-pie -Weverything -fomit-frame-pointer -O3
    KERNEL_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3

    UEFI_LINKER ?= lld-link
    UEFI_ENTRY ?= bootloader/uefi/headers/arch/arm32/entry
    KERNEL_ENTRY ?= kernel/headers/arch/arm32/entry
    MACHINE ?= arm
    EFI ?= BOOTARM.EFI

    QBINARY ?= qemu-system-arm
    QMACHINE ?= virt
    QVC ?= -device ramfb

    FD ?= FD_ARM

    BOOTS ?= UEFI

else ifeq ($(ARCH),RISC-V64)
    BOOTLOADER_TRIPLE ?= riscv64-none-elf
    KERNEL_TRIPLE ?= riscv64-none-elf
    LLVM_TRIPLE ?= elf64lriscv


    UEFI_LINKER ?= flat
    UEFI_ENTRY ?= bootloader/uefi/headers/arch/riscv64/entry
    KERNEL_ENTRY ?= kernel/headers/arch/riscv64/entry
    WRAPPER ?= pe32p
    MACHINE ?= 0x5064
    EFI ?= BOOTRISCV64.EFI

    QBINARY ?= qemu-system-riscv64
    QMACHINE ?= virt
    QVC ?= -device ramfb

    FD ?= FD_RISCV

    BOOTS ?= UEFI

    BOOTLOADER_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -mcmodel=medany -mno-relax -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3
    KERNEL_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -mcmodel=medany -mno-relax -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3
else ifeq ($(ARCH),LoongArch64)
    BOOTLOADER_TRIPLE ?= loongarch64-none-elf
    KERNEL_TRIPLE ?= loongarch64-none-elf
    LLVM_TRIPLE ?= elf64loongarch

    UEFI_LINKER ?= flat
    UEFI_ENTRY ?= bootloader/uefi/headers/arch/loongarch64/entry
    KERNEL_ENTRY ?= kernel/headers/arch/loongarch64/entry
    WRAPPER ?= pe32p
    MACHINE ?= 0x6264
    EFI ?= BOOTLOONGARCH64.EFI

    QBINARY ?= qemu-system-loongarch64
    QMACHINE ?= virt
    QVC ?= -device ramfb

    FD ?= FD_LOONGARCH

    BOOTS ?= UEFI

    BOOTLOADER_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -mno-lsx -mno-lasx -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3
    KERNEL_CFLAGS ?= -I$(SOURCE) -std=c89 -nostdlib -mno-lsx -mno-lasx -funsigned-char -fshort-wchar -fpic -fpie -Weverything -fomit-frame-pointer -O3
else
    $(error Unsupported architecture: $(ARCH). Supported: x86_64, IA-32, ARM64, ARM32, RISC-V64, LoongArch64)
endif

UEFI_ENTRY_SYMBOL ?= _start

ifeq ($(filter $(BOOT),$(BOOTS)),)
    $(error Unsupported boot BOOT: $(BOOT) for $(ARCH). Supported: $(BOOTS))
endif

QCMDLINE ?= $(QBINARY) -M $(QMACHINE) $(QFLAGS) $(QCPU) $(QVC)

ifeq ($(BOOT),UEFI)
    QCMDLINE += -drive file="$$$(FD)",format=raw,readonly=true,if=pflash
endif

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

ifneq ($(filter x86_64 IA-32,$(ARCH)),)
	@$(MAKE) --no-print-directory stage1 || exit 1
endif
	@$(MAKE) --no-print-directory uefi || exit 1

	@printf "\n$(GREEN)$(BOLD)Finished building bootloader.$(RESET)\n"

stage2:
	@printf "\n$(BOLD)Building Stage 2..$(RESET)\n"

	@mkdir -p "$(BUILD)/bootloader/bios/stage2" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Assembling Stage 2..\n\n"

	set -x; set -x; llvm-mc -triple i386-none-elf -filetype obj "$(SOURCE)/bootloader/bios/stage2/main.s" -o "$(BUILD)/bootloader/bios/stage2/main.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Assemble Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled Stage 2.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking Stage 2..\n\n"

	set -x; set -x; ld.lld -m elf_i386 -T "$(SOURCE)/bootloader/bios/stage2/linker.ld" --oformat=binary "$(BUILD)/bootloader/bios/stage2/main.o" -o "$(BUILD)/bootloader/bios/stage2/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

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
		printf "\n$(RED)✘$(RESET) $(BOLD)Stage 2 is too large ($(SECTORS) sectors, max is 64).$(RESET)\n\n"; \
		exit 1; \
	fi

	@mkdir -p "$(BUILD)/bootloader/bios/stage1" "$(BUILD)/built"
	@printf "    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Assembling Stage 1..\n\n"

	set -x; set -x; llvm-mc -triple i386-none-elf -filetype obj -defsym SECTORS=$(SECTORS) -defsym DISK=$(DISK_SECTORS) "$(SOURCE)/bootloader/bios/stage1/main.s" -o "$(BUILD)/bootloader/bios/stage1/main.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Assemble Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled Stage 1.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking Stage 1..\n\n"

	set -x; set -x; ld.lld -m elf_i386 -T "$(SOURCE)/bootloader/bios/stage1/linker.ld" --oformat=binary "$(BUILD)/bootloader/bios/stage1/main.o" -o "$(BUILD)/bootloader/bios/stage1/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

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

	set -x; set -x; clang -target $(BOOTLOADER_TRIPLE) $(BOOTLOADER_CFLAGS) -c "$(SOURCE)/bootloader/uefi/main.c" -o "$(BUILD)/bootloader/uefi/main.o" -ferror-limit=0 || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to compile UEFI Bootloader. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Compiled UEFI Bootloader.\n"

ifdef UEFI_ENTRY
	@printf "\n    $(CYAN)→$(RESET) Assembling Entry..\n\n"

	set -x; set -x; clang -target $(BOOTLOADER_TRIPLE) -c "$(SOURCE)/$(UEFI_ENTRY).s" -o "$(BUILD)/bootloader/uefi/entry.o" -ferror-limit=0 || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to assemble Entry. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled Entry.\n"
endif

ifeq ($(UEFI_LINKER),lld-link)
	@printf "\n    $(CYAN)→$(RESET) Linking UEFI Bootloader..\n\n"

	set -x; set -x; lld-link /subsystem:efi_application /entry:$(UEFI_ENTRY_SYMBOL) /machine:$(MACHINE) $(UEFI_LINK_FLAGS) "$(BUILD)/bootloader/uefi/entry.o" "$(BUILD)/bootloader/uefi/main.o" -out:"$(BUILD)/bootloader/uefi/main.efi" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link UEFI Bootloader. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked UEFI Bootloader.\n"
ifeq ($(ARCH),ARM32)
	@printf "\n    $(CYAN)→$(RESET) Patching PE machine type (0x1C4 → 0x1C2)..\n\n"

	set -x; set -x; printf '\302\001' | dd of="$(BUILD)/bootloader/uefi/main.efi" bs=1 seek=$$(( $$(od -An -tu4 -j60 -N4 "$(BUILD)/bootloader/uefi/main.efi") + 4 )) conv=notrunc 2>/dev/null || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to patch PE machine type. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Patched PE machine type.\n"

	@printf "\n    $(CYAN)→$(RESET) Patching PE entry point..\n\n"

	set -x; set -x; PE_OFF=$$(od -An -tu4 -j60 -N4 "$(BUILD)/) && \
	ENTRY_OFF=$$(( PE_OFF + 40 )) && \
	ENTRY=$$(od -An -tu4 -j$$ENTRY_OFF -N4 "$(BUILD)/bootloader/uefi/main.efi") && \
	ENTRY_FIXED=$$(( ENTRY & ~1 )) && \
	printf "$$(printf '\\%03o\\%03o\\%03o\\%03o' $$(( ENTRY_FIXED & 0xFF )) $$(( (ENTRY_FIXED >> 8) & 0xFF )) $$(( (ENTRY_FIXED >> 16) & 0xFF )) $$(( (ENTRY_FIXED >> 24) & 0xFF )))" | dd of="$(BUILD)/bootloader/uefi/main.efi" bs=1 seek=$$ENTRY_OFF conv=notrunc 2>/dev/null || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to patch PE entry point. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Patched PE entry point.\n"
endif
else ifeq ($(UEFI_LINKER),flat)
	@printf "\n    $(CYAN)→$(RESET) Linking UEFI Bootloader..\n\n"

	set -x; set -x; ld.lld -m $(LLVM_TRIPLE) -T "$(SOURCE)/bootloader/uefi/linker.ld" --oformat=binary "$(BUILD)/bootloader/uefi/entry.o" "$(BUILD)/bootloader/uefi/main.o" -o "$(BUILD)/bootloader/uefi/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link UEFI Bootloader. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked UEFI Bootloader.\n"

	@printf "\n    $(CYAN)→$(RESET) Assembling PE/COFF Wrapper..\n\n"

	set -x; set -x; llvm-mc -triple x86_64-none-elf -filetype obj -I "$(BUILD)/bootloader/uefi" -defsym MACHINE=$(MACHINE) "$(SOURCE)/bootloader/uefi/$(WRAPPER).s" -o "$(BUILD)/bootloader/uefi/pecoff.o" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Assemble PE/COFF Wrapper. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled PE/COFF Wrapper.\n"

	@printf "\n    $(CYAN)→$(RESET) Linking PE/COFF Wrapper..\n\n"

	set -x; set -x; ld.lld -m elf_x86_64 --oformat=binary "$(BUILD)/bootloader/uefi/pecoff.o" -o "$(BUILD)/bootloader/uefi/main.efi" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link PE/COFF Wrapper. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Linked PE/COFF Wrapper.\n"
else
	$(error Unset or unrecognized UEFI_LINKER for ARCH=$(ARCH): "$(UEFI_LINKER)". Expected "lld-link" or "flat")
endif

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

	set -x; set -x; clang -target $(KERNEL_TRIPLE) $(KERNEL_CFLAGS) -c "$(SOURCE)/kernel/main.c" -o "$(BUILD)/kernel/main.o" -ferror-limit=0 || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Compile Kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Compiled Kernel.\n"

ifdef KERNEL_ENTRY
	@printf "\n    $(CYAN)→$(RESET) Assembling Entry..\n\n"

	set -x; set -x; clang -target $(KERNEL_TRIPLE) -c "$(SOURCE)/$(KERNEL_ENTRY).s" -o "$(BUILD)/kernel/entry.o" -ferror-limit=0 || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to assemble Entry. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Assembled Entry.\n"
endif

	@printf "\n    $(CYAN)→$(RESET) Linking Kernel..\n\n"

	set -x; set -x; ld.lld -m $(LLVM_TRIPLE) -T "$(SOURCE)/kernel/linker.ld" --oformat=binary "$(BUILD)/kernel/entry.o" "$(BUILD)/kernel/main.o" -o "$(BUILD)/kernel/main.bin" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to Link Kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

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
	@printf "\n    $(GREEN)✓$(RESET) Created directories.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating disk image..\n\n"

	set -x; set -x; dd bs=$(DISK_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Created disk image.\n"

ifneq ($(filter x86_64 IA-32,$(ARCH)),)
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

	set -x; set -x; dd bs=$(ESP_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Created ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting ESP image (FAT16)..\n\n"

	set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "EFI" "$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying filesystem..\n\n"

	set -x; set -x; mcopy -s -i "$(BUILD)/image/esp.img" "$(BUILD)/esp"/* ::/ || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy filesystem. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied filesystem.\n"

	@cp "$(BUILD)/image/esp.img" "$(BUILD)/built/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank kernel partition image..\n\n"

	set -x; set -x; dd bs=$(PART_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Created kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting kernel partition image (exFAT)..\n\n"

	set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "OS" "$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying kernel..\n\n"

	set -x; set -x; mcopy -i "$(BUILD)/image/partition.img" "$(BUILD)/built/kernel" ::/kernel || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied kernel.\n"

	@cp "$(BUILD)/image/partition.img" "$(BUILD)/built/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Partitioning disk image..\n\n"

	set -x; set -x; printf 'label: gpt\nstart=2048, size=$(ESP_SECTORS), type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\nstart=$(PART_START), size=$(PART_SECTORS), type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7\n' | sfdisk "$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to partition disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Partitioned disk image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing ESP filesystem into image..\n\n"

	set -x; set -x; dd bs=512 seek=2048 conv=notrunc if="$(BUILD)/image/esp.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write ESP filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Written ESP filesystem into image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing kernel filesystem into image..\n\n"

	set -x; set -x; dd bs=512 seek=$(PART_START) conv=notrunc if="$(BUILD)/image/partition.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write kernel filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Written kernel filesystem into image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing Stage 2..\n\n"

	set -x; set -x; dd conv=notrunc bs=512 seek=34 if="$(BUILD)/built/stage2.bin" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write Stage 2. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Written Stage 2.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing Stage 1..\n\n"

	set -x; set -x; dd conv=notrunc bs=512 count=1 if="$(BUILD)/built/stage1.bin" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write Stage 1. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Written Stage 1.\n"

else
	@if [ ! -f "$(BUILD)/built/$(EFI)" ]; then set -e; $(MAKE) --no-print-directory uefi; fi

	@mkdir -p "$(BUILD)/esp/EFI/BOOT"
	@printf "\n    $(GREEN)✓$(RESET) Created directories.\n"

	@cp "$(BUILD)/built/$(EFI)" "$(BUILD)/esp/EFI/BOOT/$(EFI)" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage EFI binary. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged EFI binary.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank ESP image..\n\n"

	set -x; set -x; dd bs=$(ESP_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Created ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting ESP image (FAT16)..\n\n"

	set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "EFI" "$(BUILD)/image/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying filesystem..\n\n"

	set -x; set -x; mcopy -s -i "$(BUILD)/image/esp.img" "$(BUILD)/esp"/* ::/ || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy filesystem. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied filesystem.\n"

	@cp "$(BUILD)/image/esp.img" "$(BUILD)/built/esp.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage ESP image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged ESP image.\n"

	@printf "\n    $(CYAN)→$(RESET) Creating blank kernel partition image..\n\n"

	set -x; set -x; dd bs=$(PART_SIZE) count=1 if=/dev/zero of="$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to create kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Created kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Formatting kernel partition image..\n\n"

	set -x; set -x; mkfs.fat -F 16 -S 512 -h 2048 -n "OS" "$(BUILD)/image/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to format kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Formatted kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Copying kernel..\n\n"

	set -x; set -x; mcopy -i "$(BUILD)/image/partition.img" "$(BUILD)/built/kernel" ::/kernel || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to copy kernel. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Copied kernel.\n"

	@cp "$(BUILD)/image/partition.img" "$(BUILD)/built/partition.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to stage kernel partition image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	@printf "\n    $(GREEN)✓$(RESET) Staged kernel partition image.\n"

	@printf "\n    $(CYAN)→$(RESET) Repartitioning disk image for UEFI..\n\n"

	set -x; set -x; printf 'label: gpt\nstart=2048, size=$(ESP_SECTORS), type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\nstart=$(PART_START), size=$(PART_SECTORS), type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7\n' | sfdisk "$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to repartition disk image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Repartitioned disk image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing ESP filesystem into image..\n\n"

	set -x; set -x; dd bs=512 seek=2048 conv=notrunc if="$(BUILD)/image/esp.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write ESP filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

	@printf "\n    $(GREEN)✓$(RESET) Written ESP filesystem into image.\n"

	@printf "\n    $(CYAN)→$(RESET) Writing kernel filesystem into image..\n\n"

	set -x; set -x; dd bs=512 seek=$(PART_START) conv=notrunc if="$(BUILD)/image/partition.img" of="$(BUILD)/image/disk.img" || { \
	    code=$$?; \
	    printf "\n$(RED)✘$(RESET) $(BOLD)Failed to write kernel filesystem into image. Exit $$code$(RESET)\n\n"; \
	    exit $$code; \
	}

	set +x

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

	set -x; set -x; $(QCMDLINE); code=$$?; set +x; \
	if [ "$$code" -ne 0 ]; then \
	    printf "\n    $(RED)✘$(RESET) Exited with error $$code.\n"; \
	else \
	    printf "\n    $(GREEN)✓$(RESET) Exited.\n"; \
	fi

	@printf "\n$(GREEN)$(BOLD)Exited.$(RESET) Debug log: $(DIM)$(LOG)$(RESET)\n"
