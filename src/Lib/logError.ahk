logError(error) {
    ; Логгирование ошибок
    logPath := A_AppData "\AutoRecord\error.log"
    FileAppend ( A_Hour ":" A_Min ":" A_Sec " | " A_DD "." A_MM " | " "`nMessage: " e.Message "`nWhat: " e.What "`nExtra: " e.Extra "`nLine: " e.Line "`n=====`n"), logPath
}