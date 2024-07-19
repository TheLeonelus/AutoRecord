# Устанавливаем переменные
$APPDATA_PATH = $env:AppData
$AUTO_RECORD_PATH = "$APPDATA_PATH\AutoRecord"
$AUTO_RECORD_EXE = "$AUTO_RECORD_PATH\AutoRecord.exe"
$DESKTOP_PATH = [System.Environment]::GetFolderPath('Desktop')
$STARTUP_PATH = "$APPDATA_PATH\Microsoft\Windows\Start Menu\Programs\Startup"
$DOWNLOAD_URL = "https://github.com/theleonelus/autorecord/releases/latest/download/autorecord.zip"
$ZIP_FILE = "$env:USERPROFILE\AutoRecord.zip"  # полный путь к текущему скрипту

# Завершаем процесс AutoRecord.exe, если он запущен
$process = Get-Process -Name "AutoRecord" -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name "AutoRecord" -Force
    Write-Host "process AutoRecord.exe closed."
} else {
    Write-Host "process AutoRecord.exe not found."
}

# Проверяем наличие папки AutoRecord в Roaming и удаляем ее, если она существует
if (Test-Path -Path $AUTO_RECORD_PATH) {
    Remove-Item -Path $AUTO_RECORD_PATH -Recurse -Force
    Write-Host "folder $AUTO_RECORD_PATH deleted."
}

# Загружаем последний релиз AutoRecord.zip с GitHub
Write-Host "Downloading latest release of AutoRecord..."
Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ZIP_FILE -UseBasicParsing

# Проверяем успешность загрузки файла
if (-Not (Test-Path -Path $ZIP_FILE)) {
    Write-Host "Failed to download AutoRecord.zip. Exiting."
    Read-Host -Prompt "Press Enter to exit"
    exit 1
}

# Распаковываем архив AutoRecord.zip
Expand-Archive -Path $ZIP_FILE -DestinationPath $APPDATA_PATH
Write-Host "Done"

# Создаем ярлык на рабочем столе
$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut("$DESKTOP_PATH\AutoRecord.lnk")
$shortcut.TargetPath = $AUTO_RECORD_EXE
$shortcut.Save()

# Создаем ярлык в папке автозагрузки
$shortcut = $ws.CreateShortcut("$STARTUP_PATH\AutoRecord.lnk")
$shortcut.TargetPath = $AUTO_RECORD_EXE
$shortcut.Save()

Read-Host -Prompt "Press Enter to exit"
