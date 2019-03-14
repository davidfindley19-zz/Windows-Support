Function Get-UserProperties{
    Param(
      [Parameter(Mandatory=$true)]
      [string]$Server
   )
Import-Module ActiveDirectory

$data = [System.Collections.ArrayList]@()
$List = Get-Content "C:\Path\To\File.txt"

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
