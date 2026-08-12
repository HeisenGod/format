@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Registrar protocolo Magnet - Free Download Manager
color 0A

echo.
echo ================================================
echo      REGISTRAR MAGNET - FREE DOWNLOAD MANAGER
echo ================================================
echo.

set "FDM_EXE="

echo [1/3] Procurando o Free Download Manager...
echo.

:: ==================================================
:: 1. Procurar em locais conhecidos
:: ==================================================

if exist "%LOCALAPPDATA%\Softdeluxe\Free Download Manager\fdm.exe" (
    set "FDM_EXE=%LOCALAPPDATA%\Softdeluxe\Free Download Manager\fdm.exe"
    goto :FOUND
)

if exist "%ProgramFiles%\Free Download Manager\fdm.exe" (
    set "FDM_EXE=%ProgramFiles%\Free Download Manager\fdm.exe"
    goto :FOUND
)

if exist "%ProgramFiles(x86)%\Free Download Manager\fdm.exe" (
    set "FDM_EXE=%ProgramFiles(x86)%\Free Download Manager\fdm.exe"
    goto :FOUND
)

if exist "%ProgramFiles%\Softdeluxe\Free Download Manager\fdm.exe" (
    set "FDM_EXE=%ProgramFiles%\Softdeluxe\Free Download Manager\fdm.exe"
    goto :FOUND
)

if exist "%ProgramFiles(x86)%\Softdeluxe\Free Download Manager\fdm.exe" (
    set "FDM_EXE=%ProgramFiles(x86)%\Softdeluxe\Free Download Manager\fdm.exe"
    goto :FOUND
)

:: ==================================================
:: 2. Nao encontrado automaticamente
:: ==================================================

:NOT_FOUND

echo.
echo ==================================================
echo  Free Download Manager nao encontrado.
echo ==================================================
echo.
echo O programa pode nao estar instalado ou pode
echo ter sido instalado em um diretorio personalizado.
echo.
echo Informe abaixo a PASTA onde o FDM esta instalado.
echo.
echo Exemplo:
echo C:\Program Files\Free Download Manager
echo.
echo Digite "CANCELAR" para sair.
echo.

set "FDM_DIR="
set /p "FDM_DIR=Diretorio do FDM: "

if /I "%FDM_DIR%"=="CANCELAR" goto :CANCEL

:: Remove aspas caso o usuario tenha colado o caminho com elas
set "FDM_DIR=%FDM_DIR:"=%"

if not defined FDM_DIR (
    echo.
    echo [ERRO] Nenhum diretorio foi informado.
    echo.
    pause
    goto :NOT_FOUND
)

:: ==================================================
:: CORRECAO: Remove barra invertida (\) no final, se houver
:: ==================================================
if "%FDM_DIR:~-1%"=="\" set "FDM_DIR=%FDM_DIR:~0,-1%"

:: Verifica se o diretorio informado existe
if not exist "%FDM_DIR%\" (
    echo.
    echo [ERRO] O diretorio informado nao existe:
    echo %FDM_DIR%
    echo.
    pause
    goto :NOT_FOUND
)

:: Procura o executavel dentro do diretorio informado
if exist "%FDM_DIR%\fdm.exe" (
    set "FDM_EXE=%FDM_DIR%\fdm.exe"
    goto :FOUND
)

echo.
echo [ERRO] O arquivo fdm.exe nao foi encontrado nesse diretorio:
echo %FDM_DIR%
echo.
echo Verifique se voce informou a pasta correta.
echo.
pause
goto :NOT_FOUND


:: ==================================================
:: 3. FDM encontrado
:: ==================================================

:FOUND

echo.
echo [OK] Free Download Manager encontrado!
echo.
echo Caminho:
echo "%FDM_EXE%"
echo.

if not exist "%FDM_EXE%" (
    echo [ERRO] O executavel nao foi encontrado.
    echo.
    pause
    exit /b 1
)

echo [2/3] Criando registro do protocolo Magnet...
echo.

:: ==================================================
:: Cria a chave principal Magnet
:: ==================================================

reg add "HKCU\Software\Classes\Magnet" /f >nul

if errorlevel 1 (
    echo [ERRO] Nao foi possivel criar a chave Magnet.
    pause
    exit /b 1
)

:: Nome padrao
reg add "HKCU\Software\Classes\Magnet" ^
    /ve ^
    /t REG_SZ ^
    /d "Magnet URL" ^
    /f >nul

:: Content Type
reg add "HKCU\Software\Classes\Magnet" ^
    /v "Content Type" ^
    /t REG_SZ ^
    /d "application/x-magnet" ^
    /f >nul

:: URL Protocol
reg add "HKCU\Software\Classes\Magnet" ^
    /v "URL Protocol" ^
    /t REG_SZ ^
    /d "" ^
    /f >nul


:: ==================================================
:: CORRECAO: DefaultIcon formatado adequadamente
:: ==================================================

reg add "HKCU\Software\Classes\Magnet\DefaultIcon" ^
    /ve ^
    /t REG_SZ ^
    /d "\"%FDM_EXE%\",0" ^
    /f >nul


:: ==================================================
:: CORRECAO: Comando direto (chaves intermediarias auto-criadas)
:: ==================================================

reg add "HKCU\Software\Classes\Magnet\shell\open\command" ^
    /ve ^
    /t REG_SZ ^
    /d "\"%FDM_EXE%\" \"%%1\"" ^
    /f >nul

if errorlevel 1 (
    echo.
    echo [ERRO] Nao foi possivel registrar o comando.
    echo.
    pause
    exit /b 1
)


:: ==================================================
:: Conclusao
:: ==================================================

echo.
echo [3/3] Verificando registro...
echo.

reg query "HKCU\Software\Classes\Magnet\shell\open\command" /ve >nul 2>&1

if errorlevel 1 (
    echo [ERRO] O registro nao foi criado corretamente.
    echo.
    pause
    exit /b 1
)

echo ================================================
echo       MAGNET REGISTRADO COM SUCESSO!
echo ================================================
echo.
echo FDM:
echo "%FDM_EXE%"
echo.
echo Protocolo:
echo magnet://
echo.
echo O Free Download Manager agora sera usado
echo para abrir links Magnet.
echo.

pause
exit /b 0


:: ==================================================
:: Cancelamento
:: ==================================================

:CANCEL

echo.
echo Operacao cancelada pelo usuario.
echo.
pause
exit /b 0