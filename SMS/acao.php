<?php
//#CONF DATABASE CONECT.
include('conf.php');
$telefonePost = $_POST["telefone"];

$telefonePost = str_replace("-", "", str_replace(" ", "", str_replace(")", "", str_replace("(", "", $telefonePost))));

		 //conexao ok, entao tenta montar o query
			//atribiu nome do banco para variavel db_name
			mysql_select_db($db_name);
			//verifica qual campo do telefone está vaziu e poe o voucher dentro da variavel "query"
			$query=mysql_query("SELECT voucher FROM dados WHERE telefone='' LIMIT 1");
			$voucherQuery = mysql_result($query, 0);
			//faz update do campo emissao
			$str="UPDATE dados SET telefone='".$telefonePost."' WHERE voucher='".$voucherQuery."'";
			$query = mysql_query($str);
			mysql_close($db_con);//fecha conexao com o mysql
		
			

//redireciona para a página inicial
header("Location: status.html");
die();
?>
