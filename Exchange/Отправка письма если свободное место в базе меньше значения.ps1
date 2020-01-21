Clear-Host
$Size = (Get-Mailboxdatabase -Identity "Removed Mailbox" -Status).AvailableNewMailboxSpace -replace "^.+ \("
$Size = $Size -replace " by.+"
$Size = $Size -replace ","
$Size.ToString()
$Size = $Size/1Gb
#$Size = '{0:F}' -f $Size
$Size
If ($Size -lt 40) 
{
	$emailFrom = "<RemovedMailboxWhiteSize@zaoeps.local>"
	$emailTo = "sistemnaya_gr@zaoeps.local"
	$subject = "Заканчивается свободное место в почтовой базе Removed Mailbox"
	$body = "Свободное место в почтовой базе Removed Mailbox составляет "+('{0:F}' -f $Size)+" Gb"
	$message = New-Object System.Net.Mail.MailMessage –ArgumentList $emailFrom, $emailTo, $subject, $body
	$smtpServer = "172.25.71.94"
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)
	$smtp.Send($message)
}