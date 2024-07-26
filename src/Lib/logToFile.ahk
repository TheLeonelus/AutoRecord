logToFile(message, severity := 1) {
    severity_array := ["info", "warn", "error", "critical"]
    ; Логгирование результата кода
    result := A_Hour ":" A_Min ":" A_Sec " " A_DD "." A_MM " | " severity_array[severity] "`n" message "`n"
    shared_log_obj.info_log_file.Seek(0, 2)
    shared_log_obj.info_log_file.Write(result)
}