function Get-WECacheData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,HelpMessage = 'Path with Cache File')]
        [ValidateScript( {Test-Path -Path $_ -PathType Leaf})]
        [string]
        $WECacheExportFile
    )

    process {
        $CacheValues = Get-ConfigurationData -ConfigurationPath $WECacheExportFile -OutputType PSObject
        if ($CacheValues) {
            ForEach ($value in $CacheValues.Definitions) {
                $Properties = $value | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                foreach ($property in $Properties) {
                    $value.$property
                }
            }
        }
    }
}