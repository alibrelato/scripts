<script>
		document.write('<style>.noscript { display:none }</style>');
</script>
<form action="http://10.10.10.2/index.php" method="post" id="redirectform">
<input type="hidden" name="client_mac" value="$CLIENT_MAC$">
<input type="hidden" name="client_ip" value="$CLIENT_IP$">
<input name="action" type="hidden" value="$PORTAL_ACTION$">
<input name="redirurl" type="hidden" value="$PORTAL_REDIRURL$">
<span class="noscript">Javascript is disabled, click to
<input name="submitx" type="submit" value="Continue" />
</span>
</form>
<script type="text/javascript">
    function doredirect () {
        var frm = document.getElementById("redirectform");
        frm.submit();
    }
    window.onload = doredirect;
</script>