
GDT_Start:          ; Create a global descriptor table
    null_descriptor:
        dd 0x0 ; 8 bits of zeros
        dd 0x0
    code_descriptor:
        dw 0xFFFF ; Limit (16 bits)
        dw 0x0 ; Base (24 bits in total) (16 bits)
        db 0x0 ; Base (8 bits)
        db 10011010b ; First 4 bits: present, priviledge, type. Last 4 bits: Type flags
        db 11001111b ; Other flags (4 bits) + Limit (4 bits)
        db 0x0 ; Base (8 bits)
    data_descriptor:
        dw 0xFFFF ; Limit (16 bits)
        dw 0x0 ; Base (24 bits in total) (16 bits)
        db 0x0 ; Base (8 bits)
        db 10010010b ; First 4 bits: present, priviledge, type. Last 4 bits: Type flags
        db 11001111b ; Other flags (4 bits) + Limit (4 bits)
        db 0x0 ; Base (8 bits)
GDT_End:
GDT_Descriptor:
    dw GDT_End - GDT_Start - 1 ; Size of GDT
    dd GDT_Start ; Start address of GDT
CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start