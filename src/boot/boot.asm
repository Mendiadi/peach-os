ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0 ; create 33 bytes after the short jmp

start:
    jmp 0:step2


step2:
    cli ;clear interrupts flags
    mov ax , 0x7c0
    mov ds, ax
    mov es, ax
    mov ss, ax ; set stack segment to be 0
    mov sp, 0x7c00
    sti ;enables interrupts flags
    

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 11001111b
    db 0

gdt_data:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 11001111b
    db 0
gdt_end:


gdt_descriptor:
    dw gdt_start - gdt_end-1
    dd gdt_start

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    in al, 0x92
    or al, 2
    out 0x92, al
 
    jmp $

times 510-($-$$) db 0 ; says we need to fill atleast 510 bytes of data
                      ; pad the extra 10 bytes with zeros - thats allowed us to go dw
                      ; and add are boot signature here
dw 0xAA55 ; put thats in binary stright to our file


; nasm from terminal$ nasm -f bin ./boot.asm -o ./boot.bin

;ndisasm ./boot.bin >> terminal bin 

; run on vm command >>$ qemu-system-x86_64 -hda ./boot.bin
