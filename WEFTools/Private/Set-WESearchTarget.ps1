function Set-WESearchTarget {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ComputerName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LogName

    )
    process {
        foreach ($computer in $computerName) {
            @{
                Servers = @{
                    Enabled = $true
                    Server  = @{
                        ComputerName = $Computer
                        LogName      = $LogName
                    }
                }
            }
        }
    }
}