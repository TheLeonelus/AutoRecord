/**
 * 
 * @param {String} message - string to be written
 * @param {Integer} severity - represents message severity
 * <br> 1 - Info (if omitted)
 * <br> 2 - Warn
 * <br> 3 - Error
 * <br> 4 - Critical
 */
logToFile(varToLog, severity := 1) {
    severity_array := ["info", "warn", "error", "critical"]
    template := A_Hour ":" A_Min ":" A_Sec " " A_DD "." A_MM " | " severity_array[severity] "`n"
    if severity >= 3 {
        result := template "Message: " varToLog.Message "`nWhat: " varToLog.What "`nExtra: " varToLog.Extra "`nLine: " varToLog.Line "`nFile: " varToLog.File "`nStack:" varToLog.Stack "`n=====`n"
        Throw(varToLog)
    }
        else
        result := template varToLog "`n"
    OutputDebug(result)
    shared_obj.info_log.Seek(0, 2)
    shared_obj.info_log.Write(result)
}