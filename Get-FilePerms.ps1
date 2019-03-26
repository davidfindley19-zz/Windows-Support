<#
    .SYNOPSIS
        Function to grab file acls.
    .DESCRIPTION
        A function that outputs the file permissions set for a directory into a CSV file. Works for 
        network and local shares.
    .NOTES
        Author:     David Findley
        Date:       3/25/2019
        Version:    1.1
        Change log:
                    1.0 (3/25) - Initial script to pull ACls from a folder.
                    1.1 (3/26) - Added in code for pulling subfolders.  
    .EXAMPLE
        Get-FilePerms -Path \\PATH\TO\THE\FOLDER
#>

Function Get-FilePerms{

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path
    )

Write-Host "File Share Permissions Report for $Path" -ForegroundColor Blue
$data = [System.Collections.ArrayList]@()
$subs = [System.Collections.ArrayList]@()
$acl = Get-Acl -Path $Path
$owner = $acl | select -expand Owner

foreach($accessRule in $acl.Access)
{
    Write-Output $accessRule.IdentityReference $accessRule.FileSystemRights
    $FolderDetails = [PSCustomObject]@{
        Name = $Path
        Group = $accessRule.IdentityReference
        Rights = $accessRule.FileSystemRights
        'Folder Owner' = $owner
    }
    $data.Add($FolderDetails) > $null
}

$data | Export-Csv C:\Temp\"File Permissions Report.csv" -NoTypeInformation

    $subfolders = Get-ChildItem $Path
    foreach ($subfolder in $subfolders){
        $subacl = $null
        $subacl = get-acl "$Path\$subfolder" | % {$_.access} | select filesystemrights, identityreference
        $subowner = get-acl "$Path\$subfolder"  

    $SubFolderDetails = [PSCustomObject]@{
        Name = $subfolder
        Group = $subacl.IdentityReference -join "`n"
        Rights = $subacl.FileSystemRights -join "`n"
        "Folder Owner" = $subowner.owner -join "`n"
    }
    Write-Output $subacl.IdentityReference $subacl.FileSystemRights
    $subs.Add($SubFolderDetails) > $null
    }
    
    $subs | Export-Csv C:\Temp\"File Permissions Report.csv" -Append -NoTypeInformation

}
