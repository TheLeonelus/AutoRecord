SendNotification(wParam, lParam, msg, hwnd)
{
    TrayTip A_ScriptName "`n" HandleMiddlewareMessage(wParam, lParam, msg, hwnd)
    return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

#Include <HandleMiddlewareMessage>