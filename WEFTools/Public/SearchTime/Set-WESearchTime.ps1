function Set-WESearchTime {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = 'Time range definition')]
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
        $DateTo

    )
    process {
        switch ($Times) {
            { $PSItem -eq 'CurrentDayMinusDayX' } {
                @{
                    $PSitem = @{
                        Enabled = $true
                        Days    = $Days
                    }
                }
                break
            }
            { $PSItem -eq 'CurrentDayMinuxDaysX' } {
                @{
                    $PSitem = @{
                        Enabled = $true
                        Days    = $Days
                    }
                }
                break
            }
            { $PSItem -eq 'CustomDate' } {
                @{
                    CustomDate = @{
                        Enabled  = $true
                        DateFrom = $DateFrom
                        DateTo   = $DateTo
                    }
                }
                break
            }
            Default {
                @{
                    $PSItem = @{
                        Enabled = $true 
                    }
                }
            }
        }
    }
}