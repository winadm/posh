# Ящики (не факсы) на которые нет ни укого доступа, кроме "SELF" (красный цвет), если при этом учетка отключена - поносный цвет
# Или доступ только у пустой группы типа AccessList (красный цвет)
# Доступ у непустой группы - зеленый цвет
# Доступ у отключенного пользователя - синий цвет у имени этого пользователя
# Остальное - белый цвет

$Boxes = Get-Mailbox -Database "Removed Mailbox" | Where {$_.name -notlike "*Факс"}

$BoxesM = @() # Общие ящики на которые нет ни укого достпуа, кроме "SELF"
$BoxesAccessListEmpty = @() # Ящики с доступом только для группы AccessList и она пуста
Foreach ($Box in $Boxes)
{
		
		$AccessUser = @()
		Get-MailboxPermission $Box | 
		Where {
			-not ($_.User -like "ZAOEPS\Администраторы домена") -and
			-not ($_.User -like "ZAOEPS\Администраторы предприятия") -and
			-not ($_.User -like "ZAOEPS\dom_admin") -and
			-not ($_.User -like "ZAOEPS\IAbramov") -and
			-not ($_.User -like "ZAOEPS\sredkin") -and
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
			-not ($_.User -like "NT AUTHORITY\SYSTEM") -and
			-not ($_.User -like "ZAOEPS\ServerAdmin") -and
			-not ($_.User -like "ZAOEPS\Public Folder Management") -and
			-not ($_.User -like "NT AUTHORITY\SELF")
		} | %{$AccessUser += $_.User.SecurityIdentifier.Value}
		If ($AccessUser.Count -eq 0) 
		{
			"--------------------------------------------------------"
			$Enabled = $null
			$Enabled = (get-aduser ((Get-Mailbox $Box.Name).UserPrincipalName -replace "@.+$")).Enabled
			If ($Enabled -eq $false) 
			{
				Write-Host $Box.Name" - Ни у кого нет прав на почтовый ящик (учетная запись отключена)" -ForegroundColor DarkYellow
#				Add-Content c:\1\RM_E.txt $Box.Name
			}
			Else {Write-Host $Box.Name" - Ни у кого нет прав на почтовый ящик" -ForegroundColor Red}
			$NotManagedBy = $true
			$BoxesM += $Box
			
		}
		If ($AccessUser.Count -gt 0) 
		{
			"--------------------------------------------------------"
			Write-Host $Box.Name" - Права на почтовый ящик есть у:"
			For ($i=0; $i -lt $AccessUser.Count; $i++)
			{
				$Str = $AccessUser[$i]
				$UtIsUser = $null # Предположим, что объект, который имеет права на ящик, не является пользователем
				$ErrorActionPreference = "SilentlyContinue"
				$UtIsUser = Get-ADUser -Filter {SID -eq $Str} -Properties SID
				$ErrorActionPreference = "Continue"
				If ($UtIsUser -ne $null)
				{	# Если объект есть пользователь
					Get-ADUser -Filter {SID -eq $Str} -Properties SID , Enabled | 
					%{
						If ($_.Enabled) {$Enabled = " - активный"} Else {$Enabled = " - отключен"}
						If ($Enabled -like " - отключен") {Write-Host ">>> " $_.name $Enabled -ForegroundColor Blue}
						Else {">>> "+ $_.name + $Enabled}
					}
				}
				Else
				{	# Если объект не пользователь, т.е. объект - есть группа
					
					$String = Get-ADGroup -Filter {SID -eq $Str} -Properties SID | 
					%{
						">>> "+$_.SamAccountName+" ("+$_.Name+")"
						$AccessListGroupe_SamAccountName = $_.SamAccountName
					}					
					If ($String -match "List")
					{						
						$members = Get-ADGroupMember $AccessListGroupe_SamAccountName | %{$_.name}
						If ($members -ne $null)
						{
							Write-Host $String -ForegroundColor DarkGreen
						}
						Else
						{
							Write-Host $String -ForegroundColor Red
							$BoxesAccessListEmpty += $Box
						}
					}
					Else {$String}
				}
			}		
		}		
}