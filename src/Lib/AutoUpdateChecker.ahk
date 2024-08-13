AutoUpdateChecker(Version) {
    ;=============== CURRENT VERSION ==================================
    Current_version := Version  ; Ваша текущая версия
    ;==================================================================

    repoOwner := "TheLeonelus"
    repoName := "AutoRecord"

    try
    {
        url := "https://api.github.com/repos/" repoOwner "/" repoName "/releases/latest"
        WinHttpReq := ComObject("WinHttp.WinHttpRequest.5.1")
        WinHttpReq.Open("GET", url)
        WinHttpReq.Send()
        data := Json.parse(WinHttpReq.ResponseText)

        latest_version := data["tag_name"]

        ; Удалить префикс 'v', если он есть
        if (SubStr(latest_version, 1, 1) = "v")
            latest_version := SubStr(latest_version, 2)


        if (Current_version != latest_version) && (latest_version != "")
        {
            result := MsgBox("Your current version: " Current_version "`nNew version available: " latest_version "`n`nDo you want to update?", "New Update Available", 4 + 48)

            if (result = "Yes")
            {
                Try
                    Run A_temp "\install.bat", A_temp
            }
        }
        else MsgBox("You are up to date")
    }
    catch as e {
        logToFile (e, 2)
    }
}

#Include <logToFile>