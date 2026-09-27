# source/bootloader/uefi/headers/arch/x86_64/entry.s

.global _start

.extern efi_main

.section .text._start, "ax"
_start:
    subq $40, %rsp

    call efi_main

    addq $40, %rsp

    ret
