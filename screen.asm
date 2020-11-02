
screen:
.ptr = 0xB8000
.pos:
.cx db 0
.cy db 0
.attr db 0x0F;0xAB A=background B=foreground

screen.hex32:
        ror     eax,16
        call    screen.hex16
        ror     eax,16
        call    screen.hex16
        ret

screen.hex16:
        xchg    al,ah
        call    screen.hex8
        xchg    al,ah
        call    screen.hex8
        ret

screen.hex8:
        ror     al,4
        call    screen.hex4
        ror     al,4
        call    screen.hex4
        ret

screen.hex4:
        push    ax
        and     al,0x0F
        add     al,'0'
        cmp     al,'9'
        jle     .z
        add     al,'A'-'9'-1
.z:
        call    screen.putch
        pop     ax
        ret

screen.puts:
        push    eax
        push    esi
screen.puts.rr:
        mov     al,[esi]
        cmp     al,0
        je      screen.puts.re
        call    screen.putch
        inc     esi
        jmp     screen.puts.rr
screen.puts.re:
        pop     esi
        pop     eax
        ret

screen.putch: ;in=al
        cmp     al,0x08
        jne     screen.putch.n1
        cmp     byte[screen.cx],0
        jne     screen.putch.ne
        dec     byte[screen.cx]
        jmp     screen.putch.ne
screen.putch.n1:
        cmp     al,0x09
        jne     screen.putch.n2
        push    ax
        mov     al,byte[screen.cx]
        add     al,8
        and     al,(not 7)
        mov     byte[screen.cx],al
        pop     ax
        jmp     screen.putch.ne
screen.putch.n2:
        cmp     al,0x0D; \r
        jne     screen.putch.n3
        mov     byte[screen.cx],0
        jmp     screen.putch.ne
screen.putch.n3:
        cmp     al,0x0A; \n
        jne     screen.putch.n4
        mov     byte[screen.cx],0
        inc     byte[screen.cy]
        jmp     screen.putch.ne
screen.putch.n4:
        cmp     al,0x20; space
        jl      screen.putch.ne
        push    ebx
        push    esi
        push    eax
        push    eax
        xor     eax,eax
        mov     al,byte[screen.cy]
        mov     bl,80
        mul     bl
        mov     bh,0
        mov     bl,byte[screen.cx]
        add     bx,ax
        xor     eax,eax
        add     ax,bx
        add     ax,bx
        mov     esi,screen.ptr
        pop     ebx
        mov     bh,byte[screen.attr]
        mov     word[esi+eax],bx
        pop     eax
        pop     esi
        pop     ebx
        inc     byte[screen.cx]
screen.putch.ne:
        cmp     byte[screen.cx],80
        jl      screen.putch.nn
        mov     byte[screen.cx],0
        inc     byte[screen.cy]
screen.putch.nn:
        call    screen.move_cursor
        ret

screen.move_cursor:
        ret
        push    ax
        push    bx
        push    dx
        mov     al,byte[screen.cy]
        mov     bl,80
        mul     bl
        mov     bh,0
        mov     bl,byte[screen.cx]
        add     bx,ax
        mov     al,14
        mov     dx,0x03D4
        out     dx,al
        mov     al,bh
        mov     dx,0x03D5
        out     dx,al
        mov     al,15
        mov     dx,0x03D4
        out     dx,al
        mov     al,bl
        mov     dx,0x03D5
        out     dx,al
        pop     dx
        pop     bx
        pop     ax
        ret

screen.cls:
        push    eax
        push    esi
        mov     esi,screen.ptr
        mov     eax,0
.z:
        mov     word[esi+eax],0x0F20
        add     ax,2
        cmp     ax,80*25
        jne     .z
        mov     byte[screen.cx],0
        mov     byte[screen.cy],0
        call    screen.move_cursor
        pop     esi
        pop     eax
        ret


