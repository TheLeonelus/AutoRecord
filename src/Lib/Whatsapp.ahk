#NoTrayIcon
logToFile("Whatsapp module is loaded.")

GroupAdd "window_call_titles", "Voice call ‎- WhatsApp" ; English
GroupAdd "window_call_titles", "Аудиозвонок ‎- WhatsApp" ; Russian
GroupAdd "window_call_titles", "Ligação de voz ‎ - WhatsApp" ; Portugese (Brazil)
GroupAdd "window_call_titles", "Chamada de voz ‎ - WhatsApp" ; Portugese (Portu)
GroupAdd "window_call_titles", "Appel vocal ‎- WhatsApp" ; French
GroupAdd "window_call_titles", "음성통화 ‎- WhatsApp" ; Korean
GroupAdd "window_call_titles", "Chiamata vocale ‎- WhatsApp" ; Italian

Loop
{
    try {
        ; look for whatsapp window
        window_id := WinWait("ahk_group window_call_titles")
        handleRecording(window_id, "Whatsapp")
    }
    catch as e {
        logToFile(e, 3)
        pause(1)
    }
    ; delay between new loop
    Sleep shared_obj.check_delay
}

#Include <logToFile>
#Include <handleRecording>