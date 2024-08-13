# Устанавливаем переменные
$AUTO_RECORD_PATH = "$env:Appdata\AutoRecord"
$AUTO_RECORD_EXE = "$AUTO_RECORD_PATH\AutoRecord.exe"
$DESKTOP_PATH = [System.Environment]::GetFolderPath('Desktop')
$STARTUP_PATH = "$env:Appdata\Microsoft\Windows\Start Menu\Programs\Startup"
$DOWNLOAD_URL = "https://github.com/theleonelus/autorecord/releases/latest/download/autorecord.zip"
$ZIP_FILE = "$env:USERPROFILE\AutoRecord.zip"  # полный путь к текущему скрипту

# Завершаем процесс AutoRecord.exe, если он запущен
$processAR = Get-Process -Name "AutoRecord" -ErrorAction SilentlyContinue
if ($processAR) {
    Stop-Process -Name "AutoRecord" -Force
    Write-Host "process AutoRecord.exe closed."
}
else {
    Write-Host "process AutoRecord.exe not found."
}

# Завершаем процесс obs64.exe, если он запущен
$processOBS = Get-Process -Name "obs64" -ErrorAction SilentlyContinue
if ($processOBS) {
    Stop-Process -Name "obs64" -Force
    Write-Host "process obs64.exe closed."
}
else {
    Write-Host "process obs64.exe not found."
}
# Загружаем последний релиз AutoRecord.zip с GitHub
Write-Host "Downloading latest release of AutoRecord..."
Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ZIP_FILE -UseBasicParsing

Wait-Process -Id $processAR.id

# Проверяем наличие папки AutoRecord в Roaming и удаляем ее, если она существует
if (Test-Path -Path $AUTO_RECORD_PATH) {
    Remove-Item -Path $AUTO_RECORD_PATH -Recurse -Force
    Write-Host "folder $AUTO_RECORD_PATH deleted."
}



# Проверяем успешность загрузки файла
if (-Not (Test-Path -Path $ZIP_FILE)) {
    Write-Host "Failed to download AutoRecord.zip. Exiting."
    Read-Host -Prompt "Press Enter to exit"
    exit 1
}

# Распаковываем архив AutoRecord.zip
Expand-Archive -Path $ZIP_FILE -DestinationPath $AUTO_RECORD_PATH
Write-Host "Done"

# Загружаем конфиг obs-websocket
$jsonConfig = '
{
    "alerts_enabled":  false,
    "auth_required":  false,
    "first_load":  false,
    "server_enabled":  true,
    "server_password":  "",
    "server_port":  4455
}' | ConvertFrom-Json
$jsonConfig | ConvertTo-Json | Set-Content -Path "$env:appdata\obs-studio\plugin_config\obs-websocket\config.json" -Encoding UTF8

# Создаем ярлык на рабочем столе
$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut("$DESKTOP_PATH\AutoRecord.lnk")
$shortcut.TargetPath = $AUTO_RECORD_EXE
$shortcut.Save()

# Создаем ярлык AutoRecord в папке автозагрузки
$shortcut = $ws.CreateShortcut("$STARTUP_PATH\AutoRecord.lnk")
$shortcut.TargetPath = $AUTO_RECORD_EXE
$shortcut.Save()
# Создаем ярлык ОБС в папке автозагрузки и назначаем рабочую папку
$shortcut = $ws.CreateShortcut("$STARTUP_PATH\obs64.lnk")
$shortcut.TargetPath = ("C:\Program Files\obs-studio\bin\64bit\obs64.exe")
$shortcut.WorkingDirectory = ("C:\Program Files\obs-studio\bin\64bit")
$shortcut.Save()

Read-Host -Prompt "Press Enter to exit"
