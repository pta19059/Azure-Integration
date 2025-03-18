# Define the URL of the API endpoint
$uri = ""

# Define the headers for the request
$headers = @{
    "Content-Type" = "application/json"
    # Uncomment and add your subscription key if required
    # "Ocp-Apim-Subscription-Key" = ""
}

# Define the body of the request
$body = @{
    id = "ABC-003"
    customerName = "Umbrella Corp2"
    contactPerson = "John Doe-X"
    contactPhone = "889 562254"
    address = @{
        city = "Springfield"
        addressLine1 = "Main street ,14"
        postcode = "0656"
    }
} | ConvertTo-Json

# Define the path to the local PFX file and the password (if any)
$pfxPath = ""
$pfxPassword = $null  # Set to $null if there is no password

try {
    # Load the PFX file from the local file system
    Write-Host "Loading PFX file from local file system..."
    $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList ($pfxPath, $pfxPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)
    Write-Host "PFX file loaded successfully:"
    $certificate | Format-List

    # Check if the certificate details are populated
    if (-not $certificate.Subject) {
        throw "Certificate loading failed. Subject is empty."
    }

    # Log the request details
    Write-Host "Request URI: $uri"
    Write-Host "Request Headers: $($headers | ConvertTo-Json -Depth 10)"
    Write-Host "Request Body: $body"

    # Send the POST request with the certificate
    Write-Host "Sending POST request to API endpoint..."
    $response = Invoke-WebRequest -Uri $uri -Method Post -Headers $headers -Body $body -Certificate $certificate

    # Output the response
    Write-Host "Response received:"
    $response.Content | ConvertTo-Json -Depth 10
} catch {
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
