/* source/bootloader/uefi/linker.ld */

PHDRS {
    text PT_LOAD FLAGS(5);
    rodata PT_LOAD FLAGS(4);
    data/bss PT_LOAD FLAGS(6);
}

ENTRY(_start)

SECTIONS {
    . = 0x0;

    .text : {
        *(.text._start) *(.text.efi_main) *(.text) *(.text.*)
    } : text

    .rodata ALIGN(0x1000) : {
        *(.rodata) *(.rodata.*)
    } : rodata

    .data ALIGN(0x1000) : {
        *(.data) *(.data.*) *(.sdata) *(.sdata.*)
    } : data/bss

    .bss ALIGN(0x1000) : {
        *(.bss) *(.bss.*) *(.sbss) *(.sbss.*) *(COMMON)
    } : data/bss

    .shstrtab : { *(.shstrtab) }

    /DISCARD/ : { *(*) }
}
