<#
    .SYNOPSIS
        Reinstalls the SCCM client.
    .DESCRIPTION
        Uninstalls the SCCM client and deletes any associated files. Then reinstalls the client.
    .NOTES
        Author:     David Findley
        Date:       7/3/2019
        Version:    1.1
#>

Function Reset-SCCM {

Write-Host "SCCM Repair Process" -ForegroundColor Green

Write-Host `n"Stopping Windows Management services..."
Stop-Service -Name Winmgmt -Force

Write-Host `n"Starting uninstall service..."
Start-Process C:\Windows\ccmsetup\ccmsetup.exe -ArgumentList "/uninstall" -Wait
Write-Host `n"Waiting on the uninstall process to complete..." 
Write-Host `n"Uninstall complete. Continuing with removal." -ForegroundColor Green

Set-Location C:\

Write-Host `n"Removing SCCM related folders."

$Folders = @(
    "C:\Windows\CCM"
    "C:\Windows\ccmcache"
    "C:\Windows\ccmsetup"
)

foreach ($Folder in $Folders){
    Write-Host `n"Removing $Folder" -ForegroundColor Magenta
    Remove-Item -Path $Folder -Recurse -Force -Confirm:$false -ErrorAction Continue -Verbose | Out-Host
    if ($? -eq $true){
        Write-Host `n"$Folder removed." -ForegroundColor Green
    }
    else {
        Write-Host `n"$Folder not found or an error has occurred." -ForegroundColor Red
    }
}

Write-Host `n"Deleting SCCM related files."

$Files = @(
    "C:\Windows\SMSCFG.INI"
    "C:\Windows\sms*.mif"
)

foreach($File in $Files){
    Write-Host `n"Removing $File." -ForegroundColor Magenta
    Remove-Item -Path $File -Force -Confirm:$false -ErrorAction Continue -Verbose | Out-Host 
    if ($? -eq $true){
        Write-Host "$File removed." -ForegroundColor Green
    }
    else {
        Write-Host "$File not found or an error has occurred." -ForegroundColor Red
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
    Remove-Item $Key -Recurse -Force -Confirm:$false -ErrorAction Continue -Verbose | Out-Host
        if ($? -eq $true) {
            Write-Host "$Key removed." -ForegroundColor Green
        }
        else {
            Write-Host "$Key not found or an error has occurred." -ForegroundColor Red
        }
}

Write-Host `n"Restarting the WMI Service..." -ForegroundColor Yellow
Start-Service -Name Winmgmt
Start-Sleep 2

Write-Host `n"Reinstalling the SCCM Client..." -ForegroundColor Yellow
New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\PATH\TO\SHARE"
Set-Location P:\
Start-Process .\ccmsetup.exe -Wait

Write-Host `n"Script cleanup..."
Set-Location C:\ 
Remove-PSDrive -Name "P"
Start-Sleep 2
Exit

}
