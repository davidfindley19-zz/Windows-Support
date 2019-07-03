<#
    .SYNOPSIS
        Reinstalls the SCCM client.
    .DESCRIPTION
        Uninstalls the SCCM client and deletes any associated files. Then reinstalls the client.
    .NOTES
        Author:     David Findley
        Date:       7/3/2019
        Version:    1.0
#>

Function Reset-SCCM {

Write-Host "SCCM Repair Process" -ForegroundColor Green

Write-Host `n"Stopping Windows Management services..."
Stop-Service -Name Winmgmt -Force

Write-Host `n"Setting SCCM uninstall location." 
Set-Location C:\Windows\ccmsetup

Write-Host `n"Starting uninstall service..."
Start-Process .\ccmsetup -ArgumentList "/uninstall" -Wait
Write-Host `n"Waiting on the uninstall process to complete..." 
Write-Host `n"Uninstall complete. Continuing with removal." -ForegroundColor Green

Set-Location C:\

Write-Host `n"Removing SCCM related files and folders."
Get-ChildItem C:\Windows\CCM | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path C:\Windows\ccmcache -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path C:\Windows\ccmsetup -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path C:\Windows\SMSCFG.INI -Confirm:$false -ErrorAction SilentlyContinue

Write-Host `n"Setting location for Registry key deletion..."
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\CCMSetup\' -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\CCM\' -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\SMS\' -Recurse -Confirm:$false -ErrorAction SilentlyContinue

Write-Host `n"Restarting the WMI Service..." -ForegroundColor Yellow
Start-Service -Name Winmgmt
Start-Sleep 2

Write-Host `n"Reinstalling the SCCM Client..." -ForegroundColor Yellow
New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\path\to\network\share"
Set-Location P:\
Start-Process .\ccmsetup.exe -Wait

Write-Host `n"Script cleanup..."
Set-Location C:\ 
Remove-PSDrive -Name "P"
Start-Sleep 2
Exit

}
