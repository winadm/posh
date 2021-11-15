# Скрипт создает определенную структуру OU в Active Directory, создает группу администратров, назначет права на новые OU
# используется при создании нового филиала (города) в Active Directory с типовой структурой контейнеров
# Подробности и описание в статье: https://winitpro.ru/index.php/2021/11/15/sozdat-strukturu-ou-v-active-directory-powershell/


# Задаем название контейнера
$City = "NSK"
$CityRu="Новосибирск"
$DomainDN=(Get-ADDomain).DistinguishedName
$OUs = @(
"Admins",
"Computers",
"Contacts",
"Groups",
"Servers",
"Service Accounts",
"Users"
)
# создаем OU
$newOU=New-ADOrganizationalUnit -Name $City  –Description “Контейнер для пользователей $CityRu” -PassThru
ForEach ($OU In $OUs) {
    New-ADOrganizationalUnit -Name $OU -Path $newOU
}
#Создаем административные группы
$adm_grp=New-ADGroup ($City+ "_admins") -path ("OU=Admins,OU="+$City+","+$DomainDN) -GroupScope Global -PassThru –Verbose
$adm_wks=New-ADGroup ($City+ "_account_managers") -path ("OU=Admins,OU="+$City+","+$DomainDN) -GroupScope Global -PassThru –Verbose
$adm_account=New-ADGroup ($City+ "_wks_admins") -path ("OU=Admins,OU="+$City+","+$DomainDN) -GroupScope Global -PassThru –Verbose

##### Права на сброс паролей для группы _account_managers на OU Users
    $confADRight = "ExtendedRight"
    $confDelegatedObjectType = "bf967aba-0de6-11d0-a285-00aa003049e2" # User Object Type GUID
    $confExtendedRight = "00299570-246d-11d0-a768-00aa006e0529" # Extended Right PasswordReset GUID
    $acl=get-acl ("AD:OU=Users,OU="+$City+","+$DomainDN)
    $adm_accountSID = [System.Security.Principal.SecurityIdentifier]$adm_account.SID
    #строим строку Access Control Entry (ACE)
    $aceIdentity = [System.Security.Principal.IdentityReference] $adm_accountSID
    $aceADRight = [System.DirectoryServices.ActiveDirectoryRights] $confADRight
    $aceType = [System.Security.AccessControl.AccessControlType] "Allow"
    $aceInheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "Descendents"
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($aceIdentity, $aceADRight, $aceType, $confExtendedRight, $aceInheritanceType,$confDelegatedObjectType)
    # Применяем ACL
    $acl.AddAccessRule($ace)
    Set-Acl -Path ("AD:OU=Users,OU="+$City+","+$DomainDN) -AclObject $acl
######
