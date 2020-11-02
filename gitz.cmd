:z
git add *
git commit -m "%DATE% %TIME%"
if %ERRORLEVEL% EQU 1 goto zz
git push
timeout /T 10
:zz
timeout /T 10
goto z