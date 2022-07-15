
format coff

extrn _boios_main
extrn _puts

section '.boot' code data
org 0x7c00
use16
public main16
main16:
        jmp     0:.z
.z:
        cli
        call    nmi_disable
        xor     eax,eax
        mov     ds,ax
        mov     eax,0x08
        mov     ss,ax
        mov     esp,0xF000
        lgdt    [gdtx]
        mov     eax,cr0
        or      eax,1
        mov     cr0,eax
        jmp     0x08:main32

align 32
use32
gdt:
.null:
   dq 0
.code:
   dw 0xFFFF
   dw 0
   db 0
   db 10011010b
   db 11001111b
   db 0
.data:
   dw 0xFFFF
   dw 0
   db 0
   db 10010010b
   db 11001111b
   db 0
gdt_end:
gdtx:
   dw gdt_end-gdt-1
   dd gdt

align 32
idt:
rept 32 n:0
{
      dw isr#n
      dw 0x0008
      db 0x00
      db 0x8E
      dw 0x0000
}
rept 16 n:0
{
      dw irq#n
      dw 0x0008
      db 0x00
      db 0x8E
      dw 0x0000
}
rb 8*(256-32-16)
idt_end:
idtx:
    dw idt_end-idt-1
    dd idt

extrn _stdout_color
extrn _isr_dump

align 32
isr_stack dd 0
rb 1024
isr_stack_mem:
isrz:
rept 32 n:0
{
;TODO: handle error codes
isr#n:
        mov     [isr_stack],esp
        mov     esp,isr_stack_mem
        push    word n
        jmp     isr_handler
}
isr_handler:
        mov     byte[_stdout_color],0x0c
        push    dword isr_str_err
        mov     esi,_puts
        call    esi
        add     esp,4
        xor     eax,eax
        pop     ax
        cmp     eax,20
        jl      .zz
        push    dword isr_str_err
        mov     esi,_puts
        call    esi
        jmp     .z
.zz:
        mov     esi,dword[eax*4+isr_errs]
        push    esi
        mov     esi,_puts
        call    esi
        push    dword [isr_stack]
        mov     esi,_isr_dump
        call    esi
.z:
        hlt
        jmp     .z
.errz db 0,0,0

isr_str_err db 0x0a,0x0d,'ERRORRRRR! WTF???????????',0x0a,0x0d,0

isr_err0  db 'Division By Zero',0
isr_err1  db 'Debug',0
isr_err2  db 'Non Maskable Interrupt',0
isr_err3  db 'Breakpoint',0
isr_err4  db 'Into Detected Overflow',0
isr_err5  db 'Out of Bounds',0
isr_err6  db 'Invalid Opcode',0
isr_err7  db 'No Coprocessor',0
isr_err8  db 'Double Fault',0
isr_err9  db 'Coprocessor Segment Overrun',0
isr_err10 db 'Bad TSS',0
isr_err11 db 'Segment Not Present',0
isr_err12 db 'Stack Fault',0
isr_err13 db 'General Protection Fault',0
isr_err14 db 'Page Fault',0
isr_err15 db 'Unknown Interrupt',0
isr_err16 db 'Coprocessor Fault',0
isr_err17 db 'Alignment Check',0
isr_err18 db 'Machine Check',0
isr_err19 db 'Reserved',0

align 32
isr_errs:
rept 20 n:0
{
dd isr_err#n
}

align 32
irqz:
rept 16 n:0
{
irq#n:
        cli
        push    word n
        jmp     irq_handler
}
irq_handler:
        pop     word[.n]
        pushad
        push    ds
        push    es
        push    fs
        push    gs
        mov     [irq_stack],esp
        mov     esp,irq_stack_mem
        xor     eax,eax
        mov     ax,[.n]
        mov     ebx,[irqhs+eax*4]
        cmp     ebx,0
        je      .zz
        call    ebx
.zz:
        cmp     [.n],8
        jle     .z
        mov     al,0x20
        out     0x0A,al
.z:
        mov     al,0x20
        out     0x20,al
        mov     esp,[irq_stack]
        mov     [irq_stack],0
        pop     gs
        pop     fs
        pop     es
        pop     ds
        popad
        iret
.n dw 0
public _irq_stack
_irq_stack:
irq_stack dd 0
rb 1024
irq_stack_mem:
rb 1024
irqhs:
rept 16 n:0
{
irqh#n dd 0
}

rept 4 n:1
{
public _test#n
_test#n:
.z:
        hlt
        cli
        mov     esp,.stack
        mov     eax,0xB8000
;        mov     [_stdout_x],0
;        mov     [_stdout_y],10+n*3
;        mov     esi,_printf
;        mov     esp,
        sti
        jmp     .z
rb 100
.stack:
rb 100
.msg db 'thread','0'+n,0
}

nmi_enable:
        push    ax
         in      al,0x70
        and     al,0x7F
        out     0x70,al
        pop     ax
        ret
nmi_disable:
        push    ax
        in      al,0x70
        or      al,0x80
        out     0x70,al
        pop     ax
        ret

macro cursor x,y
{
        mov     byte[screen.cx],x
        mov     byte[screen.cy],y
}

align 32
main32:
        mov     eax,0x10
        mov     ds,ax
        mov     es,ax
        mov     fs,ax
        mov     gs,ax
        mov     ss,ax
.remap_pic:
macro outb p,v
{
        mov     al,v
        out     p,al
}
        outb    0x20,0x11
        outb    0xA0,0x11
        outb    0x21,0x20
        outb    0xA1,40
        outb    0x21,0x04
        outb    0xA1,0x02
        outb    0x21,0x01
        outb    0xA1,0x01
        outb    0x21,0x0
        outb    0xA1,0x0
purge outb
.init_idt:
        lidt    [idtx]
.init_timer:
        mov     al,00110100b
        out     0x43,al
        mov     ax,1193;1193180
        out     0x40,al
        mov     al,ah
        out     0x40,al
.main:
        xor     eax,eax
        xor     ebx,ebx
        xor     ecx,ecx
        xor     edx,edx
        xor     ebp,ebp
        xor     esi,esi
        xor     edi,edi
        mov     esp,0xD000
        call    nmi_enable
        jmp     0x08:_boios_main
;        sti
;        jmp     sh
;        jmp     thread_main0
;        call    cpuid_test
.hlt:
        hlt
        jmp     .hlt

public _set_irq_handler
_set_irq_handler:
        mov     ebx,[esp+8]
        mov     eax,[esp+4]
        mov     dword[irqhs+4*eax],ebx
        ret

public _shutdown
_shutdown:
        cli
macro outw p,v
{
        mov     ax,v
        mov     dx,p
        out     dx,ax
}
        outw    0xB004, 0x2000
        outw    0x0604, 0x2000
        outw    0x4004, 0x3400
purge outw
.z:
        hlt
        jmp     .z

public _reboot
_reboot:
        cli
.r:
        in      al,0x64
        and     al,0x02
        jnz     .r
        mov     al,0xfe
        out     0x64,al
.z:
        hlt
        jmp     .z


public _printf
extrn _puthex32
extrn _putdec32
extrn _putchar
_printf:
        push    ebp
        xor     ebp,ebp
        push    ebx
        mov     ebx,[esp+12]
.n:
        mov     al,[ebx]
        inc     ebx
        cmp     al,0
        je      .r
        cmp     al,'%'
        jne     .nf
        mov     al,[ebx]
        inc     ebx
        cmp     al,0
        je      .r
        cmp     al,'x'
        je      .fx
        cmp     al,'d'
        je      .fd
        cmp     al,'s'
        je      .fs
        cmp     al,'c'
        je      .fc
        cmp     al,'#'
        je      .fh
.nf:
        push    eax
        mov     eax,_putchar
        call    eax
        add     esp,4
        jmp     .n
.fx:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_puthex32
        call    eax
        add     esp,4
        jmp     .n
.fd:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_putdec32
        call    eax
        add     esp,4
        jmp     .n
.fs:
        mov     eax,[esp+ebp*4+16]
        push    esi
        mov     esi,eax
        inc     ebp
.fsz:
        xor     eax,eax
        mov     al,byte[esi]
        cmp     al,0
        je      .fsn
        push    eax
        mov     eax,_putchar
        call    eax
        add     esp,4
        inc     esi
        jmp     .fsz
.fsn:
        pop     esi
        jmp     .n
.fc:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_putchar
        call    eax
        add     esp,4
        jmp     .n
.fh:
        inc     ebx
        push    dword '0'
        mov     eax,_putchar
        call    eax
        add     esp,4
        push    dword 'x'
        mov     eax,_putchar
        call    eax
        add     esp,4
        jmp     .fx
.r:
        pop     ebx
        pop     ebp
        ret

str_boios db 'boiOS',0

audio:
.beep:
        push    ebx
        call    .set_freq
        call    .enable
        mov     eax,ebx
        ;call    sleep_ms
        call    .disable
        pop     ebx
        ret
.set_freq:
        push    eax
        push    ecx
        push    edx
        mov     al,0xb6
        out     0x43,al
        mov     ecx,eax
        mov     edx,0
        mov     eax,1193180
        div     ecx
        out     0x42,al
        mov     al,ah
        out     0x42,al
        pop     edx
        pop     ecx
        pop     eax
        ret
.enable:
        push    ax
        in      al,0x61
        test    al,3
        jnz     ..z
        or      al,3
        out     0x61,al
        pop     ax
..z:
        ret
.disable:
        push    ax
        in      al,0x61
        and     al,0xFC
        out     0x61,al
        pop     ax
        ret




