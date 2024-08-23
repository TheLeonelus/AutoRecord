@echo off

".\Ahk2Exe.exe" /in ".\AutoRecord.ahk" /icon "icon.ico" /base ".\AutoHotkey64.exe"  /compress 0

"C:\Program Files\7-Zip\7z.exe" a AutoRecord.zip %APPDATA%\AutoRecord\* -r -xr!.vscode -x!*.log x!*.old -x!*.bat -X!Ahk2exe.exe -X!AutoHotkey64.exe -X!*.zip -X!*.json