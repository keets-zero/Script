# ==============================================================================
# NAME: NoNano.ps1
# DESCRIPTION: Purges Chrome Gemini Nano (4GB), applies Registry blocks, 
#              and locks folders to prevent re-downloads.
# STRATEGY: Offline-first / OWASP A02:2025 Hardening
# ==============================================================================

# 0. AUTO-ELEVATE TO ADMINISTRATOR (KEEPING WINDOW OPEN)
# Checks if the current session has Admin rights; if not, restarts itself.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # -NoExit keeps the blue window open after completion for your review.
    Start-Process powershell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 1. SETUP LOGGING (FIXED TO SCRIPT FOLDER)
# $PSScriptRoot ensures the log stays in the script's directory, not System32.
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "NoNano_Log.txt"

function Write-Log($Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $Message -ForegroundColor Cyan
    $logEntry | Out-File -FilePath $logFile -Append
}

Write-Log "--- NanoNuke (Gemini Purge) Started ---"
Write-Log "LOG SAVED AT: $logFile"

# 2. STOP CHROME PROCESSES
# Necessary to unlock files for deletion.
Write-Log "Closing Chrome to unlock folders..."
Stop-Process -Name "chrome" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2 

# 3. APPLY REGISTRY POLICIES (THE PERMANENT BLOCK)
# Enforces "Offline-first" behavior at the OS level.
$registryPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
if (!(Test-Path $registryPath)) { 
    New-Item -Path $registryPath -Force | Out-Null 
    Write-Log "Created Registry path: $registryPath"
}

Write-Log "Applying Registry Policies to block AI re-downloads..."
# Disables the 'brain' that fetches models.
New-ItemProperty -Path $registryPath -Name "OptimizationGuideRemoteFetchingEnabled" -Value 0 -PropertyType DWORD -Force | Out-Null
# Sets GenAI features to disabled by default.
New-ItemProperty -Path $registryPath -Name "GenAiDefaultSettings" -Value 2 -PropertyType DWORD -Force | Out-Null

# 4. DELETE THE AI FOLDERS
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$targets = @(
    "optimization_guide_model_store",
    "OnDeviceHeadSuggestModel",
    "OptimizationHints"
)

foreach ($folder in $targets) {
    $fullPath = Join-Path $chromePath $folder
    if (Test-Path $fullPath) {
        try {
            Remove-Item -Recurse -Force $fullPath -ErrorAction Stop
            Write-Log "DELETED: $folder"
        } catch {
            Write-Log "ERROR: Could not delete $folder. File might be locked."
        }
    } else {
        Write-Log "NOT FOUND: $folder (Already gone)"
    }
}

# 5. CREATE DUMMY "LOCK" FILES
# Uses a file-system collision to prevent Chrome from recreating these folders.
foreach ($folder in $targets) {
    $fullPath = Join-Path $chromePath $folder
    if (!(Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType File -Force | Out-Null
        Set-ItemProperty -Path $fullPath -Name IsReadOnly -Value $true
        Write-Log "LOCKED: Created read-only dummy file for $folder"
    }
}

Write-Log "--- Cleanup and Lock-down complete! ---"
Write-Host "`n[COMPLETED] You can find the full report at:" -ForegroundColor White
Write-Host "$logFile" -ForegroundColor Yellow
Write-Host "`nThis window will remain open so you can check the results." -ForegroundColor Gray