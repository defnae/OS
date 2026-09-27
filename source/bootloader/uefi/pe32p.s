# source/bootloader/uefi/pe32p.s

.ifndef MACHINE
.equ MACHINE, 0x8664 # Default: x86_64
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
.word 2 # NumberOfSections
.long 0 # TimeDateStamp
.long 0 # PointerToSymbolTable
.long 0 # NumberOfSymbols
.word optional_header_end - optional_header # SizeOfOptionalHeader
.word 0x0022 # Characteristics (EXECUTABLE_IMAGE | LARGE_ADDRESS_AWARE)

optional_header:

.word 0x020B # Magic (PE32+)
.byte 0 # MajorLinkerVersion
.byte 0 # MinorLinkerVersion
.long text_raw_end - text_raw_start # SizeOfCode
.long 0 # SizeOfInitializedData
.long 0 # SizeOfUninitializedData
.long text_rva - pecoff_start # AddressOfEntryPoint
.long text_rva - pecoff_start # BaseOfCode
.quad 0x140000000 # ImageBase
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
.word 0x0040 # DllCharacteristics (IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE)
.quad 0x100000 # SizeOfStackReserve
.quad 0x1000 # SizeOfStackCommit
.quad 0x100000 # SizeOfHeapReserve
.quad 0x1000 # SizeOfHeapCommit
.long 0 # LoaderFlags
.long 1 # NumberOfRvaAndSizes (one data directory: base relocations)

# Data Directories

.long reloc_rva - pecoff_start # [5] Base Relocation Table RVA
.long reloc_raw_end - reloc_rva # [5] Base Relocation Table Size

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

# Section Header: .reloc

.ascii ".reloc\0\0"
.long reloc_raw_end - reloc_rva # VirtualSize
.long reloc_rva - pecoff_start # VirtualAddress
.long reloc_raw_end - reloc_rva # SizeOfRawData
.long reloc_rva - pecoff_start # PointerToRawData
.long 0 # PointerToRelocations
.long 0 # PointerToLinenumbers
.word 0 # NumberOfRelocations
.word 0 # NumberOfLinenumbers
.long 0x42000040 # Characteristics (DISCARDABLE | READ)

.align FILEALIGN

text_rva:
text_raw_start:

.incbin "main.bin"

text_raw_end:

.align SECTALIGN

reloc_rva:

.long 0 # PageRVA
.long 8 # SizeOfBlock (header only, zero entries)

reloc_raw_end:

.align SECTALIGN

image_end:
