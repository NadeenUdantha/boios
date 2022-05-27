@echo off
taskkill /f /im virtualbox.exe
cmd /c build.cmd || goto end
start "vm" "D:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "boios" --type gui -E VBOX_GUI_DBG_ENABLED=true -E VBOX_GUI_DBG_AUTO_SHOW=true
:end