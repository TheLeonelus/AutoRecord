#NoTrayIcon

SendToast("Whatsapp module initialized.")

GroupAdd "window_call_titles", "Voice call ‎- WhatsApp"
GroupAdd "window_call_titles", "Аудиозвонок ‎- WhatsApp"
GroupAdd "window_call_titles", "Chiamata vocale ‎- WhatsApp"

Loop
{
    try {
        ; looking for whatsapp window
        window_id := WinWait("ahk_group window_call_titles")
        handleRecording(window_id)
    }
    catch as e {
        logError(e)
    }
    ; delay between new loop
    Sleep check_delay
}

; Подключаем внешние скрипты
#Include %A_AppData%\AutoRecord\Lib
#Include logError.ahk
#Include handleRecording.ahk
#Include SendToast.ahk