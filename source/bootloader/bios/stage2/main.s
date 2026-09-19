# source/bootloader/bios/stage2/main.s

.global _entry

.section .text, "ax", @progbits

.code16

.equ COM1, 0x3F8

.macro puts string
    movw $\string, %si
    movw $COM1+5, %dx

.Lp_\@_loop:
    lodsb
    testb %al, %al
    jz .Lp_\@_done
    movb %al, %cl

.Lp_\@_wait:
    inb %dx, %al
    testb $0x20, %al
    jz .Lp_\@_wait
    subb $5, %dl
    movb %cl, %al
    outb %al, %dx
    addb $5, %dl
    jmp .Lp_\@_loop

.Lp_\@_done:
.endm

_entry:
    movb %dl, disk # Save Disk Number

    puts msg

halt:
    hlt

    jmp halt

.section .rodata, "a", @progbits

msg:
    .asciz "Stage 2: Hello, world!\r\n"

.section .data, "aw", @progbits

disk:
    .byte 0
