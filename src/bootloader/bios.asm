[BITS 16]

Print4Hex:
    ; Input AX register, BL register
    ; Output: None
    ; Prints the hex value of AX register (4 nibbles). Example: AX=0x1234 will print: 0x1234
    ; If you don't want to print prefix '0x' then set BL=1, else set BL=0. Example: AX=0x1234, BL=1 will print: 1234
    push ax

    shr ax, 8
    mov ah, bl ; Print prefix according to BL input for first byte
    call Print2Hex

    ; Print low byte
    pop ax
    mov ah, 1 ; Here we don't need to print prefix
    call Print2Hex

    ret

Print2Hex:
    ; Input: AL register, AH register
    ; Output: None
    ; Print the hex value of AL register (2 nibbles). Example: AL=0x12 will print: 0x12
    ; If you don't want to print prefix '0x' then set AH=1, else set AH=0. Example: AL=0x12, AH=1 will print: 12
    cmp ah, 1
    je .no_prefix
    ; Print hex prefix
    push ax
    mov al, '0'
    call PrintCharacter
    mov al, 'x'
    call PrintCharacter
    pop ax ; Get the argument
    .no_prefix:

    ; Print high nibble
    call ALToHex
    push ax ; Store for low nibble printing later on
    mov al, ah ; Move high nibble to AL, since the PrintCharacter procedure expects the character in AL
    ; Check if nibble is greater than 0x9. If it does, then we need offset of 0x41 to get 'A' in ASCII. Else, we need offset of 0x30 to get '0' in ASCII.
    cmp al, 0xA
    jl .finish
    add al, 0x7
    .finish:
    add al, 0x30
    call PrintCharacter

    ; Print low nibble
    pop ax
    cmp al, 0xA
    jl .finish2
    add al, 0x7
    .finish2:
    add al, 0x30
    call PrintCharacter

    ret

ALToHex:
    ; Input: AL register
    ; Output: AX register
    ; Convert a number in AL to hex nibbles. Example: 256 -> 0xAB. The high nibble (0xA) is stored in AH and the low nibble (0xB) in AL
    push ax ; Save AL
    ; Get high nibble of AL, store in DH for later retrieval
    and al, 0xF0
    shr al, 4
    mov dh, al
    
    pop ax
    ; Get low nibble of AL, store in AL
    and al, 0x0F
    
    mov ah, dh ; Retrieve high nibble from DH to AH
    ret
PrintCharacter:                         ;Procedure to print character on screen
                                        ;Assume that ASCII value is in register AL
    mov ah, 0x0E                        ;Tell BIOS that we need to print one charater on screen.
    mov bh, 0x00                        ;Page no.
    mov bl, 0x07                        ;Text attribute 0x07 is lightgrey font on black background
    int 0x10                            ;Call video interrupt
    ret                                 ;Return to calling procedure
PrintString:                            ;Procedure to print string on screen
                                        ;Assume that string starting pointer is in register SI
    .next_character:                     ;Lable to fetch next character from string
        mov al, [SI]                    ;Get a byte from string and store in AL register
        inc SI                          ;Increment SI pointer
        or AL, AL                       ;Check if value in AL is zero (end of string)
        jz .exit_function                ;If end then return
        call PrintCharacter             ;Else print the character which is in AL register
        jmp .next_character              ;Fetch next character from string
        .exit_function:                  ;End label
        ret                             ;Return from procedure
PrintNewLine:
    ; Print new line
    mov al, 0x0D
    call PrintCharacter
    mov al, 0x0A
    call PrintCharacter
    ret
ClearScreen:
    mov ah, 0x0
    mov al, 0x3
    int 0x10
    ret
DiskErrorMessage db "Error reading disk, error code: ", 0
