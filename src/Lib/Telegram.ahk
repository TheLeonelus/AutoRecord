#NoTrayIcon
logToFile("Telegram module is loaded.")
telegram_id := WinWait("ahk_exe Telegram.exe ahk_class Qt51513QWindowIcon")
/**
 * Stores `media viewer` window titles, because we can't distinguish it from window call otherwise
 * 
 * Languages' strings are in the following order:
 * 
 * English | Russian | Portugese | French | Korean | Italian
 */
languages_array := ["Media viewer", "Просмотр медиа", "Visualizador de Mídia", "Lecteur multimédia", "미디어 뷰어", "Visualizzatore multimediale"]
; keeps single string after language defining
chosen_language := ""
Loop
{
    try {
        DetectHiddenWindows(true) ; Telegram hides main window instead of closing
        if WinExist("ahk_id " telegram_id) != 0 { ; Check if Telegram is still opened
            DetectHiddenWindows(false) ; Telegram creates some weird hidden windows
            telegram_window_list := WinGetList("ahk_exe Telegram.exe")
            len := telegram_window_list.Length
            if len > 1 {
                toLog := "other "
                ; Filtering Telegram windows with reversed loop, thus .RemoveAt produce expected behaviour
                loop len {
                    index := len - A_Index + 1
                    window_class := WinGetClass("ahk_id " telegram_window_list[index])
                    toLog := toLog " | " telegram_window_list[index] " | " window_class
                    ; remove windows with wrong class/id from array
                    if (telegram_window_list[index] = telegram_id || StrCompare(window_class, "Qt51513QWindowIcon", false)) {
                        telegram_window_list.RemoveAt(index)
                    }
                }
                OutputDebug("TG id: " telegram_id " | " toLog)
                ; Label for exiting outer Loop
                languageDefining:
                for window in telegram_window_list {
                    title := WinGetTitle("ahk_id" window)
                    if chosen_language = "" {
                        ; If language is unknown - look for all languages and try to define it
                        for language in languages_array {
                            if InStr(title, language) != 0 {
                                global chosen_language := language
                                logToFile("Telegram's language is defined as " chosen_language)
                                break languageDefining
                            }
                        }
                        if RegExMatch(title, "^((?>(?!TelegramDesktop).)*)$")
                            handleRecording(window, title)
                    } else {
                        ; If language is defined - do simpler validation
                        if RegExMatch(title, "^((?>(?!" chosen_language ")(?!TelegramDesktop).)*)$")
                            handleRecording(window, title)
                    }
                }
            }
        } else {
            ; Waiting for Telegram to be opened again
            DetectHiddenWindows(false) ; Telegram creates some weird hidden windows
            global chosen_language := ""
            global telegram_id := WinWait("ahk_exe Telegram.exe")
        }
    }
    catch as e {
        logToFile(e, 3)
        pause(1)
    }
    ; Delay before new loop
    Sleep shared_obj.check_delay
}

#Include <logToFile>
#Include <handleRecording>