<#
    .SYNOPSIS
        Function to grab file acls.
    .DESCRIPTION
        A function that outputs the file permissions set for a directory into a CSV file. Works for 
        network and local shares.
    .NOTES
        Author:     David Findley
        Date:       3/25/2019
        Version:    1.0
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
$CR = "`r"

$CR
Write-Host "File Share Permissions Report for $Path" $CR -ForegroundColor Blue
$CR
$acl = Get-Acl $Path
$data = [System.Collections.ArrayList]@()

foreach($accessRule in $acl.Access)
{
    Write-Output $accessRule.IdentityReference $accessRule.FileSystemRights

    $FolderDetails = [PSCustomObject]@{
        Name = $Path
        Group = $accessRule.IdentityReference
        Rights = $accessRule.FileSystemRights
    }
    $data.Add($FolderDetails) > $null
}

$data | Export-CSV C:\Temp\"File Permissions Report.csv" -NoTypeInformation

}
