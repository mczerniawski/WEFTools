# How to Deploy WEF with Palantir

## Requirements

- Fresh Windows 2016 VM with baseline policies of your choice
- Domain joined and located in OU where GPO for WEC servers is linked
- AD RSAT installed on WEC server
- Group Policies created and linked accordingly - see [Prepare GPO](.\GPO_Prepare.md)

## Introdcution

All code is supposed to be run from your local management station (this can you your workstation or dedicated management server).

- Code wrapped in regions with label `[Local]` will 'change stuff' on your workstation.
- Code wrapped in regions with label `[Remote]` will 'change stuff' on remote machines.
- Code wrapped in regions with label `[AD]` will 'change stuff' in Active Directory.
- Code wrapped in regions with label `[Verify]` will get information and output on the screen.

```powershell
# region [Local] prepare environment variables
$DomainName = 'contoso.com'
$FQDNDomainName = 'DC=contoso,DC=com'
$CollectorName= 'WEC0.{0}' -f $DomainName
$Credential = Get-Credential
$CollectorSession = New-PSSession -ComputerName $CollectorName -Credential $Credential
#endregion

# region [Local] Prepare script variables
$DownloadPath = "$env:USERPROFILE\Downloads"
$OutFileName = 'PalantirWEF.zip'
$OutFile = (Join-Path -Path $DownloadPath -ChildPath $OutFileName)
$DestinationRemoteFile = Join-Path -Path 'C:\AdminTools' -ChildPath $OutFileName
$DestinationUnzipPath = 'C:\AdminTools\WEF\'
$DestinationFullPath = Join-Path -Path $DestinationUnzipPath -ChildPath 'windows-event-forwarding-master\wef-subscriptions'
$DestinationFullPathEventChannels = Join-Path -Path $DestinationUnzipPath -ChildPath 'windows-event-forwarding-master\windows-event-channels'
$OUPathforWEFGroups = 'OU=WEFRules,OU=Security Groups,{0}' -f $FQDNDomainName
$GroupPrefix = 'WEF' #for generating AD groups
$LogPath = 'D:\Logs'
$MaxLogSize = 4GB
#endregion


#region [Local] Install AD RSAT tool if
#Invoke-command -Session $CollectorSession -ScriptBlock {
#   Install-WindowsFeature -name RSAT-AD-PowerShell
#   Update-Help -force
#}
#endregion

#region [Local] download zip with all Palantir samples from their GitHub
#Set TLS 1.2 to fir Invoke-WebRequest
if (-not ([Net.ServicePointManager]::SecurityProtocol).tostring().contains("Tls12")){
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/palantir/windows-event-forwarding/archive/master.zip -OutFile $OutFile
#endregion

#region [Remote] Copy WEF to destination server using $ToSession
Copy-Item -Path $OutFile -Destination $DestinationRemoteFile -ToSession $CollectorSession
#endregion

#region [Local] unzip
#region unzip locally for generating AD Groups and other stuff
    Expand-Archive -Path $OutFile -DestinationPath $DestinationUnzipPath -force
#endregion

#region [Remote] unzip remotely
Invoke-command -Session $CollectorSession -ScriptBlock {
    Expand-Archive -Path $USING:DestinationRemoteFile -DestinationPath $USING:DestinationUnzipPath
}
#endregion

#endregion

#region [Local] [AD] Get WEF subscriptions to create groups for each xml subscription:
$GroupNames = Get-ChildItem $DestinationFullPath -Filter '*.xml' | Select-Object BaseName
foreach ($sampleRuleName in $GroupNames){
    $groupProps = @{
        Name = '{0}-{1}' -f $GroupPrefix ,$sampleRuleName
        Path = $OUPathforWEFGroups
        GroupScope = 'Universal'
        Description= 'Computers from this group will receive subscription {0} from WEC server' -f $sampleRuleName
    }
    $testGroup = Get-ADGroup -filter {Name -eq $sampleRuleName} -ErrorAction SilentlyContinue
    if (-not ($testGroup)) {
        Write-Host "Creating Group {$($groupProps.Name)}"
        New-ADGroup @groupProps
    }
}
#endregion

#region [Remote] configure Event Forwarding on collector server
Invoke-Command -Session $CollectorSession -ScriptBlock {
    WECUtil qc /q
}
#endregion

#region [Remote] Create custom event forwarding logs based on Palantir's dll and man
Invoke-Command -Session $CollectorSession -ScriptBlock {
    Write-Host 'Stop WEC service'
    Stop-Service Wecsvc

    Write-Host 'Unload current event channnel'
    wevtutil um C:\windows\system32\CustomEventChannels.man

    #copy new man and dll
    Write-Host 'Copying EventChannel files'
    $files = "CustomEventChannels.dll","CustomEventChannels.man"
    foreach ($file in $files){
        Copy-Item -Path (Join-Path $USING:DestinationFullPathEventChannels -ChildPath $file) -Destination 'C:\Windows\system32'
    }

    #load new event channel file and start Wecsvc service
    Write-Host 'Loading new event channel file'
    wevtutil im C:\windows\system32\CustomEventChannels.man
    Write-Host 'Starting WEC service'
    Start-Service Wecsvc
}
#endregion

#region [Local] [Remote] Import XML files for rules, that will be configured on collector

Write-Host 'Import XML files for rules, that will be configured on collector'
$XMLFiles = Get-ChildItem $DestinationFullPath | Where-Object {$PSItem.Extension -eq ".xml" }

Write-Host 'Process Templates: add AD group to each template and create subscription'
foreach ($XMLFile in $XMLFiles){
        #Generate AllowedSourceDomainComputers parameter
        $GroupName = '{0}-{1}' -f $GroupPrefix , $XMLFile.Basename
        $SID = (Get-ADGroup -Identity $GroupName ).SID.Value
        $AllowedSourceDomainComputers = "O:NSG:BAD:P(A;;GA;;;{0})S:" -f $SID
        [xml]$XML = get-content $XMLFile.FullName

        #[Remote]
        Invoke-Command -Session $CollectorSession -ScriptBlock {
            $xml = $USING:XML
            $xml.subscription.AllowedSourceDomainComputers=$USING:AllowedSourceDomainComputers
            $xml.Save("$env:TEMP\temp.xml")
            wecutil cs "$env:TEMP\temp.xml"
        }
}
#endregion

#region [Verify] [Remote] View all subscriptions and ACLs
$subscriptions = Invoke-Command -Session $CollectorSession -ScriptBlock {
    #enumerate subscriptions
    $subs = wecutil es
    foreach ($sub in $subs){
        [xml]$xml=wecutil gs $sub /f:xml
        foreach ($subXML in $xml.subscription) {
            [pscustomobject]@{
                SubscriptionId = $subXML.SubscriptionId
                SubscriptionType = $subXML.SubscriptionType
                Description = $subXML.Description
                Enabled = $subXML.Enabled
                Uri = $subXML.Uri
                ConfigurationMode = $subXML.ConfigurationMode
                Delivery = $subXML.Delivery
                Query = $subXML.Query."#cdata-section"
                ReadExistingEvents = $subXML.ReadExistingEvents
                TransportName = $subXML.TransportName
                ContentFormat = $subXML.ContentFormat
                Locale = $subXML.Locale
                LogFile = $subXML.LogFile
                AllowedSourceNonDomainComputers = $subXML.AllowedSourceNonDomainComputers
                AllowedSourceDomainComputers = $subXML.AllowedSourceDomainComputers
                AllowedSourceDomainComputersFriendly = (ConvertFrom-SddlString $subXML.AllowedSourceDomainComputers).DiscretionaryAcl
            }
        }
    }
}

$subscriptions | Format-Table SubscriptionId, AllowedSourceDomainComputersFriendly, LogFile  -AutoSize
$subscriptions.count
#endregion

#region [Remote] Create LOG folder, switch location and set log size
Invoke-Command -Session $CollectorSession -ScriptBlock {
    #Create log folder if not exist
    If (-not (Test-Path $using:LogPath)){
        Write-Host 'Create log folder'
        New-Item -Path $USING:LogPath -Type Directory
    }
    else {
        Write-Host "Log Folder at {$($USING.LogPath)} exists"
    }
    $WECLogs = wevtutil el | Where-Object {$PSItem -match 'WEC'}
    foreach ($wecLog in $WECLogs) {
        Write-Host "Setting max size for log {$wecLog} to {$($USING:MaxLogSize/1GB) GB}"
        wevtutil set-log $wecLog /MaxSize:$($Using:MaxLogSize)
        $LogLocation = Join-Path -Path $USING:LogPath -ChildPath ('{0}.evtx' -f $wecLog)
        Write-Host "Setting log location {$wecLog} to {$($LogLocation)}"
        wevtutil set-log $wecLog /LogFileName:$LogLocation
    }
}
#endregion

#region [Remote] Enable remote access to Event Log to Collector - remote admin access
# Run this if you will read logs on WEC from remote management station
Invoke-Command -ComputerName $CollectorName -ScriptBlock {
    Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
}
#endregion

#region [Local] Add domain controllers to specific WEF groups
#Select which groups you'd like to add Domain Controllers to
#Proposed minimal groups are:
############################# TODO
$Groups = Get-ADGroup -filter * -SearchBase $OUPathforWEFGroups | Out-GridView -PassThru

$DomainControllers = (Get-ADDomain | Select-Object -ExpandProperty ReplicaDirectoryServers)
$servers =@(
    $DomainControllers | ForEach-Object {
        Get-ADComputer -identity (($PSItem).Split('.') | Select-Object -First 1 )
    }
)
foreach ($group in $Groups) {
    foreach ($server in $servers) {
        Write-Host "Adding Server {$($server.Name)} to group {$group}"
        Add-ADGroupMember $group -Members $server
    }
}
#endregion

#region [Local] Repeat for Computers and WEFGroups by filtering with Out-GridView output
$Groups = Get-ADGroup -filter * -SearchBase $OUPathforWEFGroups | Out-GridView -PassThru

$servers = Get-ADComputer -filter {OperatingSystem -like '*Windows*'} | Out-GridView -PassThru

foreach ($group in $Groups) {
    foreach ($server in $servers) {
        Write-Host "Adding Server {$($server.Name)} to group {$group}"
        Add-ADGroupMember $group -Members $server
    }
}
#endregion

# gpupdate doesn't work. need to reboot computer
Invoke-Command -ComputerName $DomainControllers -ScriptBlock {
    cmd /c 'gpupdate /force'
} -InDisconnectedSession

# Recommended groups where computers to add:
####################### TODO

# Cleanup
$CollectorSession | Remove-PSSession
```