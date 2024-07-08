; DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
; Version 2, December 2004
;
; Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
; Everyone is permitted to copy and distribute verbatim or modified
; copies of this license document, and changing it is allowed as long
; as the name is changed.
;
; DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
; TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
;
;0. You just DO WHAT THE FUCK YOU WANT TO.


; Чтобы не плодились инстансы скрипта
#SingleInstance
; Не даём скрипту закрыться
Persistent
; Подключаем внешние скрипты
#Include %A_AppData%\AutoRecord\Lib
#Include logError.ahk
#Include ReceiveToast.ahk
;Обзываем скрипт
A_ScriptName := "AutoRecord"

try {
  ; объект для регулировки таймингов, прерываний и доступа к функции записи
  recStatus := CriticalObject({check_delay: 500, hotkey_delay: 100})
  ; Создаём отдельный поток для мониторинга Telegram
  script:="
  (
  recStatus:=CriticalObject(a_args[1])
  lpCS:=CriticalObject(recStatus,2)
  check_delay := recStatus.check_delay
  hotkey_delay := recStatus.hotkey_delay
  #Include %A_AppData%\AutoRecord\Lib\Telegram.ahk
  )"
  tgTd := ThreadObj(script, ObjPtr(recStatus) "")
  ; Создаём отдельный поток для мониторинга Whatsapp
  script:="
  (
  recStatus:=CriticalObject(a_args[1]) ; get CriticalObject from pointer
  lpCS:=CriticalObject(recStatus,2) ; get CriticalSection
  check_delay := recStatus.check_delay
  hotkey_delay := recStatus.hotkey_delay
  #Include %A_AppData%\AutoRecord\Lib\Whatsapp.ahk
  )"
  waTd := ThreadObj(script, ObjPtr(recStatus) "")
  ; обработка сигнала на отправку Toast уведомления
  OnMessage 0xFF01, ReceiveToast
}
catch as e {
  logError(e)
}


; This program is free software. It comes without any warranty, to
; the extent permitted by applicable law. You can redistribute it
; and/or modify it under the terms of the Do What The Fuck You Want
; To Public License, Version 2, as published by Sam Hocevar. See
; http://www.wtfpl.net/ for more details.

