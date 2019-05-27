function Get-EventFromWEC {
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory=$false, HelpMessage = 'Name of file with definitions')]
        [string[]]
        $WEDefinitionName,

        [Parameter(Mandatory=$false, HelpMessage = 'Time range definition')]
        [ValidateSet('PastHour', 'CurrentHour', 'PastDay', 'CurrentDay', 'CurrentMonth', 'PastMonth', 'PastQuarter', 'CurrentQuarter', 'CurrentDayMinusDayX', 'CurrentDayMinuxDaysX', 'CustomDate', 'Last3days', 'Last7days', 'Last14days', 'Everything')]
        [string]
        $Times,

        [Parameter(Mandatory = $false, HelpMessage = 'Days for specific Times parameter')]
        [int32]
        $Days,

        [Parameter(Mandatory = $false, HelpMessage = 'DateTime for specific Times parameter')]
        [DateTime]
        $DateFrom,

        [Parameter(Mandatory = $false, HelpMessage = 'DateTime for specific Times parameter')]
        [DateTime]
        $DateTo,

        [Parameter(Mandatory = $false, HelpMessage = 'Path were definitions are stored')]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [string]
        $WEDefinitionPath,

        [Parameter(Mandatory = $false, HelpMessage = 'Name of WEC server',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $ComputerName,

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
        $WorkspacePrimaryKey,

        [Parameter(Mandatory=$false,HelpMessage = 'Path with Cache File')]
        [string]
        $WECacheExportFile,

        [Parameter(Mandatory = $false, HelpMessage = 'Output Events to Pipe',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [switch]
        $PassThru
    )
    begin {
        if ($PSBoundParameters.ContainsKey('WEDefinitionPath')) {
            $WEDefinitionPathFinal = $WEDefinitionPath
        }
        else {
            $WEDefinitionPathFinal = Get-Item -Path "$PSScriptRoot\..\Configuration\Definitions"
        }
        if($PSBoundParameters.ContainsKey('ComputerName')){
            $ComputerToQuery = $ComputerName
        }
        else {
            $ComputerToQuery = $env:ComputerName
        }
    }
    process {
        if($PSBoundParameters.ContainsKey('WEDefinitionName')){
            $WEDefinitionSet = $WEDefinitionName
        }
        else {
            $WEDefinitionSet = Get-WEDefinitionList -WEDefinitionPath $WEDefinitionPathFinal
        }
        Write-Verbose "Will proces with definitions: {$($WEDefinitionSet -join ',')}"

        #region Set Time
        $setWESearchTimeSplat = @{}
        if($PSBoundParameters.ContainsKey('Times')) {
            $setWESearchTimeSplat.Times = $Times
            if($PSBoundParameters.ContainsKey('Days')) {
                $setWESearchTimeSplat.Days = $Days
            }
            if($PSBoundParameters.ContainsKey('DateFrom')) {
                $setWESearchTimeSplat.DateFrom = $DateFrom
            }
            if($PSBoundParameters.ContainsKey('DateTo')) {
                $setWESearchTimeSplat.DateTo = $DateTo
            }
            $TimesSet = Set-WESearchTime @setWESearchTimeSplat
        }
        elseif(-not ($PSBoundParameters.ContainsKey('Times'))) {
            $TimesSet = Set-WESearchTime -Times 'Everything'
        }

        #endregion

        foreach ( $definition in $WEDefinitionSet) {
            $Definitions = Get-WEDefinition -WEDefinitionName $definition -WEDefinitionPath $WEDefinitionPathFinal
            $FindEventsSplat = @{
                Definitions = $Definitions.SearchDefinition
                Times         = $TimesSet
                Target        = Set-WESearchTarget -computerName $ComputerToQuery -LogName $Definitions.LogName
            }
            if ($PSBoundParameters.ContainsKey('WECacheExportFile')){
                $FindEventsSplat.Times = Get-WESearchTimeFromCache -Path $WECacheExportFile -WEDefinition $definition
            }
            if ($PSBoundParameters.ContainsKey('Verbose')) {
                $FindEventsSplat.Verbose = $true
            }

            $invocationStartTime = [DateTime]::UtcNow
            $WECEvent = Find-Events @FindEventsSplat
            $invocationEndTime = [DateTime]::UtcNow
            if ($WECEvent.($definition)) {
                if ($PSBoundParameters.ContainsKey('WriteToAzureLog')) {
                    $writeEventToLogAnalyticsSplat = @{
                        WECEvent            = $WECEvent
                        ALTableIdentifier   = $ALTableIdentifier
                        ALWorkspaceID       = $ALWorkspaceID
                        WorkspacePrimaryKey = $WorkspacePrimaryKey
                        invocationStartTime = $invocationStartTime
                        invocationEndTime   = $invocationEndTime
                    }
                    if($PSBoundParameters.ContainsKey('WECacheExportFile')){
                        $writeEventToLogAnalyticsSplat.WECacheExportFile= $WECacheExportFile
                    }
                    Write-EventToLogAnalytics @writeEventToLogAnalyticsSplat
                }
                if ($PSBoundParameters.ContainsKey('WECacheExportFile') -and (-not ($PSBoundParameters.ContainsKey('WriteToAzureLog')))) {
                    $updateWECacheExportFileSplat = @{
                            Path             = $WECacheExportFile
                            LastRunTime      = $invocationEndTime
                            WEDefinition     = $definition
                            LastExportStatus = 'NoExport'
                        }
                    Update-WECacheExportFile @updateWECacheExportFileSplat
                }
                if ($PSBoundParameters.ContainsKey('PassThru')) {
                    $WECEvent
                }
            }
            else {
                Write-Verbose 'No Events found'
            }
        }
    }
}