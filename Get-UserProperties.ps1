<#
    .SYNOPSIS
        Function to grab AD user properties.
    .DESCRIPTION
        Written as a function to grab an AD account's properties and export them as a CSV file. Written
        to extract accounts from a txt file, but can be updated for other types.
    .NOTES
        Author:     David Findley
        Date:       3/14/2019
        Version:    1.0
#>
Function Get-UserProperties{
    Param(
      [Parameter(Mandatory=$true)]
      [string]$Server
   )

$data = [System.Collections.ArrayList]@()
$List = Get-Content "C:\Users\Username\Documents\Github Repo\Windows-Support\Active Directory\Users.txt"

Foreach ($account in $List){
    $User = Get-ADUser -Filter {extensionattribute2 -like $account} -Properties * -Server $Server
    Write-Host "Pulling" $user.DisplayName "account information." -ForegroundColor Blue

    $ItemDetails = [PSCustomObject]@{
        Name = $account
        Username = $User.SamAccountName
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
