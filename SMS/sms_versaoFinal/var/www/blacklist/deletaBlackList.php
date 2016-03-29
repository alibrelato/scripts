<?php
include('conf.php');
$telefonePost = $_POST["telefone"];
$id = $_POST['b'];

//funcao para substituir todos espacos em branco "()" e -
$telefonePost = str_replace("-", "", str_replace(" ", "", str_replace(")", "", str_replace("(", "", $telefonePost))));
//tenta montar o query com o mysql
mysql_select_db($db_name);

// procura no banco se o telefone está na blaclist de telefones alergs
$queryBlacklist=mysql_query("SELECT telefone,id FROM blackList WHERE telefone='".$telefonePost."' LIMIT 1;");
$row = mysql_fetch_row($queryBlacklist);

if ($row[1] == 0)
	{
	mysql_close($db_con);
	header("Location: statusLiberado.php");
	die();
	}

if ($row[1] != $id)
	{
	mysql_close($db_con);
	header("Location: statusIdErrado.php");	
	die();
	}

if ($row[1] == 1 AND $id == 1)
	{
	if(isset($_POST['enviar']) && $_POST['enviar'] == "Enviar" )
		{
		$tel="DELETE FROM blackList WHERE telefone = '".$telefonePost."' AND id = '".$id."'";
		$query = mysql_query($tel);
		mysql_close($db_con);
		header("Location: statusDel.php");	
		die();
		}
	}

if ($row[1] == 2 AND $id == 2)
	{
	if(isset($_POST['enviar']) && $_POST['enviar'] == "Enviar" )
		{
		$tel="DELETE FROM blackList WHERE telefone = '".$telefonePost."' AND id = '".$id."'";
		$query = mysql_query($tel);
		mysql_close($db_con);
		header("Location: statusDel.php");	
		die();
		}
	}
die();
?>