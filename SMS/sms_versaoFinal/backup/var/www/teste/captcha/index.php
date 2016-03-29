<?php session_start(); ?>
 
<body onload="document.getElementById('captcha-form').focus()">



<p><strong>Write the following word:</strong></p>


<form action="valida.php" method="post" name="formulario" id="formulario">
<img src="captcha.php" id="captcha" /><br/>


<!-- CHANGE TEXT LINK -->
<a href="#" onclick="
    document.getElementById('captcha').src='captcha.php?'+Math.random();
    document.getElementById('captcha-form').focus();"
    id="change-image">Not readable? Change text.</a><br/><br/>


<input type="text" name="captcha" id="captcha-form" autocomplete="off" /><br/>
<input type="submit" />

</form>

</body>
</html>
