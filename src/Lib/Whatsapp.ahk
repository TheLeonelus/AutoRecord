#NoTrayIcon
Sleep(1000)
SendMiddlewareMessage("Whatsapp module initialized.", 0xFF01)

GroupAdd "window_call_titles", "Voice call ‎- WhatsApp"
GroupAdd "window_call_titles", "Аудиозвонок ‎- WhatsApp"
GroupAdd "window_call_titles", "Chiamata vocale ‎- WhatsApp"

Loop
{
    try {
        ; looking for whatsapp window
        window_id := WinWait("ahk_group window_call_titles")
        handleRecording(window_id, "Whatsapp")
    }
    catch as e {
        logError(e)
    }
    ; delay between new loop
    Sleep shared_obj.check_delay
}

#Include %A_Appdata%\AutoRecord\src\Lib\logToFile.ahk
#Include %A_Appdata%\AutoRecord\src\Lib\logError.ahk
#Include %A_Appdata%\AutoRecord\src\Lib\handleRecording.ahk
#Include %A_Appdata%\AutoRecord\src\Lib\SendMiddlewareMessage.ahk  