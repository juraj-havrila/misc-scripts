 function Get-ProvisioningShouldValues ($my_host)
{
	<#
	.SYNOPSIS
		This function will list all the members of the local group 'Administrators'
	.EXAMPLE
		
	

	
	.NOTES
		TODO:
            inspired by:
            #https://gallery.technet.microsoft.com/scriptcenter/List-Member-of-Sql-Server-58ff31c6
	#>
	[CmdletBinding()]

#Param(
#  [parameter(Mandatory=$true)]
#  [String]
#  $my_host
#)


[xml]$expected = Get-Content C:\DATA\scripts\PowerShell\validation\server_configuration_template_5.xml

#$should_hostname = $expected.xml.attributes.hostname.'#text'

foreach ($item in $expected)
{
#$item
#$item.server.hostname 
#$my_host

 if ($item.server.hostname -like $my_host)
 {

# "kokot"
$should_hostname = $item.server.hostname
$should_net_release = $item.server.net_release
$should_cpu_cores= $item.server.cpu_cores
$should_host_memory= $item.server.host_memory
$should_sql_memory= $item.server.sql_memory
$should_sql_NumErrorLogs= $item.server.sql_NumErrorLogs
$should_nic = $item.server.nic
$should_volumes = $item.server.disk
$should_host_admins = $item.server.host_admins
$should_sql_admins = $item.sql_admins



foreach ($drive in $item.server.disk)
{
#$drive.DriveLetter
}

}

}

return $should_hostname, $should_net_release, $should_cpu_cores, $should_host_memory, $should_sql_memory, $should_sql_NumErrorLogs, $should_nic, $should_volumes, $should_host_admins, $should_sql_admins
}

#Validate-HostParameters


