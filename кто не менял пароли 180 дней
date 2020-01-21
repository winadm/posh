cls
$180_Days = (Get-Date).adddays(-180)
$enablePCs = Get-ADuser -SearchBase  ‘OU=TPP Work Users and Computers,DC=TPPRF,DC=loc’ -Filter {enabled -eq $true} -Properties PasswordLastSet
$enablePCs | ForEach-Object {
  if ($_.passwordlastset -le $180_days)
      {
      $_.Name + " -- пароль устарел, последний раз менялся вот такого числа ==>" + " " + $_.passwordlastset
    }
}