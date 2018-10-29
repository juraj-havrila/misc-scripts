 function Collector-Provisioning
{
	<#
	.SYNOPSIS
		This function collects All indicators from All Servers
	.EXAMPLE
	. C:\DATA\scripts\PowerShell\validation\Collector-Provisioning.ps1; ($my_hostname, $my_net_release, $my_cpu_cores, $my_host_memory, $my_sql_memory, $my_sql_NumErrorLogs, $my_nic, $my_volumes, $my_host_admins, $my_sql_admins) = Invoke-Command -computername $serverlist -Credential e010_a_jhavril -ScriptBlock ${function:Collector-Provisioning}	
	

	
	.NOTES
		TODO:
            inspired by:
            
	#>
	[CmdletBinding()]
 


$my_hostname = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name

$dotnet_regkey = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
$my_net_release = (Get-ItemProperty -Path $dotnet_regkey -Name Release).Release

$cpu_status = Get-CimInstance -Class Win32_Processor | select systemname,Name,DeviceID,NumberOfCores,NumberOfLogicalProcessors, Addresswidth
$my_cpu_cores = ($cpu_status.NumberOfCores | Measure-Object -Sum).sum

$my_host_memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0}" -f ([math]::round(($_.Sum / 1MB),2))}
$my_sql_memory = (invoke-sqlcmd -Query "SELECT value FROM sys.configurations WHERE name='max server memory (MB)';").value

$logcount_regkey = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer'
$my_sql_NumErrorLogs = (Get-ItemProperty -Path $logcount_regkey -Name NumErrorLogs).NumErrorLogs



######## NICs


$nic_raw=Get-NetAdapterRss | Select Name, InterfaceDescription, Enabled, MaxProcessors

$my_nic = @()

foreach ($rs in $nic_raw) {
    $my_nic += [pscustomobject] @{
 
        AdapterName          = $rs.Name
        AdapterDescription   = $rs.InterfaceDescription
        RSSEnabled           = $rs.Enabled
        MaxProcessors        = $rs.MaxProcessors
        }
}


####### Disks

$volumes = Get-WmiObject -Class Win32_Volume | Select-Object -Property DriveLetter,Label,Capacity, FreeSpace, BlockSize

$my_volumes = @()

foreach ($Volume in $volumes) {
    $my_volumes += [pscustomobject] @{
        DriveLetter          = $Volume.DriveLetter
        Label                = $Volume.Label
        Capacity_GB          = [math]::round( $Volume.Capacity / [math]::pow( 1024, 3))
        Used_GB              = [math]::round( $Volume.Capacity / [math]::pow( 1024, 3)) - [math]::round($Volume.FreeSpace / [math]::pow( 1024, 3))
        BlockSize_kB         = $Volume.BlockSize / 1024
        }
}

####### Local admins

 $admin_list = Get-LocalGroupMember -Group "Administrators"
$my_host_admins = @()

foreach ($member in $admin_list) {
    $my_host_admins += [pscustomobject] @{
        ObjectClass          = $member.ObjectClass
        Name                 = $member.Name
        PrincipalSource      = $member.PrincipalSource

        }
}
######## SQL Admins

		$accessList = invoke-sqlcmd -Query "select name, isntgroup, isntuser from sys.syslogins where isntname='1'" 
		
        $my_sql_admins = @()

        foreach ($access in $accessList) { 
        $my_sql_admins += [pscustomobject] @{
			ComputerName = $hostname
			Name = $access.name
			isGroup = $access.isntgroup
			isUser = $access.isntuser

		}
}
######## Hotfix count
$pom_hotfix=Get-Hotfix
$my_hotfix_count=$pom_hotfix.count

########

return $my_hostname, $my_net_release, $my_cpu_cores, $my_host_memory, $my_sql_memory, $my_sql_NumErrorLogs, $my_nic, $my_volumes, $my_host_admins, $my_sql_admins, $my_hotfix_count


}
