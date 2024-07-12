#NoTrayIcon

SendMiddlewareMessage("Telegram module initialized.", 0xFF01)

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
            if telegram_window_list.Length > 1 {
                for i, window in telegram_window_list {
                    window_class := WinGetClass("ahk_id " window)
                    ; remove windows with wrong class/id from array
                    if window = telegram_id || window_class = "Qt51513QWindowToolSaveBits" || window_class = "WindowShadow" || window_class = "Qt51513QWindowPopupSaveBits"
                        telegram_window_list.RemoveAt(i)
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
                                        SendMiddlewareMessage("Telegram`'s language is defined as " chosen_language[3], 0xFF01)
                                        break languageDefining
                                    }
                                }
                            }
                            if RegExMatch(title,"^((?>(?!TelegramDesktop).)*)$")
                                handleRecording(window, title)
                        } else {
                            ; If language is defined - do simpler validation
                            if RegExMatch(title, "^((?>(?!" chosen_language[1] ")(?!" chosen_language[2] ")(?!TelegramDesktop).)*)$")
                                handleRecording(window, title)
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
        Sleep shared_obj.check_delay
    }

#Include %A_Appdata%\AutoRecord\src\Lib\logToFile.ahk
#Include %A_Appdata%\AutoRecord\src\Lib\logError.ahk
#Include %A_Appdata%\AutoRecord\src\Lib\handleRecording.ahk
#Include %A_Appdata%\AutoRecord\src\Lib\SendMiddlewareMessage.ahk