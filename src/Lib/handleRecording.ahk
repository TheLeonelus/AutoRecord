
handleRecording(id) {
    if TryEnterCriticalSection(lpCS) != 0 {
        ; start recording
        Send "{Ctrl down}{Alt down}{F9 down}"
        Sleep hotkey_delay
        Send "{Ctrl up}{Alt up}{F9 up}"
        SendToast("Recoridng started.")
        ; wait until window with call id is closed
        While WinExist("ahk_id" id) != 0 {
			WinWaitClose("ahk_id" id, 5000)
			}
        ; stop recording
        Send "{Ctrl down}{Alt down}{F10 down}"
        Sleep hotkey_delay
        Send "{Ctrl up}{Alt up}{F10 up}"
        SendToast("Recording stopped.")
        LeaveCriticalSection(lpCS)
    }
}