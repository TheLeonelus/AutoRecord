handleRecording(id, record_name) {
    if TryEnterCriticalSection(lpCS) {
        requestId := "profile_args_set"
        request := Format("
        (
        {
            "op": 6,
            "d": {
                "requestType": "SetProfileParameter",
                "requestId": "{1:s}",
                "requestData": {
                    "parameterCategory": "Output",
                    "parameterName": "FilenameFormatting",
                    "parameterValue": "{2:s} %DD-%MM %hh-%mm-%ss"
                }
            }
        }
        )", requestId, record_name)
        SendMiddlewareMessage(request, 0xFF02)
        if waitForResponse(requestId) {
            requestId := "record_start"
            request := Format("
            (
            {
            "op": 6,
            "d": {
                "requestType": "StartRecord",
                "requestId": "{1:s}",
                "requestData": ""
                }
            }
            )", requestId)
            SendMiddlewareMessage(request, 0xFF02)
            if waitForResponse(requestId) {
                SendMiddlewareMessage("Recording started.", 0xFF01)
            } else {
                SendMiddlewareMessage("Recording couldn't be started. `nPlease Try again or report problem.", 0xFF01)
                return
            }
            ; wait until window with call id is closed
            While WinExist("ahk_id " id) != 0 {
                WinWaitClose("ahk_id " id, 5000)
            }
            ; stop recording
            requestId := "record_stop"
            request := Format("
            (
            {
                "op": 6,
                "d": {
                    "requestType": "StopRecord",
                    "requestId": "{1:s}",
                    "requestData": ""
                }
            }
            )", requestId)
            SendMiddlewareMessage(request, 0xFF02)
            retArray := waitForResponse(requestId, "outputPath")
            if retArray[1] {
                SendMiddlewareMessage("Recording was finished. `n" retArray[2] " was saved.", 0xFF01)
            } else {
                SendMiddlewareMessage("Record couldn't be finished. Report if problem persists", 0xFF01)
            }

        }
        LeaveCriticalSection(lpCS)
    }
}
/**
 * 
 * @param {String} id - request id which we need to wait for
 * @param {string} key - additional key needed to be returned
 * @returns {Boolean | Array} - returns request status or array if key was passed
 */
WaitForResponse(id, key := "") {
    try {
        response := JSON.parse(shared_msg_obj.last_msg)
        loop {
            if response.Has("d") {
                if response["d"].Has("requestId") {
                    if StrCompare(response["d"]["requestId"], id) = 0 {
                        break
                    }
                }
            }
            response := JSON.parse(shared_msg_obj.last_msg)
        }
        MsgBox("got it " shared_msg_obj.last_msg "`nOutput: " HasProp(response, "requestId") "`nand key: " key " | " StrCompare(key, "outputPath"))
        if StrCompare(key, "outputPath") = 0 {
            retArray := [response["d"]["requestStatus"]["result"], response["d"]["responseData"]["outputPath"]]
            return retArray
        } else {
            return response["d"]["requestStatus"]["result"]
        }
    } catch {
        OutputDebug("no response yet")
    }
}

#Include <logToFile>