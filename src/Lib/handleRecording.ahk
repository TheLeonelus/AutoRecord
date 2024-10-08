/**
 * @param {Number} id - window's call 
 * @param {String} record_name - caller's name
 * @param {Boolean} setitng_label - whether show prompt after recording or not
 */
handleRecording(id, record_name, setting_label := 1) {
    try {
        if !shared_obj.record_status {
            shared_obj.record_status := 1
            logToFile("Starting recording with: " record_name " | " id, 2)
            request_id := "record_start"
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
            )", request_id)
            SendMiddlewareMessage(request, 0xFF02)
            response_status := waitForResponse(request_id)
            logToFile("response status IS: " response_status)
            switch response_status
            {
                case 100:
                {
                    SendMiddlewareMessage("Recording started.", 0xFF01)
                }
                case 500:
                {
                    SendMiddlewareMessage("Recording is already running.", 0xFF01)
                    return 0
                }
                default:
                {
                    SendMiddlewareMessage("Recording couldn't be started. `nPlease Try again or report problem.", 0xFF01)
                    return 0
                }
            }
            logToFile("Passed switch statement")
            ; wait until window with call id is closed
            While WinExist("ahk_id " id) != 0 {
                WinWaitClose("ahk_id " id, shared_obj.check_delay)
            }
            ; stop recording
            request_id := "record_stop"
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
            )", request_id)
            SendMiddlewareMessage(request, 0xFF02)
            retArray := waitForResponse(request_id, "outputPath")
            if retArray[2] {
                if (setting_label) {
                    ; creating GUI window to optionally add label to record file
                    pathArray := []
                    RegExMatch(retArray[2], "^(.*)(\/|\\)(.*)$", &pathArray)
                    gui_prompt := Gui()
                    gui_prompt.MarginX := 10
                    gui_prompt.MarginY := 10
                    gui_prompt.SetFont("s10 Q5", "Arial")
                    gui_prompt.Add("Text", "Left", "If you want to add label to recording, enter it here or leave unchanged to save it as is:")
                    gui_prompt.Add("Text", "Section", "" pathArray[1] pathArray[2])
                    gui_prompt.Add("Edit", "YP vinputName", record_name)
                    gui_prompt.Add("Text", "YP", pathArray[3])
                    gui_prompt.Add("Button", "YP x400 default", "Save").OnEvent("Click", ProcessUserInput)
                    gui_prompt.OnEvent("Close", ProcessUserInput)
                    gui_prompt.Show("AutoSize Center")
                    ProcessUserInput(*) {
                        Saved := gui_prompt.Submit()  ; Save the contents of named controls into an object.
                        if RegExMatch(Saved.inputName, 'i)^((?>(?!CON)(?!PRN)(?!AUX)(?!NUL)(?!COM\d?)(?!LPT\d?)(?![\<\>\:\“\/\|\?\*\"]).)*)$') != 0 {
                            try
                                FileMove(pathArray[1] pathArray[2] pathArray[3], pathArray[1] pathArray[2] Saved.inputName " " pathArray[3])
                            catch
                                logToFile(Error("Couldnt rename recording! Does it exist?"), 3)
                            SendMiddlewareMessage("Recording was finished. `n" pathArray[1] pathArray[2] Saved.inputName " " pathArray[3] " was saved.", 0xFF01)
                        } else {
                            try
                                FileMove(pathArray[1] pathArray[2] pathArray[3], pathArray[1] pathArray[2] record_name pathArray[3])
                            catch
                                logToFile(Error("Couldnt rename recording! Does it exist?"), 3)
                            SendMiddlewareMessage("Invalid label! File is saved as " retArray[2], 0xFF01)
                        }
                    }
                }
                else
                    SendMiddlewareMessage("Recording was finished. `n" retArray[2] " was saved.", 0xFF01)
            }
            else
                SendMiddlewareMessage("Record couldn't be finished. Report if problem persists", 0xFF01)
            logToFile("exiting handleRecording")
            shared_obj.record_status := 0
        }
        else
            Sleep shared_obj.check_delay

    } catch as e {
        logToFile(e, 3)
        pause(1)
    }
}

/**
 * @param {String} id - request id which we need to wait for
 * @param {string} key - additional key needed to be returned
 * @returns {Number} - request status code, if `key` was omitted
 * @returns {Array} -array of status `code` and `key` if last was passed
 */
WaitForResponse(id, key := "") {
    count := 1
    response := JSON.parse(shared_obj.last_request_response)
    isFound := false
    while !isFound {
        (count > 10) ? Throw(Error("Call windows wasn't found!")) : ""
            if response.Has("d") {
                logToFile("validating answer")
                if response["d"].Has("requestId") {
                    if StrCompare(response["d"]["requestId"], id) = 0 {
                        isFound := true
                        break
                    }
                }
            }
            count++
            response := JSON.parse(shared_obj.last_request_response)
            Sleep(shared_obj.check_delay)
    }
    logToFile("Got it after " count " tries | id: " id " | key: " key " | `nFound: " shared_obj.last_request_response)
    if StrCompare(key, "outputPath") = 0 {
        retArray := [response["d"]["requestStatus"]["code"], response["d"]["responseData"]["outputPath"]]
        return retArray
    } else {
        return response["d"]["requestStatus"]["code"]
    }
}

#Include <logToFile>
#Include <SendMiddlewareMessage>