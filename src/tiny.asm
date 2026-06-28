org 0x7C00

jmp start

buffer times 64 db 0

; ---------------- START ----------------

start:
    mov si, bootmsg
    call print_string

main:
    mov si, prompt
    call print_string

    mov di, buffer
    call read_line

    ; HELP
    mov si, buffer
    mov di, cmd_help
    call strcmp
    cmp al, 1
    je help

    ; HELLO
    mov si, buffer
    mov di, cmd_hello
    call strcmp
    cmp al, 1
    je hello

    ; CLEAR SCREEN
    mov si, buffer
    mov di, cmd_clear
    call strcmp
    cmp al, 1
    je clear

    ; INFO
    mov si, buffer
    mov di, cmd_info
    call strcmp
    cmp al, 1
    je info

    ; GAME
    mov si, buffer
    mov di, cmd_game
    call strcmp
    cmp al, 1
    je game

    ; UNKNOWN
    mov si, unknown
    call print_string
    jmp main

; ---------------- COMMANDS ----------------

help:
    mov si, help_text
    call print_string
    jmp main

hello:
    mov si, hello_text
    call print_string
    jmp main

clear:
    mov ax, 0x0003
    int 0x10
    jmp main

info:
    mov si, info_text
    call print_string
    jmp main

game:
    mov si, game_text
    call print_string

    mov ah, 0
    int 0x16
    mov bl, al

    mov si, result_text
    call print_string

    mov ah, 0x0E
    mov al, bl
    int 0x10

    mov al, 13
    int 0x10
    mov al, 10
    int 0x10

    jmp main

; ---------------- FUNCTIONS ----------------

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

read_line:
.read:
    mov ah, 0
    int 0x16

    cmp al, 13
    je .done

    cmp al, 8
    je .backspace

    stosb

    mov ah, 0x0E
    int 0x10
    jmp .read

.backspace:
    cmp di, buffer
    je .read

    dec di

    mov al, 8
    mov ah, 0x0E
    int 0x10

    mov al, ' '
    int 0x10

    mov al, 8
    int 0x10

    jmp .read

.done:
    mov al, 0
    stosb

    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

strcmp:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .no
    cmp al, 0
    je .yes
    inc si
    inc di
    jmp .loop
.yes:
    mov al, 1
    ret
.no:
    mov al, 0
    ret

; ---------------- STRINGS ----------------

bootmsg db "TinyOS 1.0 JAM",13,10,0
bootmsg db "TinyOS comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law."
prompt db "os> ",0

unknown db "Unknown command",13,10,0

help_text db "help hello clear info game",13,10,0
hello_text db "Hello!",13,10,0
info_text db "TinyOS single-file kernel",13,10,0
game_text db "Press any key:",13,10,0
result_text db "You pressed: ",0

cmd_help db "help",0
cmd_hello db "hello",0
cmd_clear db "clear",0
cmd_info db "info",0
cmd_game db "game",0

; ---------------- BOOT SIGNATURE ----------------
times 510-($-$$) db 0
dw 0xAA55
