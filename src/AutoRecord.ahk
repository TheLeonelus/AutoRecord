#Requires AutoHotkey v2.0-beta.1
; Чтобы не плодились инстансы скрипта
#SingleInstance Force
; Не даём скрипту закрыться
Persistent
; Подключаем внешние скрипты
#Include %A_ScriptDir%\ExternalLib
#Include WebSocket.ahk
#Include JXON.ahk
#Include <logError>
#Include <logToFile>
#Include <ReceiveToast>
Assema Gildas Sem 20399714 – (1)

;Обзываем скрипт
A_ScriptName := "AutoRecord V1.1"

Persistent

obsConnection := WebSocket("ws://127.0.0.1:4455/", {
    message: (self, data) => handleMessage(self, data),
    close: (self, status, reason) => logToFile(status ' ' reason '`n'),
})

lastData := ""

handleMessage(self, data) {
    logToFile(Data '`n')
    lastData := jxon_load(&Data)
    OutputDebug "opCode: " lastData["op"] "`n"
    switch lastData["op"]
    {
        case 0:
            response := Format("
            (
            {
            "d": {
            "rpcVersion": {1:s}
            },
            "op": 1
            }
            )", lastData["d"]["rpcVersion"])
            self.sendText(response)
            logToFile(response)

        case 2:
            OutputDebug "identified`n"
        Default:
    }
}

OutputDebug "We goog`n"

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