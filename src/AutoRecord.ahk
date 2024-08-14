#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force
Persistent

if A_IsCompiled = 0 {
  SetWorkingDir(A_AppData "\AutoRecord")
  OutputDebug("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey" "`n")
  OutputDebug("A_IsCompiled = " A_IsCompiled "`n")
}

A_ScriptName := "AutoRecord V1.1"
TrayTip("AutoRecord was initialized.", A_ScriptName, 0x4)

/**
 * @property {Integer} check_delay - stores time which Sleep occurs, so we can change it at one place only
 * @property {String} last_message - stores last received message from OBS
 * @property {String} last_request_response - stores last receive response message from OBS
 * @property {Object} info_log - stores `FileObject` to `info.log`
 * @property {Integer} record_status - stores status of recording, so we can keep different subthreads from accesing `handleRecording` simultaneously
 * @property {Number} script_hwnd - stores HWND of main script, so sub-threads can use it in sendMessage()
 * 
 * DONT DESTRUCT OBJECT
 * 
 * Object declaration is used, so local functions would explicitly access global object variable, which stores in it's properties shared variables
 * 
 * If I'd deconstruct it and make multiple alliases, it'd start some shenanigans with local-global assignment, which i'm not very good at
 */
shared_obj := { check_delay: 1000, last_message: "{}", last_request_response: "{}", info_log: openLogFile(), record_status: 0, script_hwnd: A_ScriptHwnd }
try {
  initialize_OBS()
  script := "
  (
  Alias(shared_obj:={}, ahkGetVar('shared_obj', 1, A_MainThreadID))
  )"
  ; Thread to look for Telegram
  tg_td := Worker(script "`n#Include <Telegram>", , "Telegram " A_ScriptName)
  ; Thread to look for Whatsapp
  wa_td := Worker(script "`n#Include <Whatsapp>", , "Whatsapp " A_ScriptName)
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
        self.sendText(request)
      case 7:
      {
        shared_obj.last_request_response := data
      }
      case 5:
        if parsed_message["d"]["eventType"] = "ExitStarted" {
          reinitialize_OBS()
        }
      Default:
        OutputDebug "received not handled message`n"
    }
  }

}
catch as e {
  logToFile(e, 2)
}

/**
 * Call this function if you need to create new connection to websocket or OBS was closed
 */
reinitialize_OBS() {
  ; pause sub-threads
  tg_td_pause := tg_td.Pause(1)
  wa_td_pause := wa_td.Pause(1)
  logToFile("stopped threads`n")
  global obs_connection := ""
  if ProcessExist("obs64.exe") {
    DetectHiddenWindows True
    SetTitleMatchMode 2
    ids_array := WinGetList("ahk_exe obs64.exe")
    for id in ids_array
      GroupAdd "OBS", "ahk_id " id
    WinWaitClose("ahk_group OBS")
    logToFile("obs is closed`n")
    MsgBox("OBS was closed! AutoRecord is paused until you start OBS again!", A_ScriptName, 0x1000)
    WinWait("ahk_exe obs64.exe")
    logToFile("obs is opened`n")
  }
  initialize_OBS()
  ; unpause sub-threads
  tg_td_pause := tg_td.Pause(0)
  wa_td_pause := wa_td.Pause(0)
}
/**
 * Tries to start up OBS and connect to OBS-websocket
 */
initialize_OBS() {
initialize_OBS:
  ; looking for obs, if not found, trying to start it
  if !ProcessExist("obs64.exe") {
    try {
      Run("C:\Program Files\obs-studio\bin\64bit\obs64.exe", "C:\Program Files\obs-studio\bin\64bit\")
      logToFile("OBS wasn't found, trying to start it up")
      WinWait("ahk_exe obs64.exe", , shared_obj.check_delay * 20)
    }
    catch {
      MsgBox("OBS could not be started automatically. Please try to start it up manually.", , 0x0 0x1000)
      WinWait("ahk_exe obs64.exe")
    }
  }
  Sleep(shared_obj.check_delay)
  ; try to create websocket instance and connect to server
  try {
    Global obs_connection := WebSocket("ws://127.0.0.1:4455/", {
      message: (self, data) => manageOBSMessages(self, data),
      close: (self, status, reason) => (reinitialize_OBS(), logToFile(status ' ' reason '`n', 2)) },
    )
  } catch {
    logToFile("websocket is dead`n")
    switch MsgBox("OBS web-socket couldn't be connected automatically! Retry to connect?", A_ScriptName, 0x1004) {
      case "Yes":
        ; TODO: replace goto because bad
        goto initialize_OBS
      case "No":
        ExitApp()
    }
  }
}

/**
 * Check if .log file exists, if it's not, then create and write in it
 * if it's size exceeds limit - rename/replace it to .old and create the new one.
 * @returns {File} - opened object of `info.log`
 */
openLogFile() {
  OutputDebug(A_WorkingDir "`n")
  log_path := A_AppData "\AutoRecord\info.log"
  old_log_path := A_AppData "\AutoRecord\info.log.old"
  OutputDebug(FileExist(log_path) " flags | size " FileGetSize(log_path, "K") "`n")
  if FileExist(log_path) != "" {
    if FileGetSize(log_path, "K") >= 1000 {
      OutputDebug(log_path " is too big! Rotating...`n")
      FileMove(log_path, old_log_path, 1)
    }
  }
  return FileOpen(log_path, "a")
}

/**
 * callback for `sendMessage` to exit whole application
 */
stopApplication(wParam, lParam, msg, hwnd) {
  message := HandleMiddlewareMessage(wParam, lParam, msg, hwnd)
  MsgBox("Crtical error has occured!`nError: " message "`nPlease restart AutoRecord or contact your support.", ,"0x1000 T10")
  ExitApp()
}

OnExit ExitFunc
/**
 * 
 * @param {String} ExitReason
 * @param {Integer} ExitCode
 * @returns {Integer} 
 */
ExitFunc(ExitReason, ExitCode)
{
  if ExitReason = "Menu" || ExitReason = "Single" {
    switch MsgBox("Are you sure you want to exit?", , 0x4) {
      case "Yes":
        return 0  ; Callbacks must return non-zero to avoid exit.
      case "No":
        return 1
    }
  }
  return 0
}

#Include ExternalLib\WebSocket.ahk
#Include <logToFile>
#Include <SendNotification>
#Include <HandleMiddlewareMessage>