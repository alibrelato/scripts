<?php
// Connection's Parameters
$db_host="172.30.1.15";
$db_name="smsGateway_Halia";
$username="smsuser";
$password="sgrela";
$db_con=mysql_connect($db_host,$username,$password);
$connection_string=mysql_select_db($db_name);
?>
