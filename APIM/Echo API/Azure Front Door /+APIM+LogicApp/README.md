<p>1) Policy.xml</p>
<p>&nbsp;</p>
<h1>Azure API Management Policy Explanation</h1>
<p>This policy implements a secure API gateway with client certificate validation. Here's a detailed breakdown of what it does:</p>
<h2>1. Inbound Processing</h2>
<h3>Front Door Validation</h3>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">check-header</span> <span class="hljs-attr">name</span>=<span class="hljs-string">"X-Azure-FDID"</span> <span class="hljs-attr">failed-check-httpcode</span>=<span class="hljs-string">"403"</span> <span class="hljs-attr">failed-check-error-message</span>=<span class="hljs-string">"Invalid request."</span> <span class="hljs-attr">ignore-case</span>=<span class="hljs-string">"false"</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">value</span>&gt;</span>{{FrontDoorId}}<span class="hljs-tag">&lt;/<span class="hljs-name">value</span>&gt;</span>
<span class="hljs-tag">&lt;/<span class="hljs-name">check-header</span>&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Verifies requests come through Azure Front Door by checking the&nbsp;<code>X-Azure-FDID</code>&nbsp;header</li>
<li>Blocks unauthorized access attempts with a 403 Forbidden response</li>
</ul>
<h3>Client Certificate Validation</h3>
<p>The policy implements a comprehensive certificate validation flow:</p>
<ol>
<li>
<p><strong>Header Verification</strong></p>
<ul>
<li>Checks for required headers:&nbsp;<code>X-Client-Certificate</code>&nbsp;(base64 encoded certificate) and&nbsp;<code>X-Client-Thumbprint</code></li>
<li>Returns 400 Bad Request if headers are missing</li>
</ul>
</li>
<li>
<p><strong>Certificate Processing</strong></p>
<ul>
<li>Decodes the certificate from base64</li>
<li>Computes SHA1 thumbprint from the certificate bytes</li>
<li>Verifies the computed thumbprint matches the provided thumbprint</li>
<li>Returns 401 Unauthorized if the thumbprint validation fails</li>
</ul>
</li>
<li>
<p><strong>Certificate Registration Check</strong></p>
<ul>
<li>Verifies the certificate thumbprint is registered in APIM's certificate store</li>
<li>Returns 403 Forbidden if the certificate is not registered</li>
<li>Adds&nbsp;<code>X-Client-Verified: true</code>&nbsp;header when validation succeeds</li>
</ul>
</li>
</ol>
<h3>Backend Configuration</h3>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">set-backend-service</span> <span class="hljs-attr">id</span>=<span class="hljs-string">"apim-generated-policy"</span> <span class="hljs-attr">backend-id</span>=<span class="hljs-string">"LogicApp_la-cms-integraiton-0xx_project-integ_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"</span> /&gt;</span>
<span class="hljs-tag">&lt;<span class="hljs-name">set-method</span> <span class="hljs-attr">id</span>=<span class="hljs-string">"apim-generated-policy"</span>&gt;</span>POST<span class="hljs-tag">&lt;/<span class="hljs-name">set-method</span>&gt;</span>
<span class="hljs-tag">&lt;<span class="hljs-name">rewrite-uri</span> <span class="hljs-attr">id</span>=<span class="hljs-string">"apim-generated-policy"</span> <span class="hljs-attr">template</span>=<span class="hljs-string">"/manual/paths/invoke/?api-version=2016-06-01<span class="hljs-symbol">&amp;amp;</span>sp=/triggers/manual/run<span class="hljs-symbol">&amp;amp;</span>sv=1.0<span class="hljs-symbol">&amp;amp;</span>sig={{Customers_customer_xxxxxxxxxxxxxxxxxxxxxxxxxx}}"</span> /&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Routes validated requests to a Logic App backend</li>
<li>Forces the HTTP method to POST</li>
<li>Configures the proper URI path with signature for Logic App invocation</li>
<li>Removes subscription key to prevent it from being forwarded</li>
</ul>
<h2>2. Backend Processing</h2>
<p>Simple forwarding of the request to the Logic App after all security validations pass.</p>
<h2>3. Outbound Processing</h2>
<ul>
<li>
<p>For successful responses (200-299 status codes):</p>
<ul>
<li>If response has content: passes it through unchanged</li>
<li>If response is empty: generates a standardized JSON response with:
<ul>
<li>Success status</li>
<li>Timestamp</li>
<li>Request tracking IDs (request ID, correlation ID, workflow run ID)</li>
</ul>
</li>
<li>Adds&nbsp;<code>X-Certificate-Validated: true</code>&nbsp;header</li>
</ul>
</li>
<li>
<p>For error responses: passes through the Logic App's error response unchanged</p>
</li>
</ul>
<h2>4. Error Handling</h2>
<p>If any exception occurs during policy execution:</p>
<ul>
<li>Returns a standardized 403 Forbidden response</li>
<li>Formats a JSON error body with:
<ul>
<li>Error status</li>
<li>Error message</li>
<li>UTC timestamp</li>
</ul>
</li>
</ul>
<h2>Summary</h2>
<p>This policy implements a secure API gateway that:</p>
<ol>
<li>Requires requests to come through Azure Front Door</li>
<li>Validates client certificates using a two-step process (thumbprint matching and registration check)</li>
<li>Routes validated requests to a Logic App backend</li>
<li>Standardizes responses for consistency</li>
<li>Provides proper error handling with informative messages</li>
</ol>
<p>This approach ensures that only authenticated clients with valid, registered certificates can access the backend Logic App, providing a strong security boundary.</p>
<p>&nbsp;</p>
<p>2) test_azure_front_door_POST.ps1</p>
<p>&nbsp;</p>
<h1>PowerShell Script for Certificate-Based API Authentication - Detailed Explanation</h1>
<p>This script makes a secure API call using client certificate authentication. It's designed to work with the Azure API Management policy we discussed earlier. Here's a detailed breakdown:</p>
<h2>Parameter Definition</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code>[<span class="hljs-type">Parameter</span>(<span class="hljs-type">Mandatory</span>)]
[<span class="hljs-built_in">string</span>]<span class="hljs-variable">$PfxPath</span>,       <span class="hljs-comment"># Path to the PFX file</span>

[<span class="hljs-type">Parameter</span>(<span class="hljs-type">Mandatory</span>)]
[<span class="hljs-built_in">string</span>]<span class="hljs-variable">$ApiUrl</span>         <span class="hljs-comment"># API Endpoint to call</span>
</code></pre>
</div>
</figure>
<ul>
<li>Requires two mandatory inputs: the path to a PFX certificate file and the API endpoint URL</li>
</ul>
<h2>Certificate Loading and Validation</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-variable">$ClientCertificate</span> = <span class="hljs-built_in">New-Object</span> System.Security.Cryptography.X509Certificates.X509Certificate2 `
    <span class="hljs-literal">-ArgumentList</span> (<span class="hljs-variable">$PfxPath</span>, <span class="hljs-string">""</span>, [<span class="hljs-type">System.Security.Cryptography.X509Certificates.X509KeyStorageFlags</span>]::PersistKeySet)
</code></pre>
</div>
</figure>
<ul>
<li>Loads the PFX certificate without a password (empty string)</li>
<li>Uses&nbsp;<code>PersistKeySet</code>&nbsp;flag to maintain the private key in memory</li>
<li>Displays certificate details (subject, thumbprint, validity period) for verification</li>
</ul>
<h2>Request Body Preparation</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-variable">$body</span> = <span class="hljs-selector-tag">@</span>{
    id            = <span class="hljs-string">"ABC-006"</span>
    customerName  = <span class="hljs-string">"Umbrella Corp6"</span>
    <span class="hljs-comment"># ... other fields</span>
} | <span class="hljs-built_in">ConvertTo-Json</span> <span class="hljs-literal">-Depth</span> <span class="hljs-number">5</span>
</code></pre>
</div>
</figure>
<ul>
<li>Creates a JSON payload with customer information</li>
<li>Includes nested address object with proper JSON structure</li>
</ul>
<h2>Certificate Headers Creation</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-variable">$certBase64</span> = [<span class="hljs-type">Convert</span>]::ToBase64String(<span class="hljs-variable">$ClientCertificate</span>.RawData)

<span class="hljs-variable">$headers</span> = <span class="hljs-selector-tag">@</span>{
    <span class="hljs-string">"Content-Type"</span>           = <span class="hljs-string">"application/json"</span>
    <span class="hljs-string">"X-Client-Certificate"</span>   = <span class="hljs-variable">$certBase64</span>
    <span class="hljs-string">"X-Client-Thumbprint"</span>    = <span class="hljs-variable">$ClientCertificate</span>.Thumbprint
}
</code></pre>
</div>
</figure>
<ul>
<li>Converts the certificate to Base64 format for transmission in HTTP header</li>
<li>Creates the&nbsp;<code>X-Client-Certificate</code>&nbsp;and&nbsp;<code>X-Client-Thumbprint</code>&nbsp;headers required by the APIM policy</li>
</ul>
<h2>API Request Execution</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-variable">$Response</span> = <span class="hljs-built_in">Invoke-WebRequest</span> <span class="hljs-literal">-Uri</span> <span class="hljs-variable">$ApiUrl</span> `
                              <span class="hljs-literal">-Method</span> Post `
                              <span class="hljs-literal">-Headers</span> <span class="hljs-variable">$headers</span> `
                              <span class="hljs-literal">-Body</span> <span class="hljs-variable">$body</span> `
                              <span class="hljs-literal">-Certificate</span> <span class="hljs-variable">$ClientCertificate</span> `
                              <span class="hljs-literal">-Verbose</span>
</code></pre>
</div>
</figure>
<ul>
<li>Sends a POST request to the specified API endpoint</li>
<li>Includes custom headers for certificate validation</li>
<li>Attaches the actual certificate for TLS mutual authentication</li>
<li>Uses&nbsp;<code>-Verbose</code>&nbsp;flag for detailed request/response logging</li>
</ul>
<h2>Response Processing</h2>
<ul>
<li>On success: Displays response status code, content (formatted as JSON), and headers</li>
<li>On failure: Shows error message in red text and attempts to extract the response body from the error for troubleshooting</li>
</ul>
<h2>Purpose and Relationship to APIM Policy</h2>
<p>This script is specifically designed to work with the APIM policy from the previous question:</p>
<ol>
<li>
<p>It provides&nbsp;<strong>dual certificate validation</strong>:</p>
<ul>
<li>Sends the raw certificate via the&nbsp;<code>-Certificate</code>&nbsp;parameter for TLS handshake</li>
<li>Sends the Base64-encoded certificate and thumbprint in headers for the additional validation performed by the APIM policy</li>
</ul>
</li>
<li>
<p>It's structured to handle the&nbsp;<strong>complete authentication flow</strong>&nbsp;enforced by the APIM policy:</p>
<ul>
<li>Certificate validation</li>
<li>Thumbprint matching</li>
<li>Registered certificate verification</li>
</ul>
</li>
<li>
<p>It sends a&nbsp;<strong>customer record</strong>&nbsp;as JSON to what appears to be a customer management system, likely triggering the Logic App backend we saw configured in the APIM policy.</p>
</li>
</ol>
<p>The script provides comprehensive logging to help diagnose any issues with the certificate validation or API processing.</p>
