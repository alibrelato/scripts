<?php session_start();

if (!empty($_REQUEST['captcha'])) 
{
    if (empty($_SESSION['captcha']) || trim(strtolower($_REQUEST['captcha'])) != $_SESSION['captcha']) 
	{
	header("Location: statusCaptcha.php");
    } 
	else 
	{
		include('conf.php');
		$telefonePost = $_POST["telefone"];
		$nomePost = $_POST["nome"];
		$rgfonePost = $_POST["RG"];
		//funcao para substituir todos espacos em branco "()" e -
		$telefonePost = str_replace("-", "", str_replace(" ", "", str_replace(")", "", str_replace("(", "", $telefonePost))));

		//tenta montar o query com o mysql
		mysql_select_db($db_name);
		//verifica qual campo do telefone está vaziu e poe o voucher dentro da variavel "query"
		$query=mysql_query("SELECT voucher FROM dados WHERE telefone='' LIMIT 1");
		$voucherQuery = mysql_result($query, 0);
		//faz update do campo telefone
		$tel="UPDATE dados SET telefone='".$telefonePost."' WHERE voucher='".$voucherQuery."'";
		$query = mysql_query($tel);
		//faz update do campo nome
		$nom="UPDATE dados SET nome='".$nomePost."' WHERE voucher='".$voucherQuery."'";
		$query = mysql_query($nom);
		//faz update do campo rg
		$doc="UPDATE dados SET rg='".$rgfonePost."' WHERE voucher='".$voucherQuery."'";
		$query = mysql_query($doc);
		//fecha conexao com o mysql
		mysql_close($db_con);
		//redireciona para a página inicial
		header("Location: statusRecebimento.php");
		die();
    }
unset($_SESSION['captcha']);
}
?>