function Set-SearchTarget {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [stringp[]]
        $ComputerName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [stringp[]]
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