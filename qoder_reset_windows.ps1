# Qoder Reset Tool - Windows PowerShell Version
# Feature-parity port of qoder.sh (bash) for Windows
# Repository: https://github.com/bunnysayzz/qoder-reset.git
# Author: @bunnysayzz

param(
    [switch]$Force,
    [switch]$NoBackup,
    [switch]$SelfTest,
    [string]$QoderPath
)

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$script:QoderDataDir = $null
$script:PreserveChat = $true

# Logging function
function Write-Status {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    switch ($Type) {
        "INFO"    { Write-Host "[$timestamp] [>]   $Message" -ForegroundColor Blue }
        "SUCCESS" { Write-Host "[$timestamp] [OK]  $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] [!!]  $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[$timestamp] [X]   $Message" -ForegroundColor Red }
        "HEADER"  { Write-Host "[$timestamp] [@]   $Message" -ForegroundColor Cyan }
        "STEP"    { Write-Host "[$timestamp] [-]   $Message" -ForegroundColor DarkCyan }
        "CLEAN"   { Write-Host "[$timestamp] [*]   $Message" -ForegroundColor Magenta }
        default   { Write-Host "[$timestamp] $Message" }
    }
}

# Banner
function Show-Banner {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Magenta
    Write-Host "                  Qoder Reset Tool - Windows                   " -ForegroundColor Magenta
    Write-Host "               Complete Identity Reset Solution                " -ForegroundColor Magenta
    Write-Host "            Mac apps, visit: http://macbunny.co                " -ForegroundColor Magenta
    Write-Host "================================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Repository: https://github.com/bunnysayzz/qoder-reset.git" -ForegroundColor Cyan
    Write-Host "Author: @bunnysayzz" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This tool will reset all Qoder application identity information" -ForegroundColor Yellow
    Write-Host "including machine ID, telemetry data, hardware fingerprints," -ForegroundColor Yellow
    Write-Host "and network traces to make Qoder recognize your device as new." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Get Qoder from: https://qoder.com" -ForegroundColor Green
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "                         WARNING                                " -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "This tool will permanently delete Qoder identity data." -ForegroundColor Yellow
    Write-Host "Make sure to close Qoder completely before proceeding." -ForegroundColor Yellow
    Write-Host ""
}

# Check if Qoder is running
function Test-QoderRunning {
    Write-Status "Checking Qoder process status..." "HEADER"

    $systemInfo = "$env:OS" + " " + (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
    $qoderPids = Get-Process -Name "*qoder*" -ErrorAction SilentlyContinue

    if ($qoderPids) {
        Write-Status "Qoder is currently running (PIDs: $($qoderPids.Id -join ', '))" "ERROR"
        Write-Status "Please close Qoder completely before proceeding" "WARNING"
        Write-Status "On Windows: Close from taskbar or Task Manager" "WARNING"
        Write-Host ""
        Read-Host "Press Enter after closing Qoder, or Ctrl+C to cancel"

        $qoderPids = Get-Process -Name "*qoder*" -ErrorAction SilentlyContinue
        if ($qoderPids) {
            Write-Status "Qoder is still running. Please close it completely." "ERROR"
            exit 1
        }
    }

    Write-Status "Qoder is not running" "SUCCESS"
}

# Find Qoder data directory
function Get-QoderDataDirectory {
    if ($QoderPath) {
        if (Test-Path $QoderPath) {
            return $QoderPath.TrimEnd('\')
        }
        return $null
    }

    if ($env:APPDATA -and (Test-Path "$env:APPDATA\Qoder")) {
        Write-Status "Found Qoder in APPDATA: $env:APPDATA\Qoder" "INFO"
        return (Join-Path $env:APPDATA "Qoder")
    }
    if ($env:LOCALAPPDATA -and (Test-Path "$env:LOCALAPPDATA\Qoder")) {
        Write-Status "Found Qoder in LOCALAPPDATA: $env:LOCALAPPDATA\Qoder" "INFO"
        return (Join-Path $env:LOCALAPPDATA "Qoder")
    }
    if ($env:USERPROFILE -and (Test-Path "$env:USERPROFILE\AppData\Roaming\Qoder")) {
        Write-Status "Found Qoder in USERPROFILE/Roaming: $env:USERPROFILE\AppData\Roaming\Qoder" "INFO"
        return (Join-Path $env:USERPROFILE "AppData\Roaming\Qoder")
    }
    if ($env:USERPROFILE -and (Test-Path "$env:USERPROFILE\AppData\Local\Qoder")) {
        Write-Status "Found Qoder in USERPROFILE/Local: $env:USERPROFILE\AppData\Local\Qoder" "INFO"
        return (Join-Path $env:USERPROFILE "AppData\Local\Qoder")
    }

    return $null
}

# Inspect the Qoder directory
function Show-QoderDirectoryInfo {
    $dir = $script:QoderDataDir

    if (-not (Test-Path $dir)) {
        Write-Status "Qoder directory not found: $dir" "ERROR"
        Write-Status "Please ensure Qoder is installed and has been run at least once" "ERROR"
        exit 1
    }

    Write-Status "Qoder directory found: $dir" "SUCCESS"

    $keyFiles = @("machineid", "User\globalStorage\storage.json")
    foreach ($file in $keyFiles) {
        if (Test-Path (Join-Path $dir $file)) {
            Write-Status "Found: $file" "SUCCESS"
        } else {
            Write-Status "Missing: $file" "WARNING"
        }
    }

    $cacheDirs = @("Cache", "GPUCache", "Code Cache", "SharedClientCache")
    $foundCache = 0
    foreach ($d in $cacheDirs) {
        if (Test-Path (Join-Path $dir $d)) { $foundCache++ }
    }
    Write-Status "Found $foundCache/$($cacheDirs.Count) cache directories" "INFO"
}

# Utilities
function New-QoderGuid { [System.Guid]::NewGuid().ToString() }

function Get-Sha256Hex {
    param([string]$InputText)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($InputText))
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
    } finally {
        $sha.Dispose()
    }
}

# Set a (possibly dotted) key in a PSCustomObject parsed from JSON
function Set-QoderJsonField {
    param($Obj, [string]$Name, $Value)
    if ($null -ne $Obj.PSObject.Properties[$Name]) {
        $Obj.$Name = $Value
    } else {
        $Obj | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
    }
}

# Create backup of the whole Qoder directory
function New-QoderBackup {
    if ($NoBackup) { return }

    $dir = $script:QoderDataDir
    $backupName = "Qoder.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $backupPath = Join-Path (Split-Path -Parent $dir) $backupName

    try {
        Copy-Item -Path $dir -Destination $backupPath -Recurse -Force
        Write-Status "Backup created successfully: $backupPath" "SUCCESS"
    } catch {
        Write-Status "Warning: Backup creation failed, but continuing..." "WARNING"
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Reset machine ID + additional IDs + storage.json
function Reset-MachineId {
    Write-Status "Resetting machine ID..." "STEP"

    $dir = $script:QoderDataDir
    $machineIdFile = Join-Path $dir "machineid"
    $newMachineId = New-QoderGuid

    if (Test-Path $machineIdFile) {
        $machineIdBackup = "$machineIdFile.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $machineIdFile $machineIdBackup -Force -ErrorAction SilentlyContinue
        $oldId = (Get-Content $machineIdFile -Raw).Trim()
        Write-Status "Old machine ID: $oldId" "INFO"
    }

    [System.IO.File]::WriteAllText($machineIdFile, $newMachineId, [System.Text.Encoding]::ASCII)
    Write-Status "Created new machine ID: $newMachineId" "SUCCESS"

    $additionalIds = @("deviceid", "hardware_uuid", "system_uuid", "platform_id", "installation_id")
    foreach ($idFile in $additionalIds) {
        [System.IO.File]::WriteAllText((Join-Path $dir $idFile), (New-QoderGuid), [System.Text.Encoding]::ASCII)
        Write-Status "Created: $idFile" "SUCCESS"
    }

    $storageFile = Join-Path $dir "User\globalStorage\storage.json"
    if (Test-Path $storageFile) {
        try {
            $data = Get-Content $storageFile -Raw | ConvertFrom-Json

            Set-QoderJsonField -Obj $data -Name "telemetry.machineId" -Value (Get-Sha256Hex -InputText $newMachineId)
            Set-QoderJsonField -Obj $data -Name "telemetry.devDeviceId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "telemetry.sqmId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "telemetry.sessionId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "telemetry.installationId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "telemetry.clientId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "telemetry.userId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "telemetry.anonymousId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "hardwareId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "platformId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "cpuId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "gpuId" -Value (New-QoderGuid)
            Set-QoderJsonField -Obj $data -Name "memoryId" -Value (New-QoderGuid)

            Set-QoderJsonField -Obj $data -Name "system.platform" -Value "windows"
            Set-QoderJsonField -Obj $data -Name "system.arch" -Value $env:PROCESSOR_ARCHITECTURE
            Set-QoderJsonField -Obj $data -Name "system.version" -Value "10.0.22621"
            Set-QoderJsonField -Obj $data -Name "system.build" -Value "22621"
            Set-QoderJsonField -Obj $data -Name "system.locale" -Value "en-US"
            Set-QoderJsonField -Obj $data -Name "system.timezone" -Value "Eastern Standard Time"

            $json = $data | ConvertTo-Json -Depth 20
            [System.IO.File]::WriteAllText($storageFile, $json, [System.Text.Encoding]::UTF8)
            Write-Status "Updated storage.json with new identifiers" "SUCCESS"
        } catch {
            Write-Status "Failed to update storage.json" "WARNING"
        }
    }
}

# Create telemetry files
function Reset-Telemetry {
    Write-Status "Resetting telemetry data..." "STEP"

    $dir = $script:QoderDataDir
    $telemetryFiles = @(
        @{ Key = "telemetry.machineId";       Value = (Get-Sha256Hex -InputText (New-QoderGuid)) }
        @{ Key = "telemetry.devDeviceId";     Value = (New-QoderGuid) }
        @{ Key = "telemetry.sqmId";           Value = (New-QoderGuid) }
        @{ Key = "telemetry.sessionId";       Value = (New-QoderGuid) }
        @{ Key = "telemetry.installationId";  Value = (New-QoderGuid) }
        @{ Key = "telemetry.clientId";        Value = (New-QoderGuid) }
        @{ Key = "telemetry.userId";          Value = (New-QoderGuid) }
        @{ Key = "telemetry.anonymousId";     Value = (New-QoderGuid) }
    )

    foreach ($item in $telemetryFiles) {
        [System.IO.File]::WriteAllText((Join-Path $dir $item.Key), $item.Value, [System.Text.Encoding]::ASCII)
        Write-Status "Created: $($item.Key)" "SUCCESS"
    }
}

# Clean cache directories
function Clear-CacheDirectories {
    Write-Status "Cleaning cache directories..." "STEP"

    $dir = $script:QoderDataDir
    $cacheDirs = @(
        "Cache", "Code Cache", "GPUCache", "DawnGraphiteCache", "DawnWebGPUCache",
        "ShaderCache", "DawnCache", "MediaCache", "CachedData", "CachedProfilesData",
        "CachedExtensions", "IndexedDB", "CacheStorage", "WebSQL"
    )

    $cleanedCount = 0
    foreach ($d in $cacheDirs) {
        $dirPath = Join-Path $dir $d
        if (Test-Path $dirPath) {
            try {
                Remove-Item $dirPath -Recurse -Force
                Write-Status "Cleaned: $d" "CLEAN"
                $cleanedCount++
            } catch {
                Write-Status "Failed to clean: $d" "WARNING"
            }
        }
    }

    Write-Status "Cleaned $cleanedCount cache directories" "SUCCESS"
}

# Clean identity files
function Clear-IdentityFiles {
    Write-Status "Cleaning identity files..." "STEP"

    $dir = $script:QoderDataDir
    $identityFiles = @(
        "Network Persistent State", "TransportSecurity", "Trust Tokens", "Trust Tokens-journal",
        "SharedStorage", "SharedStorage-wal", "Local Storage", "Session Storage",
        "WebStorage", "Shared Dictionary", "Cookies", "Cookies-journal",
        "Login Credentials", "Login Data", "Login Data-journal",
        "DeviceMetadata", "HardwareInfo", "SystemInfo", "AutofillStrikeDatabase",
        "AutofillStrikeDatabase-journal", "Feature Engagement Tracker",
        "Platform Notifications", "VideoDecodeStats", "OriginTrials",
        "BrowserMetrics", "SafeBrowsing", "QuotaManager", "QuotaManager-journal",
        "Network Action Predictor"
    )

    $cleanedCount = 0
    foreach ($f in $identityFiles) {
        $filePath = Join-Path $dir $f
        if (Test-Path $filePath) {
            try {
                if (Test-Path $filePath -PathType Container) {
                    Remove-Item $filePath -Recurse -Force
                } else {
                    Remove-Item $filePath -Force
                }
                Write-Status "Cleaned: $f" "CLEAN"
                $cleanedCount++
            } catch {
                Write-Status "Failed to clean: $f" "WARNING"
            }
        }
    }

    Write-Status "Cleaned $cleanedCount identity files" "SUCCESS"
}

# Clean SharedClientCache
function Clear-SharedClientCache {
    Write-Status "Cleaning SharedClientCache..." "STEP"

    $sharedCache = Join-Path $script:QoderDataDir "SharedClientCache"
    if (-not (Test-Path $sharedCache)) { return }

    $cacheFiles = @(".info", ".lock", "mcp.json", "server.json", "auth.json")
    foreach ($file in $cacheFiles) {
        $filePath = Join-Path $sharedCache $file
        if (Test-Path $filePath) {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
            Write-Status "Cleaned: SharedClientCache/$file" "CLEAN"
        }
    }

    Get-ChildItem $sharedCache -Filter "tmp*" -File -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
    Write-Status "Cleaned temporary files in SharedClientCache" "CLEAN"

    if ($script:PreserveChat) {
        $cacheSubPath = Join-Path $sharedCache "cache"
        if (Test-Path $cacheSubPath) {
            Remove-Item $cacheSubPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Status "Cleaned: SharedClientCache/cache" "CLEAN"
        }
    } else {
        Get-ChildItem $sharedCache -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne "index" } |
            ForEach-Object { Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
        Write-Status "Cleaned SharedClientCache (preserving index for chat)" "CLEAN"
    }
}

# Reset hardware fingerprints
function Reset-HardwareFingerprints {
    Write-Status "Resetting hardware fingerprints..." "STEP"

    $dir = $script:QoderDataDir

    $hardwareFiles = @("cpu_id", "gpu_id", "memory_id", "board_serial", "bios_uuid")
    foreach ($file in $hardwareFiles) {
        $filePath = Join-Path $dir $file
        if (Test-Path $filePath) {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
            Write-Status "Removed: $file" "CLEAN"
        }
    }

    foreach ($file in $hardwareFiles) {
        [System.IO.File]::WriteAllText((Join-Path $dir $file), (New-QoderGuid), [System.Text.Encoding]::ASCII)
        Write-Status "Created: $file" "SUCCESS"
    }

    $fakeHardwareFile = Join-Path $dir "hardware_detection.json"
    $fakeDeviceFile = Join-Path $dir "device_capabilities.json"
    $fakeSystemFile = Join-Path $dir "system_features.json"

    $hardwareJson = @"
{
    "cpu": {
        "name": "Intel Core i7-13700K",
        "cores": 16,
        "threads": 24,
        "frequency": "3.4GHz"
    },
    "gpu": {
        "name": "NVIDIA GeForce RTX 4070",
        "memory": "12GB",
        "driver_version": "545.84"
    },
    "memory": {
        "total": "32GB",
        "type": "DDR5",
        "speed": "5600MHz"
    }
}
"@
    [System.IO.File]::WriteAllText($fakeHardwareFile, $hardwareJson, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($fakeDeviceFile, '{"capabilities": ["gpu_acceleration", "hardware_video_decode", "webgl2"]}', [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($fakeSystemFile, '{"features": ["avx2", "sse4", "aes_ni", "virtualization"]}', [System.Text.Encoding]::UTF8)
    Write-Status "Created fake hardware detection files" "SUCCESS"
}

# Clean chat history
function Clear-ChatHistory {
    if ($script:PreserveChat) {
        Write-Status "Preserving chat history as requested" "INFO"
        return
    }

    Write-Status "Cleaning chat history..." "STEP"

    $dir = $script:QoderDataDir
    $workspaceStorage = Join-Path $dir "User\workspaceStorage"
    $cleanedCount = 0

    if (Test-Path $workspaceStorage) {
        Get-ChildItem $workspaceStorage -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            foreach ($name in @("chatSessions", "chatEditingSessions")) {
                $chatDir = Join-Path $_.FullName $name
                if (Test-Path $chatDir) {
                    Remove-Item $chatDir -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Status "Cleaned chat directory: $($chatDir.Substring($dir.Length + 1))" "CLEAN"
                    $cleanedCount++
                }
            }
        }
    }

    if ($cleanedCount -gt 0) {
        Write-Status "Cleaned $cleanedCount chat directories" "SUCCESS"
    } else {
        Write-Status "No chat directories found to clean" "INFO"
    }
}

# Show operations menu
function Show-Menu {
    Write-Host ""
    Write-Host "Available operations:" -ForegroundColor Cyan
    Write-Host "1) Complete Reset (Recommended)"
    Write-Host "2) Reset Machine ID only"
    Write-Host "3) Reset Telemetry only"
    Write-Host "4) Clean Cache only"
    Write-Host "5) Clean Identity Files only"
    Write-Host "6) Reset Hardware Fingerprints only"
    Write-Host "7) Exit"
    Write-Host ""
}

# Perform the complete reset
function Invoke-CompleteReset {
    Write-Status "Starting complete Qoder reset..." "HEADER"
    Write-Host ""
    Test-QoderRunning
    if (-not $script:QoderDataDir) {
        $script:QoderDataDir = Get-QoderDataDirectory
    }
    if (-not $script:QoderDataDir) {
        Write-Status "Qoder directory not found in any Windows location" "ERROR"
        Write-Status "Searched: APPDATA, LOCALAPPDATA, USERPROFILE/AppData/Roaming, USERPROFILE/AppData/Local" "ERROR"
        exit 1
    }
    Show-QoderDirectoryInfo

    Write-Status "Performing reset operations..." "HEADER"
    Write-Host ""

    New-QoderBackup
    Reset-MachineId
    Reset-Telemetry
    Clear-CacheDirectories
    Clear-IdentityFiles
    Clear-SharedClientCache
    Reset-HardwareFingerprints
    Clear-ChatHistory

    Write-Status "Complete reset finished successfully!" "SUCCESS"
    Write-Status "You can now restart Qoder and it will recognize your device as new" "INFO"
}

# Main interactive entry (mirrors qoder.sh)
function Start-Interactive {
    Show-Banner

    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "                     IMPORTANT WARNING                          " -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "This tool will permanently delete Qoder identity data." -ForegroundColor Yellow
    Write-Host "Make sure to close Qoder completely before proceeding." -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Do you want to continue? (y/N)"
    if ($confirm -notmatch "^[Yy]") {
        Write-Status "Operation cancelled by user" "INFO"
        return
    }

    Write-Host ""
    $preserve = Read-Host "Do you want to preserve chat history? (Y/n)"
    if ($preserve -match "^[Nn]") {
        $script:PreserveChat = $false
        Write-Status "Chat history will be cleaned" "INFO"
    } else {
        $script:PreserveChat = $true
        Write-Status "Chat history will be preserved" "INFO"
    }

    while ($true) {
        Show-Menu
        $selection = Read-Host "Select operation (1-7)"

        switch ($selection) {
            "1" {
                Invoke-CompleteReset
                break
            }
            "2" {
                Test-QoderRunning
                $script:QoderDataDir = Get-QoderDataDirectory
                if (-not $script:QoderDataDir) {
                    Write-Status "Qoder directory not found in any Windows location" "ERROR"
                    exit 1
                }
                Show-QoderDirectoryInfo
                Reset-MachineId
                Read-Host "Press Enter to exit"
                return
            }
            "3" {
                Test-QoderRunning
                $script:QoderDataDir = Get-QoderDataDirectory
                if (-not $script:QoderDataDir) {
                    Write-Status "Qoder directory not found in any Windows location" "ERROR"
                    exit 1
                }
                Show-QoderDirectoryInfo
                Reset-Telemetry
                Read-Host "Press Enter to exit"
                return
            }
            "4" {
                Test-QoderRunning
                $script:QoderDataDir = Get-QoderDataDirectory
                if (-not $script:QoderDataDir) {
                    Write-Status "Qoder directory not found in any Windows location" "ERROR"
                    exit 1
                }
                Show-QoderDirectoryInfo
                Clear-CacheDirectories
                Read-Host "Press Enter to exit"
                return
            }
            "5" {
                Test-QoderRunning
                $script:QoderDataDir = Get-QoderDataDirectory
                if (-not $script:QoderDataDir) {
                    Write-Status "Qoder directory not found in any Windows location" "ERROR"
                    exit 1
                }
                Show-QoderDirectoryInfo
                Clear-IdentityFiles
                Read-Host "Press Enter to exit"
                return
            }
            "6" {
                Test-QoderRunning
                $script:QoderDataDir = Get-QoderDataDirectory
                if (-not $script:QoderDataDir) {
                    Write-Status "Qoder directory not found in any Windows location" "ERROR"
                    exit 1
                }
                Show-QoderDirectoryInfo
                Reset-HardwareFingerprints
                Read-Host "Press Enter to exit"
                return
            }
            "7" {
                Write-Status "Exiting..." "INFO"
                return
            }
            default {
                Write-Status "Invalid selection. Please choose 1-7." "ERROR"
            }
        }
    }
}

# Footer
function Show-Footer {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "                         SUCCESS                                " -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "Operation completed successfully!" -ForegroundColor Green
    Write-Host "You can now restart Qoder and it will recognize your device as new." -ForegroundColor Green
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "                   IMPORTANT NEXT STEP                          " -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "Download a fingerprint browser and set it as default!" -ForegroundColor Yellow
    Write-Host "Best options: Mullvad Browser, Firefox + Arkenfox, Brave" -ForegroundColor Cyan
    Write-Host "Download: https://www.privacyguides.org/en/desktop-browsers/" -ForegroundColor Cyan
    Write-Host "Use the fingerprint browser for new Qoder signup to avoid detection!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "                  Qoder Reset Tool - Windows                   " -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "Repository: https://github.com/bunnysayzz/qoder-reset.git" -ForegroundColor Cyan
    Write-Host "Author: @bunnysayzz" -ForegroundColor Cyan
    Write-Host "Mac apps: http://macbunny.co" -ForegroundColor Cyan
    Write-Host ""

    if (-not $SelfTest) {
        Read-Host "Press Enter to exit"
    }
}

# Entry point
if ($SelfTest) {
    $script:PreserveChat = $false
    Invoke-CompleteReset
    Show-Footer
} else {
    Start-Interactive
    Show-Footer
}