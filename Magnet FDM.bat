@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Registrar protocolo Magnet - Free Download Manager
color 0A

echo.
echo ================================================
echo     REGISTRAR MAGNET - FREE DOWNLOAD MANAGER
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
:: Remove barra invertida no final, se houver
:: ==================================================

if "%FDM_DIR:~-1%"=="\" set "FDM_DIR=%FDM_DIR:~0,-1%"

:: ==================================================
:: Verifica se o diretorio informado existe
:: ==================================================

if not exist "%FDM_DIR%\" (
    echo.
    echo [ERRO] O diretorio informado nao existe:
    echo %FDM_DIR%
    echo.
    pause
    goto :NOT_FOUND
)

:: ==================================================
:: Procura o executavel dentro do diretorio informado
:: ==================================================

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
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: Nome padrao
:: ==================================================

reg add "HKCU\Software\Classes\Magnet" ^
    /ve ^
    /t REG_SZ ^
    /d "Magnet URL" ^
    /f >nul

if errorlevel 1 (
    echo [ERRO] Nao foi possivel definir o nome do protocolo.
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: Content Type
:: ==================================================

reg add "HKCU\Software\Classes\Magnet" ^
    /v "Content Type" ^
    /t REG_SZ ^
    /d "application/x-magnet" ^
    /f >nul

if errorlevel 1 (
    echo [ERRO] Nao foi possivel definir o Content Type.
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: URL Protocol
:: ==================================================

reg add "HKCU\Software\Classes\Magnet" ^
    /v "URL Protocol" ^
    /t REG_SZ ^
    /d "" ^
    /f >nul

if errorlevel 1 (
    echo [ERRO] Nao foi possivel definir o URL Protocol.
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: DefaultIcon
:: ==================================================

reg add "HKCU\Software\Classes\Magnet\DefaultIcon" ^
    /ve ^
    /t REG_SZ ^
    /d "\"%FDM_EXE%\",0" ^
    /f >nul

if errorlevel 1 (
    echo [ERRO] Nao foi possivel configurar o icone.
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: Comando do Magnet
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
:: 3/3 - Verificacao REAL do registro
:: ==================================================

echo.
echo [3/3] Verificando registro...
echo.

set "REGISTERED_COMMAND="

for /f "tokens=2,*" %%A in (
    'reg query "HKCU\Software\Classes\Magnet\shell\open\command" /ve 2^>nul'
) do (
    if "%%A"=="REG_SZ" set "REGISTERED_COMMAND=%%B"
)

if not defined REGISTERED_COMMAND (
    echo [ERRO] O comando nao foi encontrado no registro.
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: Comando esperado (CORRIGIDO)
:: ==================================================

:: Removemos as barras invertidas, que não sao necessarias no comando 'set'
set "EXPECTED_COMMAND="%FDM_EXE%" "%%1""

:: ==================================================
:: Remocao de aspas para comparacao segura (CORRIGIDO)
:: ==================================================

:: Compara as strings sem aspas para evitar erros de sintaxe no IF do Batch
set "CHK_REG=%REGISTERED_COMMAND:"=%"
set "CHK_EXP=%EXPECTED_COMMAND:"=%"

if /I not "%CHK_REG%"=="%CHK_EXP%" (
    echo [ERRO] O comando registrado nao corresponde ao FDM encontrado.
    echo.
    echo Comando esperado:
    echo %EXPECTED_COMMAND%
    echo.
    echo Comando encontrado:
    echo %REGISTERED_COMMAND%
    echo.
    pause
    exit /b 1
)

:: ==================================================
:: Verificacao do DefaultIcon
:: ==================================================

set "REGISTERED_ICON="

for /f "tokens=2,*" %%A in (
    'reg query "HKCU\Software\Classes\Magnet\DefaultIcon" /ve 2^>nul'
) do (
    if "%%A"=="REG_SZ" set "REGISTERED_ICON=%%B"
)

if not defined REGISTERED_ICON (
    echo [ERRO] O DefaultIcon nao foi encontrado no registro.
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================
echo       MAGNET REGISTRADO COM SUCESSO!
echo ================================================
echo.
echo FDM:
echo "%FDM_EXE%"
echo.
echo Comando registrado:
echo %REGISTERED_COMMAND%
echo.
echo Icone registrado:
echo %REGISTERED_ICON%
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
