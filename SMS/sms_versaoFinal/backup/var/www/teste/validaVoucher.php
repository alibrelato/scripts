<?php session_start();

if (!empty($_REQUEST['captcha'])) 
{
    if (empty($_SESSION['captcha']) || trim(strtolower($_REQUEST['captcha'])) != $_SESSION['captcha']) 
	{
	header("Location: statusCaptcha.php");
    } 
	else 
	{
	header("Location: http://192.168.19.254:8000);
    }
unset($_SESSION['captcha']);
}
?>