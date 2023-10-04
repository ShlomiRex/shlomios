org 0x7c00  ; This sets the origin of the program to 0x7C00, which is the standard location for a bootloader.

section .text
start:
    ; Set up the video mode (mode 3, 80x25 text mode)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Set cursor position (row = 0, column = 0)
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 0x00
    mov dl, 0x00
    int 0x10

    ; Print 'Hello, World!' to the screen
    mov si, hello_string
print_char:
    lodsb          ; Load the next character from [si] into AL and increment SI
    test al, al    ; Check if it's the null terminator (end of string)
    jz done        ; If it is, we are done
    mov ah, 0x0E   ; Video teletype function (print character)
    mov bh, 0x00   ; Page number (0 for mode 3)
    mov bl, 0x07   ; Text attribute (white on black)
    int 0x10       ; Call BIOS interrupt to print character
    jmp print_char ; Continue printing the next character

done:
    ; Infinite loop to halt the CPU
    cli
    hlt

hello_string:
    db 'Hello, World!',0  ; Null-terminated string

times 510-($-$$) db 0  ; Fill the rest of the 512-byte boot sector with zeros
dw 0xAA55              ; Boot signature to indicate a valid boot sector
