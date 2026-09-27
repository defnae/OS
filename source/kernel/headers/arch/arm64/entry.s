# source/kernel/headers/arch/arm64/entry.s

.global _start

.extern kmain

.section .text._start, "ax", @progbits

.align 2

_start:
    b kmain
