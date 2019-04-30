function Set-WESearchTime {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('CurrentDay','CurrentDayMinusDayX','CurrentDayMinuxDaysX','CurrentHour','CurrentMonth','CurrentQuarter','CustomDate','Everything','Last14days','Last3days','Last7days','OnDay','PastDay','PastHour','PastMonth','PastQuarter')]
        [string[]]
        $Time
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