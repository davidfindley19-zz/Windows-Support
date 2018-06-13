<# 
.SYNOPSIS
    Scripted update of our company default signature file.
.DESCRIPTION
    The concept is pretty simple. It prompts for the basic user information and then replaces variables set in the HTML file. It is then output as an updated HTML file 
    leaving the original source file intact. 
.NOTES
    Author: David Findley
    Date: June 13, 2018
    Version 1.0 (Prod): Automated update of HTML signature file. 
#>

Write-host "Automated Tool to Update User Signatures"

$FullName = Read-Host "What is the user's full name? "
$Title = Read-Host "What is their title? "
$MobilePhone = Read-Host "Mobile phone number? "
$OfficePhone = Read-Host "Office phone number? "

$OriginalFile = ".\Signature_Template.htm" 
$DestinationFile = ".\$FullName Signature.html"

(Get-Content $OriginalFile) | ForEach-Object {
    $_  -replace '%displayName%', "$FullName" `
        -replace '%title%', "$Title" `
        -replace '%mobile%', "$MobilePhone" `
        -replace '%telephoneNumber%', "$OfficePhone"
} | Set-Content -Encoding UTF8 -Path $DestinationFile 