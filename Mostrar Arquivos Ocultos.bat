@echo off
title Mostrar Arquivos Ocultos

echo Ativando exibição de arquivos ocultos...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
/v Hidden ^
/t REG_DWORD ^
/d 1 ^
/f

echo.
echo Arquivos ocultos ativados com sucesso!
pause
