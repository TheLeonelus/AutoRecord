#NoTrayIcon
logToFile("Telegram module is loaded.")
telegram_id := WinWait("ahk_exe Telegram.exe ahk_class Qt51513QWindowIcon")
telegram_pid := WinGetPID("ahk_exe Telegram.exe")
telegram_window_list := []
/*
Here language arrays are defined with their respective title strings
To add new one we need to define it and add into languages_array afterwards
*/
en_array := ["Media viewer", "English"]
ru_array := ["Просмотр медиа", "Russian"]
port_array := ["Visualizador de Mídia", "Portuguese"]
french_array := ["Lecteur multimédia", "French"]
; korean_array := ["미디어 뷰어", "파일 선택", "Korean"]
; italian_array := ["", "", "Italian"]
languages_array := [en_array, ru_array, port_array, french_array]
; keeps single array after language defining
chosen_language := []
Loop
{
    try {
        ; Checking if Telegram is still opened
        if WinExist("ahk_id " telegram_id) != 0 {
            ; Retrieve window list
            telegram_window_list := WinGetList("ahk_exe Telegram.exe")
            len := telegram_window_list.Length
            if len > 1 {
                ; Filtering Telegram windows
                loop len {
                    index := len - A_Index + 1
                    window_class := WinGetClass("ahk_id " telegram_window_list[index])
                    ; remove windows with wrong class/id from array
                    if (telegram_window_list[index] = telegram_id || StrCompare(window_class, "Qt51513QWindowIcon", false)) {
                        telegram_window_list.RemoveAt(index)
                    }
                }
                ; Label for exiting outer Loop
                languageDefining:
                for window in telegram_window_list {
                    title := WinGetTitle("ahk_id" window)
                    if chosen_language.Length = 0 {
                        ; If language is unknown - try to define it, then start record
                        for language in languages_array {
                            for title_string in language {
                                if InStr(title, title_string) != 0 {
                                    chosen_language := language
                                    SendMiddlewareMessage("Telegram`'s language is defined as " chosen_language[2], 0xFF01)
                                    break languageDefining
                                }
                            }
                        }
                        if RegExMatch(title, "^((?>(?!TelegramDesktop).)*)$")
                            handleRecording(window, title)
                    } else {
                        ; If language is defined - do simpler validation
                        if RegExMatch(title, "^((?>(?!" chosen_language[1] ")(?!TelegramDesktop).)*)$")
                            handleRecording(window, title)
                    }
                }
            }
            ; Waiting for Telegram to be opened again
        } else {
            chosen_language := []
            telegram_id := WinWait("ahk_exe Telegram.exe")
            telegram_pid := WinGetPID("ahk_exe Telegram.exe")
        }
    }
    catch as e {
        logToFile(e, 3)
    }
    ; Delay before new loop
    Sleep shared_obj.check_delay
}

#Include <logToFile>
#Include <handleRecording>
#Include <SendMiddlewareMessage>