function Update-WECacheExportFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]
        $WEDefinition,

        [Parameter(Mandatory = $true, HelpMessage = 'Path with Cache File',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [DateTime]
        $LastRunTime,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [DateTime]
        $LastSuccessExportTime,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $LastExportStatus
    )

    begin {
        $Cache = if (Test-Path -Path $Path -PathType Leaf) {
            Write-Verbose "Reading Cache from {$Path}"
            Get-ConfigurationData -ConfigurationPath $Path -OutputType HashTable
        }
        if (-not $Cache) {
            $NewCache = @{
                Definitions = @{ }
            }
            Write-Verbose "No Cache File found in {$Path}. Creating."
            $NewCache | ConvertTo-Json -Depth 99 | Out-File $Path
            $Cache = Get-ConfigurationData -ConfigurationPath $Path -OutputType HashTable
        }
    }

    process {
        foreach ($definition in $WEDefinition) {
            #Entry exists - Update
            if ($Cache.Definitions.($definition)) {
                Write-Verbose "Updating cache entry {$definition} with LastExportStatus - {$LastExportStatus} and LastRunTime {$LastRunTime} and LastSuccessExportTime - {$LastSuccessExportTime}"
                $Cache.Definitions.($definition).LastRunTime = $LastRunTime
                $Cache.Definitions.($definition).LastExportStatus = $LastExportStatus
                if($PSBoundParameters.ContainsKey('LastSuccessExportTime')){
                    $Cache.Definitions.($definition).LastSuccessExportTime = $LastSuccessExportTime
                }
            }
            #No entry in cache - create
            else {
                Write-Verbose "Creating cache entry {$definition}"
                $definitionRunTime = @{
                    LastRunTime = $LastRunTime
                    LastExportStatus = $LastExportStatus
                }
                if($PSBoundParameters.ContainsKey('LastSuccessExportTime')){
                    $definitionRunTime.LastSuccessExportTime = $LastSuccessExportTime
                }
                $Cache.Definitions.Add($definition, $definitionRunTime)
            }
        }
    }
    end {
        Write-Verbose "Writing cache to file in {$Path}"
        $Cache | ConvertTo-Json -Depth 99 | Out-File $Path
    }
}