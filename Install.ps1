# Defining constants
Set-Location -Path "$env:Appdata"
$AUTO_RECORD_PATH = "$env:Appdata\AutoRecord"
$AUTO_RECORD_EXE = "$AUTO_RECORD_PATH\AutoRecord.exe"
$DESKTOP_PATH = [System.Environment]::GetFolderPath('Desktop')
$STARTUP_PATH = "$env:Appdata\Microsoft\Windows\Start Menu\Programs\Startup"
$DOWNLOAD_URL = "https://github.com/theleonelus/autorecord/releases/latest/download/autorecord.zip"
$ZIP_FILE = "$env:UserProfile\AutoRecord.zip" 

# Stop autorecord.exe process
$process = Get-Process -Name "AutoRecord" -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name "AutoRecord" -Force
    Write-Host "process AutoRecord.exe closed."
}
else {
    Write-Host "process AutoRecord.exe not found."
}

# Stop obs64.exe process
$process = Get-Process -Name "obs64" -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name "obs64" -Force
    Write-Host "process obs64.exe closed."
}
else {
    Write-Host "process obs64.exe not found."
}

# Clean old code
if (Test-Path -Path $AUTO_RECORD_PATH) {
    if (Test-Path -Path $AUTO_RECORD_PATH\Lib\) {
        Remove-Item -Path $AUTO_RECORD_PATH\Lib\ -Recurse -Force
    }
    if (Test-Path -Path $AUTO_RECORD_PATH\ExternalLib\) {
        Remove-Item -Path $AUTO_RECORD_PATH\ExternalLib\ -Recurse -Force
    }
    Remove-Item -Path $AUTO_RECORD_PATH\AutoRecord.* -Recurse -Force
}

# Download latest release AutoRecord.zip from GitHub
Write-Host "Downloading latest release of AutoRecord..."
try {
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ZIP_FILE -UseBasicParsing
}
catch {
    Write-Host "Failed to download AutoRecord.zip. Exiting."
    Read-Host -Prompt "Press Enter to exit"
    exit 1
} 

# Unzip AutoRecord.zip
Expand-Archive -Path $ZIP_FILE -DestinationPath $AUTO_RECORD_PATH -Force
Remove-Item -Path $ZIP_FILE

# Download install.bat to be able to update in the future
(Invoke-WebRequest https://raw.githubusercontent.com/TheLeonelus/AutoRecord/main/install.bat).Content | Out-File -FilePath $AUTO_RECORD_PATH\install.bat -Encoding UTF8

# Import obs-websocket config
Write-Host "Inserting default websocket config"
$jsonConfig = '
{
    "alerts_enabled":  false,
    "auth_required":  false,
    "first_load":  false,
    "server_enabled":  true,
    "server_password":  "",
    "server_port":  4455
}' | ConvertFrom-Json
if (Test-Path -Path "$env:appdata\obs-studio\plugin_config\obs-websocket\") {
    $jsonConfig | ConvertTo-Json | Set-Content -Path "$env:appdata\obs-studio\plugin_config\obs-websocket\config.json" -Encoding UTF8
}
else {
    $global = "$env:appdata\obs-studio\global.ini"
    $regex = '(?ms)(\[OBSWebSocket\]\n)(.*?)(\n\[)'
    (Get-Content $global -Raw -Encoding UTF8) -replace $regex, 
    '$1FirstLoad=false
ServerEnabled=true
ServerPort=4455
AlertsEnabled=false
AuthRequired=false
ServerPassword=
$3' | Set-Content $global -Encoding UTF8
}


# Create shortcut on desktop
$ws = New-Object -ComObject WScript.Shell
Write-Host "Adding AutoRecord to Desktop"
$shortcut = $ws.CreateShortcut("$DESKTOP_PATH\AutoRecord.lnk")
$shortcut.TargetPath = $AUTO_RECORD_EXE
$shortcut.Save()


# Create AutoRecord shortcut in startup
Write-Host "Adding AutoRecord to Startup"
$shortcut = $ws.CreateShortcut("$STARTUP_PATH\AutoRecord.lnk")
$shortcut.TargetPath = $AUTO_RECORD_EXE
$shortcut.Save()


# Create OBS shortcut in startup
Write-Host "Adding OBS to Startup"
$shortcut = $ws.CreateShortcut("$STARTUP_PATH\obs64.lnk")
$shortcut.TargetPath = ("C:\Program Files\obs-studio\bin\64bit\obs64.exe")
$shortcut.WorkingDirectory = ("C:\Program Files\obs-studio\bin\64bit")
$shortcut.Save()


Read-Host -Prompt "Press Enter to exit"