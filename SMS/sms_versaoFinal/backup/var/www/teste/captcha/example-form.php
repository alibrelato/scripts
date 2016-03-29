<?php session_start(); ?>

<body onload="document.getElementById('captcha-form').focus()">

<?php

/** Validate captcha */
if (!empty($_REQUEST['captcha'])) {
    if (empty($_SESSION['captcha']) || trim(strtolower($_REQUEST['captcha'])) != $_SESSION['captcha']) {
        $captcha_message = "Invalid captcha";
        $style = "background-color: #FF606C";
    } else {
        $captcha_message = "Valid captcha";
        $style = "background-color: #CCFF99";
    }

    $request_captcha = htmlspecialchars($_REQUEST['captcha']);

    echo <<<HTML
        <div id="result" style="$style">
        <h2>$captcha_message</h2>
        <table>
        <tr>
            <td>Session CAPTCHA:</td>
            <td>{$_SESSION['captcha']}</td>
        </tr>
        <tr>
            <td>Form CAPTCHA:</td>
            <td>$request_captcha</td>
        </tr>
        </table>
        </div>
HTML;
    unset($_SESSION['captcha']);
}


?>

<p><strong>Write the following word:</strong></p>

<form method="GET">
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
