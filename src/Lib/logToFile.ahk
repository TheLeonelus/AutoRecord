logToFile(message, severity := 1) {
    severity_array := ["info", "warn", "error", "critical"]
    ; Логгирование результата кода
    logPath := A_AppData "\AutoRecord\info.log"
    FileAppend A_Hour ":" A_Min ":" A_Sec " " " " A_DD "." A_MM " | " severity_array[severity] " | " "`n" message "`n", logPath
}

