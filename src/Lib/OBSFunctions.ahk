/**
 * handle responses from server
 * @param {WebSocket} self - WebSocket instance
 * @param {String} data - received message
 */
manageOBSMessages(self, data) {
    ; write response to logs and shared_object
    logToFile("Received: " data)
    shared_obj.last_message := data
    parsed_message := JSON.parse(data)
    switch parsed_message["op"]
    {
        case 0:
            ; hello
            response := Format("
        (
        {
        "d": {
        "rpcVersion": {1:s}
        },
        "op": 1
        }
        )", parsed_message["d"]["rpcVersion"])
            Sleep shared_obj.check_delay
            self.sendText(response)
            logToFile("Sent: " response)
        case 2:
            ; identify
            OutputDebug "identified`n"
            Sleep shared_obj.check_delay
            OutputDebug "Setting record output name`n"
            request := "
        (
        {
            "op": 6,
            "d": {
                "requestType": "SetProfileParameter",
                "requestId": "profile_args_set",
                "requestData": {
                    "parameterCategory": "Output",
                    "parameterName": "FilenameFormatting",
                    "parameterValue": "%DD-%MM %hh-%mm-%ss"
                }
            }
        }
        )"
            self.sendText(request)
        case 7:
        {
            shared_obj.last_request_response := data
        }
        case 5:
            if parsed_message["d"]["eventType"] = "ExitStarted" {
                reinitialize_OBS()
            }
        Default:
            OutputDebug "received not handled message`n"
    }
}

/**
 * Call this function if you need to create new connection to websocket or OBS was closed
 */
reinitialize_OBS() {
    ; pause sub-threads
    tg_td.Pause(1)
    wa_td.Pause(1)
    logToFile("stopped threads`n")
    global obs_connection := ""
    if ProcessExist("obs64.exe") {
        DetectHiddenWindows True
        SetTitleMatchMode 2
        ids_array := WinGetList("ahk_exe obs64.exe")
        for id in ids_array
            GroupAdd "OBS", "ahk_id " id
        WinWaitClose("ahk_group OBS")
        logToFile("obs is closed`n")
        MsgBox("OBS was closed! AutoRecord is paused until you start OBS again!", A_ScriptName, 0x1000)
        WinWait("ahk_exe obs64.exe")
        logToFile("obs is opened`n")
    }
    initialize_OBS()
    ; unpause sub-threads
    tg_td.Pause(0)
    wa_td.Pause(0)
}
/**
 * Tries to start up OBS and connect to OBS-websocket
 */
initialize_OBS() {
    ; looking for obs, if not found, trying to start it
    if !ProcessExist("obs64.exe") {
        try {
            Run("C:\Program Files\obs-studio\bin\64bit\obs64.exe", "C:\Program Files\obs-studio\bin\64bit\")
            logToFile("OBS wasn't found, trying to start it up")
            WinWait("ahk_exe obs64.exe", , shared_obj.check_delay * 20)
        }
        catch {
            MsgBox("OBS could not be started automatically. Please try to start it up manually.", , 0x0 0x1000)
            WinWait("ahk_exe obs64.exe")
        }
    }
initialize_websocket:
    Sleep(shared_obj.check_delay)
    ; try to create websocket instance and connect to server
    try {
        Global obs_connection := WebSocket("ws://127.0.0.1:4455/", {
            message: (self, data) => manageOBSMessages(self, data),
            close: (self, status, reason) => (reinitialize_OBS(), logToFile(status ' ' reason '`n', 2)) },
        )
    } catch {
        logToFile("websocket is dead`n")
        switch MsgBox("OBS websocket couldn't be connected automatically! Maybe OBS isn't loaded yet, retry to connect?", A_ScriptName, 0x1004) {
            case "Yes":
                ; TODO: replace goto because bad
                goto initialize_websocket
            case "No":
                ExitApp()
        }
    }
}

#Include <HandleMiddlewareMessage>
#include <logToFile>