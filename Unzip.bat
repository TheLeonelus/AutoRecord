@echo off
:: Устанавливаем переменные
set "APPDATA_PATH=%AppData%"
set "AUTO_RECORD_PATH=%APPDATA_PATH%\AutoRecord"
set "AUTO_RECORD_EXE=%AUTO_RECORD_PATH%\AutoRecord.exe"
set "DESKTOP_PATH=%USERPROFILE%\Desktop"
set "STARTUP_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "DOWNLOAD_URL=https://github.com/theleonelus/autorecord/releases/latest/download/autorecord.zip
set "ZIP_FILE=%~dp0AutoRecord.zip"  REM полный путь к текущему батчу

:: Завершаем процесс AutoRecord.exe, если он запущен
tasklist /fi "imagename eq AutoRecord.exe" | find /i "AutoRecord.exe" >nul 2>&1
if not errorlevel 1 (
    taskkill /f /im AutoRecord.exe >nul 2>&1
    echo process AutoRecord.exe closed.
) else (
    echo process AutoRecord.exe not found.
)

:: Проверяем наличие папки AutoRecord в Roaming и удаляем ее, если она существует
if exist "%AUTO_RECORD_PATH%" (
    rmdir /s /q "%AUTO_RECORD_PATH%"
    echo folder %AUTO_RECORD_PATH% deleted.
)

:: Загружаем последний релиз AutoRecord.zip с GitHub
echo Downloading latest release of AutoRecord...
curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"

:: Проверяем успешность загрузки файла
if not exist "%ZIP_FILE%" (
    echo Failed to download AutoRecord.zip. Exiting.
    pause
    exit /b 1
)

:: Распаковываем архив AutoRecord.zip
powershell -command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%APPDATA_PATH%'"
echo Done

:: Создаем ярлык на рабочем столе
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP_PATH%\AutoRecord.lnk'); $s.TargetPath = '%AUTO_RECORD_EXE%'; $s.Save()"

:: Создаем ярлык в папке автозагрузки
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%STARTUP_PATH%\AutoRecord.lnk'); $s.TargetPath = '%AUTO_RECORD_EXE%'; $s.Save()"

pause
