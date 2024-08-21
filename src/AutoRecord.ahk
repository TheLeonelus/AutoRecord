#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force
Persistent

if A_IsCompiled = 0 {
  SetWorkingDir(A_AppData "\AutoRecord")
  OutputDebug("AutoRecord.ahk - AutoHotkey v" A_AhkVersion " ahk_class AutoHotkey" "`n")
  OutputDebug("A_IsCompiled = " A_IsCompiled "`n")
}
A_ScriptName := "AutoRecord V1.2.0"
TrayTip("AutoRecord was initialized.", A_ScriptName, 0x4)


try {
  /**
   * @property {Integer} check_delay - unified time to wait for anything
   * @property {String} last_message - last received message from OBS
   * @property {String} last_request_response - last received response message from OBS
   * @property {Object} info_log - `FileObject` to `info.log`
   * @property {Integer} record_status - status of recording, which stops different subthreads from accesing `handleRecording` simultaneously
   * @property {Number} script_hwnd - HWND of main script to use it sub-threads `sendMessage()`
   * @property {Map} settings - map object with settings parameters
   * @property {Boolean} show_tg_label - show prompt at the end of Telegram recording 
   * @property {Boolean} show_wa_label - show prompt at the end of Whatsapp recording 
   * @property {Boolean} check_for_update - check for updates at the startup
   * 
   * DONT DESTRUCT OBJECT
   * 
   * Object declaration is used, so local functions can explicitly access global object variable, which stores in it's properties shared variables
   * 
   * If you would deconstruct it and make multiple alliases, it'd start some shenanigans with local-global assignment, which i'm not going to deal with
   */
  global shared_obj := {
    check_delay: 1000,
    last_message: "{}",
    last_request_response: "{}",
    info_log: openLogFile(),
    record_status: 0,
    script_hwnd: A_ScriptHwnd,
    settings: Map(
      "show_tg_label", 1,
      "show_wa_label", 1,
      "check_for_update", 1
    )
  }
  setSettings()
  fillTrayMenu()
  if shared_obj.settings["check_for_update"]
    AutoUpdateChecker() ; Check for updates here
  initializeOBS()
  script := "
  (
  Alias(shared_obj:={}, ahkGetVar('shared_obj', 1, A_MainThreadID))
  )"
  ; Thread for Telegram module
  tg_td := Worker(script "`n#Include <Telegram>", , A_ScriptName " | Telegram")
  ; Thread for Whatsapp module
  wa_td := Worker(script "`n#Include <Whatsapp>", , A_ScriptName " | Whatsapp")
  script := unset

  OnMessage(0xFF01, SendNotification)
  OnMessage(0xFF02, sendOBSCommand)
  OnMessage(0xFF03, stopApplication)
}
catch as e {
  logToFile(e, 3)
}

/**
 * @returns {File} - opened object of `info.log`
 * 
 * Check if .log file exists or create and write in it
 * if it's size exceeds limit - replace it to .old and create the new one.
 */
openLogFile() {
  OutputDebug(A_WorkingDir "`n")
  log_path := A_ScriptDir "\info.log"
  old_log_path := A_ScriptDir "\info.log.old"
  OutputDebug(FileExist(log_path) " flags | size " (FileExist(log_path) ? FileGetSize(log_path, "K") "`n" : ""))
  if FileExist(log_path) != "" {
    if FileGetSize(log_path, "K") >= 1000 {
      OutputDebug(log_path " is too big! Rotating...`n")
      FileMove(log_path, old_log_path, 1)
    }
  }
  return FileOpen(log_path, "a")
}

/**
 * @param {Boolean} rewrite - function can be called again with this param evaluated to true to rewrite file
 * 
 * Check if `settings.json` exists, otherwise create it
 * If file's content is valid json, then apply it to shared object and modify tray menu
 */
setSettings(rewrite := false) {
  settings_json_path := A_ScriptDir "\settings.json"
  if !FileExist(settings_json_path) || rewrite {
    settings_json := FileOpen(settings_json_path, "w")
    settings_json.Write(JSON.stringify(shared_obj.settings))
    settings_json.Close()
  } else {
    settings_json := FileOpen(settings_json_path, "a -d")
    settings_json.Seek(0, 0)
    settings_content := settings_json.Read()
    shared_obj.settings := JSON.parse(settings_content)
    settings_json.Close()
  }
}

OnExit ExitFunc
/**
 * @param {String} ExitReason
 * @param {Integer} ExitCode
 */
ExitFunc(ExitReason, ExitCode)
{
  shared_obj.info_log.Close()
  if ExitReason = "Menu" || ExitReason = "Single" || ExitCode = 1 {
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
#Include <fillTrayMenu>
#Include <AutoUpdateChecker>