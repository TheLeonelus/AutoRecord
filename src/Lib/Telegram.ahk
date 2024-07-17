#NoTrayIcon

SendToast("Telegram module initialized.")

telegram_id := WinWait("ahk_exe Telegram.exe")
telegram_pid := WinGetPID("ahk_exe Telegram.exe")
telegram_window_list := []

/*
Здесь объявляются массивы строк для разных языков
Для добавления нового языка необходимо добавить новый язык с заголовками окон выбора файла, просмотра медиа и выбора изображения на аватарку
После чего добавить его в двумерный массив languages_array
*/
en_array := ["Media viewer", "Choose Files", "English"]
ru_array := ["Просмотр медиа", "Выбор файлов", "Russian"]
port_array := ["Visualizador de Mídia", "Escolher Arquivos", "Portuguese"]
french_array := ["Lecteur multimédia", "Choisir des fichiers", "French"]
; korean_array := ["미디어 뷰어", "파일 선택", "Korean"]
; italian_array := ["", "", "Italian"]
languages_array := [en_array, ru_array, port_array, french_array]
; keeps single array after language defining
chosen_language := []

Loop
{
    try {
        ; Проверяем на наличие процесса Telegram
        if WinExist("ahk_id" telegram_id) != 0 {
            ; получаем список окон Telegram
            telegram_window_list := WinGetList("ahk_exe Telegram.exe")
            ; Если окон больше одного, то перебираем их на наличие окна со звонком
            ; Если окон больше одного, то перебираем их на наличие окна со звонком
            len := telegram_window_list.Length
            if len > 1 {
                loop len {
                    index := len - A_Index + 1
                    window_class := WinGetClass("ahk_id " telegram_window_list[index])
                    OutputDebug StrCompare(window_class, "Qt51513QWindowIcon", false)
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
                                    SendToast("Telegram`'s language is defined as " chosen_language[3])
                                    break languageDefining
                                }
                            }
                        }
                        if RegExMatch(title, "^((?>(?!TelegramDesktop).)*)$")
                            handleRecording(window)
                    } else {
                        ; If language is defined - do simpler validation
                        if RegExMatch(title, "^((?>(?!" chosen_language[1] ")(?!" chosen_language[2] ")(?!TelegramDesktop).)*)$")
                            handleRecording(window)
                    }
                }
                break_languageDefining:
            }
            ; Waiting for Telegram if it was closed
        } else {
            chosen_language := []
            telegram_id := WinWait("ahk_exe Telegram.exe")
            telegram_pid := WinGetPID("ahk_exe Telegram.exe")
        }
    }
    catch as e {
        logError(e)
    }
    ; Delay before new loop
    Sleep check_delay
}

#Include <logToFile>
#Include <logError>
#Include <handleRecording>
#Include <SendToast>