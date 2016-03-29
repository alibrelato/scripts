<?php session_start();
/** Validate captcha */
if (!empty($_REQUEST['captcha'])) {
    if (empty($_SESSION['captcha']) || trim(strtolower($_REQUEST['captcha'])) != $_SESSION['captcha']) {
	echo "captcha inválido";
    } else {
	echo "captcha válido";
    }

    unset($_SESSION['captcha']);
}


?> 
