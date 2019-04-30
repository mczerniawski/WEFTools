# Sample scripts to run

## TODO: schedule tasks

## Install PSWinReporting and WEFTools

```powershell
Install-Module pswinreportingv2 -Force
Install-Module WEFTools -Force
```

```powershell
Import-Module  WEFTools -Force
Import-Module  PSWinReportingV2 -Force

$GetEventFromWECsplat = @{
    WriteToAzureLog = $true
       ALTableIdentifier          = 'WECLogs' #Name of Table in Azure Log Analytics
       ALWorkspaceID       = '' # your workspaceID in Azure Log Analytics
       WorkspacePrimaryKey           = '' # PrimaryKey for given Workspace
       Verbose = $true
}
Get-EventFromWEC @GetEventFromWECsplat
```
