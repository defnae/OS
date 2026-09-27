# source/kernel/headers/arch/x86_64/entry.s

.global _start

.extern kmain

.section .text._start, "ax", @progbits
_start:
    subq $40, %rsp

    call kmain

    addq $40, %rsp

    ret
