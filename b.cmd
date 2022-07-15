@echo off
:r
taskkill /f /im bochs.exe
cmd /c build.cmd || goto end
cmd /c bochs -q -f bochsrc
goto r
:end