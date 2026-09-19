# source/bootloader/uefi/pe32.s (PE32, 32-bit machines)

.ifndef MACHINE
.equ MACHINE, 0x14c # Default: IA-32
.endif

.equ SECTALIGN, 0x20
.equ FILEALIGN, 0x20

.section ., "awx", @progbits

pecoff_start:

# DOS Header

.ascii "MZ"
.fill 0x3C - (. - pecoff_start), 1, 0
.long pe_header - pecoff_start # e_lfanew

.align 4

pe_header:

.ascii "PE\0\0"

# COFF File Header

.word MACHINE
.word 1 # NumberOfSections
.long 0 # TimeDateStamp
.long 0 # PointerToSymbolTable
.long 0 # NumberOfSymbols
.word optional_header_end - optional_header # SizeOfOptionalHeader
.word 0x0102 # Characteristics (EXECUTABLE_IMAGE | 32BIT_MACHINE)

optional_header:

.word 0x010B # Magic (PE32)
.byte 0 # MajorLinkerVersion
.byte 0 # MinorLinkerVersion
.long text_raw_end - text_raw_start # SizeOfCode
.long 0 # SizeOfInitializedData
.long 0 # SizeOfUninitializedData
.long text_rva - pecoff_start # AddressOfEntryPoint
.long text_rva - pecoff_start # BaseOfCode
.long text_rva - pecoff_start # BaseOfData (PE32 only, no PE32+ equivalent)
.long 0x400000 # ImageBase (32-bit here, not 8 bytes like PE32+)
.long SECTALIGN # SectionAlignment
.long FILEALIGN # FileAlignment
.word 0 # MajorOperatingSystemVersion
.word 0 # MinorOperatingSystemVersion
.word 0 # MajorImageVersion
.word 0 # MinorImageVersion
.word 0 # MajorSubsystemVersion
.word 0 # MinorSubsystemVersion
.long 0 # Win32VersionValue
.long image_end - pecoff_start # SizeOfImage
.long text_rva - pecoff_start # SizeOfHeaders
.long 0 # CheckSum
.word 10 # Subsystem (EFI_APPLICATION)
.word 0 # DllCharacteristics
.long 0x100000 # SizeOfStackReserve
.long 0x1000 # SizeOfStackCommit
.long 0x100000 # SizeOfHeapReserve
.long 0x1000 # SizeOfHeapCommit
.long 0 # LoaderFlags
.long 0 # NumberOfRvaAndSizes (no data directories)

optional_header_end:

# Section Header: .text

.ascii ".text\0\0\0"
.long text_raw_end - text_raw_start # VirtualSize
.long text_rva - pecoff_start # VirtualAddress
.long text_raw_end - text_raw_start # SizeOfRawData
.long text_rva - pecoff_start # PointerToRawData
.long 0 # PointerToRelocations
.long 0 # PointerToLinenumbers
.word 0 # NumberOfRelocations
.word 0 # NumberOfLinenumbers
.long 0xE0000020 # Characteristics (CODE | EXECUTE | READ | WRITE)

.align FILEALIGN

text_rva:
text_raw_start:

.incbin "build/bootloader/uefi/main.bin"

text_raw_end:

.align SECTALIGN

image_end:
