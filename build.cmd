@echo off
rm R:\*.o
rm R:\*.bin
rm R:\image.iso
copy image.iso R:\image.iso
fasm boot.asm boot.bin || goto end
miso R:\image.iso -py -a boot.bin || goto end
:end
exit /b %ERRORLEVEL%