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
; ru_array := ["Просмотр медиа", "Выбор файлов", "Russian"]
; port_array := ["Visualizador de Mídia", "Escolher Arquivos", "Portuguese"]
french_array := ["Lecteur multimédia", "Choisir des fichiers", "French"]
; korean_array := ["미디어 뷰어", "파일 선택", "Korean"]
; italian_array := ["", "", "Italian"]
; languages_array := [en_array, ru_array, port_array, french_array]
languages_array := [en_array, french_array]
; хранит массив языка после определения
chosen_language := []

Loop
{
    try {
        ; Проверяем на наличиее процесса Telegram
        if WinExist("ahk_id" telegram_id) != 0 {
            ; получаем список окон Telegram
            telegram_window_list := WinGetList("ahk_exe Telegram.exe")
            ; Если окон больше одного, то перебираем их на наличие окна со звонком
            if telegram_window_list.Length > 1 {
                ; Метка для выхода из цикла
                languageDefining:
                    for window in telegram_window_list {
                        title := WinGetTitle("ahk_id" window)
                        if chosen_language.Length = 0 {
                            ; Если язык неизвестен, пробуем определить, попутно перебирая все возможные варианты
                            for language in languages_array {
                                for title_string in language {
                                    if InStr(title, title_string) != 0 {
                                        chosen_language := language
                                        SendToast("Telegram language is defined as " chosen_language[3])
                                        break languageDefining
                                    }
                                }
                            }
                            if window != telegram_id && title != "Qt51513QWindowToolSaveBits" && WinGetClass("ahk_id" window) != "Qt51513QWindowPopupSaveBits" && RegExMatch(title,"^((?>(?!TelegramDesktop).)*)$")
                                handleRecording(window)

                        } else {
                            ; Если язык известен, то сокращаем перебор
                            if window != telegram_id && title != "Qt51513QWindowToolSaveBits" && WinGetClass("ahk_id" window) != "Qt51513QWindowPopupSaveBits" && RegExMatch(title, "^((?>(?!" chosen_language[1] ")(?!" chosen_language[2] ")(?!TelegramDesktop).)*)$")
                                handleRecording(window)
                        }
                    }
                break_languageDefining:

                }
            ; Если Telegram был закрыт - ждём новый
            } else {
                chosen_language := []
                telegram_id := WinWait("ahk_exe Telegram.exe")
                telegram_pid := WinGetPID("ahk_exe Telegram.exe")
            }
        }
        catch as e {
            logError(e)
        }
        ; Задержка перед новой поиском
        Sleep check_delay
    }

    ; Подключаем внешние скрипты
#Include %A_AppData%\AutoRecord\Lib
#Include logInfo.ahk
#Include logError.ahk
#Include handleRecording.ahk
#Include SendToast.ahk