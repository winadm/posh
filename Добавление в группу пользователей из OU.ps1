#Get-ADUser -SearchBase "OU=Пользователи,OU=ХОЛДИНГ,DC=zaoeps,DC=local" -Filter {enabled -eq $true} |
#%{Add-ADGroupMember -Identity term_RDP -Members $_}
