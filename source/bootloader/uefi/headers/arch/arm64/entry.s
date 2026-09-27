# source/bootloader/uefi/headers/arch/arm64/entry.s

.global _start

.extern efi_main

.section .text._start, "ax"

.align 2

_start:
    b efi_main
