$serverlist = Get-Content C:\DATA\scripts\PowerShell\vag5_servers.txt

#$serverlist = "S010A66MEZ43A","S010A66MEZ44B"
#$serverlist = "S010AHZ07A"


. C:\DATA\scripts\PowerShell\validation\Get-ProvisioningShouldValues.ps1; 
foreach ($my_server in $serverlist) {
$should_hostname=''
($should_hostname, $should_net_release, $should_cpu_cores, $should_host_memory, $should_sql_memory, $should_sql_NumErrorLogs, $should_nic, $should_volumes, $should_host_admins, $should_sql_admins) = (Get-ProvisioningShouldValues $my_server)

if ($should_hostname){
. C:\DATA\scripts\PowerShell\validation\Collector-Provisioning.ps1; ($my_hostname, $my_net_release, $my_cpu_cores, $my_host_memory, $my_sql_memory, $my_sql_NumErrorLogs, $my_nic, $my_volumes, $my_host_admins, $my_sql_admins) = Invoke-Command -computername $my_server -Credential e010_a_jhavril -ScriptBlock ${function:Collector-Provisioning}





if ($should_hostname -like $my_hostname) {Write-Host -ForegroundColor "Green" "OK  | Hostname: $my_hostname"}
    else {Write-Host -ForegroundColor "Red" "NOK | Hostname: $my_hostname does not match required $should_hostname"}
if ($should_cpu_cores -eq $my_cpu_cores) {Write-Host -ForegroundColor "Green" "OK  | CPU Cores: $my_cpu_cores"}
    else {Write-Host -ForegroundColor "Red" "NOK | CPU Cores: $my_cpu_cores does not match required $should_cpu_cores"}
if ($should_host_memory -eq $my_host_memory) {Write-Host -ForegroundColor "Green" "OK  | Host Memory: $my_host_memory"}
    else {Write-Host -ForegroundColor "Red" "NOK | Host Memory: $my_host_memory does not match required $should_host_memory"}
if ($should_sql_memory -eq $my_sql_memory) {Write-Host -ForegroundColor "Green" "OK  | SQL Memory: $my_sql_memory"}
    else {Write-Host -ForegroundColor "Red" "NOK | SQL Memory: $my_sql_memory does not match required $should_sql_memory"}
if ($should_sql_NumErrorLogs -eq $my_sql_NumErrorLogs) {Write-Host -ForegroundColor "Green" "OK  | Number of SQL Error Logs: $my_sql_NumErrorLogs"}
    else {Write-Host -ForegroundColor "Red" "NOK | Number of SQL Error Logs: $my_sql_NumErrorLogs does not match required $should_sql_NumErrorLogs"}
if ($should_net_release -eq $my_net_release) {Write-Host -ForegroundColor "Green" "OK  | .NET Release: $my_net_release"}
    else {Write-Host -ForegroundColor "Red" "NOK | .NET Release: $my_net_release does not match required $should_net_release"}


#### Disk Check
foreach ($should_drive in $should_volumes){
    foreach ($is_drive in $my_volumes){

if ($should_drive.DriveLetter -like $is_drive.DriveLetter){

  if (($should_drive.Label -like $is_drive.Label) -and ($should_drive.Capacity_GB -eq $is_drive.Capacity_GB) -and ($should_drive.BlockSize_kB -eq $is_drive.BlockSize_kB)) {
    Write-Host -ForegroundColor "Green" "OK  | Disk Drive "$should_drive.DriveLetter" has required Capacity "$is_drive.Capacity_GB"GB, Block Size "$is_drive.BlockSize_kB"kB and Label "$is_drive.Label ""
    }
    else {
        Write-Host -ForegroundColor "Red" "NOK | Disk Drive "$should_drive.DriveLetter" with required Capacity "$should_drive.Capacity_GB"GB, Block Size "$should_drive.BlockSize_kB"kB and Label "$should_drive.Label "does not match with actual "$is_drive.Capacity_GB"GB, "$is_drive.BlockSize_kB"kB and "$is_drive.Label " label"
        }
  }
     }
  }

####NIC Check



###





#$should_hostname
#$my_host_memory
}
}
