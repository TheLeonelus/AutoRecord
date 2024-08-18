/**
 * @returns {String} - return received string from buffer
 * 
 * Arguments must be passed from OnReceive as callback
 * 
 * Implementation is taken from Autohotkey.com
 */
ReceiveMiddlewareMessage(wParam, lParam, msg, hwnd)
{
    StringAddress := NumGet(lParam, 2 * A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
    return CopyOfData  ; Returning received string
}