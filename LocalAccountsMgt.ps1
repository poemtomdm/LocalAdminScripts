#Necessary modules
Install-Module azuread -Force
Import-Module azuread -Force

#AAD connection
$UPN = whoami /upn
Connect-AzureAD -AccountId $UPN

#TO EDIT : targeted AAD group
$aadgroup = "SG.AZ.SG.OSS-UEM-Users"


#function to get recursive users of targeted group

Function Get-RecursiveAzureAdGroupMemberUsers{
[cmdletbinding()]
param(
   [parameter(Mandatory=$True,ValueFromPipeline=$true)]
   $AzureGroup
)
    Begin{
        If(-not(Get-AzureADCurrentSessionInfo)){Connect-AzureAD}
    }
    Process {
        [psobject[]] $UserMembers = @()
        Write-Verbose -Message "Enumerating $($AzureGroup.DisplayName)"
        $Members = Get-AzureADGroupMember -ObjectId $AzureGroup.ObjectId -All $true
        
        $UserMembers = $Members | Where-Object{$_.ObjectType -eq 'User'}
        If($Members | Where-Object{$_.ObjectType -eq 'Group'}){
            $UserMembers += $Members | Where-Object{$_.ObjectType -eq 'Group'} | ForEach-Object{ Get-RecursiveAzureAdGroupMemberUsers -AzureGroup $_}
        }
    }
    end {
        Return $UserMembers
    }

}


#clean adm grp
$adms = Get-LocalGroupMember -SID "S-1-5-32-544" -member * | select name -ExpandProperty name

foreach ($adm in $adms) {
    
    if ($adm -ne  "$env:COMPUTERNAME\Gisemonde.Pettersen") {

    
    Remove-LocalGroupMember -SID "S-1-5-32-544" -Member $adm -ErrorAction SilentlyContinue }


}

#get users concerned
$users = Get-AzureADGroup -SearchString $aadgroup | Get-RecursiveAzureAdGroupMemberUsers | select UserPrincipalName -ExpandProperty UserPrincipalName


#add users to group
foreach  ($user in $users) {

Add-LocalGroupMember -SID "S-1-5-32-544" -Member "AzureAD\$user"

}


