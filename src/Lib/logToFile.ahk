/**
 * 
 * @param {String} message - string to be written
 * @param {Integer} severity - represents message severity <br>
 * 1 - Info (if omitted) <br>
 * 2 - Warn <br>
 * 3 - Error <br>
 * 4 - Critical <br>
 */
logToFile(message, severity := 1) {
    severity_array := ["info", "warn", "error", "critical"]
    ; Логгирование результата кода
    if severity = 3
        result := A_Hour ":" A_Min ":" A_Sec " " A_DD "." A_MM " | " severity_array[severity] "`n" message.message "`nLine: " message.Line "`n"
    else
        result := A_Hour ":" A_Min ":" A_Sec " " A_DD "." A_MM " | " severity_array[severity] "`n" message "`n"
    OutputDebug(result)
    shared_log_obj.info_log.Seek(0, 2)
    shared_log_obj.info_log.Write(result)
}