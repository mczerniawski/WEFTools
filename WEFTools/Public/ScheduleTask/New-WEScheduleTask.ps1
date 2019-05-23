function New-WEScheduleTask {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        $TaskName,
        $TaskExecutionTimeLimit,
        $TaskTrigger,
        $TaskUser,
        #$TaskSetting,
        [int32]
        $TaskRepeatTime,
        [Parameter(Mandatory, HelpMessage = 'Name of file with definitions')]
        #[ValidateSet('ADComputerCreatedChanged', 'ADGroupChanges', 'ADGroupCreateDelete', 'ADPasswordChange', 'ADUserAccountEnabledDisabled', 'ADUserLocked', 'ADUserUnlocked', 'LogClearSystem', 'LogClearSecurity', 'OSStartupShutdownCrash', 'OSStartupShutdownDetailed', 'OSCrash')]
        [string[]]
        $WEDefinitionName,
        $WECacheFile,
        [Parameter(Mandatory = $false, HelpMessage = 'Should extracted logs be sent to Azure LA',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [switch]
        $WriteToAzureLog,

        [Parameter(Mandatory = $false, HelpMessage = 'Name for Table to store Events in Azure Log Analytics',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $ALTableIdentifier,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $ALWorkspaceID,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $WorkspacePrimaryKey

    )

    process {
        $TaskCommand = @"
        Import-Module WEFTools -Force
        foreach ($def in $WEDefinitionName) {
            $Times = Get-WESearchTimeFromCache -Path $WECacheFile -WEDefinition $def
            $GetEventFromWECSplat = @{
                WEDefinitionName    = $def
                WriteToAzureLog     = $WriteToAzureLog
                ALTableIdentifier   = $ALTableIdentifier
                ALWorkspaceID       = $ALWorkspaceID
                WorkspacePrimaryKey = $WorkspacePrimaryKey
                Times = $Times
                WECacheExportFile = $WECacheFile
            }
            Get-EventFromWEC @GetEventFromWECSplat
        }
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
            RepetitionDuration = ([timeSpan]::MaxValue)
        }
        $TaskTrigger = New-ScheduledTaskTrigger @TaskTriggerSettings
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
            Trigger  = $TaskTrigger
            TaskName = $TaskName
            Settings = $TaskSetting
            User     = "SYSTEM"
        }
        Register-ScheduledTask @registerScheduledTaskSplat
    }
    end {
    }
}