function Get-EventFromWEC {
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory, HelpMessage = 'Name of file with definitions')]
        #[ValidateSet('ADComputerCreatedChanged','ADGroupChanges','ADGroupCreateDelete','ADPasswordChange','ADUserAccountEnabledDisabled','ADUserLocked','ADUserUnlocked','LogClearSystem','LogClearSecurity','OSStartupShutdownCrash','OSStartupShutdownDetailed','OSCrash')]
        [string[]]
        $WEDefinitionName,

        [Parameter(Mandatory, HelpMessage = 'Hashtable with time range definition')]
        [Hashtable]
        $Times,

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

        foreach ( $definition in $WEDefinitionName) {
            $Definitions = Get-WEDefinition -WEDefinitionName $definition -WEDefinitionPath $WEDefinitionPathFinal
            $FindEventsSplat = @{
                Definitions = $Definitions.SearchDefinition
                Times         = $Times
                Target        = Set-WESearchTarget -computerName $ComputerToQuery -LogName $Definitions.LogName
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