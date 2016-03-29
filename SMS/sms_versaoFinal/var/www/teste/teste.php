<?php
include('conf.php');
$telefonePost="5185422169";
$query =mysql_query("SELECT COUNT(telefone) AS total_number FROM dados WHERE data >= DATE_SUB(CURDATE(), INTERVAL 20 DAY) AND telefone = '".$telefonePost."';");
$result  = mysql_fetch_assoc($query);

// se ele solicitou mais de 7 vouchers nos umtimos 20 dias, insere o usuario automaticamente na black list de particulares
if ($result['total_number'] > 6)
	{
		echo "bloqueou numero $telefonePost";
		mysql_close($db_con);
	}
else
	{
		echo "nao bloqueou numero $telefonePost";
		mysql_close($db_con);
	}
?>