#Requires AutoHotkey v2.0-beta.1
#SingleInstance
Persistent
#Include ExternalLib\WebSocket.ahk
#Include ExternalLib\JXON.ahk
#Include <logError>
#Include <logToFile>
#Include <ReceiveToast>

A_ScriptName := "AutoRecord V1.1"

try {
  ; looking for obs, if not found, trying to start it
  if !ProcessExist("obs64.exe") {
    try {
      Run("C:\Program Files\obs-studio\bin\64bit\obs64.exe", "C:\Program Files\obs-studio\bin\64bit\")
      OutputDebug("OBS wasn't found, trying to start it up")
    }
    catch {
      MsgBox("OBS wasn`t found. Please try to start it up manually.",,0x2)
    }
  }
  try {
    obsConnection := WebSocket("ws://127.0.0.1:4455/", {
      message: (self, data) => handleMessage(self, data),
      close: (self, status, reason) => logToFile(status ' ' reason '`n'),
    })
  } catch as e {
    OutputDebug("websocket is ded")
    Throw e
  }
    lastData := ""
  ; handle responses from server
  handleMessage(self, data) {
    logToFile(Data '`n')
    lastData := jxon_load(&Data)
    OutputDebug "opCode: " lastData["op"] "`n"
    switch lastData["op"]
    {
      case 0:
        ; hello
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
        ; identify
        OutputDebug "identified`n"
      Default:
    }
  }

  OutputDebug "We goog`n"

  ; объект для регулировки таймингов, прерываний и доступа к функции записи
  recStatus := CriticalObject({ check_delay: 500, hotkey_delay: 100 })
  ; Создаём отдельный поток для мониторинга Telegram
  script := "
  (
    recStatus := CriticalObject(a_args[1])
    lpCS := CriticalObject(recStatus,2)
    check_delay := recStatus.check_delay
    hotkey_delay := recStatus.hotkey_delay
    #Include %A_AppData%\AutoRecord\Lib\Telegram.ahk
    )"
  tgTd := ThreadObj(script, ObjPtr(recStatus) "")
  ; Создаём отдельный поток для мониторинга Whatsapp
  script := "
  (
    recStatus := CriticalObject(a_args[1]) ; get CriticalObject from pointer
    lpCS := CriticalObject(recStatus,2) ; get CriticalSection
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