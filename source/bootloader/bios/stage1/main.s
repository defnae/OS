# source/bootloader/bios/stage1/main.s

.global _start

.section ., "awx", @progbits

.code16

.equ LBA_START, 34
.ifndef SECTORS
.equ SECTORS, 64
.endif

.equ LOAD_SEG, 0x0000
.equ LOAD_OFF, 0x7E00

.equ TARGET, 0x00007E00
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

_start:
    cli # Clear Interrupts

    ljmp $0x0000, $seginit # Normalize Code Segment (CS)

seginit:
    xorw %ax, %ax # Clear AX

    movw %ax, %ds # Clear Data Segment (DS)
    movw %ax, %es # Clear Extra Segment (ES)

    movw %ax, %ss # Clear Stack Segment (SS)

stackinit:
    movw $0x7C00, %sp # Set Stack Pointer

    movb %dl, disk # Save Disk Number

init:
    movw $COM1+1, %dx
    xorb %al, %al
    outb %al, %dx # Disable Interrupts (IER)

    movb $0x80, %al
    incw %dx
    incw %dx # COM1+3 (LCR)
    outb %al, %dx # Enable DLAB

    subw $3, %dx # COM1+0 (Divisor LSB)
    movb $0x0C, %al
    outb %al, %dx # 9600 Baud LSB (12)

    incw %dx # COM1+1 (Divisor MSB)
    xorb %al, %al
    outb %al, %dx # Baud MSB = 0

    incw %dx
    incw %dx # COM1+3 (LCR)
    movb $0x03, %al
    outb %al, %dx # 8N1, DLAB off

    decw %dx # COM1+2 (FCR)
    movb $0xC7, %al
    outb %al, %dx # Enable FIFOs

    incw %dx
    incw %dx # COM1+4 (MCR)
    movb $0x0B, %al
    outb %al, %dx # RTS/DTR Active

    puts msg

load:
    movb disk, %dl
    movw $dap, %si
    movb $0x42, %ah

    int $0x13

    jc error

    puts loaded

    movb disk, %dl

    jmp TARGET

error:
    puts fail

halt:
    hlt
    jmp halt

msg:
    .asciz "Stage 1: Hello, world!\r\n"
loaded:
    .asciz "Stage 1: Second Stage Loaded.\r\n"
fail:
    .asciz "Stage 1: Failed to Read Disk.\r\n"

disk:
    .byte 0

dap:
    .byte 0x10
    .byte 0x00

    .word SECTORS
    .word LOAD_OFF
    .word LOAD_SEG

    .long LBA_START
    .long 0

.fill 446 - (. - _start), 1, 0 # Padding

# Protective MBR

.byte 0x00 # Boot Indicator (0x00 = Inactive)
.byte 0x00, 0x02, 0x00 # Starting CHS (0/0/2)
.byte 0xEE # Partition Type (0xEE = GPT Protective)
.byte 0xFF, 0xFF, 0xFF # Ending CHS (Maximum)
.long 0x00000001 # Starting LBA (Sector 1, GPT Header)
.long 0x000007FF # Sector Count

.fill 16, 1, 0 # Second Partition Entry (Empty)

.fill 16, 1, 0 # Third Partition Entry (Empty)

.fill 16, 1, 0 # Fourth Partition Entry (Empty)

.word 0xAA55 # MBR Magic
