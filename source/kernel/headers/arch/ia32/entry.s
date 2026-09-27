# source/kernel/headers/arch/ia32/entry.s

.global _start

.extern kmain

.section .text._start, "ax", @progbits
_start:
    call kmain

    ret
