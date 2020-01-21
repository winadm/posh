# Поиск в конкретном контейнере AD всех отключенный учетных записей (строка 8)
# И удаление из всех групп (группа "Пользователи домена" останется)

If  ( (Get-Module -Name activedirectory) -ne $null ) {} Else {"ActiveDirectory module was not loaded. Loading AD...";Import-Module activedirectory;"ActiveDirectory module loaded."}

Clear-Host
Write-Host "Выполнение скрипта..." -ForegroundColor DarkGreen
Get-ADUser -SearchBase "OU=УказатьКонтейнер,OU=Уволенные,OU=Пользователи,OU=ХОЛДИНГ,DC=zaoeps,DC=local" -Filter {enabled -eq $false} -Properties MemberOf | ForEach-Object {
	$MemberOf = $_.MemberOf # Получаем массив групп, членом которых является пользователь
	$_.samaccountname
#	$MemberOf
#	If ($MemberOf -ne $null) {$LastNoNullMemberOf = $MemberOf}
	If ($MemberOf -ne $null) {
		For ($i =0 ; $i -lt $MemberOf.Count; $i++) {
#			$i
			Remove-ADGroupMember -Identity $MemberOf[$i] -Members $_ -Confirm:$false
			"Удалена группа: "+$MemberOf[$i]
		}
	}
}