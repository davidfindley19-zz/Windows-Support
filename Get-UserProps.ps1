<#
    .SYNOPSIS
        Function to grab AD user properties.
    .DESCRIPTION
        Written as a function with a menu to grab an AD account's properties and export them as a CSV file. 
        Written to extract accounts from a txt file, but can be updated for other types. The script allows the user 
        to select the property they need to search with. Written according to what I normally search with, but can 
        be edited for different properties. 
    .NOTES
        Author:     David Findley
        Date:       3/14/2019
        Version:    1.0
#>

Function Get-UserProps {

Param(
    [Parameter(Mandatory=$true)]
    [string]$Domain
)
Function Show-Menu
{
    cls
    Write-Host " ================ Checking user properties on domain: $Domain =============== "

    Write-Host "1: Press '1' to search by extensionattribute2."
    Write-Host "2: Press '2' to search by email address."
    Write-Host "3: Press '3' to search by upn."
    Write-Host "Q: Press 'Q' to quit."
}

Function Get-Properties {
    
        cls
        $data = [System.Collections.ArrayList]@()
        $List = Get-Content "C:\Temp\Users.txt"
        $User = $null
        Foreach ($account in $List){
            $User = Get-ADUser -Filter {$property -like $account} -Properties * -Server $Domain
            Write-Host "Pulling" $user.DisplayName "account information." -ForegroundColor Blue

        $ItemDetails = [PSCustomObject]@{
            Name = $account
            Username = $User.SamAccountName
            'MyAccess ID' = $User.extensionattribute2
            Email = $User.emailaddress
            UPN = $User.userprincipalname
            'Last Logon' = $User.lastlogondate
            Enabled = $User.Enabled
            'Password Expired' = $User.passwordexpired
            'Account Created' = $User.whenCreated
        }
        $data.Add($ItemDetails) > $null
        }    
        
$data | Export-Csv C:\Temp\Results.csv -NoTypeInformation

}

do{

    Show-Menu
    $input = Read-Host "Please make a selection."
    switch($input)
    {
        1 {$property = 'extensionattribute2'}
        2 {$property = 'emailaddress'}
        3 {$property = 'userprincipalname'}
        Q {return}
    }
      
    Get-Properties

    Pause
    
}
until ($input -eq 'q')

}
