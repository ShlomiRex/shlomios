[global Start]
[BITS 16]
[ORG 0x7C00]

section .text

Start:
    ; Initialize segments
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; DL stores the current drive number, save in variable
    mov [BOOT_DRIVE], dl

    ; Initialize the stack
    mov bp, 0x7C00
    mov sp, bp

    ; Print hello message
    call ClearScreen
    mov SI, hello_msg
    call PrintString

    ; Check A20 line
    ; call check_a20
    ; cmp ax, 1
    ; je A20Enabled
    ; mov SI, a20_disabled_msg
    ; call PrintString
    ; call PrintNewLine
    ;call EnableA20
    
    ; Read kernel - read 20 sectors. This might cause issues later, but for now our kernel is less than 10 MegaBytes.
    xor ax, ax
    mov es, ax
    mov ds, ax
    
    mov bx, KERNEL_ADDRESS
    mov dh, 20
    mov ah, 2
    mov al, dh
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc DiskError
    jmp NoDiskError

    DiskError:
        mov SI, disk_error_msg
        call PrintString
        call PrintNewLine

        ; Error code
        mov al, ah
        mov ah, 0
        call Print2Hex
        jmp $
    NoDiskError:
        mov SI, ok_msg
        call PrintString
        call PrintNewLine
        jmp EnterProtectedMode
; EnableA20: ; Fast A20 method
;     in al, 0x92
;     or al, 2
;     out 0x92, al
;     ret
; check_a20:
;     pushf
;     push ds
;     push es
;     push di
;     push si
 
;     cli
 
;     xor ax, ax ; ax = 0
;     mov es, ax
 
;     not ax ; ax = 0xFFFF
;     mov ds, ax
 
;     mov di, 0x0500
;     mov si, 0x0510
 
;     mov al, byte [es:di]
;     push ax
 
;     mov al, byte [ds:si]
;     push ax
 
;     mov byte [es:di], 0x00
;     mov byte [ds:si], 0xFF
 
;     cmp byte [es:di], 0xFF
 
;     pop ax
;     mov byte [ds:si], al
 
;     pop ax
;     mov byte [es:di], al
 
;     mov ax, 0
;     je check_a20__exit
 
;     mov ax, 1
 
; check_a20__exit:
;     pop si
;     pop di
;     pop es
;     pop ds
;     popf
 
;     ret
%include "pm.asm"
%include "gdt.asm"
%include "bios.asm"


BOOT_DRIVE db 0
KERNEL_ADDRESS equ 0x1000 ; Don't start at 0 to avoid overwriting interrupt vector table of the BIOS
hello_msg db "Running in 16-bit real mode...", 0
ok_msg db "OK", 0
disk_error_msg db "Error reading disk, error code: ", 0
; a20_enabled_msg db "A20 line enabled", 0
; a20_disabled_msg db "A20 line disabled", 0

times 510 - ($ - $$) db 0
dw 0xAA55
