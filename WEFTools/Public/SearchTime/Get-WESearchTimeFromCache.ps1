function Get-WESearchTimeFromCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Path with Cache File')]
        #[ValidateScript( {Test-Path -Path $_ -PathType Leaf})]
        [string]
        $Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $WEDefinition

    )
    process {
        Write-Verbose "Reading Cache from {$Path}"
        $Cache = Get-ConfigurationData -ConfigurationPath $Path -OutputType HashTable -ErrorAction SilentlyContinue

        $CurrentDefinition = $Cache.Definitions.($WEDefinition)
        $CurrentDate = [DateTime]::Now
        $LastDate = if($CurrentDefinition.LastSuccessExportTime) {
            ($CurrentDefinition.LastSuccessExportTime).ToLocalTime()
        }
        if ($null -eq $LastDate) {
            $Times = @{
                Everything = @{
                    Enabled = $true
                }
            }
            Write-Verbose -Message "No LastSuccessExportTime value found. Set time to {Everything} for definition {$WEDefinition}"
        }
        else {
            $Times = @{
                CustomDate = @{
                    Enabled  = $true
                    DateFrom = $LastDate
                    DateTo   = $CurrentDate
                }
            }
            Write-Verbose -Message "LastSuccessExportTime value found. Set date from to {$LastDate} for definition {$WEDefinition}"
        }
        $Times
    }
}