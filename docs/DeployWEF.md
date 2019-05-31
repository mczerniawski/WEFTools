```powershell

# region [Local] prepare environment variables
$DomainName = 'contoso.com'
$FQDNDomainName = 'DC=contoso,DC=com'
$TaskScheduleRunner = 'WEC0.{0}' -f $DomainName
$Credential = Get-Credential
$CollectorSession = New-PSSession -ComputerName $TaskScheduleRunner -Credential $Credential
#endregion

#region [Remote] configure WEFTools on WEC server
Invoke-Command -Session $TaskScheduleRunner -ScriptBlock {
    Install-Module PSWinReportingV2 -Force
    Install-Module WEFTools -Force
}
#endregion

#region [Remote] configure Task Scheduler on WEC server
Invoke-Command -Session $TaskScheduleRunner -ScriptBlock {
    #$WriteToAzureLog = $true
    $ALTableIdentifier = 'WECLogs'
    $ALWorkspaceID = 'e2920363-xxxx-yyyy-zzzz-7400006ff801'
    $WorkspacePrimaryKey = 'cGNQmJJ.........SCQYFIAdN00cjfR/PvDXABfxLf....=='
    $WECacheFile = 'C:\AdminTools\WEFCache.json'
    $Repeat = 10
    $TaskName = 'WEF Test task'
    $TaskCommand = @"
        Import-Module WEFTools -Force
        `$GetEventFromWECSplat = @{
            WriteToAzureLog     = `$true
            ALTableIdentifier   = '$ALTableIdentifier'
            ALWorkspaceID       = '$ALWorkspaceID'
            WorkspacePrimaryKey = '$WorkspacePrimaryKey'
            WECacheExportFile   = '$WECacheFile'
        }
        Get-EventFromWEC @GetEventFromWECSplat
"@
    $TaskActionSettings = @{
        Execute  = 'powershell.exe'
        Argument = "-ExecutionPolicy Bypass $TaskCommand"
    }
    $TaskAction = New-ScheduledTaskAction @TaskActionSettings
    $TaskTriggerSettings = @{
        Once               = $true
        At                 = (Get-Date).Date
        RepetitionInterval = (New-TimeSpan -Minutes $Repeat)
    }
    $TaskTrigger = New-ScheduledTaskTrigger @TaskTriggerSettings
    $TaskTriggerSettings1 = @{
        AtStartup = $true
    }
    $TaskTrigger1 = New-ScheduledTaskTrigger @TaskTriggerSettings1
    $newScheduledTaskSettingsSetSplat = @{
        StartWhenAvailable         = $true
        RunOnlyIfNetworkAvailable  = $true
        DontStopOnIdleEnd          = $true
        DontStopIfGoingOnBatteries = $true
        AllowStartIfOnBatteries    = $true
    }
    $TaskSetting = New-ScheduledTaskSettingsSet @newScheduledTaskSettingsSetSplat

    $registerScheduledTaskSplat = @{
        Action   = $TaskAction
        RunLevel = 'Highest'
        Trigger  = @($TaskTrigger, $TaskTrigger1)
        TaskName = $TaskName
        Settings = $TaskSetting
        User     = "SYSTEM"
    }
    Register-ScheduledTask @registerScheduledTaskSplat
}
$CollectorSession | Remove-PSSession
```