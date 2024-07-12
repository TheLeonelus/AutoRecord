handleRecording(id, record_name) {
    if TryEnterCriticalSection(lpCS) {
        response := Format("
        (
        {
            "op": 6,
            "d": {
                "requestType": "SetProfileParameter",
                "requestId": "profile",
                "requestData": {
                    "parameterCategory": "Output",
                    "parameterName": "FilenameFormatting",
                    "parameterValue": "{1:s} %DD-%MM %hh-%mm-%ss"
                }
            }
        }    
        )", record_name)
        SendMiddlewareMessage(response, 0xFF02)
        ; start recording
        ; Send "{Ctrl down}{Alt down}{F9 down}"
        ; Sleep shared.obj_hotkey_delay
        ; Send "{Ctrl up}{Alt up}{F9 up}"
        response := "
        (
        {
        "op": 6,
        "d": {
            "requestType": "StartRecord",
            "requestId": "record_start",
            "requestData": ""
            }
        }
        )"
        SendMiddlewareMessage(response, 0xFF02)
        SendMiddlewareMessage("Recording started.", 0xFF01)
        ; wait until window with call id is closed
        While WinExist("ahk_id" id) != 0 {
            WinWaitClose("ahk_id" id, 5000)
        }
        ; stop recording
        response := "
        (
        {
            "op": 6,
            "d": {
                "requestType": "StopRecord",
                "requestId": "record_stop",
                "requestData": ""
            }
        }
        )"
        ; Send "{Ctrl down}{Alt down}{F10 down}"
        ; Sleep shared.obj_hotkey_delay
        ; Send "{Ctrl up}{Alt up}{F10 up}"
        MsgBox response
        SendMiddlewareMessage(response, 0xFF02)
        Sleep(500)
        SendMiddlewareMessage("Recording stopped.", 0xFF01)
        LeaveCriticalSection(lpCS)
    }
}

#Include <logToFile>