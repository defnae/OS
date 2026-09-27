# source/bootloader/uefi/headers/arch/loongarch64/entry.s

.global _start

.extern efi_main

.section .text._start, "ax", @progbits

_start:
    b efi_main
