// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

const char kbd_map[256] = "\0\27"
                          "1234567890-="
                          "\b\t"
                          "qwertyuiop[]"
                          "\x0a\0"
                          "asdfghjkl;'`"
                          "\0"
                          "\\zxcvbnm,./"
                          "\0*\0 ";

uint8_t kbd_bufs = 0;
uint8_t kbd_bufe = 0;
uint8_t kbd_buf[256];

/*-kbd.irq:
-        xor     eax,eax
-        in      al,0x60
-        bt      ax,7
-        jc      .z
-        xor     ebx,ebx
-        mov     bl,[kbd.bufe]
-        mov     [kbd.buf+ebx],al
-        inc     byte[kbd.bufe]
-.z:
-        ret
-kbd.getch:
-        xor     eax,eax
-        jmp     .z
-.zz:
-        hlt
-.z:
-        mov     al,byte[kbd.bufs]
-        cmp     al,byte[kbd.bufe]
-        je      .zz
-        inc     byte[kbd.bufs]
-        mov     al,[kbd.buf+eax]
-        mov     al,byte[kbd.codes+eax]
-        call    screen.putch
-        ret
-kbd.gets: ;esi=buf
-        push    eax
-        push    esi
-.nxt:
-        call    kbd.getch
-        cmp     al,0x0a
-        je      .e
-        mov     [esi],al
-        inc     esi
-        jmp     .nxt
-.e:
-        mov     byte[esi],0
-        pop     esi
-        pop     eax
-        ret
-*/

void kbd_handler(void)
{
    uint8_t c = in_byte(0x60);
    if (!(c & 0x80))
        kbd_buf[kbd_bufe++] = c;
    processes_sync();
}

uint8_t readchar(void)
{
    debug();
    while (kbd_bufs == kbd_bufe)
        hlt();
    uint8_t c = kbd_buf[kbd_bufs++];
    c = kbd_map[c];
    return c;
}

uint8_t getchar(void)
{
    uint8_t c = readchar();
    putchar(c);
    return c;
}

uint16_t gets(uint8_t *buf, int sz)
{
    uint16_t x = 0;
    uint8_t c;
    while (x < sz - 1)
    {
        c = readchar();
        if (c == '\n')
        {
            putchar(c);
            break;
        }
        if (c == '\b')
        {
            if (x)
            {
                putchar(c);
                buf[--x] = 0;
            }
            continue;
        }
        else
            putchar(c);
        buf[x++] = c;
    }
    buf[x] = 0;
    return x;
}
