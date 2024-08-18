#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force
Persistent

OutputDebug("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey`n")
TraySetIcon("*",, true)
A_ScriptName := "AutoRecord V1.1"
TrayTip("AutoRecord was initialized.", A_ScriptName, 0x4)

try {
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
  global shared_obj := { check_delay: 1000, last_message: "{}", last_request_response: "{}", info_log: openLogFile(), record_status: 0, script_hwnd: A_ScriptHwnd }
  initialize_OBS()
  script := "
  (
  Alias(shared_obj:={}, ahkGetVar('shared_obj', 1, A_MainThreadID))
  )"
  ; Thread to look for Telegram
  tg_td := Worker(script "`n#Include <Telegram>", , "Telegram " A_ScriptName)
  ; Thread to look for Whatsapp
  wa_td := Worker(script "`n#Include <Whatsapp>", , "Whatsapp " A_ScriptName)

  OnMessage(0xFF01, SendNotification)
  OnMessage(0xFF02, sendOBSCommand)
  OnMessage(0xFF03, stopApplication)
}
catch as e {
  logToFile(e, 3)
}

/**
 * Check if .log file exists or create and write in it
 * if it's size exceeds limit - replace it to .old and create the new one.
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
#Include <OBSFunctions>
#Include <logToFile>
#Include <ReceiveCallbacks>