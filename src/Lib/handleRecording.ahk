 /**
 * 
 * @param {Number} id - window's call 
 * @param {string} record_name - caller's name if it's known, otherwise if omitted, prompt box will ask at the end, how to name recording
 */
 handleRecording(id, record_name := "") {
    logToFile("Starting recording with: " record_name " | " id)
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
            )", requestId)
            SendMiddlewareMessage(request, 0xFF02)
            response_status := waitForResponse(requestId)
            logToFile("response IS : " response_status)
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
                 WinWaitClose("ahk_id " id, shared_var_obj.check_delay)
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
         logToFile("exiting handling")
         LeaveCriticalSection(var_CS)
     } catch Error as e {
         logError(e)
     }
 }
 /**
 * 
 * @param {String} id - request id which we need to wait for
 * @param {string} key - additional key needed to be returned
 * @returns {Number | Array} - returns request code or array of code and key if key was passed
 */
 WaitForResponse(id, key := "") {
     try {
         count := 1
         response := JSON.parse(shared_msg_obj.last_request_response)
         loop {
            logToFile("validating answer: " shared_msg_obj.last_request_response)
             if response.Has("d") {
                 if response["d"].Has("requestId") {
                     if StrCompare(response["d"]["requestId"], id) = 0 {
                         break
                     }
                 }
             }
             count++
             response := JSON.parse(shared_msg_obj.last_request_response)
             Sleep(shared_var_obj.check_delay)
         }
         logToFile("Got it after " count " tries`n" "got it " shared_msg_obj.last_request_response " Output: " HasProp(response, "requestId") " and key: " key " | " StrCompare(key, "outputPath"))
         if StrCompare(key, "outputPath") = 0 {
             retArray := [response["d"]["requestStatus"]["code"], response["d"]["responseData"]["outputPath"]]
             return retArray
         } else {
             return response["d"]["requestStatus"]["code"]
         }
     } catch as e {
         logToFile("something went wrong: " e.Message " | Line: " e.Line)
     }
 }

 #Include <logToFile>