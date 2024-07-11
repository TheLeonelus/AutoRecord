# AutoRecord

## Russian

Этот скрипт создан для автоматизирования записи звоноков из Telegram и Whatsapp, используя возможности AHK.

Скрипт ищет окна со звонком из TG и WA, при нахождении отправляет горячие клавиши на начало записи и, при закрытии, на её окончание.
Конечное ПО для записи непринципиально, главное выставить следующие горячие клавиши в нём:

- Начало записи Ctrl+Alt+F9
- Конец записи Ctrl+Alt+F10

Взамен хоткеям можно использовать и API, к примеру obs-websocket.

Данный скрипт задействует возможности мультипоточности AHK_H v2.

### Компиляция

TBA

## English

This script is designed for automating calls` recording from Telegram Desktop and Whatsapp Desktop by utilizing AHK possibilites.

Basically it looks for call`s window and on success - begin recording, by means of hotkey input or using API e.g. obs-websocket

It utilizes AHK_H v2 multithreading functions.

### Compiling

TBA

## Licensing

This software was created thanks to:

- [AutoHotKey](https://github.com/AutoHotkey/AutoHotkey/tree/alpha)
- [Ahkdll-V2](https://github.com/HotKeyIt/ahkdll-v2-release/)
- [Ahk2exe](https://github.com/AutoHotkey/Ahk2Exe)
- Icon created by [bqlqn - Flaticon](https://www.flaticon.com/free-icon/radio-waves_1340130)
