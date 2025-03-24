param (
    [Parameter(Mandatory)]
    [string]$PfxPath,       # Path to the PFX file

    [Parameter(Mandatory)]
    [string]$ApiUrl         # API Endpoint to call
)

# Loading the PFX certificate (without password)
try {
    Write-Host "Loading certificate from: $PfxPath"
    $ClientCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 `
        -ArgumentList ($PfxPath, "", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)
}
catch {
    Write-Error "Error loading the PFX certificate: $($_.Exception.Message)"
    exit 1
}

# Print certificate details for verification
Write-Host "Certificate loaded successfully:"
Write-Host "Subject: $($ClientCertificate.Subject)"
Write-Host "Thumbprint: $($ClientCertificate.Thumbprint)"
Write-Host "Validity: from $($ClientCertificate.NotBefore) to $($ClientCertificate.NotAfter)"

# Prepare the POST request body
$body = @{
    id            = "ABC-006"
    customerName  = "Umbrella Corp6"
    contactPerson = "John Doe-XYZ"
    contactPhone  = "889 5622545678"
    address       = @{
        city          = "Springfield"
        addressLine1  = "Main street ,15"
        postcode      = "0659"
    }
} | ConvertTo-Json -Depth 5

# Export certificate to Base64 for custom header
$certBase64 = [Convert]::ToBase64String($ClientCertificate.RawData)

# Define request headers
$headers = @{
    "Content-Type"           = "application/json"
    "X-Client-Certificate"   = $certBase64
    "X-Client-Thumbprint"    = $ClientCertificate.Thumbprint
    # If required, uncomment and insert the APIM subscription key
    #"Ocp-Apim-Subscription-Key" = "dcf576a6e1064d119779f408818efc8c"
}

# Display request details
Write-Host "`nRequest details:"
Write-Host "URI: $ApiUrl"
Write-Host "Headers: $(ConvertTo-Json $headers -Depth 10)"
Write-Host "Body: $body"

# Send request to backend using Invoke-WebRequest
try {
    Write-Host "`nForwarding POST request..."
    $Response = Invoke-WebRequest -Uri $ApiUrl `
                                  -Method Post `
                                  -Headers $headers `
                                  -Body $body `
                                  -Certificate $ClientCertificate `
                                  -Verbose

    Write-Host "`nRequest completed successfully!"
    Write-Host "HTTP response code: $($Response.StatusCode)"

    # Print response content
    Write-Host "`nResponse content:"
    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    # If available, show response headers
    Write-Host "`nResponse headers received:"
    foreach ($header in $Response.Headers.GetEnumerator()) {
        Write-Host "  $($header.Key): $($header.Value)"
    }

}
catch {
    Write-Host "An error occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    # Additional debug information
    if ($_.Exception.Response -is [System.Net.HttpWebResponse]) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $responseBody = (New-Object System.IO.StreamReader $responseStream).ReadToEnd()
        Write-Host "Response body:" -ForegroundColor Red
        Write-Host $responseBody -ForegroundColor Red
    }
}
