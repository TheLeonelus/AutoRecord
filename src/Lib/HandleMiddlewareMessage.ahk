/**
 * arguments must be passed from OnReceive as callback
 * @param wParam
 * @param lParam
 * @param msg
 * @param hwnd 
 * @returns {String} - return received string from buffer
 */
HandleMiddlewareMessage(wParam, lParam, msg, hwnd)
{
    StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
    return CopyOfData  ; Returning received string
}