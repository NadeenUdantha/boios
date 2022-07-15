@echo off
taskkill /f /im virtualboxvm.exe
cmd /c build.cmd || goto end
start "vm" "D:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "boios" --type gui
rem -E VBOX_GUI_DBG_ENABLED=true -E VBOX_GUI_DBG_AUTO_SHOW=true
:end