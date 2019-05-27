function Get-WECacheData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = 'Path with Cache File')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [string]
        $WECacheExportFile
    )

    process {
        $CacheValues = Get-ConfigurationData -ConfigurationPath $WECacheExportFile -OutputType PSObject
        if ($CacheValues) {
            $Keys = $CacheValues.Definitions | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            foreach ($key in $Keys) {
                $def = [ordered]@{
                    DefinitionName = $key
                }
                $Properties = $CacheValues.Definitions.$Key | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                foreach ($property in $Properties) {
                    $def.$Property = $CacheValues.Definitions.$key.$property
                }
                New-Object PSObject -Property $def
            }
        }
    }
}