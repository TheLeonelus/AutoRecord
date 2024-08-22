/**
 * generate custom tray menu
 */
fillTrayMenu() {
    ; remove default tray menu and create new one
    tray_menu := A_TrayMenu
    tray_menu.Delete()
    if !A_IsCompiled
        tray_menu.AddStandard() ; for debugging
    tray_menu.Add("Settings", gui_settings)
    tray_menu.Add() ; separator
    tray_menu.Add("Open folder logs", logOpen)
    tray_menu.Add("Check for updates", checkForUpdates)
    tray_menu.Add("About", about)
    tray_menu.Add() ; separator
    tray_menu.Add("Reload", menuReload)
    tray_menu.Add("Exit", menuExit)
    ; ================================
    /**
     * open logs file
     */
    gui_settings(*) {
        ; Create settings GUI
        settings := Gui()
        settings.SetFont("s10 Q5 bold", "Arial")
        settings.Add("Text", "WP+400 Center", "Settings")
        settings.Add("Progress", "w400 h5 c" GetSysColor(), 100)
        settings.SetFont("s10 Q5 norm", "Arial")
        checkbox_array := [
            "Check for updates",
            "Telegram",
            "Whatsapp"
        ]
        for key, value in shared_obj.settings {
            switch A_Index {
                case 1:
                    settings.Add("Text", "Section",
                        "Toggle check for updates at the start of the application")
                    key := settings.AddCheckBox("Checked" value " v" key, checkbox_array[A_Index])
                    key.OnEvent("Click", ProcessUserInput)
                    settings.Add("Text", "Section",
                        "`nToggle renaming of a record at the end of the recording for:")
                default:
                    key := settings.AddCheckBox("Checked" value " v" key, checkbox_array[A_Index])
                    key.OnEvent("Click", ProcessUserInput)

            }

        }
        settings.Show("AutoSize Center")
        ProcessUserInput(GuiCtrlObj, *) {
            shared_obj.settings[GuiCtrlObj.Name] := GuiCtrlObj.Value
            setSettings(true)
        }
    }

    logOpen(*) {
        chars := DllCall("GetFinalPathNameByHandle", "Ptr", shared_obj.info_log.Handle, "Ptr", 0, "UInt", 0, "UInt", 0)
        VarSetStrCapacity(&filePath, chars)
        DllCall("GetFinalPathNameByHandle", "Ptr", shared_obj.info_log.Handle, "Str", filePath, "UInt", chars, "UInt", 0)
        filePath := RegExReplace(filePath, "^\\\\\?\\")
        Run(filePath)
    }

    checkForUpdates(*) {
        ; Check for updates here
        AutoUpdateChecker(true)
        return 0
    }

    about(*) {
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

    GetSysColor() {
        reg_value := RegRead("HKCU\SOFTWARE\Microsoft\Windows\DWM", "AccentColor")
        return_value := RegExReplace(Format("{:X}", reg_value), "i).{2}(.{6})", "$1",)
        Return return_value
    }

    menuReload(*) {
        Reload()
    }
    menuExit(*) {
        ExitApp(1)
    }
}

#Include <AutoUpdateChecker>