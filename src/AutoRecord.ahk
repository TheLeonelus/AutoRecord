#SingleInstance
Persistent

if !A_IsCompiled {
  SetWorkingDir(A_AppData "\AutoRecord")
  MsgBox("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey")
  MsgBox(A_ScriptFullPath)
}
A_ScriptName := "AutoRecord V1.1"

shared_var_obj := CriticalObject({ check_delay: 500 })
shared_msg_obj := CriticalObject({ last_message: "", last_request_response: "" })
shared_log_obj := CriticalObject({ info_log_file: FileOpen(A_AppData "\AutoRecord\info.log", "a") })
msg_CS := CriticalObject(shared_msg_obj, 2)


; defining criticalobject variables for managing access to operations between threads

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
      message: (self, data) => manageOBSMessages(self, data),
      close: (self, status, reason) => logToFile(status ' ' reason '`n'),
    })
  } catch as e {
    OutputDebug("websocket is ded`n")
  }
  script := "
  (
    ; get CriticalObjects from pointer
    shared_var_obj := CriticalObject(a_args[1])
    shared_msg_obj := CriticalObject(a_args[2])
    shared_log_obj := CriticalObject(a_args[3])
    ; get CriticalSections
    var_CS := CriticalObject(shared_var_obj,2)
    )"
  ; Thread to look for Telegram
  tg_td := ThreadObj(script "`n#Include <Telegram>", ObjPtr(shared_var_obj) " " ObjPtr(shared_msg_obj) " " ObjPtr(shared_log_obj))
  ; Thread to look for Whatsapp
  wa_td := ThreadObj(script "`n#Include <Whatsapp>", ObjPtr(shared_var_obj) " " ObjPtr(shared_msg_obj) " " ObjPtr(shared_log_obj))
  ; handle signal to send notification
  OnMessage(0xFF01, SendNotification)
  ; handle signal to send command to OBS websocket
  OnMessage(0xFF02, sendOBSCommand)

sendOBSCommand(wParam, lParam, msg, hwnd)
{
  response := HandleMiddlewareMessage(wParam, lParam, msg, hwnd)
  logToFile("Got msg to send: " response)
  obs_connection.sendText(response)
  return true
}


; handle responses from server
manageOBSMessages(self, data) {
  ; write response to logs and shared object
  logToFile("Received: " data '`n')
  TryEnterCriticalSection(msg_CS)
  shared_msg_obj.last_message := data
  LeaveCriticalSection(msg_CS)
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
        OutputDebug "Setting record output name"
        request := "
        (
        {
            "op": 6,
            "d": {
                "requestType": "SetProfileParameter",
                "requestId": "profile_args_set",
                "requestData": {
                    "parameterCategory": "Output",
                    "parameterName": "FilenameFormatting",
                    "parameterValue": "%DD-%MM %hh-%mm-%ss"
                }
            }
        }
        )"
        obs_connection.sendText(request)
    case 7:
    {
      TryEnterCriticalSection(msg_CS)
      shared_msg_obj.last_request_response := data
      LeaveCriticalSection(msg_CS)
    }
    Default:
      OutputDebug data
  }
}

#Include ExternalLib\WebSocket.ahk

#Include <logToFile>
#Include <SendNotification>
#Include <HandleMiddlewareMessage>