function Get-DisconnectedMailbox {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [System.String]
        $Name = '*'
    )
    
    $mailboxes = Get-MailboxServer
    $mailboxes | %{
        $disconn = Get-Mailboxstatistics -Server $_.name | ?{ $_.DisconnectDate -ne $null }
        $disconn | ?{$_.displayname -like $Name} | 
            Select DisplayName,
            @{n="StoreMailboxIdentity";e={$_.MailboxGuid}},
            Database
    }
}