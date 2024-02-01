# скрипт для блокировки IP адресов, с которых идут попытки RDP подключений с перебором паролей
# Подробности здесь: https://winitpro.ru/index.php/2019/10/02/blokirovka-rdp-atak-firewall-powershell/
# количество неудачных попыток входа с одного IP адреса, при достижении которого нужно заблокировать IP
$badAttempts = 5
# Просмотр лога за последние 2 часа
$intervalHours = 2
# Если в блокирующем правиле более 3000 уникальных IP адресов, создать новое правило Windows Firewall
$ruleMaxEntries = 3000
# номер порта, на котором слушает RDP
$RdpLocalPort=3389
# файл с логом работы PowerShell скрипта
$log = "c:\ps\rdp_block.log"
# Список доверенных IP адресов, которые нельзя блокировать
$trustedIPs = @("192.168.1.100", "192.168.1.101","8.8.8.8")  

$startTime = [DateTime]::Now.AddHours(-$intervalHours)
$badRDPlogons = Get-EventLog -LogName 'Security' -After $startTime -InstanceId 4625 |
    Where-Object { $_.Message -match 'logon type:\s+(3)\s' } |
    Select-Object @{n='IpAddress';e={$_.ReplacementStrings[-2]}}
$ipsArray = $badRDPlogons |
    Group-Object -Property IpAddress |
    Where-Object { $_.Count -ge $badAttempts } |
    ForEach-Object { $_.Name }

# Удалить доверенные IP адреса 
$ipsArray = $ipsArray | Where-Object { $_ -notin $trustedIPs }


if ($ipsArray.Count -eq 0) {
    return
}
[System.Collections.ArrayList]$ips = @()
[System.Collections.ArrayList]$current_ip_lists = @()
$ips.AddRange([string[]]$ipsArray)
$ruleCount = 1
$ruleName = "BlockRDPBruteForce" + $ruleCount
$foundRuleWithSpace = 0

while ($foundRuleWithSpace -eq 0) {
    $firewallRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if ($null -eq $firewallRule) {
        New-NetFirewallRule -DisplayName $ruleName –RemoteAddress 1.1.1.1 -Direction Inbound -Protocol TCP –LocalPort $RdpLocalPort -Action Block
        $firewallRule = Get-NetFirewallRule -DisplayName $ruleName
        $current_ip_lists.Add(@(($firewallRule | Get-NetFirewallAddressFilter).RemoteAddress))
        $foundRuleWithSpace = 1
    } else {
        $current_ip_lists.Add(@(($firewallRule | Get-NetFirewallAddressFilter).RemoteAddress))
        
        if ($current_ip_lists[$current_ip_lists.Count – 1].Count -le ($ruleMaxEntries – $ips.Count)) {
            $foundRuleWithSpace = 1
        } else {
            $ruleCount++
            $ruleName = "BlockRDPBruteForce" + $ruleCount
        }
    }
}
# Удалить IP адреса, которые уже есть в правиле 
for ($i = $ips.Count – 1; $i -ge 0; $i--) {
    foreach ($current_ip_list in $current_ip_lists) {
        if ($current_ip_list -contains $ips[$i]) {
            $ips.RemoveAt($i)
            break
        }
    }
}

if ($ips.Count -eq 0) {
    exit
}

# Заблокировать IP в firewall и записать в лог
$current_ip_list = $current_ip_lists[$current_ip_lists.Count – 1]
foreach ($ip in $ips) {
    $current_ip_list += $ip
    (Get-Date).ToString().PadRight(22) + ' | ' + $ip.PadRight(15) + ' | The IP address has been blocked due to ' + ($badRDPlogons | Where-Object { $_.IpAddress -eq $ip }).Count + ' failed login attempts over ' + $intervalHours + ' hours' >> $log
}

Set-NetFirewallRule -DisplayName $ruleName -RemoteAddress $current_ip_list
