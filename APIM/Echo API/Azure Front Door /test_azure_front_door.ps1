param (
    [Parameter(Mandatory)]
    [string]$PfxPath,         # Path to your .pfx file with no password
    [Parameter(Mandatory)]
    [string]$ApiUrl           # The API endpoint
)

Write-Host "Importing certificate from: $PfxPath"

# Correct way to import a .pfx file without a password
try {
    $ClientCertificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($PfxPath, "", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)
}
catch {
    Write-Host "ERROR: Failed to import PFX certificate. Details: $($_.Exception.Message)"
    exit 1
}

# Display certificate details
Write-Host "Certificate Subject: $($ClientCertificate.Subject)"
Write-Host "Certificate Thumbprint: $($ClientCertificate.Thumbprint)"
Write-Host "NotBefore: $($ClientCertificate.NotBefore), NotAfter: $($ClientCertificate.NotAfter)"

# Save Thumbprint
$Thumbprint = $ClientCertificate.Thumbprint

# Export certificate to Base64
$certBytes = $ClientCertificate.RawData
$certBase64 = [System.Convert]::ToBase64String($certBytes)

# Headers with certificate details
$headers = @{
    "X-Client-Certificate" = $certBase64
    "X-Client-Thumbprint" = $Thumbprint
}

# Invoke API with certificate and headers
try {
    Write-Host "Making request to: $ApiUrl"
    $Response = Invoke-WebRequest -Uri $ApiUrl -Certificate $ClientCertificate -Headers $headers -Verbose

    Write-Host "Response Status Code:" $Response.StatusCode
    Write-Host "Response Headers:"
    $Response.Headers.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)"
    }
    Write-Host "`nResponse Body:"
    Write-Host $Response.Content

    # Safely check for request headers
    if ($Response -and $Response.BaseResponse -and $Response.BaseResponse.RequestMessage -and $Response.BaseResponse.RequestMessage.Headers) {
        Write-Host "`nRequest Headers:"
        $Response.BaseResponse.RequestMessage.Headers.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)"
        }
    }
    else {
        Write-Host "`nNo request header information available."
    }
}
catch {
    Write-Host "ERROR: Client certificate validation failed or other request error."
    Write-Host "Details: $($_.Exception.Message)"
    exit 1
}
