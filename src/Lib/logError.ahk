logError(e) {
    ; Логгирование ошибок
    log_path := A_AppData "\AutoRecord\error.log"
    string_to_log := A_Hour ":" A_Min ":" A_Sec " | " A_DD "." A_MM " | " "`nMessage: " e.Message "`nWhat: " e.What "`nExtra: " e.Extra "`nLine: " e.Line "`n=====`n"
    OutputDebug(string_to_log)
    MsgBox(e.Message,,0x1000 0x0)
    FileAppend (string_to_log), log_path
}