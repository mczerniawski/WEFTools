Function Export-WEToLogAnalytics {
    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    Param(

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $ALWorkspaceID,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $WorkspacePrimaryKey,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]
        $WECEvent,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        $ALTableIdentifier,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        $TimeStampField
    )
    process {
        $bodyAsJson = ConvertTo-Json $WECEvent
        $body = [System.Text.Encoding]::UTF8.GetBytes($bodyAsJson)
        $method = 'POST'
        $resource = '/api/logs'
        $rfc1123date = [DateTime]::UtcNow.ToString("r")
        $contentType = 'application/json'

        $getLogAnalyticsSignatureSplat = @{
            ALWorkspaceID       = $ALWorkspaceID
            WorkspacePrimaryKey = $WorkspacePrimaryKey
            Date                = $rfc1123date
            ContentLength       = $body.Length
            Method              = $method
            ContentType         = $contentType
            Resource            = $resource
        }
        $signature = Get-WELogAnalyticsSignature @getLogAnalyticsSignatureSplat

        $uri = "https://{0}.ods.opinsights.azure.com{1}?api-version=2016-04-01" -f $ALWorkspaceID, $resource

        $headers = @{
            "Authorization"        = $signature;
            "Log-Type"             = $ALTableIdentifier;
            "x-ms-date"            = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }

        $invokeWebRequestSplat = @{
            ContentType     = $contentType
            Method          = $method
            UseBasicParsing = $true
            Uri             = $uri
            Headers         = $headers
            Body            = $body
        }
        $response = Invoke-WebRequest @invokeWebRequestSplat
        $response.StatusCode
    }
}