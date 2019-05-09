function New-WEScheduledTask {
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
    [ValidateSet('ADComputerCreatedChanged','ADGroupChanges','ADGroupCreateDelete','ADPasswordChange','ADUserAccountEnabledDisabled','ADUserLocked','ADUserUnlocked','LogClearSystem','LogClearSecurity')]
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
        Import-Module C:\AdminTools\WEFTools -Force
        foreach ($def in $WEDefinitionName) {
            $Times = Get-WESearchTimeFromCache -Path $WECacheFile -WEDefinition $def
            $GetEventFromWECSplat = @{
                WEDefinitionName = $def
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
            Execute = 'powershell.exe'
            Argument = "-ExecutionPolicy Bypass $TaskCommand"
        }
        $TaskAction = New-ScheduledTaskAction @TaskActionSettings
        $TaskTriggerSettings =@{
            Once = $true
            At = (Get-Date).Date
            RepetitionInterval = (New-TimeSpan -Minutes $Repeat)
            RepetitionDuration = ([timeSpan]::MaxValue)
        }
        $TaskTrigger = New-ScheduledTaskTrigger @TaskTriggerSettings
        $newScheduledTaskSettingsSetSplat = @{
            StartWhenAvailable = $true
            RunOnlyIfNetworkAvailable = $true
            DontStopOnIdleEnd = $true
            DontStopIfGoingOnBatteries = $true
            AllowStartIfOnBatteries = $true
        }
        $TaskSetting = New-ScheduledTaskSettingsSet @newScheduledTaskSettingsSetSplat

        $registerScheduledTaskSplat = @{
            Action = $TaskAction
            RunLevel = 'Highest'
            Trigger = $TaskTrigger
            TaskName = $TaskName
            Settings = $TaskSetting
            User = "SYSTEM"
        }
        Register-ScheduledTask @registerScheduledTaskSplat
    }

    end {
    }
}


<#
# Change these three variables to whatever you want
$jobname = "Recurring PowerShell Task"
$script =  "C:\Scripts\Test-ExampleScript.ps1 -Server server1"
$repeat = (New-TimeSpan -Minutes 5)

# The script below will run as the specified user (you will be prompted for credentials)
# and is set to be elevated to use the highest privileges.
# In addition, the task will run every 5 minutes or however long specified in $repeat.
$scriptblock = [scriptblock]::Create($script)
$trigger = New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat
$msg = "Enter the username and password that will run the task";
$credential = $Host.UI.PromptForCredential("Task username and password",$msg,"$env:userdomain\$env:username",$env:userdomain)

$options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger -ScheduledJobOption $options -Credential $credential

$Trigger= New-ScheduledTaskTrigger -At 10:00am -Daily
$User= "NT AUTHORITY\SYSTEM"
$Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -encodedCommand $encodedCommand"
Register-ScheduledTask -TaskName "StartupScript_PS" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force

# register script as scheduled task
$Trigger = New-ScheduledTaskTrigger -Once -At '11:00' -RandomDelay '02:00' -RepetitionInterval '04:00'
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ex bypass -encodedCommand $encodedCommand"
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit "01:00"
Register-ScheduledTask -TaskName "Objectivity AdobeReaderDCUpdate" -Trigger $Trigger -User $User -Action $Action -Settings $Settings -Force

#>