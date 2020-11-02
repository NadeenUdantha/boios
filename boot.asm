
macro outb p,v
{
        mov     al,v
        out     p,al
}

org 0x7c00
use16
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
        jmp     08h:main32
use32
gdt:
gdt_null:
   dq 0
gdt_code:
   dw 0xFFFF
   dw 0
   db 0
   db 10011010b
   db 11001111b
   db 0
gdt_data:
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

isrz:
rept 32 n:0
{
isr#n:
        push    word n
        jmp     isr_handler
}
isr_handler:
        mov     esi,str_err
        call    screen.puts
        xor     eax,eax
        pop     ax
        cmp     eax,32
        jg      .z
        cmp     eax,20
        jl      .zz
        mov     eax,19
.zz:
        mov     esi,dword[eax*4+isr_errs]
        call    screen.puts
        mov     esi,str_err
        call    screen.puts
.z:
        hlt
        jmp     .z

str_err db 0x0a,0x0d,'ERRORRRRR! WTF???????????',0x0a,0x0d,0

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

isr_errs:
rept 20 n:0
{
dd isr_err#n
}

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
        mov     [irq_stack],esp
        xor     eax,eax
        mov     ax,[.n]
        mov     ebx,[irqhs+eax*4]
        cmp     ebx,0
        je      .zz
        call    ebx
.zz:
        cmp     [.n],8
        jle     .z
        outb    0xA0,0x20
.z:
        outb    0x20,0x20
        mov     [irq_stack],0
        popad
        iret
.n dw 0
irq_stack dd 0
irqhs:
rept 16 n:0
{
irqh#n dd 0
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

num_threads equ 256
THREAD_MASK equ num_threads-1

rept num_threads n:0
{
thread_main#n:
        mov     ax,n*0x0100
.hlt:
        hlt
        cli
        cursor  (n*5) mod (16*5),n/16
        call    screen.hex16
        sti
        inc     ax
        jmp     .hlt
}

main32:
        mov     eax,0x08
        mov     ds,ax
        mov     es,ax
        mov     fs,ax
        mov     gs,ax
.remap_pic:
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
.init_idt:
        lidt    [idtx]
        call    screen.cls
;        mov     esi,str_hello
;        call    screen.puts
.init_timer:
        mov     al,00110100b
        outb    0x43,al
        mov     ax,1193;1193;1193180
        out     0x40,al
        mov     al,ah
        out     0x40,al
.init_irqs:
        mov     [irqh0],irq_timer
        mov     [irqh1],irq_kbd
        xor     eax,eax
        xor     ebx,ebx
        xor     ecx,ecx
        xor     edx,edx
        xor     ebp,ebp
        xor     esi,esi
        xor     edi,edi
        call    nmi_enable
        sti
        jmp     thread_main0
;        call    cpuid_test
.hlt:
        hlt
        jmp     .hlt

cpuid_test:
        mov     eax,0
        cpuid
        mov     dword[.tmp16x],ebx
        mov     dword[.tmp16x+4],edx
        mov     dword[.tmp16x+8],ecx
        mov     esi,.tmp16x
        call    screen.puts
        mov     eax,1
        cpuid
        mov     al,' '
        call    screen.putch
        mov     eax,ecx
        call    screen.hex32
        mov     al,' '
        call    screen.putch
        mov     eax,ecx
        and     ax,1 shl 5
        shl     al,4
        add     al,'0'
        call    screen.putch
        ret
.tmp16x rb 13

macro dump32 n,var
{
        push    eax
        push    esi
        mov     esi,n
        call    screen.puts
        mov     eax,var
        call    screen.hex32
        pop     esi
        pop     eax
}
struc thread n=0,main=0
{
        .regs tregs n
        .n db n
        .main dd main
}
struc tregs n
{
.edi dd 0
.esi dd 0
.ebp dd 0
.esp dd 0xF000+(n+1)*0x0FF
.ebx dd 0
.edx dd 0
.ecx dd 0
.eax dd 0

.eip dd 0
.cs dd 0x08
.eflags dd 0x0202
.esp2 dd 0
.ss dd 0
}
tregs.size=8+5

dump_regs:
virtual at eax
.tregs tregs 0
end virtual
        dump32  .str_eax,[.tregs.eax]
        dump32  .str_ebx,[.tregs.ebx]
        dump32  .str_ecx,[.tregs.ecx]
        dump32  .str_edx,[.tregs.edx]
        dump32  .str_ebp,[.tregs.ebp]
        dump32  .str_esi,[.tregs.esi]
        dump32  .str_edi,[.tregs.edi]
        dump32  .str_esp,[.tregs.esp]
        dump32  .str_eip,[.tregs.eip]
        dump32  .str_cs,[.tregs.cs]
        dump32  .str_eflags,[.tregs.eflags]
        dump32  .str_esp2,[.tregs.esp2]
        dump32  .str_ss,[.tregs.ss]
        ret

.str_eax db 'eax=',0
.str_ecx db ' ecx=',0
.str_edx db ' edx=',0
.str_ebx db ' ebx=',0
.str_esp db ' esp=',0
.str_ebp db ' ebp=',0
.str_esi db ' esi=',0
.str_edi db ' edi=',0
.str_eip db ' eip=',0
.str_cs db ' cs=',0
.str_eflags db ' eflags=',0
.str_esp2 db ' esp2=',0
.str_ss db ' ss=',0

irq_thread:
        xor     eax,eax
        mov     al,[threads.cur]
        inc     al
        and     al,THREAD_MASK
        mov     [threads.cur],al
        mov     ebx,[threads+(eax-1)*4]
        mov     [.cur],ebx
        mov     ebx,[threads+(eax)*4]
        mov     [.nxt],ebx
.load_regs:
        mov     esi,[irq_stack]
        mov     edi,[.cur]
        mov     ecx,tregs.size
.copy:
        mov     eax,dword[ss:esi]
        mov     dword[edi],eax
        add     esi,4
        add     edi,4
        dec     ecx
        jnz     .copy
.edit_regs:
        mov     eax,[.nxt]
virtual at eax
.thr thread
end virtual
        cmp     [.thr.regs.eip],0
        jne     .z
        mov     ebx,[.thr.main]
        mov     [.thr.regs.eip],ebx
.z:
;        cursor  0,5
;        call    dump_regs
.save_regs:
        mov     esi,[irq_stack]
        mov     edi,[.nxt]
        mov     ecx,tregs.size
.copy2:
        mov     eax,dword[edi]
        mov     dword[ss:esi],eax
        add     esi,4
        add     edi,4
        dec     ecx
        jnz     .copy2
        ret
.cur dd 0
.nxt dd 0

threads:
rept num_threads n:0
{
        dd thread#n
}
.cur db 0
rept num_threads n:0
{
        thread#n thread n,thread_main#n
}

audio:
.beep:
        push    ebx
        call    .set_freq
        call    .enable
        mov     eax,ebx
        call    sleep_ms
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

str_hello db 0x0a,0x0d,'Hello World!',0x0a,0x0d,0

sleep_ms:
        push    eax
        add     eax,dword[timeMs]
.z:
        hlt
        cmp     eax,dword[timeMs]
        jg      .z
        pop     eax
        ret

timeMs dd 0
irq_timer:
        inc     dword[timeMs]
        call    irq_thread
        ret

irq_kbd:
        xor     eax,eax
        in      al,0x60
        mov     ebx,eax
        and     ebx,0x80
        jnz     .z
;        cmp     al,.code_end-.code_start
;        jl      .z
        mov     al,byte[eax+.code_start]
        call    screen.putch
.z:
        ret

.code_start:
db 0,27,'1234567890-=',0
db 0,'qwertyuiop[]',0
db 0,'asdfghjkl;',"'`"
db 0,'\zxcvbnm,./',0
.code_end:

include 'screen.asm'
