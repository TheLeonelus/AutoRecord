#SingleInstance
Persistent

if !A_IsCompiled {
  SetWorkingDir(A_AppData "\AutoRecord")
  MsgBox("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey")
  MsgBox(A_ScriptFullPath)
}
A_ScriptName := "AutoRecord V1.1"


shared_obj := CriticalObject({ check_delay: 500, hotkey_delay: 100})
shared_msg_obj := CriticalObject({last_msg: ""})
lpCS := CriticalObject(shared_msg_obj, 2)

try {
  ; object to store shared variable between threads
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
  script := "
  (
    shared_obj := CriticalObject(a_args[1]) ; get CriticalObject from pointer
    shared_msg_obj := CriticalObject(a_args[2])
    lpCS := CriticalObject(shared_obj,2) ; get CriticalSection
    )"
  ; Thread to look for Telegram
  tg_td := ThreadObj(script "`n#Include <Telegram>", ObjPtr(shared_obj) "" " " ObjPtr(shared_msg_obj) "")
  ; Thread to look for Whatsapp
  wa_td := ThreadObj(script "`n#Include <Whatsapp>", ObjPtr(shared_obj) "" " " ObjPtr(shared_msg_obj) "")
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
  logToFile("Got msg to send: " response)
  obs_connection.sendText(response)
  return true
}

; handle responses from server
handleMessage(self, data) {
  ; write response to logs and shared object
  logToFile("Received: " data '`n')
  TryEnterCriticalSection(lpCS)
  shared_msg_obj.last_msg := data
  LeaveCriticalSection(lpCS)
  parsed_message := JSON.parse(data)
  OutputDebug "opCode: " parsed_message["op"] "`n"
  switch parsed_message["op"]
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
            )", parsed_message["d"]["rpcVersion"])
      self.sendText(response)
      logToFile(response)

    case 2:
      ; identify
      OutputDebug "identified`n"
    Default:
      OutputDebug ""
  }
}

#Include ExternalLib\WebSocket.ahk
#Include <logError>
#Include <logToFile>
#Include <SendNotification>
#Include <HandleMiddlewareMessage>