# AutoRecord

## Russian

Этот скрипт создан для автоматизирования звонок из Telegram и Whatsapp, используя возможности AHK.

Скрипт ищет окна со звонком из TG и WA, при нахождении отправляет hotkey на начало записи и, при закрытии, на её окончание.
Конечное ПО для записи непринципиально, главное выставить следующие горячие клавиши в нём:

- Начало записи Ctrl+Alt+F9
- Конец записи Ctrl+Alt+F10

Данный скрипт задействует возможности мультипоточности AHK_H v2.

### Компиляция

TBA

### TO-DO

- [ ] Изменение названия записи согласно тому, кто звонит
- [ ] Логирование записи и работы приложения для сбора статистики
- [ ] Подумать над скриптом, который будет автоматически настраивать OBS
- [ ] Изменить скрипт для автоматического скачивания релиза с github
- [ ] Добавить Actions для автоматической компиляции бинарника
- [ ] Объединять уведомления от TG и WA при запуске, чтобы уведомления не накладывались друг на друга, добавить обработку ошибки при запуске
- [ ] Изменить контекстное меню в трее (см. объект Menu)

## English

This script is created for automating calls from Telegram Desktop and Whatsapp Desktop by using AHK.

This script uses AHK_H v2 multithreading functions.

### Compiling

TBA

## Licensing

This software was created thanks to:

- [AutoHotKey](https://github.com/AutoHotkey/AutoHotkey/tree/alpha)
- [Ahkdll-V2](https://github.com/HotKeyIt/ahkdll-v2-release/)
- [Ahk2exe](https://github.com/AutoHotkey/Ahk2Exe)
- Icon created by [bqlqn - Flaticon](https://www.flaticon.com/free-icon/radio-waves_1340130)
