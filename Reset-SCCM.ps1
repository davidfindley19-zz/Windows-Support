Function Reset-SCCM {
    Function Write-Log {
        [CmdletBinding()]
        param(
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [string]$Message,
         
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [ValidateSet('Information','Warning','Error')]
            [string]$Severity = 'Information'
        )
         
        [pscustomobject]@{
            Time = (Get-Date -F g)
            Message = $Message
            Severity = $Severity
            } | Export-Csv -Path $FilePath\LogFile.csv -Append -NoTypeInformation
        }
    Function New-Path{
    $Path = Test-Path "C:\Temp"

    if ($Path -eq $false){
        mkdir "C:\Temp"
        Write-Host `n"C:\Temp directory created."
    }
    else {

    }
}    

Write-Host "SCCM Repair Process" -ForegroundColor Green
New-Path
$FilePath = "C:\Temp"
Write-Log "SCCM repair script was started by $env:USERNAME on machine $env:COMPUTERNAME. " -Severity Information
Write-Log "Start time: $(Get-Date -Format "HH:mm")"
Write-Log "Windows Management service and it dependecies was stopped. " -Severity Information
Write-Host `n"Stopping Windows Management services..."
Stop-Service -Name Winmgmt -Force

Write-Host `n"Starting uninstall service..."
Write-Log "CCMSetup.exe /uninstall started. " -Severity Information
Start-Process C:\Windows\ccmsetup\ccmsetup.exe -ArgumentList "/uninstall" -Wait
Write-Host `n"Waiting on the uninstall process to complete..." 
Write-Host `n"Uninstall complete. Continuing with removal." -ForegroundColor Green
Write-Log "Uninstall succeeded." -Severity Information

Set-Location C:\

Write-Host `n"Removing SCCM related folders."

$Folders = @(
    "C:\Windows\CCM"
    "C:\Windows\ccmcache"
    "C:\Windows\ccmsetup"
)

foreach ($Folder in $Folders){
    Write-Host `n"Removing $Folder" -ForegroundColor Magenta
    Write-Log "Removing $Folder" -Severity Information
    Remove-Item -Path $Folder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose | Out-Host
    if ($? -eq $true){
        Write-Host `n"$Folder removed." -ForegroundColor Green
        Write-Log "$Folder was removed. " -Severity Information
    }
    else {
        Write-Host `n"$Folder not found or an error has occurred." -ForegroundColor Red
        Write-Log "$Folder removal failed." -Severity Error
    }
}

Write-Host `n"Deleting SCCM related files."

$Files = @(
    "C:\Windows\SMSCFG.INI"
    "C:\Windows\sms*.mif"
)

foreach($File in $Files){
    Write-Host `n"Removing $File." -ForegroundColor Magenta
    Write-Log "Removing $File." -Severity Information
    Remove-Item -Path $File -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose | Out-Host 
    if ($? -eq $true){
        Write-Host "$File removed." -ForegroundColor Green
        Write-Log "$File was removed." -Severity Information
    }
    else {
        Write-Host "$File not found or an error has occurred." -ForegroundColor Red
        Write-Log "$File removal failed." -Severity Error
    }
}

Write-Host `n"Setting location for Registry key deletion..."
$RegistryKeys = @(
    "HKLM:\SOFTWARE\Microsoft\ccm"
    "HKLM:\SOFTWARE\Microsoft\CCMSETUP"
    "HKLM:\SOFTWARE\Microsoft\SMS"
)

foreach ($Key in $RegistryKeys){
    Write-Host "Removing $Key" -ForegroundColor Magenta
    Write-Log "Removing the key $Key" -Severity Information
    Remove-Item $Key -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose | Out-Host
        if ($? -eq $true) {
            Write-Host "$Key removed." -ForegroundColor Green
            Write-Log "$Key was removed." -Severity Information
        }
        else {
            Write-Host "$Key not found or an error has occurred." -ForegroundColor Red
            Write-Log "$Key was not removed. " -Severity Error
        }
}

Write-Host `n"Restarting the WMI Service..." -ForegroundColor Yellow
Write-Log "Windows Management service restarted." -Severity Information
Start-Service -Name Winmgmt
Start-Sleep 2

Write-Host `n"Reinstalling the SCCM Client..." -ForegroundColor Yellow
Write-Log "New PSDrive was mapped. " -Severity Information
New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\Path\to\Installer\"
Set-Location P:\
Write-Log "The ccmsetup.exe process was started." -Severity Information
Start-Process .\ccmsetup.exe -Wait

Write-Host `n"Script cleanup..."
Write-Log "Installation finished. PSDrive removed and script closed out." -Severity Information
Set-Location C:\ 
Remove-PSDrive -Name "P"
Start-Sleep 2
Write-Log "Script finished at $(Get-Date -Format "HH:mm")"
Set-ItemProperty $FilePath\LogFile.csv -Name IsReadOnly -Value $true
Rename-Item -Path $FilePath\LogFile.csv -NewName $FilePath\SCCMRepairLog$(Get-Date -Format MMddyy-HHmm).csv

}
