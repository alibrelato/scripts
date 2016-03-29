<?php
include('conf.php');
$telefonePost = $_POST["telefone"];

//funcao para substituir todos espacos em branco "()" e -
$telefonePost = str_replace("-", "", str_replace(" ", "", str_replace(")", "", str_replace("(", "", $telefonePost))));
//tenta montar o query com o mysql
mysql_select_db($db_name);

// procura no banco se o telefone está na blaclist de telefones alergs
$queryBlacklist=mysql_query("SELECT telefone,id FROM blackList WHERE telefone='".$telefonePost."' LIMIT 1;");
$row = mysql_fetch_row($queryBlacklist);

if ($row[1]==1)
	{
	header("Location: statusBlacklistAlergs.php");
	die();
	}
if ($row[1]==2)
	{
	header("Location: statusBlacklistParticular.php");
	die();
	}
else
	{
	header("Location: statusLiberado.php");
	die();
	}
	
mysql_close($db_con);
//redireciona para a página inicial
//header("Location: statusRecebimento.php");
die();
?>
