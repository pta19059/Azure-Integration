<p class="demoTitle"><strong>Base inbound policy</strong></p>
<p>Condition: If the client certificate is not provided --&gt; Return a 403 Forbidden response</p>
<p>Condition: If the client certificate's thumbprint does not match any registered certificate in APIM --&gt; Return a 403 Forbidden response with a specific reason.</p>
<p>Otherwise, if the client certificate is valid -- &gt;&nbsp;Set a header to indicate the client certificate is validated</p>
<!-- Comments are visible in the HTML source only -->
