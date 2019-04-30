function Get-EventFromWEC {
    [CmdletBinding()]

    param
    (
        #DefinitionsAD = Get-WEFDefinitions
        #Times         = Get-WEFTimes
        #Target        = Get-WEFTarget
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
        $WorkspacePrimaryKey
    )
    process {

        #TUTAJ zbuduj sobie co wyciagnac z logow na podstawie AD definitions
        #jak juz bedize calosc - wykonac

        #$FindEventsSplat = @{
        #    DefinitionsAD = Get-WEFDefinitions
        #    Times         = Get-WEFTimes
        #    Target        = Set-SearchTarget -computerName $ComputerName -LogName $DefinitionsAD.SearchLogName
        #    Verbose       = $true
        #}

        $invocationStartTime = [DateTime]::UtcNow
        #Find-Events @FindEventsSplat
        $WECEvent = Get-ConfigurationData -ConfigurationPath 'C:\Repos\Private-GIT\WEFTools\WEFTools\Configuration\Definitions\SampleEvents.json'
        Start-Sleep -Seconds 2

        $invocationEndTime = [DateTime]::UtcNow

        if ($PSBoundParameters.ContainsKey('WriteToAzureLog')) {
            $writeEventToLogAnalyticsSplat = @{
                WECEvent            = $WECEvent
                ALTableIdentifier   = $ALTableIdentifier
                ALWorkspaceID       = $ALWorkspaceID
                WorkspacePrimaryKey = $WorkspacePrimaryKey
                invocationStartTime = $invocationStartTime
                invocationEndTime   = $invocationEndTime
            }
            Write-EventToLogAnalytics @writeEventToLogAnalyticsSplat
        }
    }
}