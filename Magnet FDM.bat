@echo off
title Registrar protocolo Magnet para Free Download Manager

echo Criando chaves do Registro...

:: Cria a chave Magnet
reg add "HKCU\Software\Classes\Magnet" /f

:: Valores da chave Magnet
reg add "HKCU\Software\Classes\Magnet" /ve /t REG_SZ /d "Magnet URL" /f
reg add "HKCU\Software\Classes\Magnet" /v "Content Type" /t REG_SZ /d "application/x-magnet" /f
reg add "HKCU\Software\Classes\Magnet" /v "URL Protocol" /t REG_SZ /d "" /f

:: Cria DefaultIcon
reg add "HKCU\Software\Classes\Magnet\DefaultIcon" /f

:: Cria Shell > Open > Command
reg add "HKCU\Software\Classes\Magnet\shell" /f
reg add "HKCU\Software\Classes\Magnet\shell\open" /f
reg add "HKCU\Software\Classes\Magnet\shell\open\command" /f

:: Define o comando do Free Download Manager
reg add "HKCU\Software\Classes\Magnet\shell\open\command" ^
/ve ^
/t REG_SZ ^
/d "\"%LOCALAPPDATA%\Softdeluxe\Free Download Manager\fdm.exe\" \"%%1\"" ^
/f

echo.
echo ==========================================
echo Protocolo Magnet registrado com sucesso!
echo ==========================================
pause