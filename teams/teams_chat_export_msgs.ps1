# Скрипт позволяет экспортировать из чата Teams все сообщения и ответы на них в HTML файл
# Подробнее настройка и использование описаны здесь: https://winitpro.ru/index.php/2023/02/01/eksport-chatov-teams/

# подключаемся к Azure AD и получаем токен
$clientId = " our_app_ID"
$tenantName = "yourtenant.onmicrosoft.com"
$clientSecret = "your_secret"
$resource = "https://graph.microsoft.com/"
$Username = "user@yourtenant.onmicrosoft.com"
$Password = "yourpassword"

$ReqTokenBody = @{
    Grant_Type    = "Password"
    client_Id     = $clientID
    Client_Secret = $clientSecret
    Username      = $Username
    Password      = $Password
    Scope         = "https://graph.microsoft.com/.default"
}
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

# вывести список групп teams
header= @{Authorization = "Bearer $($TokenResponse.access_token)"}
$BaseURI = "https://graph.microsoft.com/beta"
$AllMicrosoftTeams = (Invoke-RestMethod -Uri  "$($BaseURI)/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')" -Headers $header -Method Get -ContentType "application/json").value
$AllMicrosoftTeams| FT id, DisplayName,Description

# вывести список каналов в группе Teams
$TeamsID="your_team_id"
$TeamsChannels = (Invoke-RestMethod -Uri "$($BaseURI)/teams/$($TeamsID)/channels" -Headers $Header -Method Get -ContentType "application/json").value
$TeamsChannels | FT id, DisplayName,Description

# получить список сообщений и ответов в чате из указанного канала Teams 
$ChannelID="your_chat_id "
$Header =@{Authorization = "Bearer $($Tokenresponse.access_token)"}
$apiUrl = "https://graph.microsoft.com/beta/teams/$TeamsID/channels/$ChannelID/messages"
$Data = Invoke-RestMethod -Uri $apiUrl -Headers $header  -Method Get
$Messages = ($Data | Select-Object Value).Value
class messageData
{
    [string]$dateTime
    [string]$from
    [string]$body   
    [string]$re   
    messageData()
    {
        $this.dateTime = ""
        $this.from = ""
        $this.body = ""
        $this.re = ""
    }
}
$messageSet = New-Object System.Collections.ArrayList;
foreach ($message in $Messages)
{
    $result = New-object messageData
    $result.DateTime=Get-Date -Date (($message).createdDateTime) -Format 'yyyy/MM/dd HH:mm'
    $result.from = $message.from.user.displayName
    $result.body = $message.body.content
    $messageSet.Add($result)
    #parsing replies
    $repliesURI = "https://graph.microsoft.com/beta/teams/" + $TeamsID + "/channels/" + $ChannelID + "/messages/" + $message.ID + "/replies?`$top100"
    $repliesResponse = Invoke-RestMethod -Method Get -Uri $repliesURI  -Headers $header
    foreach ($reply in $repliesResponse.value)
     {
        $replyData = New-Object messageData
        $replyData.dateTime = Get-Date -Date (($reply).createdDateTime) -Format 'yyyy/MM/dd HH:mm'
        $replyData.from = $reply.from.user.displayName
        $replyData.body= $reply.body.content
        $replyData.re="RE"
        $messageSet.Add($replyData)
     } 
}
$messageSet|ConvertTo-Html | Out-File c:\ps\teams_chat_history.html -Encoding utf8
