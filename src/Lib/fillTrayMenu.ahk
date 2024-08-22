/**
 * generate custom tray menu
 */
fillTrayMenu() {
    ; Create settings submenu
    submenu_settings := Menu()
    submenu_array := ["Show prompt to change label (TG)", "Show prompt to change label (WA)", "Check for updates at start"]
    settings_array := [] ; keep setting keys to access it later
    for key, value in shared_obj.settings {
        settings_array.Push(key)
        submenu_settings.Add(submenu_array[A_Index], settingToggle)
        value ? submenu_settings.Check(submenu_array[A_Index]) : ""
    }
    submenu_array := unset
    ; remove default tray menu and create new one
    tray_menu := A_TrayMenu
    tray_menu.Delete()
    if !A_IsCompiled
        tray_menu.AddStandard() ; for debugging
    tray_menu.Add("Settings", submenu_settings)
    tray_menu.Add("Open logs", logOpen)
    tray_menu.Add("Check for updates", checkForUpdates)
    tray_menu.Add("About", about)
    tray_menu.Add() ; separator
    tray_menu.Add("Reload", menuReload)
    tray_menu.Add("Exit", menuExit)
    ; ================================
    /**
     * open logs file
     */
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
    /**
     * @param {String} ItemName 
     * @param {Number} ItemPos 
     * @param {Menu} MenuObject 
     * 
     * change setting value and save it
     */
    settingToggle(ItemName, ItemPos, MenuObject) {
        shared_obj.settings[settings_array[ItemPos]] := Abs(shared_obj.settings[settings_array[ItemPos]] - 1)
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

#Include <AutoUpdateChecker>