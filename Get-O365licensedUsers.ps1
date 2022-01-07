#Connect to Azure AD.
#--------------------
Connect-MsolService -Credential $Credentials

#Write the function.
#-------------------
Function Get-O365LicensedUsers {

$LogFile = "c:\temp\Office_365_Licenses.csv" 

$licensetype = Get-MsolAccountSku | Where {$_.ConsumedUnits -ge 1} 
 
    foreach ($license in $licensetype)  {     
    $headerstring = "DisplayName,UserPrincipalName,AccountSku" 
     
    foreach ($row in $($license.ServiceStatus))  { 
        $headerstring = ($headerstring + "," + $row.ServicePlan.servicename) } 
     
    Out-File -FilePath $LogFile -InputObject $headerstring -Encoding UTF8 -append 
    write-host ("Gathering users with the following subscription: " + $license.accountskuid) 
 
    $users = Get-MsolUser -all | where {$_.isLicensed -eq "True" -and $_.licenses.accountskuid -contains $license.accountskuid} 

    foreach ($user in $users) { 
         
        write-host ("Processing " + $user.displayname) 
 
        $thislicense = $user.licenses | Where-Object {$_.accountskuid -eq $license.accountskuid} 
        $datastring = ($user.displayname + "," + $user.userprincipalname + "," + $license.SkuPartNumber) 
         
            foreach ($row in $($thislicense.servicestatus)) { 
             
            $datastring = ($datastring + "," + $($row.provisioningstatus))} 
         
    Out-File -FilePath $LogFile -InputObject $datastring -Encoding UTF8 -append} 
    Out-File -FilePath $LogFile -InputObject " " -Encoding UTF8 -append}             
 
    write-host ("Script Completed.  Results available in " + $psdir + $LogFile) -ForegroundColor Green
}

#Call the function.
#------------------
Get-O365LicensedUsers