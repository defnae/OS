# source/bootloader/uefi/headers/arch/ia32/entry.s

.global _start

.extern _efi_main

.section .text._start, "ax"
_start:
    jmp _efi_main
