@echo off
cmd /c build.cmd || goto end2
rem objdump -D -b binary -mi386 -Maddr16,data16,intel R:\boios\boot.bin
objdump -D R:\boios\main2.tmp -M intel > R:\boios\main2.tmp.asm
objcopy --only-keep-debug R:\boios\main2.tmp R:\boios\main.debug
nm R:\boios\main.debug | grep " T " | awk '{ print $1" "$3 }' > R:\boios\main.debug.sym
code R:\boios\main2.tmp.asm
:end2