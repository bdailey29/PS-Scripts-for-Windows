
#Office 365 License Delegation
$username = ""
$AESKeyFilePath = "C:\"
$AESKey = Get-Content $AESKeyFilePath
$credpath = "C:\"
$pwdstring = Get-Content $credpath
$securepwd = $pwdstring | ConvertTo-SecureString -Key $AESKey
$credObject = New-Object System.Management.Automation.PSCredential-ArgumentList $username, $securepwd

#Wait 60 seconds for scheduled task to run on it3
#Start-Sleep -Seconds 60

#Force Sync with Azure AD via on-prem ADFS Server
Invoke-Command -ComputerName "XXX" -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta } -Credential $credObject

#Wait 90 seconds for sync to finish before connecting to Azure
Start-Sleep -Seconds 90

#Connect to Azure AD
Connect-MsolService -Credential $credObject

#Store E3 License Into A Variable (optional)
#$E3License = Get-MsolAccountSku | where-object {$_.AccountSkuID -eq 'wearepop0:ENTERPRISEPACK'}

# Disable the Exchange Online service so it does not get added with all the other services in the E3 license
$NoExchange = New-MsolLicenseOptions -AccountSkuID "XXX" -DisabledPlans "XXX"

#add username variable, remember to put quotes!
$newO365user = "XXX"

#User must first be assigned locale ID before assigning a license
Set-MsolUser -UserPrincipalName $newO365user -UsageLocation US

#Assign the License!
Set-MsolUserLicense -UserPrincipalName $newO365user -AddLicenses "XXX" -LicenseOptions $NoExchange

$LicenseStatus = Get-Msoluser -UserPrincipalName $newO365user | Format-List -Property isLicensed
Write-Output $LicenseStatus #| Add-Content $logfile

exit