/**
 * callback for `sendMessage` to send TrayTip from main thread (which doesn't hide icon)
 */
SendNotification(wParam, lParam, msg, hwnd)
{
    TrayTip("`n" ReceiveMiddlewareMessage(wParam, lParam, msg, hwnd))
    return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

/**
 * callback for `sendMessage` to exit whole application
 */
stopApplication(wParam, lParam, msg, hwnd) {
    message := ReceiveMiddlewareMessage(wParam, lParam, msg, hwnd)
    MsgBox("Crtical error has occured!`nError: " message "`nPlease restart AutoRecord or contact your support.", , "0x1000")
    ExitApp()
}

/**
 * callback for `sendMessage` to send messages to OBS
 */
sendOBSCommand(wParam, lParam, msg, hwnd)
{
    response := ReceiveMiddlewareMessage(wParam, lParam, msg, hwnd)
    logToFile("Got string to send: " response)
    obs_connection.sendText(response)
    return true
}

#Include <ReceiveMiddlewareMessage>
#Include <logToFile>