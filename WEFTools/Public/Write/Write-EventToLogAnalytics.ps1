function Write-EventToLogAnalytics {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $WECEvent,

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

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [DateTime]
        $invocationStartTime,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [DateTime]
        $invocationEndTime

    )


    process {

        $batchId = [System.Guid]::NewGuid()
        $EventGroups = $WECEvent.GetEnumerator() | Select-Object -ExpandProperty Name
        foreach ($Group in $EventGroups) {
            $LogsToAzureLogs = $WECEvent[$Group]
            $LogsToAzureLogs | Add-Member -MemberType NoteProperty -Name 'InvocationId' -Value ([System.Guid]::NewGuid())
            $LogsToAzureLogs | Add-Member -MemberType NoteProperty -Name 'invocationStartTime' -Value $invocationStartTime
            $LogsToAzureLogs | Add-Member -MemberType NoteProperty -Name 'invocationEndTime' -Value $invocationEndTime
            $LogsToAzureLogs | Add-Member -MemberType NoteProperty -Name 'BatchId' -Value $BatchId
            $LogsToAzureLogs | Add-Member -MemberType NoteProperty -Name 'HostComputer' -Value ($env:computername)
            $exportArguments = @{
                ALWorkspaceID       = $ALWorkspaceID
                WorkspacePrimaryKey = $WorkspacePrimaryKey
                ALTableIdentifier   = $ALTableIdentifier
                TimeStampField      = $invocationStartTime
                WECEvent            = $LogsToAzureLogs
            }
            Write-Verbose -Message "Writing {$($LogsToAzureLogs.Count)} Events of {$Group} to Azure Log with: WorkspaceID - {$ALWorkspaceID}, BatchID - {$BatchId} into Table - {$ALTableIdentifier}"

            $result = Export-WEToLogAnalytics @exportArguments
            if ($result -ne 200) {
                Write-Error -Message "Something went wrong with exporting to Azure Log - {ErrorCode: $($result.ErrorCode)}"
            }
        }
    }
}