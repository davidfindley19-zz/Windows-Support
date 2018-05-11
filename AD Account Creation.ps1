<#
.SYNOPSIS
    Scripted account and mailbox creation for new users.
.DESCRIPTION
    This is accomplished by prompting with a form for the new user's information. The script will truncate the full name to create the username based off Tradewind Energy standards. After the username
    is created, based off the role, groups/permissions will be assigned to the user. The final step of this script is to create the mailbox on our Exchange server.
.NOTES
    Author: David Findley
    Date: May 10 2018
    Version: 1.01 - Edited for consistency with our production version.
#>

Write-Host "Manual Account and Mailbox Creation"

# Importing Active Directory module for AD manipulation. 
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Just grabbing current user credentials. This is assuming user executing script has privileges to modify domain users.
$UserCredential = Get-Credential "$env:USERDOMAIN\$env:USERNAME"

# Prompting for new user's full name.
$FirstName = Read-Host -Prompt "Enter the user's first name:"
$LastName = Read-Host -Prompt "Enter the user's last name:"

# Creates all lowercase username based on first initial and last name standard.
$UserName = $($FirstName.Substring(0,1) + $LastName).ToLower()

# Defines variables used later. Most of these are hard coded as they apply to each user. Some information is made up currently :)
$FullName = "$FirstName " + "$LastName"
$SamAccountName = $UserName
$GivenName = $FirstName
$Surname = $LastName
$EmailAddress = $UserName + "@business.com"
$StreetAddress = "12345 S. Road"
$City = "City"
$State = "State"
$Company = "Business Name"
$PhoneNumber = "555-555-5555"
$Account = (dsquery user -samid $UserName)

# Sanity check on username creation. Eventually this will query AD and verify that the account doesn't exist. 
Write-Host "The following user, $FullName, will be created using the following username: $UserName. "
$Readhost = Read-Host "[Y]es or [N]o"
switch ($Readhost) {
    Y {Write-Host "Continuing with this username. "; $Create=$true }
    N {Write-Warning "Username is incorrect."; $Create=$false }
    Default {"No response. Exiting script"; exit}
}

# Sanity check on username creation. Eventually this will query AD and verify that the account doesn't exist.
if ($Account -eq $null){
Write-Warning "The following username is available: $UserName. Would you like to continue? "
$Readhost = Read-Host "[Y]es or [N]o"
switch ($Readhost) {
    Y {Write-Host "Great! Continuing with this username. "; $Create=$true }
    N {Write-Host "Let's try that again."; $Create=$false }
    Default {"Invalid response. Exiting script"; exit}
}
}
else {
    Write-Error "This username, $UserName, is not available. Please try again."
    exit
}
if ($Create -eq $true) {
    try {
        New-ADUser  -Name $FullName `
                    -SamAccountName $SamAccountName `
                    -GivenName $Surname 
        Write-Host "$FullName : Account created successfully." 
    }
        
    catch {
        Write-Warning "$FullName : Error occurred while creating account. $_"
        exit

    }
}
else {
    Write-Host "Exiting Script"
    exit
}

# Due to the limitations mentioned above, we'll now fill in the missing information for the created account.
if (dsquery user -samid $UserName) {
    Get-ADUser $UserName | Set-ADUser   -GivenName $FirstName `
                                        -Surname  $LastName `
                                        -EmailAddress $EmailAddress `
                                        -Company $Company `
                                        -UserPrincipalName "$UserName@domain.com" `
                                        -Enable $true `
                                        -DisplayName "$FirstName $LastName"
                                    
    
}   
else {
    Write-Host "User does not exist in AD."
    
}

# Adding user to group(s) based off of the team they will be joining. Right now the script only does a group at a time. Will udpate to do multiple.
$TeamName = Read-Host "What group will $FirstName $LastName be a part of? Please enter one: IT, Accounting, Executives "
if ($TeamName -eq "IT") {
    Add-ADGroupMember -Identity "IT-Test" -Member $UserName # Test groups in the test environment. 
    Write-Host "User successfully added to group IT."
    }
        if ($TeamName -eq "Accounting"){
        Add-ADGroupMember -Identity "Accounting-Test" -Member $UserName  
    Write-Host "User successfully added to group GIS."
        }
        
else {
    Write-Host "User not added to any groups."
    exit
    }
