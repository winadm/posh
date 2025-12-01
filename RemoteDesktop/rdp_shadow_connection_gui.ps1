# PowerShell скрипт с GUI для вывода списка активных терминальных (RDP) сессий пользователей и подключения к ним через Remote Desktop Shadowing
# Работает во всех версиях Windows Server выше 2012, роль RDSH не обязательна 
# Подробности здесь: https://winitpro.ru/index.php/2014/02/12/rds-shadow-v-windows-2012-r2/

Add-Type -AssemblyName System.Windows.Forms

$Header = "SESSIONNAME", "USERNAME", "ID", "STATUS"

$dlgForm = New-Object System.Windows.Forms.Form
$dlgForm.Text = 'Session Connect'
$dlgForm.Width = 400
$dlgForm.AutoSize = $true

$dlgBttn = New-Object System.Windows.Forms.Button
$dlgBttn.Text = 'Control'
$dlgBttn.Location = New-Object System.Drawing.Point(15, 10)
$dlgForm.Controls.Add($dlgBttn)

$dlgList = New-Object System.Windows.Forms.ListView
$dlgList.Location = New-Object System.Drawing.Point(0, 50)
$dlgList.Width = $dlgForm.ClientRectangle.Width
$dlgList.Height = $dlgForm.ClientRectangle.Height
$dlgList.Anchor = "Top, Left, Right, Bottom"
$dlgList.MultiSelect = $false
$dlgList.View = 'Details'
$dlgList.FullRowSelect = $true
$dlgList.GridLines = $true
$dlgList.Scrollable = $true
$dlgForm.Controls.Add($dlgList)

# Add columns to the ListView
foreach ($column in $Header) {
    $dlgList.Columns.Add($column) | Out-Null
}

# Populate ListView items
(qwinsta.exe | findstr "Active") -replace "^[\s>]" , "" -replace "\s+", "," | 
    ConvertFrom-Csv -Header $Header | ForEach-Object {
        $dlgListItem = New-Object System.Windows.Forms.ListViewItem($_.SESSIONNAME)
        $dlgListItem.SubItems.Add($_.USERNAME) | Out-Null
        $dlgListItem.SubItems.Add($_.ID) | Out-Null
        $dlgListItem.SubItems.Add($_.STATUS) | Out-Null
        $dlgList.Items.Add($dlgListItem) | Out-Null
    }

# Button click event handler
$dlgBttn.Add_Click({
    $SelectedItem = $dlgList.SelectedItems[0]
    if ($null -eq $SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Выберите сессию для подключения")
    } else {
        $session_id = $SelectedItem.SubItems[2].Text
        mstsc /shadow:$session_id /control
        # To show session id in a message box, uncomment the next line
        # [System.Windows.Forms.MessageBox]::Show($session_id)
    }
})

$dlgForm.ShowDialog()
