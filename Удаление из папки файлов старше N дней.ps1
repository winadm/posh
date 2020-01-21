Clear-Host
$FolderPath = "\\b000074\C$\SecLog"
$Files = Get-ChildItem $FolderPath
$NowDate = Get-Date
[system.decimal]$DaysOfLive = 30
#$DaysOfLive

For ($i=0; $i -lt $Files.Count; $i++) 
{
	$TimeDifference = $NowDate - $Files[$i].CreationTime
	#$TimeDifference.TotalDays
	If ($TimeDifference.TotalDays -gt $DaysOfLive) {Del -Force -Confirm:$false $Files[$i].FullName}
}