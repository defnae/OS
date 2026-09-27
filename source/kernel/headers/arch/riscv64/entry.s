# source/kernel/headers/arch/riscv64/entry.s

.global _start

.extern kmain

.section .text._start, "ax", @progbits

_start:
    tail kmain
