# source/bootloader/uefi/headers/arch/arm32/entry.s

.global _start

.extern efi_main

.section .text._start, "ax"

.align 2

_start:
    .long 0xe59f3000 @ldr r3, [pc, #0] Load word into r3
    .long 0xe12fff13 @bx r3 Switch to Thumb if r3 bit 0 set
    .long efi_main
