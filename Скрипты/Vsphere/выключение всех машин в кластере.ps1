#Очищаем экран от прошлых выводов
Clear-Host

$dns = nslookup testredkin

for ($i=4; $i -lt ($dns.Count - 1); $i++)
{
	$dns[$i]=$dns[$i] -replace "a\S+"
	$dns[$i]=$dns[$i] -replace "\s+"
}	
$dc_ip=@()

for ($i=4; $i -lt ($dns.Count - 1); $i++)
{
	$dc_ip+= $dns[$i]
}


#Переменные: имя сервера с vicenter, имя кластера, где будем выключать виртуалки,
#массив контроллеров домена,
#время в секундах, через которое выключаемые виртуалки жестко погасятся.
$vi_server="b000343.zaoeps.local"
$cluster="testoff"
$dc=@()
$time = 120

#булевые переменные для проверки состояния проверки и то, что проверка уже была
$poweron = $true
$timecount = $false

#Подключаемся к серверу и забираем список виртуалок из нужного кластера
Connect-VIServer -Server $vi_server
$vm=get-cluster -Name $cluster |get-vm

for ($i=0; $i -le ($dc_ip.Count-1); $i++)
{
	for ($j=0; $j -le ($vm.Count-1); $j++)
	{
		$vmguest = Get-VMGuest -VM $vm[$j]
		if ($vmguest.IPAddress  -eq $dc_ip[$i])
		{
			$dc+=$vm[$j]
		}
	}
}
#Посылаем команду выключить гостевую ОС для каждой виртуалки кроме ДЦ
foreach ($i in $vm)
{
	$k = 0
	for ($j=0;$j -le ($dc.Count - 1); $j++)
	{
		if (($i.name -eq $dc[$j].name) -and ($i.PowerState -notlike "PoweredOff"))
		{
			$k = 1
		}		
	}
	if ($k -eq 0)
	{
		shutdown-vmguest -VM $i.Name -Confirm:$false 
	}
}

#Если виртуалки не все выключены, то ждем один раз, указанное время,
#потом жестко выключаем всё кроме ДЦ

while ($poweron)
{
	$poweron = $false
	$vm=get-cluster -Name $cluster |get-vm
	foreach ($i in $vm)
	{	
		$k = 0
		for ($j=0;$j -le ($dc.Count - 1); $j++)
		{
			if ($i.name -eq $dc[$j].name)
			{
				$k = 1
			}			
		}
		if ($k -eq 0)
		{
			if 	($i.PowerState -notlike "PoweredOff")
			{
				if (-not $timecount)
				{
					$poweron = $true
					Start-Sleep -Seconds $time
					$timecount = $true
				}
				else
				{
					$poweron = $true
					Stop-VM -VM $i -Confirm:$false					
				}
			}		
		}
	}	
}

$timecount = $false
$poweron = $true 

#Выключаем ДЦ
foreach ($i in $dc)
{
	
	if ($i.powerstate -notlike "PoweredOff")
	{
		shutdown-vmguest -VM $i.Name -Confirm:$false 	
	}
	
}

#Аналогичная проверка  на то, что виртуалки отключились с жестким выключением через 
#заданный промежуток времени
Start-Sleep -Seconds $time
$dc=@()

foreach ($i in $dc)
{
	
	if ($i.powerstate -notlike "PoweredOff")
	{
		Stop-VM -VM $i -Confirm:$false	
	}
	
}

