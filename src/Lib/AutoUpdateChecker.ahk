/**
 * 
 * @param {Boolean} notify 
 */
AutoUpdateChecker(notify := false) {
    RegExMatch(A_ScriptName, "V(.*)$", &Match_array)
    Current_version := Match_array[1]

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

        ; Delete prefix 'v'
        if (SubStr(latest_version, 1, 1) = "v")
            latest_version := SubStr(latest_version, 2)

        if (Current_version != latest_version) && (latest_version != "")
        {
            result := MsgBox("AutoRecord current version is: " Current_version "`nNew version is available: " latest_version "`n`nWould you like to update now?", "New Update Available", 4 + 48)

            if (result = "Yes")
            {
                    Run(A_WorkingDir "\install.bat")
                    ExitApp()
            }
        }
        else if notify
            MsgBox("You are up to date")
    }
    catch as e {
        logToFile (e, 2)
    }
}

#Include <logToFile>