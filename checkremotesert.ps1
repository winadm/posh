$minCertAge = 60
 $timeoutMs = 10000
 $sites = @(
 "https://winitpro.ru",
 "https://www.google.com/",
 )
 
# отключить проверку корректности сертфиката 
 [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
foreach ($site in $sites)
 {
	 Write-Host Проверка $site -f Green
	 $req = [Net.HttpWebRequest]::Create($site)
	 $req.Timeout = $timeoutMs
	try {$req.GetResponse() |Out-Null} catch {Write-Host Exception while checking URL $site`: $_ -f Red}
	[datetime]$certExpDate = $req.ServicePoint.Certificate.GetExpirationDateString()
	 [int]$certExpiresIn = ($certExpDate - $(get-date)).Days
	$certName = $req.ServicePoint.Certificate.GetName()
	 $certThumbprint = $req.ServicePoint.Certificate.GetCertHashString()
	 $certEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
	 $certIssuer = $req.ServicePoint.Certificate.GetIssuerName()
	if ($certExpiresIn -gt $minCertAge)
		{Write-Host Сертификат для сайта $site истечет через $certExpiresIn days [$certExpDate] -f Green}

	 else
		{Write-Host Сертификат для сайта  $site истечет через  $certExpiresIn days [$certExpDate]. Подробности:`n`nCert name: $certName`nCert thumbprint: $certThumbprint`nCert effective date: $certEffectiveDate`nCert issuer: $certIssuer -f Red}

 }