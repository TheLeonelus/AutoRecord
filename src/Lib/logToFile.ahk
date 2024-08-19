/**
 * @param {String} message - string to be written
 * @param {Integer} severity - represents message severity
 * 
 * 1 - Info *(if omitted)*
 * 
 * 2 - Warn
 * 
 * 3 - Error
 * 
 * 4 - Critical
 */
logToFile(varToLog, severity := 1) {
    severity_array := ["info", "warn", "error", "critical"]
    template := A_Hour ":" A_Min ":" A_Sec " " A_DD "." A_MM " | " severity_array[severity] "`n"
    if severity >= 3 {
        result := template "Message: " varToLog.Message "`nWhat: " varToLog.What "`nExtra: " varToLog.Extra "`nLine: " varToLog.Line "`nFile: " varToLog.File "`nStack:" varToLog.Stack "`n=====`n"
        SendMiddlewareMessage(varToLog.Message, 0xFF03)
    }
    else
        result := template varToLog "`n"
    OutputDebug(result)
    shared_obj.info_log.Seek(0, 2)
    shared_obj.info_log.Write(result)
}

#Include <SendMiddlewareMessage>