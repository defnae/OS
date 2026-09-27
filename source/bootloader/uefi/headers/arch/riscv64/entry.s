# source/bootloader/uefi/headers/arch/riscv64/entry.s

.global _start

.extern efi_main

.section .text._start, "ax", @progbits

_start:
    tail efi_main
