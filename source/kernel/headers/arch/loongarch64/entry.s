# source/kernel/headers/arch/loongarch64/entry.s

.global _start

.extern kmain

.section .text._start, "ax", @progbits

_start:
    b kmain
