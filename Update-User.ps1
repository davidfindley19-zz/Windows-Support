<#
    .SYNOPSIS
        Function written to update a user's Email Address, SIP Address, and UPN.
    .DESCRIPTION
        Pulls from a list of users and performs the updates on their listed email address,
        SIP address, and UPN. Works from primary AD. 
    .NOTES
        Author: David Findley
        Date: 3/14/2019
        Version: 1.0 - Created from multiple previously written scripts.
#>

Function Update-User{
    $users = Import-Csv "C:\Path\to\file.csv"
    Function Update-UPN{
        
        foreach ($user in $users){
        
            Write-Host "Setting" $user.AccessID "new UPN." -ForegroundColor Yellow
            Set-ADUser $user.AccessID -UserPrincipalName $user.NewUPN -ErrorAction SilentlyContinue 
        
        }
        }
        Function Update-Email{
            
            foreach ($user in $users){
            
                Write-Host "Setting" $user.AccessID "new Email." -ForegroundColor Green
                Set-ADUser $user.AccessID -EmailAddress $user.NewUPN -ErrorAction SilentlyContinue 
            
            }
            }
        Function Update-SIP{
                
            foreach ($user in $users){
                #Have to generate the string to the SIP address since it's replacing an entry in an array.
                $OldAddress = Get-ADuser $user.AccessID -prop proxyaddresses | select -ExpandProperty proxyaddresses
                $OldUPN = "SIP:" + $user.OldUPN
                $NewUPN = $OldAddress -replace  "$OldUPN","SIP:$($user.NewUPN)" 
                
                Write-Host "Setting " $user.AccessID "new SIP." -ForegroundColor Blue
                #Replacing SIP in array.
                Set-ADUser $user.AccessID -Replace @{proxyaddresses=$NewUPN} -ErrorAction SilentlyContinue                    
                }
            }       
    #Calling each function for the account update.
    Update-SIP
    Update-Email
    Update-UPN
}
        
