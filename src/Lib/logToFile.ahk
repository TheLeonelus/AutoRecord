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
    result := A_Hour ":" A_Min ":" A_Sec " " A_DD "." A_MM " | " severity_array[severity] "`n" message "`n"
    shared_log_obj.info_log_file.Seek(0, 2)
    shared_log_obj.info_log_file.Write(result)
}