# Sample scripts to run

## TODO: schedule tasks

## Install PSWinReporting and WEFTools

```powershell
Import-Module  WEFTools -Force
Import-Module  PSWinReportingV2 -Force

$WEDefinitionSet = @('ADComputerCreatedChanged','ADComputerDeleted',
                     'ADGroupChanges','ADGroupCreateDelete',
                     'ADPasswordChange',
                     'ADUserAccountEnabledDisabled','ADUserCreateDelete',
                     'ADUserLocked','ADUserUnlocked',
                     'LogClearSecurity','LogClearSystem',
                     'OSCrash','OSStartupShutdownCrash','OSStartupShutdownDetailed'
                     )
$Times = @{
    CurrentDayMinuxDaysX = @{
        Enabled = $true
        Days    = 1 # goes back X days and shows X number of days till Today
    }
}
$Events = foreach ($def in $WEDefinitionSet) {
    $GetEventFromWECSplat = @{
        WEDefinitionName    = $def
        #Verbose            = $true
        PassThru            = $true
        Times               = $Times
    }
    Get-EventFromWEC @GetEventFromWECSplat
}
$Keys = $Events.GetEnumerator() | Select-Object -ExpandProperty Keys

foreach ($k in $Keys) {
    $Events.$k | Out-GridView -Title $k
}


## Run with cache file and send to Azure Logs

```powershell

import-module C:\AdminTools\WEFTools -Force

$WEDefinitionSet = @('ADComputerCreatedChanged','ADComputerDeleted',
                     'ADGroupChanges','ADGroupCreateDelete',
                     'ADPasswordChange',
                     'ADUserAccountEnabledDisabled','ADUserCreateDelete',
                     'ADUserLocked','ADUserUnlocked',
                     'LogClearSecurity','LogClearSystem',
                     'OSCrash','OSStartupShutdownCrash','OSStartupShutdownDetailed'
                     )

$CacheFile = 'C:\AdminTools\Cache.json'

foreach ($def in $WEDefinitionSet) {
    $Times = Get-WESearchTimeFromCache -Path $CacheFile -WEDefinition $def
    $GetEventFromWECSplat = @{
        WEDefinitionName = $def
        WriteToAzureLog     = $true
        ALTableIdentifier   = 'WECLogs' #Name of Table in Azure Log Analytics
        ALWorkspaceID       = 'e1c2ce64-xxxx-yyyy-zzzz-555zzzzzzzz'
        WorkspacePrimaryKey = 'nXPotOAwqxgMXFq........./sNAyvYOrZg=='
        Times               = $Times
        WECacheExportFile   = $CacheFile
        Verbose             = $true
    }
    Get-EventFromWEC @GetEventFromWECSplat
}
```