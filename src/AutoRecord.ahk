; Чтобы не плодились инстансы скрипта
#SingleInstance Force
; Не даём скрипту закрыться
Persistent
; Подключаем внешние скрипты
#Include %A_AppData%\AutoRecord\Lib
#Include logError.ahk
#Include ReceiveToast.ahk
;Обзываем скрипт
A_ScriptName := "AutoRecord v1.0.0"

try {
  ; объект для регулировки таймингов, прерываний и доступа к функции записи
  recStatus := CriticalObject({check_delay: 500, hotkey_delay: 50})
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