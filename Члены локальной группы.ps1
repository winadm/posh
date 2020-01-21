cls

$Servers = (Get-ADComputer -Filter {(name -like "b0*") -and (enabled -eq $true)}).name
$gr = "Remote Desktop Users"

Foreach ($Server in $Servers)
{
	"-------------------------"
	$server
	If (Test-Connection -ComputerName $server -Count 2 -ErrorAction SilentlyContinue)
	{
		([ADSI]"WinNT://$Server/$gr").psbase.invoke("Members") | % {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
	}
	Else {"Not pingable"}
}