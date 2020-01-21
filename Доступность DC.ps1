#доступность LDAPS порта (TCP 636) на каждом DC в домене с помощью командлета Test-NetConnection. Если LDAPS порт на DC не доступен, появляется предупреждение.


cls
$AllDCs = Get-ADDomainController -Filter * | Select-Object Hostname,Ipv4address,isGlobalCatalog,Site,Forest,OperatingSystem
ForEach($DC in $AllDCs)
{
$PortResult=Test-NetConnection -ComputerName $DC.Hostname -Port 636 -InformationLevel Quiet
if ($PortResult -ne "$True"){
write-host $DC.Hostname " не доступен" -BackgroundColor Red -ForegroundColor White
}else {
write-host $DC.Hostname " доступен" }
}

#Выведем более удобную таблицу, в которой указаны все контроллеры домена с их именем, IP адресом, версией ОС и именем сайта AD

Get-ADDomainController -Filter *| Select Name, ipv4Address, OperatingSystem, site | Sort-Object name