logInfo(string) {
    ; Логгирование результата кода
    logPath := A_AppData "\AutoRecord\info.log"
    FileAppend ( A_Hour ":" A_Min ":" A_Sec " | " A_DD "." A_MM " | " string "`n"), logPath
}