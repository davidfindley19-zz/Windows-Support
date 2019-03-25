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
        Version:    1.2
        Change Log:
                    1.0 (3/14) - Imported original script from Get-ADUserProperties that initially included logging.
                    1.1 (3/14) - Wrote as function Get-UserProps for easier searching. 
                    1.2 (3/19) - Added Write-Log function for recording all search output. 
#>

#Declaration of function that runs the script. Domain is mandatory.
Function Get-UserProps {

Function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
     
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
     
    [pscustomobject]@{
        Time = (Get-Date -F g)
        Message = $Message
        Severity = $Severity
        } | Export-Csv -Path "C:\Temp\Logs\LogFileUserProps.csv" -Append -NoTypeInformation
    }
    

Function Show-Domain{
    Clear-Host
    Write-Host " ========== Please select your domain to connect to ========== "
#Multiple domains to choose from in our environment.
    Write-Host "1: Press '1' to connect to domain1."
    Write-Host "2: Press '2' to connect to domain2."
    Write-Host "Q: Press 'Q' to quit."
}
#Function for the menu output.
Function Show-Menu
{
    Clear-Host
    Write-Host " ================ Checking user properties on domain: $domain =============== "

    Write-Host "1: Press '1' to search by extensionattribute2."
    Write-Host "2: Press '2' to search by email address."
    Write-Host "3: Press '3' to search by upn."
    Write-Host "Q: Press 'Q' to quit."
}

#The AD search function.
Function Get-Properties {
    
        Clear-Host
        Write-Log -Message "Searching the $domain domain." -Severity Information
        Write-Log -Message "User search started at $(Get-Date -Format "HH:mm")"
        $data = [System.Collections.ArrayList]@()
        $List = Get-Content "C:\Temp\Users.txt"
        $User = $null
        Foreach ($account in $List){
            $User = Get-ADUser -Filter {$property -like $account} -Properties * -Server $domain
            Write-Host "Getting" $user.DisplayName "account information." -ForegroundColor Blue
        
            if($user -ne $null){
                Write-Log -Message "Successfully found $account" -Severity Information
            }
            elseif($user -eq $null){
                Write-Log -Message "$account not found." -Severity Error
            }

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
            'Password Last Set' = $User.passwordlastset
        }
        $data.Add($ItemDetails) > $null
        }    
#Export as CSV for easier reporting.       
$data | Export-Csv C:\Temp\Results.csv -NoTypeInformation
Write-Log -Message "User search completed at $(Get-Date -Format "HH:mm")"
Rename-Item -Path C:\Temp\Logs\LogFile.csv -NewName C:\Temp\Logs\LogFile$(Get-Date -Format MMddyy-HHmm).csv
Rename-Item -Path C:\Temp\Results.csv -NewName C:\Temp\Results\Results$(Get-Date -Format MMddyy-HHmm).csv

}

#Allows you to the make selection. Mostly behind the scenes for Show-Menu
do{
    Show-Domain
    $domainoption = Read-Host "Please make a selection."
    switch ($domainoption) {
        1 {$domain = 'domain1'}
        2 {$domain = 'domain2'}
        Q {return}
    }

    Show-Menu
    $input = Read-Host "Please make a selection."
    switch($input)
    {
        1 {$property = 'extensionattribute2'}
        2 {$property = 'emailaddress'}
        3 {$property = 'userprincipalname'}
        Q {return}
    }
    #Calls the search function from above  
    Get-Properties

    Pause
    
}
until ($input -eq 'q')

}

