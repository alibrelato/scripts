<?php
// Connection's Parameters
$db_host="172.30.1.15";
$db_name="smsGateway_Halia";
$username="smsGateway_Halia";
$password="dJi@#!327dwR";
$db_con=mysql_connect($db_host,$username,$password);
$connection_string=mysql_select_db($db_name);

//if (!$db_con) {
//     die('Nao possivel conectar: ' . mysql_error());
//}
//else
//{
//echo 'Conexao bem sucedida';
//mysql_select_db($db_name);
//}


?>
