@echo off
:r
taskkill /f /im bochs.exe
cmd /c dump.cmd || goto end
bochsdbg -q -f bochsrc
:end