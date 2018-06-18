<#
.SYNOPSIS 
    Creates and HTML Outlook signature based off of the current user logged in.
.DESCRIPTION
    This script pulls the current username from the local machine and queries AD to get the required information
    for the HTML signature. This does require the use of a HTML template. There was a template used for branding 
    with our company. This does require the installation of the PowerShell module from the Microsoft RSAT tools.
.NOTES
    Author: David Findley
    Date: June 18, 2018
    Version: 1.0
#>

Write-Host "Queries AD to get user information for HTML Signature"

Import-Module ActiveDirectory -ErrorAction SilentlyContinue
$UserName = $env:UserName
$path = 'Default path\to HTML\template'
$sigTemplate = 'Signature_Template.htm'
$HTMLFiles = 'Signature_Template'
$Signatures = 'C:\Users\$UserName\AppData\Roaming\Microsoft'
$displayName = Get-ADUser $UserName -Properties * | Select-Object -ExpandProperty displayName
$title = Get-ADUser $UserName -Properties * | Select-Object -ExpandProperty Title
$mobile = Get-ADUser $UserName -Properties * | Select-Object -ExpandProperty Mobile
$officeNumber = Get-ADUser $UserName -Properties * | Select-Object -ExpandProperty telephoneNumber
$FileOutput = 'File Output\Path'

(Get-Content $path\$sigTemplate) | ForEach-Object {
	$_  -replace '%displayName%', "$displayName" `
	    -replace '%title%', "$title" `
	    -replace '%title%', "$title" `
	    -replace '%mobile%', "$mobile" `
	    -replace '%telephoneNumber%', "$officeNumber"
} | Set-Content -Encoding UTF8 -Path $sigOutput

Copy-Item -Path $FileOutput, $HTMLFiles -Destination $Signatures -Recurse
