# Подгрузить командлеты Exchange (занимает некоторое время)
# add-pssnapin microsoft.exchange.management.powershell.e2010

Clear-Host
$NewPostDomain = "elliron.com" 					 # Новый почтовый домен для пользователя
Get-ADGroupMember "TestReplaceAddr" -Recursive | # Получение всех членов группы, включая членство в подчиненных группах
Where {$_.objectClass -eq "User"} |           # Выборка только учетных записей
%{Get-Mailbox $_.name |                       # Получение почтового ящика пользователя
 %{											  # Для каждого почтового ящика
 	$NeedUpdateAddresses = $false			  # Сброс переменной - обновлять список почтовых адресов не требуется
	$Addresses = $_.EmailAddresses            # Запоминаем все почтовые адреса с атрибутами (smtp, sip и т.д.)
	For ($i=0; $i -lt $Addresses.Count; $i++) # Для всех почтовых адресов пользователя 
	{
		If ( ($Addresses[$i].ProxyAddressString -cmatch "SMTP") -and # Заглавные SMTP в атрибуте "ProxyAddressString" означает адрес в качестве отправителя (основной)
		($Addresses[$i].ProxyAddressString -notmatch $NewPostDomain) -and 
		($Addresses[$i].ProxyAddressString -notmatch "zaoeps.local") ) 
		{	# Если почтовый адрес основной
			$Addresses[$i].ProxyAddressString   # Отладочный вывод ProxyAddressString
			$EMail = $Addresses[$i].SmtpAddress # Запоминаем сам адрес
			$EMail -match "^.+\@"               # Выделяем имя адреса без домена
			$EMail = $Matches[0]+$NewPostDomain # Формируем новый адрес имя@домен
			$EMail                              # Здесь уже готовый адрес для замены
			$Addresses[$i] = $EMail             # Заменяем основной почтовый адрес на новый. Замена происходит только в переменной, но не на почтовом сервере
			$NeedUpdateAddresses = $true	    # Требуется обновить список почтовых адресов
		}
	}
	$Addresses # Отладочный вывод списка почтовых адресов текущего почтового ящика
	
	# Запись сформированного списка почтовых адресов в ящик пользователя, если список обновился
	#If ($NeedUpdateAddresses) {Set-Mailbox $_ -EmailAddresses $Addresses}
  }
}