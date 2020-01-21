 param (
    $User,
    $PDC = "adcore1",
    $Count = 1,
 ) 
    $FilterHash = @{}
    $FilterHash.LogName = "Security"
    $FilterHash.ID = "4740"
    if ($User) {
        $FilterHash.data =$User
        $Count = 1
    }
    $FilterHash2 = @{}
    $FilterHash2.LogName = "Security"
    $FilterHash2.ID = "4625"
    Get-WinEvent -Computername $PDC -FilterHashtable $FilterHash -MaxEvents $Count |  foreach {
        $ResultHash = @{} 
        $ResultHash.Username = ([xml]$_.ToXml()).Event.EventData.Data | ? {$_.Name -eq “TargetUserName”} | %{$_."#text"}
        $ResultHash.DCFrom = ([xml]$_.ToXml()).Event.EventData.Data | ? {$_.Name -eq “TargetDomainName”} | %{$_."#text"}
        $ResultHash.LockTime = $_.TimeCreated
        $FilterHash2.data = $username
        Get-WinEvent -Computername $dcfrom -FilterHashtable $FilterHash2 -MaxEvents 1 | foreach {
            $ResultHash.SrcHost = ([xml]$_.ToXml()).Event.EventData.Data | ? {$_.Name -eq “IpAddress”} | %{$_."#text"}
            $ResultHash.LogonType = ([xml]$_.ToXml()).Event.EventData.Data | ? {$_.Name -eq “LogonType”} | %{$_."#text"}
            $ResultHash.FalureTime = $_.TimeCreated
            $ResultHash 
        }
    }
 
 #Set-ExecutionPolicy Restricted -Scope CurrentUser
 #Set-ExecutionPolicy Bypass -Scope CurrentUser
    
