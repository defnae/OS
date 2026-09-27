/* source/bootloader/bios/stage2/linker.ld */

PHDRS {
    text PT_LOAD FLAGS(5);
    rodata PT_LOAD FLAGS(4);
    data/bss PT_LOAD FLAGS(6);
}

ENTRY(_start)

SECTIONS {
    . = 0x7E00;

    .text : {
        *(.text._start) *(.text) *(.text.*)
    } : text

    .rodata ALIGN(0x1000) : {
        *(.rodata) *(.rodata.*)
    } : rodata

    .data ALIGN(0x1000) : {
        *(.data) *(.data.*)
    } : data/bss

    .bss ALIGN(0x1000) : {
        *(.bss) *(.bss.*) *(COMMON)
    } : data/bss

    .shstrtab : { *(.shstrtab) }

    /DISCARD/ : { *(*) }
}
