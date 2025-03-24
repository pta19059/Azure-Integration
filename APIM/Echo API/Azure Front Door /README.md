<p class="demoTitle">&nbsp;</p>
<p>1) <strong>test_azure_front_door.ps1</strong></p>
<h2>1. Script Parameters</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-keyword">param</span> (
    [<span class="hljs-type">Parameter</span>(<span class="hljs-type">Mandatory</span>)]
    [<span class="hljs-built_in">string</span>]<span class="hljs-variable">$PfxPath</span>,         <span class="hljs-comment"># The path to the PFX certificate file (without a password)</span>
    
    [<span class="hljs-type">Parameter</span>(<span class="hljs-type">Mandatory</span>)]
    [<span class="hljs-built_in">string</span>]<span class="hljs-variable">$ApiUrl</span>           <span class="hljs-comment"># The API endpoint URL you want to call</span>
)
</code></pre>
</div>
</figure>
<ul>
<li><strong>Parameters</strong>: This script expects two mandatory parameters:
<ul>
<li><strong><code>$PfxPath</code></strong>: Specifies the file path to a&nbsp;<code>.pfx</code>&nbsp;certificate file. A&nbsp;<code>.pfx</code>&nbsp;file typically contains both the public certificate and the associated private key. In this case, we assume the&nbsp;<code>.pfx</code>&nbsp;file does&nbsp;<strong>not</strong>&nbsp;have a password.</li>
<li><strong><code>$ApiUrl</code></strong>: Specifies the URL of the API endpoint you want to call.</li>
</ul>
</li>
</ul>
<hr />
<h2>2. Importing the Certificate</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Importing certificate from: <span class="hljs-variable">$PfxPath</span>"</span>

<span class="hljs-keyword">try</span> {
    <span class="hljs-variable">$ClientCertificate</span> = [<span class="hljs-type">System.Security.Cryptography.X509Certificates.X509Certificate2</span>]::new(
        <span class="hljs-variable">$PfxPath</span>, 
        <span class="hljs-string">""</span>, 
        [<span class="hljs-type">System.Security.Cryptography.X509Certificates.X509KeyStorageFlags</span>]::DefaultKeySet
    )
}
<span class="hljs-keyword">catch</span> {
    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"ERROR: Failed to import PFX certificate. Details: <span class="hljs-variable">$</span>(<span class="hljs-variable">$_</span>.Exception.Message)"</span>
    <span class="hljs-keyword">exit</span> <span class="hljs-number">1</span>
}
</code></pre>
</div>
</figure>
<ul>
<li>
<p><strong>What it does:</strong></p>
<ul>
<li>Imports a certificate from the specified&nbsp;<code>.pfx</code>&nbsp;file.</li>
<li>It initializes an&nbsp;<code>X509Certificate2</code>&nbsp;instance, which represents an X.509 certificate.</li>
<li>Since the&nbsp;<code>.pfx</code>&nbsp;file doesn't have a password, an empty string (<code>""</code>) is passed as the second argument.</li>
<li>The third argument (<code>X509KeyStorageFlags.DefaultKeySet</code>) specifies default storage behavior for the imported certificate.</li>
</ul>
</li>
<li>
<p><strong>Error handling:</strong></p>
<ul>
<li>If the import fails (e.g., the file doesn't exist or is corrupted), the script will print the error details and exit immediately.</li>
</ul>
</li>
</ul>
<hr />
<h2>3. Display Certificate Details</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Certificate Subject: <span class="hljs-variable">$</span>(<span class="hljs-variable">$ClientCertificate</span>.Subject)"</span>
<span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Certificate Thumbprint: <span class="hljs-variable">$</span>(<span class="hljs-variable">$ClientCertificate</span>.Thumbprint)"</span>
<span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"NotBefore: <span class="hljs-variable">$</span>(<span class="hljs-variable">$ClientCertificate</span>.NotBefore), NotAfter: <span class="hljs-variable">$</span>(<span class="hljs-variable">$ClientCertificate</span>.NotAfter)"</span>
</code></pre>
</div>
</figure>
<ul>
<li><strong>What it does:</strong>
<ul>
<li>Prints basic information about the imported certificate:
<ul>
<li><strong>Subject</strong>: The entity the certificate identifies (usually an organization or person).</li>
<li><strong>Thumbprint</strong>: A unique identifier (SHA-1 hash) of the certificate.</li>
<li><strong>NotBefore / NotAfter</strong>: The validity period of the certificate.</li>
</ul>
</li>
</ul>
</li>
</ul>
<hr />
<h2>4. Extracting Thumbprint and Encoding Certificate to Base64</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-variable">$Thumbprint</span> = <span class="hljs-variable">$ClientCertificate</span>.Thumbprint

<span class="hljs-variable">$certBytes</span> = <span class="hljs-variable">$ClientCertificate</span>.RawData
<span class="hljs-variable">$certBase64</span> = [<span class="hljs-type">System.Convert</span>]::ToBase64String(<span class="hljs-variable">$certBytes</span>)
</code></pre>
</div>
</figure>
<ul>
<li><strong>What it does:</strong>
<ul>
<li>Saves the certificate thumbprint into a variable&nbsp;<code>$Thumbprint</code>.</li>
<li>Extracts the raw certificate data (<code>RawData</code>) and encodes it in Base64 format (<code>$certBase64</code>).</li>
<li>This Base64-encoded certificate string can be easily sent in HTTP headers or requests.</li>
</ul>
</li>
</ul>
<hr />
<h2>5. Preparing HTTP Headers</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-variable">$headers</span> = <span class="hljs-selector-tag">@</span>{
    <span class="hljs-string">"X-Client-Certificate"</span> = <span class="hljs-variable">$certBase64</span>
    <span class="hljs-string">"X-Client-Thumbprint"</span> = <span class="hljs-variable">$Thumbprint</span>
}
</code></pre>
</div>
</figure>
<ul>
<li><strong>What it does:</strong>
<ul>
<li>Creates a custom HTTP headers dictionary containing:
<ul>
<li><code>"X-Client-Certificate"</code>: The Base64-encoded certificate.</li>
<li><code>"X-Client-Thumbprint"</code>: The certificate's thumbprint.</li>
</ul>
</li>
<li>These headers can be used by the server or API endpoint to validate and identify the certificate and client.</li>
</ul>
</li>
</ul>
<hr />
<h2>6. Making an HTTP Call to the API</h2>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">PowerShell</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-keyword">try</span> {
    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Making request to: <span class="hljs-variable">$ApiUrl</span>"</span>
    <span class="hljs-variable">$Response</span> = <span class="hljs-built_in">Invoke-WebRequest</span> <span class="hljs-literal">-Uri</span> <span class="hljs-variable">$ApiUrl</span> <span class="hljs-literal">-Certificate</span> <span class="hljs-variable">$ClientCertificate</span> <span class="hljs-literal">-Headers</span> <span class="hljs-variable">$headers</span> <span class="hljs-literal">-Verbose</span>

    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Response Status Code:"</span> <span class="hljs-variable">$Response</span>.StatusCode
    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Response Headers:"</span>
    <span class="hljs-variable">$Response</span>.Headers.GetEnumerator() | <span class="hljs-built_in">ForEach-Object</span> {
        <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"  <span class="hljs-variable">$</span>(<span class="hljs-variable">$_</span>.Key): <span class="hljs-variable">$</span>(<span class="hljs-variable">$_</span>.Value)"</span>
    }

    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"`nResponse Body:"</span>
    <span class="hljs-built_in">Write-Host</span> <span class="hljs-variable">$Response</span>.Content

    <span class="hljs-comment"># Display sent request headers (if available)</span>
    <span class="hljs-keyword">if</span> (<span class="hljs-variable">$Response</span> <span class="hljs-operator">-and</span> <span class="hljs-variable">$Response</span>.BaseResponse <span class="hljs-operator">-and</span> <span class="hljs-variable">$Response</span>.BaseResponse.RequestMessage <span class="hljs-operator">-and</span> <span class="hljs-variable">$Response</span>.BaseResponse.RequestMessage.Headers) {
        <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"`nRequest Headers:"</span>
        <span class="hljs-variable">$Response</span>.BaseResponse.RequestMessage.Headers.GetEnumerator() | <span class="hljs-built_in">ForEach-Object</span> {
            <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"  <span class="hljs-variable">$</span>(<span class="hljs-variable">$_</span>.Key): <span class="hljs-variable">$</span>(<span class="hljs-variable">$_</span>.Value)"</span>
        }
    }
    <span class="hljs-keyword">else</span> {
        <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"`nNo request header information available."</span>
    }
}
<span class="hljs-keyword">catch</span> {
    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"ERROR: Client certificate validation failed or other request error."</span>
    <span class="hljs-built_in">Write-Host</span> <span class="hljs-string">"Details: <span class="hljs-variable">$</span>(<span class="hljs-variable">$_</span>.Exception.Message)"</span>
    <span class="hljs-keyword">exit</span> <span class="hljs-number">1</span>
}
</code></pre>
</div>
</figure>
<ul>
<li>
<p><strong>What it does:</strong></p>
<ul>
<li>Executes an HTTPS request (<code>Invoke-WebRequest</code>) to the specified API URL (<code>$ApiUrl</code>).</li>
<li>Sends the client certificate (<code>-Certificate $ClientCertificate</code>) and previously prepared custom headers.</li>
<li>Verbose output (<code>-Verbose</code>) provides detailed logging about the request process.</li>
<li>After the response arrives, the script prints:
<ul>
<li>The HTTP status code (e.g.,&nbsp;<code>200 OK</code>).</li>
<li>All response headers provided by the server.</li>
<li>The response body content returned from the API.</li>
</ul>
</li>
<li>Additionally, the script attempts to print request headers sent to the server (if available).</li>
</ul>
</li>
<li>
<p><strong>Error handling:</strong></p>
<ul>
<li>Any HTTP errors (including certificate validation failures, connection issues, etc.) are caught, and the relevant error details are shown.</li>
</ul>
</li>
</ul>
<hr />
<h2>🚩&nbsp;<strong>Summary of What the Script Does:</strong></h2>
<ul>
<li>Imports an X509 certificate from a&nbsp;<code>.pfx</code>&nbsp;file.</li>
<li>Prints useful information about the certificate.</li>
<li>Sends an HTTPS request to an API endpoint, attaching:
<ul>
<li>The client certificate for mutual TLS (if the server requires it).</li>
<li>Custom headers containing the certificate's details (Base64 representation and thumbprint).</li>
</ul>
</li>
<li>Provides detailed output about the API request and response.</li>
<li>Includes clear error handling and messaging.</li>
</ul>
<p>&nbsp;</p>
<p><strong>2) Policy.xml</strong></p>
<p>&nbsp;</p>
<p>This APIM (Azure API Management) policy performs certificate validation based on HTTP headers sent by the client. Let's examine it step-by-step:</p>
<hr />
<h2>🚩 Detailed Explanation of the Policy:</h2>
<h3>📥&nbsp;<strong>Inbound Section</strong>&nbsp;(<code>&lt;inbound&gt;</code>):</h3>
<h4>1.&nbsp;<strong>Base Policy Inclusion</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">base</span> /&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Includes the default inbound policy definitions that may exist at higher scopes (such as global or product-level policies).</li>
</ul>
<h4>2.&nbsp;<strong>Header Check (<code>X-Azure-FDID</code>)</strong></h4>
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
<li>Checks if the incoming HTTP request has a header called&nbsp;<code>X-Azure-FDID</code>&nbsp;and ensures it matches the value of the APIM variable&nbsp;<code>{{FrontDoorId}}</code>.</li>
<li>If the header is missing or doesn't match, the request is immediately rejected with HTTP&nbsp;<code>403 Forbidden</code>.</li>
</ul>
<h4>3.&nbsp;<strong>Certificate and Thumbprint Headers Check</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">choose</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">when</span> <span class="hljs-attr">condition</span>=<span class="hljs-string">"@(context.Request.Headers.ContainsKey("</span><span class="hljs-attr">X-Client-Certificate</span>") &amp;&amp; <span class="hljs-attr">context.Request.Headers.ContainsKey</span>("<span class="hljs-attr">X-Client-Thumbprint</span>"))"&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Checks if both headers&nbsp;<code>X-Client-Certificate</code>&nbsp;and&nbsp;<code>X-Client-Thumbprint</code>&nbsp;exist in the request.</li>
<li>If either header is missing, it rejects the request immediately with HTTP&nbsp;<code>400 Bad Request</code>.</li>
</ul>
<hr />
<h3>🔐&nbsp;<strong>Certificate Validation Logic (inside the&nbsp;<code>&lt;when&gt;</code>&nbsp;condition)</strong>:</h3>
<h4>a.&nbsp;<strong>Extract Headers into Variables</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">set-variable</span> <span class="hljs-attr">name</span>=<span class="hljs-string">"certBase64"</span> <span class="hljs-attr">value</span>=<span class="hljs-string">"@(context.Request.Headers.GetValueOrDefault("</span><span class="hljs-attr">X-Client-Certificate</span>",""))" /&gt;</span>
<span class="hljs-tag">&lt;<span class="hljs-name">set-variable</span> <span class="hljs-attr">name</span>=<span class="hljs-string">"providedThumbprint"</span> <span class="hljs-attr">value</span>=<span class="hljs-string">"@(context.Request.Headers.GetValueOrDefault("</span><span class="hljs-attr">X-Client-Thumbprint</span>","")<span class="hljs-attr">.ToUpperInvariant</span>()<span class="hljs-attr">.Replace</span>(" ", ""))" /&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Takes the Base64-encoded certificate from the&nbsp;<code>X-Client-Certificate</code>&nbsp;header.</li>
<li>Takes the thumbprint from the&nbsp;<code>X-Client-Thumbprint</code>&nbsp;header and normalizes it (uppercase, no spaces).</li>
</ul>
<h4>b.&nbsp;<strong>Decode the Certificate from Base64</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">set-variable</span> <span class="hljs-attr">name</span>=<span class="hljs-string">"certBytes"</span> <span class="hljs-attr">value</span>=<span class="hljs-string">"@(Convert.FromBase64String((string)context.Variables["</span><span class="hljs-attr">certBase64</span>"]))" /&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Decodes the Base64-encoded certificate string into a byte array.</li>
</ul>
<h4>c.&nbsp;<strong>Compute the SHA-1 Thumbprint from Certificate Bytes</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">set-variable</span> <span class="hljs-attr">name</span>=<span class="hljs-string">"computedThumbprint"</span> <span class="hljs-attr">value</span>=<span class="hljs-string">"@(
    BitConverter.ToString(System.Security.Cryptography.SHA1.Create().ComputeHash((byte[])context.Variables["</span><span class="hljs-attr">certBytes</span>"]))<span class="hljs-attr">.Replace</span>("<span class="hljs-attr">-</span>", "")<span class="hljs-attr">.ToUpperInvariant</span>()
)" /&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Computes the SHA-1 hash (thumbprint) of the decoded certificate bytes and stores it as a normalized uppercase string.</li>
</ul>
<h4>d.&nbsp;<strong>Compare Computed Thumbprint with Provided Thumbprint</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">choose</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">when</span> <span class="hljs-attr">condition</span>=<span class="hljs-string">"@((string)context.Variables["</span><span class="hljs-attr">computedThumbprint</span>"] == <span class="hljs-string">(string)context.Variables[</span>"<span class="hljs-attr">providedThumbprint</span>"])"&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Checks if the thumbprint computed from the certificate exactly matches the thumbprint header provided by the client.</li>
<li>If the thumbprints do&nbsp;<strong>not</strong>&nbsp;match, it returns&nbsp;<code>401 Unauthorized</code>&nbsp;immediately.</li>
</ul>
<h4>e.&nbsp;<strong>Check Thumbprint Against APIM Registered Certificates</strong></h4>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">choose</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">when</span> <span class="hljs-attr">condition</span>=<span class="hljs-string">"@(!context.Deployment.Certificates.Any(c =&gt; c.Value.Thumbprint.ToUpperInvariant() == (string)context.Variables["</span><span class="hljs-attr">computedThumbprint</span>"]))"&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">return-response</span>&gt;</span>
            <span class="hljs-tag">&lt;<span class="hljs-name">set-status</span> <span class="hljs-attr">code</span>=<span class="hljs-string">"403"</span> <span class="hljs-attr">reason</span>=<span class="hljs-string">"Forbidden"</span> /&gt;</span>
            <span class="hljs-tag">&lt;<span class="hljs-name">set-body</span>&gt;</span>Client certificate thumbprint is not registered in APIM.<span class="hljs-tag">&lt;/<span class="hljs-name">set-body</span>&gt;</span>
        <span class="hljs-tag">&lt;/<span class="hljs-name">return-response</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">when</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">otherwise</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">set-header</span> <span class="hljs-attr">name</span>=<span class="hljs-string">"X-Client-Verified"</span> <span class="hljs-attr">exists-action</span>=<span class="hljs-string">"override"</span>&gt;</span>
            <span class="hljs-tag">&lt;<span class="hljs-name">value</span>&gt;</span>true<span class="hljs-tag">&lt;/<span class="hljs-name">value</span>&gt;</span>
        <span class="hljs-tag">&lt;/<span class="hljs-name">set-header</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">otherwise</span>&gt;</span>
<span class="hljs-tag">&lt;/<span class="hljs-name">choose</span>&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Checks if the computed thumbprint from the certificate matches&nbsp;<strong>any</strong>&nbsp;thumbprint registered in Azure APIM's internal certificate store (<code>context.Deployment.Certificates</code>).</li>
<li>If the thumbprint is&nbsp;<strong>not</strong>&nbsp;registered in APIM, the request is rejected with HTTP status&nbsp;<code>403 Forbidden</code>.</li>
<li>If the thumbprint&nbsp;<strong>is</strong>&nbsp;registered in APIM, it sets a custom header&nbsp;<code>X-Client-Verified: true</code>&nbsp;to indicate successful validation.</li>
</ul>
<hr />
<h3>📤&nbsp;<strong>Backend Section (<code>&lt;backend&gt;</code>)</strong>:</h3>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">backend</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">base</span> /&gt;</span>
<span class="hljs-tag">&lt;/<span class="hljs-name">backend</span>&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Includes any existing default backend policy definitions.</li>
</ul>
<hr />
<h3>📤&nbsp;<strong>Outbound Section (<code>&lt;outbound&gt;</code>)</strong>:</h3>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">outbound</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">base</span> /&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">choose</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">when</span> <span class="hljs-attr">condition</span>=<span class="hljs-string">"@((int)context.Response.StatusCode &gt;= 200 &amp;&amp; (int)context.Response.StatusCode &lt; 300)"</span>&gt;</span>
            <span class="hljs-tag">&lt;<span class="hljs-name">set-body</span>&gt;</span>Certificate is valid. Request Succeeded.<span class="hljs-tag">&lt;/<span class="hljs-name">set-body</span>&gt;</span>
        <span class="hljs-tag">&lt;/<span class="hljs-name">when</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">choose</span>&gt;</span>
<span class="hljs-tag">&lt;/<span class="hljs-name">outbound</span>&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>Modifies the response body if the backend response is successful (HTTP status within&nbsp;<code>200-299</code>), returning a simple message:&nbsp;<code>"Certificate is valid. Request Succeeded."</code>.</li>
</ul>
<hr />
<h3>⚠️&nbsp;<strong>On-Error Section (<code>&lt;on-error&gt;</code>)</strong>:</h3>
<figure class="CodeBlock-module__container--BRsgk CodeBlock-module__immersive--vxBb6">
<figcaption class="CodeBlock-module__header--RMUQr"><span class="CodeBlock-module__languageName--ZLWCa">XML</span></figcaption>
<div class="CodeBlock-module__copyContainer--HAOPj">&nbsp;</div>
<div class="CodeBlock-module__codeContainer--dAEis">
<pre class="CodeBlock-module__code--KUcqT" tabindex="0"><code><span class="hljs-tag">&lt;<span class="hljs-name">on-error</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">base</span> /&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">return-response</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">set-status</span> <span class="hljs-attr">code</span>=<span class="hljs-string">"403"</span> <span class="hljs-attr">reason</span>=<span class="hljs-string">"Certification Validation Failed"</span> /&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">set-body</span>&gt;</span>Your certificate is invalid or does not match the configured certificate in APIM.<span class="hljs-tag">&lt;/<span class="hljs-name">set-body</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">return-response</span>&gt;</span>
<span class="hljs-tag">&lt;/<span class="hljs-name">on-error</span>&gt;</span>
</code></pre>
</div>
</figure>
<ul>
<li>If any unexpected error occurs during the policy execution (e.g., exception thrown during certificate decoding or validation), the API returns a standardized HTTP&nbsp;<code>403 Forbidden</code>&nbsp;response indicating validation failure.</li>
</ul>
<hr />
<h2>📝&nbsp;<strong>Summary of What the Policy Does</strong>:</h2>
<ol>
<li><strong>Verifies essential headers</strong>&nbsp;(<code>X-Azure-FDID</code>,&nbsp;<code>X-Client-Certificate</code>,&nbsp;<code>X-Client-Thumbprint</code>).</li>
<li><strong>Decodes the received certificate</strong>&nbsp;from a base64 string.</li>
<li><strong>Computes the thumbprint</strong>&nbsp;of the provided certificate.</li>
<li><strong>Checks</strong>&nbsp;that computed thumbprint matches the client's provided thumbprint.</li>
<li><strong>Validates</strong>&nbsp;that the thumbprint is explicitly registered in APIM's own certificate store.</li>
<li><strong>Rejects requests</strong>&nbsp;that fail any of these checks with clear HTTP statuses (<code>400</code>,&nbsp;<code>401</code>, or&nbsp;<code>403</code>).</li>
<li><strong>Modifies successful responses</strong>&nbsp;to clearly indicate the validation succeeded.</li>
</ol>
<p>&nbsp;</p>
<p>In short, this policy ensures strong client authentication based on certificates and prevents unauthorized access to your APIs by strictly validating that the presented certificates are both correct and pre-registered in your APIM instance.</p>
