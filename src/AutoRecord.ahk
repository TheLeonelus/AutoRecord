#SingleInstance Force
Persistent

if A_IsCompiled = 0 {
  SetWorkingDir(A_AppData "\AutoRecord")
  OutputDebug("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey")
  OutputDebug("A_IsCompiled = " A_IsCompiled)
}
A_ScriptName := "AutoRecord V1.1"

; object to control access to CS
control_CO := { check_delay: 500 }
; object to write and share messages from OBS
shared_msg_obj := { last_message: "{}", last_request_response: "{}" }
; object to share log's FileObject
shared_log_obj := { info_log: FileOpen(A_AppData "\AutoRecord\info.log", "a") }

try {

  ; looking for obs, if not found, trying to start it
  if !ProcessExist("obs64.exe") {
    try {
      Run("C:\Program Files\obs-studio\bin\64bit\obs64.exe", "C:\Program Files\obs-studio\bin\64bit\")
      logToFile("OBS wasn't found, trying to start it up")
    }
    catch {
      MsgBox("OBS wasn`t found. Please try to start it up manually.", , 0x2)
    }
  }
  try {
    obs_connection := WebSocket("ws://127.0.0.1:4455/", {
      message: (self, data) => manageOBSMessages(self, data),
      close: (self, status, reason) => logToFile(status ' ' reason '`n', 2),
    })
  } catch {
    logToFile("websocket is dead`n")
  }
  script := "
  (
    Alias(control_CO:={}, ahkGetVar('control_CO', 1, A_MainThreadID))
    Alias(shared_msg_obj:={}, ahkGetVar('shared_msg_obj', 1, A_MainThreadID))
    Alias(shared_log_obj:={}, ahkGetVar('shared_log_obj', 1, A_MainThreadID))
  )"
  ; Thread to look for Telegram
  tg_td := Worker(script "`n#Include <Telegram>")
  ; Thread to look for Whatsapp
  wa_td := Worker(script "`n#Include <Whatsapp>")

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
    shared_msg_obj.last_message := data
    parsed_message := JSON.parse(data)
    logToFile("opCode: " parsed_message["op"] "`n")
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
        shared_msg_obj.last_request_response := data
      }
      Default:
        OutputDebug "received not handled message"
    }
  }

}
catch as e {
  logToFile(e, 3)
}

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode)
{
  MsgBox("Exiting")
  return 0  ; Callbacks must return non-zero to avoid exit.
  ; Do not call ExitApp -- that would prevent other callbacks from being called.
}

#Include ExternalLib\WebSocket.ahk

#Include <logToFile>
#Include <SendNotification>
#Include <HandleMiddlewareMessage>