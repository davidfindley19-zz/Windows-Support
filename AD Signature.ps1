<#	
.SYNOPSIS
    Searches AD for user information without RSAT Tools.
.DESCRIPTION
    We ran into an issue with pulling AD objects for the script since we didn't want to install RSAT tools on all the machines. This method uses ADSISEARCHER to pull 
    the user's information and generates their HTML signature. It copies to Signatures folder after the file is generated. 
.NOTES
    Author: David Findley/David Wendt
    Date: July 5, 2018
    Version: 1.0 (Prod)
#>

#This requires an HTML template file. Path to the file goes here.
$path = '\\PATH\TO\FILE'
#Gets current logged in user's name
$objUser = $env:USERNAME
#Gets user's display name
$displayName = ([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$objUser))").FindAll().Properties.displayname
#Gets user's title
$title = ([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$objUser))").FindAll().Properties.title
#Gets user's telephone (office phone)
$officeNumber = ([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$objUser))").FindAll().Properties.telephonenumber
#Gets user's mobile number
$mobile = ([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$objUser))").FindAll().Properties.mobile
#Signature template file
$sigTemplate = 'HTML Template File.HTM'
#Folder need with .htm file. Contains image and styling.
$sigFiles = 'Signature_Template'
#Path for output
$sigOutput = "\\OUTPUT\FILE\PATH\$objUser Signature.htm"

#In our environment, neither phone number is required to be listed. So this checks if that field is empty. 
if (($officeNumber -eq $null) -AND ($mobile -eq $null)) {
	
    $mobile = Read-Host "  enter your cell phone number: "
    (Get-Content $path\$sigTemplate) | ForEach-Object {
        $_ -replace 'O:', $null `
            -replace '%displayName%', "$displayName" `
            -replace '%title%', "$title" `
            -replace '%mobile%', "$mobile" `
            -replace '%telephoneNumber', "$null"
		
    } | Set-Content -Encoding UTF8 -Path $sigOutput
	
}
elseif ($mobile -eq $null) {
    $mobile = Read-Host "  enter your cell phone number: "
    (Get-Content $path\$sigTemplate) | ForEach-Object {
        $_ -replace '%displayName%', "$displayName" `
            -replace '%title%', "$title" `
            -replace '%mobile%', "$mobile" `
            -replace '%telephoneNumber', "$officeNumber"
    }
}
else {
    #Placing variables in signature template with above information
    (Get-Content $path\$sigTemplate) | ForEach-Object {
        $_ -replace '%displayName%', "$displayName" `
            -replace '%title%', "$title" `
            -replace '%mobile%', "$mobile" `
            -replace '%telephoneNumber%', "$officeNumber"
		
    } | Set-Content -Encoding UTF8 -Path $sigOutput
}

#Copy the folder over with the HTML template. 
$sig_Folder = Start-Process cmd -ArgumentList '/c robocopy "\\PATH\TO\FILE\Signature_Template" %appdata%\Microsoft\Signatures\Signature_Template /e'
#Copying file to local Signature folder for user in Outlook. 
$Signatures = Start-Process cmd -ArgumentList '/c robocopy "\\PATH\TO\SIGNATURE" %appdata%\Microsoft\Signatures "%username% Signature.htm" /W:1'


$sig_Folder
$Signatures

