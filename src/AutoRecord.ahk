#SingleInstance Force
Persistent

if A_IsCompiled = 0 {
  SetWorkingDir(A_AppData "\AutoRecord")
  OutputDebug("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey" "`n")
  OutputDebug("A_IsCompiled = " A_IsCompiled "`n")
}

A_ScriptName := "AutoRecord V1.1"
DetectHiddenWindows True
SetTitleMatchMode 2

/**
 * @property {Integer} check_delay - stores time which Sleep occurs, so we can change it at one place only
 * @property {String} last_message
 * @property {String} last_request_response
 * @property {Object} info_log
 * <br> DONT DESTRUCT OBJECT
 * <br> Object declaration is used, so local functions would explicitly access global object variable, which stores in it's properties shared variables
 * <br> If I'd deconstruct it and make multiple alliases, it'd start some shenanigans with local-global assignment, which i'm not very good at
 */
shared_obj := { check_delay: 500, last_message: "{}", last_request_response: "{}", info_log: FileOpen(A_AppData "\AutoRecord\info.log", "a"), record_status: 0, script_hwnd: A_ScriptHwnd }

try {
  ; looking for obs, if not found, trying to start it
  if !ProcessExist("obs64.exe") {
    try {
      Run("C:\Program Files\obs-studio\bin\64bit\obs64.exe", "C:\Program Files\obs-studio\bin\64bit\")
      logToFile("OBS wasn't found, trying to start it up")
      WinWait("ahk_exe obs64.exe", , 10000)
    }
    catch {
      MsgBox("OBS wasn`t found. Please try to start it up manually.", , 0x2)
    }
  }
  try {
    Global obs_connection := WebSocket("ws://127.0.0.1:4455/", {
      message: (self, data) => manageOBSMessages(self, data),
      close: (self, status, reason) => logToFile(status ' ' reason '`n', 2),
    })
  } catch {
    logToFile("websocket is dead`n")
  }
  script := "
  (
  Alias(shared_obj:={}, ahkGetVar('shared_obj', 1, A_MainThreadID))
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
    ; write response to logs and shared_object
    logToFile("Received: " data '`n')
    shared_obj.last_message := data
    parsed_message := JSON.parse(data)
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
        Sleep shared_obj.check_delay
        self.sendText(response)
        logToFile("Sent: " response)

      case 2:
        ; identify
        OutputDebug "identified`n"
        Sleep shared_obj.check_delay
        OutputDebug "Setting record output name`n"
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
        shared_obj.last_request_response := data
      }
      Default:
        OutputDebug "received not handled message`n"
    }
  }

}
catch as e {
  logToFile(e, 2)
}

OnExit ExitFunc
ExitFunc(ExitReason, ExitCode)
{
  switch MsgBox("Are you sure you want to exit?", A_ScriptName, 0x4) {
    case "Yes":
      return 0  ; Callbacks must return non-zero to avoid exit.
    case "No":
      return 1
    default:
      return 0  ; Callbacks must return non-zero to avoid exit.
  }
}

#Include ExternalLib\WebSocket.ahk
#Include <logToFile>
#Include <SendNotification>
#Include <HandleMiddlewareMessage>