<# 
.SYNOPSIS
    Scripted update of our company default signature file.
.DESCRIPTION
    The concept is pretty simple. It prompts for the basic user information and then replaces variables set in the HTML file. It is then output as an updated HTML file 
    leaving the original source file intact. This all based on our default HTML signature file that is updated as a user needs. Just fill in the spots with your custom
    file and create some variables and you're all set. This is mostly to show the syntax for updating it. 
.NOTES
    Author: David Findley
    Date: June 13, 2018
    Version 1.0 (Prod): Automated update of HTML signature file. 
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]$FullName,
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [string]$MobilePhone,
    [Parameter(Mandatory = $true)]
    [string]$OfficePhone
)

Write-host "Automated Tool to Update User Signatures"

$OriginalFile = ".\Signature_Template.htm" 
$DestinationFile = ".\$FullName Signature.html"

(Get-Content $OriginalFile) | ForEach-Object {
    $_  -replace '%displayName%', "$FullName" `
        -replace '%title%', "$Title" `
        -replace '%mobile%', "$MobilePhone" `
        -replace '%telephoneNumber%', "$OfficePhone"
} | Set-Content -Encoding UTF8 -Path $DestinationFile 