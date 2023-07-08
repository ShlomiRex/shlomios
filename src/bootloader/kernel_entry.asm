; This program will be compiled into an ELF object file, since we need to link it.
; It will be loaded into kernel position we defined in our bootloader.

[BITS 32]
[extern main]

call main
jmp $
