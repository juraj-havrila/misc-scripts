## Windows Firewall Rules Management Script of Prod/IT
## Requires import file with FW rules in .json format (same format like export file -option '/e')
## Juraj Havrila, 2019-07-29
## ToDo: Generate Report of Rules differing or missing according to the input file (/c)
## ToDo: Help output (/h)
## Todo: Specify LogFile (/l)

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "/i"){ $fileImport=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-i"){ $fileImport=$args[ $i+1 ]}
    if ($args[ $i ] -eq "/e"){ $fileExport=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-e"){ $fileExport=$args[ $i+1 ]}
}
New-Item -Path "C:\Temp\LogFiles_ServerInstallation" -ItemType Directory -ErrorAction Ignore
$scriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$scriptLog = "C:\Temp\LogFiles_ServerInstallation\$scriptName.log"
if ($fileImport){
    $my_infile=$PSScriptRoot+"\"+$fileImport
    if (!(Test-Path $fileImport)) { $fileImport = $my_infile}
    $fw_rules_should = Get-Content $fileImport | ConvertFrom-Json
    $my_timestamp = Get-Date -Format g
    Add-Content $scriptlog "$my_timestamp INFO: Importing FW Configuration from file $my_infile"
    }
  else{
    $my_infile=$PSScriptRoot+"\"+$scriptName+".json"
    if ((Test-Path $my_infile)) {
        $my_timestamp = Get-Date -Format g
        Add-Content $scriptlog "$my_timestamp INFO: Importing FW Configuration from (default) file $my_infile"
        $fw_rules_should = Get-Content $my_infile | ConvertFrom-Json
        }
        else { 
        $my_timestamp = Get-Date -Format g
        Add-Content $scriptlog "$my_timestamp INFO: No Import file with FW rules found."
        }
  }
$property_list= ("Name","Description","Profile","ServiceName","ApplicationName","Protocol","LocalAdresses","LocalPorts","RemoteAddresses","RemotePorts","Direction","Action","Enabled")
#### Hashes of config codes
#$code_protocol=@{1 ="ICMP"; 6="TCP"; 17="UDP";27="RDP";58="ICMPv6";256="Any"}    #$code_protocol[1] or $code_protocol.1
$code_protocol= @{256="Any";1=”ICMPv4”;2=”IGMP”;6=”TCP”;17=”UDP”;41=”IPv6”;43=”IPv6Route”; 44=”IPv6Frag”; 47=”GRE”; 58=”ICMPv6”;59=”IPv6NoNxt”;60=”IPv6Opts”;112=”VRRP”; 113=”PGM”;115=”L2TP”;”ICMPv4”=1;”IGMP”=2;”TCP”=6;”UDP”=17;”IPv6”=41;”IPv6Route”=43;”IPv6Frag”=44;”GRE”=47;”ICMPv6”=48;”IPv6NoNxt”=59;”IPv6Opts”=60;”VRRP”=112; ”PGM”=113;”L2TP”=115}
$code_scope=@{0="All Networks"; 1="Only local subnets"; 2="Custom Scope"; 3="Max scope"}
$code_ipversion=@{0="IPv4"; 1="IPv6"; 2="Any"}
#$code_direction=@{1="Inbound"; 2="Outbound"}
$code_direction=@{1=”Inbound”; 2=”outbound”; ”Inbound”=1;”outbound”=2} 
$code_profile=@{1GB=”All”;1="Domain"; 2="Private";4="Public";2147483647="Any"}
$code_action=@{0="Block"; 1="Allow"}
$code_status=@{0="Disabled"; 1="Enabled"}
#$code_icmptype
####
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
$fw_rules_is = (New-Object -comObject HNetCfg.FwPolicy2).rules | select $property_list
if ($fileExport){
    $my_outfile=$PSScriptRoot+"\"+$fileExport
    $fw_rules_is | ConvertTo-Json -depth 100 | Out-File $my_outfile
    $my_timestamp = Get-Date -Format g
    Add-Content $scriptlog "$my_timestamp INFO: Exporting FW Configuration into file $my_outfile"
    }
 foreach ($my_fw_rule_should in $fw_rules_should){
    $is_there=0
    foreach ($my_fw_rule_is in $fw_rules_is){
        if (($my_fw_rule_is.Name -eq $my_fw_rule_should.Name) -and ($my_fw_rule_is.ApplicationName -eq $my_fw_rule_should.ApplicationName) -and ($my_fw_rule_is.Protocol -eq $my_fw_rule_should.Protocol) -and ($my_fw_rule_is.LocalPorts -eq $my_fw_rule_should.LocalPorts) -and ($my_fw_rule_is.Direction -eq $my_fw_rule_should.Direction)){
            $is_there=1
            }
        }
        if ($is_there){
            $my_timestamp = Get-Date -Format g
            Add-Content $scriptlog "$my_timestamp INFO: FW Rule $my_fw_rule_should already exists and will not be imported"
            }
        else {
            $my_timestamp = Get-Date -Format g
            Add-Content $scriptlog "$my_timestamp INFO: FW Rule $my_fw_rule_should will be imported"
            if (! $my_fw_rule_should.Profile) {$my_fw_rule_should.Profile=2147483647} 
            $my_name=$my_fw_rule_should.Name
            $my_description=$my_fw_rule_should.Description
            $my_protocol=$code_protocol.($my_fw_rule_should.Protocol)
            $my_direction=$code_direction.($my_fw_rule_should.Direction)
            if (! $my_fw_rule_should.Profile) {$my_profile="Any"}
              else {$my_profile=$code_profile.($my_fw_rule_should.Profile) }
            $my_action=$code_action.($my_fw_rule_should.Action)
            $my_status=$code_status.($my_fw_rule_should.Enabled)
            if ($my_status){$my_enabled="True"} else {$my_enabled="False"}
            if (! $my_fw_rule_should.ApplicationName) {$my_application="Any"}
              else {$my_application=$my_fw_rule_should.ApplicationName}
            if (!$my_fw_rule_should.LocalPorts -Or $my_fw_rule_should.LocalPorts -eq "*"){ $my_localports="Any" }
              else {
                  $my_localports=$my_fw_rule_should.LocalPorts
                  $my_localports=$my_localports.split(",")
                  }
            if (!$my_fw_rule_should.RemotePorts -Or $my_fw_rule_should.RemotePorts -Eq "*"){$my_remoteports="Any"}
              else {
                  $my_remoteports=$my_fw_rule_should.RemotePorts
                  $my_remoteports=$my_localports.split(",")
                  }
            $my_localadress=$my_fw_rule_should.LocalAddresses
            $my_remoteadress=$my_fw_rule_should.RemoteAddresses
            New-NetFirewallRule -Direction $my_direction -DisplayName $my_name -Enabled $my_enabled -Profile $my_profile -Program $my_application -Protocol $my_protocol -LocalPort $my_localports -Description $my_description -RemotePort $my_remoteports -LocalAddress $my_localaddress -RemoteAddress $my_remoteaddress -Action $my_action 
           }
}