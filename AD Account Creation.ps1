<#
.SYNOPSIS
    Scripted account and mailbox creation for new users.
.DESCRIPTION
    This is accomplished by prompting with a form for the new user's information. The script will truncate the full name to create the username based off company IT standards. After the username
    is created, based off the role, groups/permissions will be assigned to the user. The final step of this script is to create the mailbox on our Exchange server.
.NOTES
    Author: David Findley
    Date: May 10 2018
    Version: 1.3 - Multi-group support in AD. 
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

# Adding user to group(s) based off of the team they will be joining. These three groups are examples of multiple choice. 
$TeamName = Read-Host "What group will $FirstName $LastName be a part of? Please enter one: Executive, Accounting, IT "
    if ($TeamName -eq "Executive") {
        Add-ADPrincipalGroupMembership -Identity:"CN=$FirstName $LastName,CN=Users,DC=servername,DC=local" -MemberOf:"CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", `
        "CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", `
        "CN=Full Group Name,CN=Users,DC=servername,DC=local" -Server:"servername.domainname.local"
        Write-Host "User, $FirstName $LastName, successfully added to GIS Groups."
        }
            elseif ($TeamName -eq "Accounting"){
            Add-ADPrincipalGroupMembership -Identity:"CN=$FirstName $LastName,CN=Users,DC=servername,DC=local" -MemberOf:"CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", `
            "CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", `
            "CN=Full Group Name,CN=Users,DC=servername,DC=local" -Server:"servername.domainname.local"
            Write-Host "User, $FirstName $LastName, successfully added to Accounting Groups."
            }
                elseif ($TeamName -eq "IT") {
                Add-ADPrincipalGroupMembership -Identity:"CN=$FirstName $LastName,CN=Users,DC=servername,DC=local" -MemberOf:"CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", `
                "CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", "CN=Full Group Name,CN=Users,DC=servername,DC=local", `
                "CN=Full Group Name,CN=Users,DC=servername,DC=local" -Server:"servername.domainname.local"
                Write-Host "User, $FirstName $LastName, successfully added to IT Groups."
                }
        
    else {
    Write-Host "User not added to any groups."
    exit
    }
