#SingleInstance
Persistent

if !A_IsCompiled {
  SetWorkingDir(A_AppData "\AutoRecord\src")
  MsgBox(A_AhkVersion)
  MsgBox(A_ScriptFullPath)
}
A_ScriptName := "AutoRecord V1.1"
try {
  ; объект для регулировки таймингов, прерываний и доступа к функции записи
   shared_obj := CriticalObject({ check_delay: 500, hotkey_delay: 100, last_msg: "" })
  ; looking for obs, if not found, trying to start it
  if !ProcessExist("obs64.exe") {
    try {
      Run("C:\Program Files\obs-studio\bin\64bit\obs64.exe", "C:\Program Files\obs-studio\bin\64bit\")
      OutputDebug("OBS wasn't found, trying to start it up")
    }
    catch {
      MsgBox("OBS wasn`t found. Please try to start it up manually.", , 0x2)
    }
  }
  try {
    obs_connection := WebSocket("ws://127.0.0.1:4455/", {
      message: (self, data) => handleMessage(self, data),
      close: (self, status, reason) => logToFile(status ' ' reason '`n'),
    })
  } catch as e {
    OutputDebug("websocket is ded`n")
    Throw e
  }
  ; handle responses from server
  handleMessage(self, data) {
    logToFile(Data '`n')
    shared_obj.last_msg := jxon_load(&Data)
    OutputDebug "opCode: " shared_obj.last_msg["op"] "`n"
    switch shared_obj.last_msg["op"]
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
            )", shared_obj.last_msg["d"]["rpcVersion"])
        self.sendText(response)
        logToFile(response)

      case 2:
        ; identify
        OutputDebug "identified`n"
      Default:
        logToFile(Jxon_Dump(shared_obj.last_msg))
    }
  }

  ; Создаём отдельный поток для мониторинга Telegram
  script := "
  (
    shared_obj := CriticalObject(a_args[1]) ; get CriticalObject from pointer
    lpCS := CriticalObject(shared_obj,2) ; get CriticalSection
    #Include %A_appdata%\AutoRecord\src\Lib\Telegram.ahk
    )"
  tg_td := ThreadObj(script, ObjPtr(shared_obj) "")
  ; Создаём отдельный поток для мониторинга Whatsapp
  script := "
  (
    shared_obj := CriticalObject(a_args[1]) ; get CriticalObject from pointer
    lpCS := CriticalObject(shared_obj,2) ; get CriticalSection
    #Include %A_appdata%\AutoRecord\src\Lib\Whatsapp.ahk
  )"
  wa_td := ThreadObj(script, ObjPtr(shared_obj) "") ; Here is pointer to CO
  ; handle signal to send notification
  OnMessage(0xFF01, SendNotification)
  ; handle signal to send command to OBS websocket
  OnMessage(0xFF02, sendOBSCommand)
}
catch as e {
  logError(e)
}

sendOBSCommand(wParam, lParam, msg, hwnd)
{
    response := HandleMiddlewareMessage(wParam, lParam, msg, hwnd)
    logToFile(response)
    obs_connection.sendText(response)
    return 
}

#Include ExternalLib\WebSocket.ahk
#Include ExternalLib\JXON.ahk
#Include <logError>
#Include <logToFile>
#Include <SendNotification>
#Include <HandleMiddlewareMessage>