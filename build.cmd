@echo off
multigitz adcompush local main -d .git2 -m "%DATE% %TIME%"
rm R:\boios\*.o
rm R:\boios\*.bin
rm R:\boios\image.iso
mkdir R:\boios\
copy image.iso R:\boios\image.iso
for %%x in (*.c) do gcc -std=gnu11 -ffreestanding -Wno-implicit-function-declaration -Wall -O3 -fstrength-reduce -nostdinc -fno-builtin -m32 -mgeneral-regs-only -c -o R:\boios\%%x.o %%x || goto end
fasm boot.asm R:\boios\boot.obj || goto end
ld -T ld.txt -m i386pe -o R:\boios\main.tmp R:\boios\boot.obj R:\boios\*.o || goto end
objcopy -O pe-i386 -j .text -j .boot R:\boios\main.tmp R:\boios\main2.tmp || goto end
objcopy -O binary R:\boios\main2.tmp R:\boios\boot.bin || goto end
miso R:\boios\image.iso -py -a R:\boios\boot.bin || goto end
color 0a
:end
exit /b %ERRORLEVEL%