Clear-Host

#В одну строку
Get-Mailboxdatabase -status | %{$_.name+" "+$_.availablenewmailboxspace}

#Подробный вариант
#$name=Get-Mailboxdatabase -status 
#foreach ($i in $name)
#{
#	$i.name+" "+$i.availablenewmailboxspace
#}