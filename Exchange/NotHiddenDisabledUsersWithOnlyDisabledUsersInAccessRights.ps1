# Поиск почтовых ящиков для отключенных пользователей, у которых почтовые адреса не скрыты в адресной книге
# и к которым предоставлены права FullAccess только для отключенных пользователей

Clear-Host
$DisabledUsers = @()
Get-Mailbox -ResultSize unlimited | 
%{    
      $Samaccountname = $_.samaccountname
      $User = Get-ADUser -Filter {samaccountname -eq $Samaccountname} -Properties samaccountname,enabled
      If ($User.enabled -eq $false) {$DisabledUsers+=$User.SamAccountName}
      
}

$NotHiddenDisabledUsers = @()
$DisabledUsers |
Get-Mailbox | 
%{if ($_.HiddenFromAddressListsEnabled -eq $false){$NotHiddenDisabledUsers+=$_.samaccountname}}

$NotHiddenDisabledUsersWithOnlyDisabledUsersInAccessRights = @()

Foreach ($NotHiddenDisabledUser in $NotHiddenDisabledUsers)
{
	#Get-ADUser $NotHiddenDisabledUser | %{$DisplayName = $_.name}	
	$FullAccessUser = @()
	$DisplayName="zaoeps\"+$NotHiddenDisabledUser
	Get-MailboxPermission -Identity $DisplayName |
	Where {
		-not ($_.User -like "ZAOEPS\Администраторы домена") -and
		-not ($_.User -like "ZAOEPS\Администраторы предприятия") -and
		-not ($_.User -like "ZAOEPS\dom_admin") -and
		-not ($_.User -like "ZAOEPS\IAbramov") -and
		-not ($_.User -like "ZAOEPS\sredkin") -and
		-not ($_.User -like "ZAOEPS\VMusatov") -and
		-not ($_.User -like "ZAOEPS\Exchange Services") -and
		-not ($_.User -like "ZAOEPS\Exchange Organization Administrators") -and
		-not ($_.User -like "ZAOEPS\Exchange Trusted Subsystem") -and
		-not ($_.User -like "ZAOEPS\Organization Management") -and
		-not ($_.User -like "ZAOEPS\Exchange Enterprise Servers") -and
		-not ($_.User -like "ZAOEPS\Exchange View-Only Administrators") -and
		-not ($_.User -like "ZAOEPS\Delegated Setup") -and
		-not ($_.User -like "ZAOEPS\Exchange Domain Servers") -and
		-not ($_.User -like "ZAOEPS\Exchange Servers") -and
		-not ($_.User -like "NT AUTHORITY\NETWORK SERVICE") -and
		-not ($_.User -like "NT AUTHORITY\система") -and
		-not ($_.User -like "ZAOEPS\ServerAdmin") -and
		-not ($_.User -like "ZAOEPS\Public Folder Management") -and
		-not ($_.User -like "NT AUTHORITY\SELF")
	}| %{$FullAccessUser += $_.User.SecurityIdentifier.Value}
#	If ($FullAccessUser -eq @()) {"Ни у кого нет прав"}
	$ActiveUsers = $false
	For ($i=0; $i -lt $FullAccessUser.Count; $i++)
	{
		$Str = $FullAccessUser[$i]
		If ((Get-ADUser -Filter {SID -eq $Str} -Properties SID , Enabled).Enabled){$ActiveUsers = $true}
	}
	If ($ActiveUsers) 
	{Write-Host $NotHiddenDisabledUser" - используется активным пользователем" -ForegroundColor Red} 
	Else 
	{
		$NotHiddenDisabledUsersWithOnlyDisabledUsersInAccessRights+=$NotHiddenDisabledUser
		Write-Host $NotHiddenDisabledUser" - не используется активным пользователем" -ForegroundColor DarkGreen
	}
}
	