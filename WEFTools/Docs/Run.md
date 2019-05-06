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

$WEDefinitionSet = @('ComputerCreateDeleteChange', 'GroupCreateDelete', 'ADGroupChanges', 'UserAccountEnabledDisabled', 'UserLocked', 'UserPasswordChange', 'UserUnlocked')
$Times = @{
    CurrentDayMinuxDaysX = @{
        Enabled = $true
        Days    = 1 # goes back X days and shows X number of days till Today
    }
}
$Events = foreach ($def in $WEDefinitionSet) {
    $GetEventFromWECSplat = @{
        WEDefinitionName = $def
        #WriteToAzureLog     = $true
        #ALTableIdentifier   = 'WECLogs' #Name of Table in Azure Log Analytics
        #ALWorkspaceID       = '' # your workspaceID in Azure Log Analytics
        #WorkspacePrimaryKey = '' # PrimaryKey for given Workspace
        #Verbose             = $true
        Output = $true
        Times = $Times
    }
    Get-EventFromWEC @GetEventFromWECSplat
}

$Events
```
