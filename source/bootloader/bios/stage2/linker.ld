/* source/bootloader/bios/stage2/linker.ld */

PHDRS {
    text PT_LOAD FLAGS(5);
    rodata PT_LOAD FLAGS(4);
    data PT_LOAD FLAGS(6);
    bss PT_LOAD FLAGS(6);
}

ENTRY(_start)

SECTIONS {
    . = 0x7E00;

    .text : {
        *(.text) *(.text.*)
    } : text

    .rodata ALIGN(0x1000) : {
        *(.rodata) *(.rodata.*)
    } : rodata

    .data ALIGN(0x1000) : {
        *(.data) *(.data.*)
    } : data

    .bss ALIGN(0x1000) : {
        *(.bss) *(.bss.*) *(COMMON)
    } : bss

    .shstrtab : { *(.shstrtab) }

    /DISCARD/ : { *(*) }
}
