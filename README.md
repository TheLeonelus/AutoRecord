# AutoRecord

## Russian

Этот скрипт создан для автоматизирования записи звоноков из Telegram и Whatsapp, используя возможности AHK и [OBS-websocket](https://github.com/obsproject/obs-websocket/).

Скрипт ищет окна со звонком из TG и WA, при нахождении начинает запись в [OBS](https://github.com/obsproject/obs-studio/) и, соотвественно при закрытии, завершает её. 

На данный момент используется obs-websocket для подключения и управления записью в OBS.

Данный скрипт задействует возможности мультипоточности AHK_H v2.

### Компиляция

- Клонируем репозиторий
- Скачиваем [последний релиз AutoHotkey/Ahk2Exe](https://github.com/AutoHotkey/Ahk2Exe/releases/latest/)
- Скачиваем последний релиз [thqby/AutoHotkey_H](https://github.com/thqby/AutoHotkey_H/)
- Перемещаем в папку src
  - `Main_compile.bat`
  - `Ahk2Exe.exe`
  - `Autohotkey64.exe`
- Запускаем `Main_compile.bat`
- С бинарником необходимо таскать все библиотеки, так как пока не понятно, как собирать все .ahk в одного мегазорда
### Установка

Чтобы произвести автоматическую установку AutoRecord, нужно запустить файл `Install.bat` (Для тех у кого стоит политика запрета использования PowerShell)

или выполнить эту команду в PowerShell:

```powershell
iwr https://raw.githubusercontent.com/TheLeonelus/AutoRecord/main/Install.ps1 | iex
```
## English

This script is designed for automating calls` recording from Telegram Desktop and Whatsapp Desktop by utilizing AHK possibilites.

Basically it looks for call`s window and on success - begin recording, by means of hotkey input or using API e.g. obs-websocket

It utilizes AHK_H v2 multithreading functions.

### Compiling

TBA

## Licensing

This software was created with thanks to:

- [AutoHotKey](https://github.com/AutoHotkey/AutoHotkey/tree/alpha)
- Fork of [AHK_H](https://github.com/thqby/AutoHotkey_H/) from [thqby](https://github.com/thqby)
- [AHK2_lib](https://github.com/thqby/ahk2_lib)
- [Ahk2exe](https://github.com/AutoHotkey/Ahk2Exe)
- Icon created by [bqlqn - Flaticon](https://www.flaticon.com/free-icon/radio-waves_1340130)
- [JXON_ahk2](https://github.com/TheArkive/JXON_ahk2)
- [OBS-websocket](https://github.com/obsproject/obs-websocket/)
