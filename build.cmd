@echo off
rm R:\boios\*
mkdir R:\boios
copy image.iso R:\boios\image.iso
fasm boot.asm R:\boios\boot.bin || goto end
miso R:\boios\image.iso -py -a R:\boios\boot.bin || goto end
:end
exit /b %ERRORLEVEL%