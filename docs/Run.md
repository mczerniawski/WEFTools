# Sample scripts to run

<!-- TOC -->
- [Install required modules](#Install-PSWinReporting-and-WEFTools)
- [Check current list of definitions](#Get-Current-Definition-List)
- [How to run search with all definitions](#Run-all-definitions)
- [How to run search with only specific definitions](#Run-only-specific-Definitions)
- [How using cache file send results to Azure log](#Use-Cache-and-Azure-Log)
- [Easily view all results in out-gridview windows](#View-all-definitions-in-Out-Grid-windows)
- [Check cache file content](#View-cache-file-content)
<!-- /TOC -->

## Install PSWinReporting and WEFTools

```powershell
Install-Module WEFTools -Force
Install-Module PSWinReportingV2 -Force
Import-Module  WEFTools -Force
Import-Module  PSWinReportingV2 -Force
```

## Get Current Definition List

```powershell
Get-WEDefinitionList
```

Will result in list of current `definition files`:

```cmd
ADComputerCreatedChanged
ADComputerDeleted
ADGroupChanges
ADGroupCreateDelete
ADPasswordChange
ADUserAccountEnabledDisabled
ADUserCreateDelete
ADUserLocked
ADUserUnlocked
LogClearSecurity
LogClearSystem
OSCrash
OSStartupShutdownCrash
OSStartupShutdownDetailed
```

## Run all definitions

Search for events from 1 Past Day. DateTime Parameters are derived from PSWinDocumentation!

```powershell
$GetEventFromWECSplat = @{
    Times               = 'CurrentDayMinuxDaysX'
    Days                = 1
    WECacheExportFile   = 'C:\AdminTools\Cache.json'
    Verbose             = $true
    PassThru            = $true
}
$Events = Get-EventFromWEC @GetEventFromWECSplat
```

## Run only specific Definitions

```powershell
$WEDefinitionSet = @('LogClearSecurity','LogClearSystem',
                     'OSCrash','OSStartupShutdownCrash','OSStartupShutdownDetailed'
                     )
$Events = foreach ($definition in $WEDefinitionSet) {
    $GetEventFromWECSplat = @{
        WEDefinitionName    = $definition
        Times               = 'CurrentDayMinuxDaysX'
        Days                = 1
        Verbose             = $true
        PassThru            = $true
    }
    Get-EventFromWEC @GetEventFromWECSplat
}
```

## Use Cache and Azure Log

- Get last success export time from cache file.
- Set search date FROM based on cache for given definition and TO as current
- If found export events to Azure Logs
- Update cache file with LastRunTime (now) and LastExporTime (if succeeded) for given definition

```powershell
Import-Module WEFTools -Force
$GetEventFromWECSplat = @{
    WriteToAzureLog     = $true
    ALTableIdentifier   = 'WECLogs' #Name of Table in Azure Log Analytics
    ALWorkspaceID       = 'e1c2ce64-xxxx-yyyy-zzzz-555zzzzzzzz'
    WorkspacePrimaryKey = 'nXPotOAwqxgMXFq........./sNAyvYOrZg=='
    WECacheExportFile   = 'C:\AdminTools\Cache.json'
    PassThru    = $true
}
$Events =  Get-EventFromWEC @GetEventFromWECSplat
```

## View all definitions in Out-Grid windows

```powershell
$Keys = $Events.GetEnumerator() | Select-Object -ExpandProperty Keys
foreach ($k in $Keys) {
    $Events.$k | Out-GridView -Title $k
}
```

## View cache file content

```powershell
Get-WECacheData -WECacheExportFile C:\admintools\Cache.json
```

The result will look like this:

```cmd
DefinitionName               LastExportStatus LastRunTime         LastSuccessExportTime
--------------               ---------------- -----------         ---------------------
ADComputerCreatedChanged     Success          22.05.2019 10:00:10 22.05.2019 10:00:10
ADGroupChanges               Success          27.05.2019 12:50:48 27.05.2019 12:50:48
ADGroupCreateDelete          Success          27.05.2019 12:51:03 27.05.2019 12:51:03
ADPasswordChange             Success          27.05.2019 12:51:14 27.05.2019 12:51:14
ADUserAccountEnabledDisabled Success          27.05.2019 12:51:25 27.05.2019 12:51:25
ADUserCreateDelete           Success          22.05.2019 10:41:53 22.05.2019 10:41:53
LogClearSecurity             Success          24.05.2019 13:42:57 24.05.2019 13:42:57
LogClearSystem               Success          24.05.2019 13:42:59 24.05.2019 13:42:59
OSStartupShutdownCrash       Success          27.05.2019 14:56:50 27.05.2019 14:56:50
OSStartupShutdownDetailed    Success          27.05.2019 14:56:57 27.05.2019 14:56:57
```