#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force
Persistent

TraySetIcon("*", , true)
A_ScriptName := "AutoRecord V1.1"
TrayTip(A_ScriptName " was initialized.", , 0x4)

try {
  /**
   * @property {Integer} check_delay - unified time to wait for anything
   * @property {String} last_message - last received message from OBS
   * @property {String} last_request_response - last received response message from OBS
   * @property {Object} info_log - `FileObject` to `info.log`
   * @property {Integer} record_status - status of recording, which stops different subthreads from accesing `handleRecording` simultaneously
   * @property {Number} script_hwnd - HWND of main script to use it sub-threads `sendMessage()`
   * @property {Map} settings - map object with settings parameters
   * @property {Boolean} tg_label - show prompt at the end of Telegram recording 
   * @property {Boolean} wa_label - show prompt at the end of Whatsapp recording 
   * @property {Boolean} do_check_updates - check for updates at the startup
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
      "tg_label", 0,
      "wa_label", 0,
      "do_check_updates", 0
    )
  }
  setSettings()
  logToFile(A_ScriptDir)
  initializeOBS()
  fillTrayMenu()
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
  }
}

OnExit ExitFunc
/**
 * @param {String} ExitReason
 * @param {Integer} ExitCode
 */
ExitFunc(ExitReason, ExitCode)
{
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

/**
 * generate custom tray menu
 */
fillTrayMenu() {
  tray_menu := A_TrayMenu
  tray_menu.Delete()
  if !A_IsCompiled
    tray_menu.AddStandard()
  tray_menu.Add() ; separator
  submenu_settings := Menu()
  submenu_array := ["Don't ask for Telegram label", "Don't ask for Whatsapp label", "Check for updates at start"]
  settings_array := []
  for key, value in shared_obj.settings {
    settings_array.Push(key)
    submenu_settings.Add(submenu_array[A_Index], settingToggle)
    value ? submenu_settings.Check(submenu_array[A_Index]) : ""
  }
  tray_menu.Add("Settings", submenu_settings)
  tray_menu.Add("Open logs", logOpen)
  tray_menu.Add("Check for updates", checkForUpdates)
  tray_menu.Add("About", about)
  tray_menu.Add() ; separator
  tray_menu.Add("Reload", menuReload)
  tray_menu.Add("Exit", menuExit)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  logOpen(*) {
    chars := DllCall("GetFinalPathNameByHandle", "Ptr", shared_obj.info_log.Handle, "Ptr", 0, "UInt", 0, "UInt", 0)
    VarSetStrCapacity(&filePath, chars)
    DllCall("GetFinalPathNameByHandle", "Ptr", shared_obj.info_log.Handle, "Str", filePath, "UInt", chars, "UInt", 0)
    filePath := RegExReplace(filePath, "^\\\\\?\\")
    Run(filePath)
  }
  checkForUpdates(*) {
    ; Run here function to check for updates
    return 0
  }
  about(*) {
    GetSysColor()
    {
      reg_value := RegRead("HKCU\SOFTWARE\Microsoft\Windows\DWM", "AccentColor")
      return_value := RegExReplace(Format("{:X}", reg_value), "i).{2}(.{6})", "$1",)
      Return return_value
    }
    about_menu := Gui()
    about_menu.SetFont("s10 Q5", "Arial")
    about_menu.Add("Text", "WP+250", A_ScriptName "`nAutomating calls` recording from Telegram and Whatsapp Messengers")
    about_menu.AddLink(, '<a href="https://github.com/TheLeonelus/AutoRecord/blob/main/LICENSE">WTFPL License @ 2024</a>')
    about_menu.Add("Progress", "w5 h100 ys c" GetSysColor(), 100)
    about_menu.AddLink("ys", '
    (
    <a href="https://github.com/TheLeonelus/AutoRecord">Source code</a>`nCreated by:
    - <a href="https://github.com/PavelLange666">PavelLange666</a>
    - <a href="https://github.com/TheLeonelus">TheLeonelus</a> 
    )')
    about_menu.Show("AutoSize Center")

  }

  TestRename(*)
  {
    static OldName := "", NewName := ""
    if NewName != "renamed"
    {
      OldName := "TestRename"
      NewName := "renamed"
    }
    else
    {
      OldName := "renamed"
      NewName := "TestRename"
    }
    tray_menu.Rename(OldName, NewName)
  }

  settingToggle(ItemName, ItemPos, MenuObject) {
    temp := shared_obj.settings[settings_array[ItemPos]]
    shared_obj.settings[settings_array[ItemPos]] := Abs(temp - 1)
    setSettings(true)
    MenuObject.ToggleCheck(ItemName)
  }

  menuReload(*) {
    Reload()
  }
  menuExit(*) {
    ExitApp(1)
  }
}

#Include ExternalLib\WebSocket.ahk
#Include <OBSFunctions>
#Include <logToFile>
#Include <ReceiveCallbacks>