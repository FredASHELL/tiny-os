org 0x7C00

jmp start

buffer times 32 db 0

start:
    mov si, welcome
    call print_string

shell:
    mov si, prompt
    call print_string

    mov di, buffer
    call read_line

    ; help
    mov si, buffer
    mov di, cmd_help
    call strcmp
    cmp al, 1
    je do_help

    ; hello
    mov si, buffer
    mov di, cmd_hello
    call strcmp
    cmp al, 1
    je do_hello

    ; clear
    mov si, buffer
    mov di, cmd_clear
    call strcmp
    cmp al, 1
    je do_clear

    ; game
    mov si, buffer
    mov di, cmd_game
    call strcmp
    cmp al, 1
    je do_game

    ; gfx
    mov si, buffer
    mov di, cmd_gfx
    call strcmp
    cmp al, 1
    je do_gfx

    mov si, unknown
    call print_string
    jmp shell

; ---------------- COMMANDS ----------------

do_help:
    mov si, help_text
    call print_string
    jmp shell

do_hello:
    mov si, hello_text
    call print_string
    jmp shell

do_clear:
    mov ax, 0x0003
    int 0x10
    jmp shell

do_game:
    mov si, game_intro
    call print_string

    mov ah, 0
    int 0x16
    mov bl, al

    mov ah, 0x0E
    mov al, bl
    int 0x10

    mov al, 13
    int 0x10
    mov al, 10
    int 0x10

    cmp bl, '5'
    je win

lose:
    mov si, lose_text
    call print_string
    jmp shell

win:
    mov si, win_text
    call print_string
    jmp shell

do_gfx:
    ; VGA mode 13h (320x200 256 colors)
    mov ax, 0x0013
    int 0x10

    mov ax, 0xA000
    mov es, ax

    xor di, di
    xor dl, dl

draw:
    mov al, dl
    stosb
    inc dl
    cmp di, 64000
    jne draw

wait_key:
    mov ah, 0
    int 0x16

    mov ax, 0x0003
    int 0x10

    jmp shell

; ---------------- PRINT STRING ----------------

print_string:
    mov ah, 0x0E

.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next

.done:
    ret

; ---------------- READ LINE ----------------

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

    mov ah, 0x0E
    mov al, 8
    int 0x10

    mov al, ' '
    int 0x10

    mov al, 8
    int 0x10

    jmp .read

.done:
    mov al, 0
    stosb

    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10

    ret

; ---------------- STRING COMPARE ----------------

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

welcome db "TinyOS v1.0",13,10
        db "TinyOS comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law.",13,10
        db "Type help for commands",13,10,13,10,0

prompt db "user@tinyos $ ",0

unknown db "Unknown command",13,10,0

help_text db "help hello clear game gfx",13,10,0
hello_text db "Hello!",13,10,0

game_intro db "Guess 0-9: ",0
win_text db "You win!",13,10,0
lose_text db "Wrong!",13,10,0

cmd_help db "help",0
cmd_hello db "hello",0
cmd_clear db "clear",0
cmd_game db "game",0
cmd_gfx db "gfx",0

times 510-($-$$) db 0
dw 0xAA55
