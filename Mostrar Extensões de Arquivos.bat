@echo off
title Mostrar Extensões de Arquivos

echo Ativando exibição das extensões...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
/v HideFileExt ^
/t REG_DWORD ^
/d 0 ^
/f

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo Extensões de arquivos ativadas com sucesso!
pause