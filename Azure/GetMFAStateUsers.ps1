# Скрипт для получения MFA статусов для всех пользователей в тенанте AzureAD/Microsoft 365
# подробнее https://winitpro.ru/index.php/2021/11/15/vklyuchit-otklyuchit-mfa-polzovatelu-azure-ad-microsoft-365/
Connect-MsolService
$Report = @()
$AzUsers = Get-MsolUser -All 
ForEach ($AzUser in $AzUsers) {  
    $DefaultMFAMethod = ($AzUser.StrongAuthenticationMethods | ? { $_.IsDefault -eq "True" }).MethodType
    $MFAState = $AzUser.StrongAuthenticationRequirements.State
    if ($MFAState -eq $null) {$MFAState = "Disabled"} 
    $objReport = [PSCustomObject]@{
        User     = $AzUser.UserPrincipalName
        MFAState = $MFAState
        MFAPhone = $AzUser.StrongAuthenticationUserDetails.PhoneNumber
        MFAMethod = $DefaultMFAMethod 
    }
    $Report += $objReport
}
$Report
