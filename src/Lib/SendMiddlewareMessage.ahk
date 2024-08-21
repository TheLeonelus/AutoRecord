/**
 * @param {String} StringToSend -  string to pass with code
 * @param {Number} code - HEX machine code which will be distinguished by main thread
 * @returns {Integer} - return value (0 or 1) from main thread
 * 
 * Implementation is taken from Autohotkey.com
 */
SendMiddlewareMessage(StringToSend, code)
{
    CopyDataStruct := Buffer(3 * A_PtrSize)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("Ptr", SizeInBytes  ; OS requires that this be done.
        , "Ptr", StrPtr(StringToSend)  ; Set lpData to point to the string itself.
        , CopyDataStruct, A_PtrSize)
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows True
    SetTitleMatchMode 2
    TimeOutTime := 5000  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    try
        RetValue := SendMessage(code, 0, CopyDataStruct, , A_ScriptHwnd = shared_obj.script_hwnd ? "" : shared_obj.script_hwnd, , , , TimeOutTime) ; Here we send actual message
    catch TimeoutError
        logToFile("SendMessage callback did not confirm.", 2)
    DetectHiddenWindows Prev_DetectHiddenWindows  ; Restore original setting for the caller.
    SetTitleMatchMode Prev_TitleMatchMode         ; Same.
}