<?php session_start();

//faz teste se o captcha digitado no site e valido
if (!empty($_REQUEST['captcha'])) 
{
	//se o captcha e invalido, redireciona o usuario para a pagina de erro
    if (empty($_SESSION['captcha']) || trim(strtolower($_REQUEST['captcha'])) != $_SESSION['captcha']) 
	{
	header("Location: statusCaptcha.php");
    } 
	else 
	{
		//se o captcha e valido, executa os filtros de blacklist e se o usuario passar pelos filtros, faz a requisicao do voucher
		//declaracao das variaveis
		include('conf.php'); //faz o include das conf do banco
		$telefonePost = $_POST["telefone"]; //captura o telefone difitado na pagina
		$nomePost = $_POST["nome"]; //captura o nome digitado na pagina
		$rgfonePost = $_POST["RG"]; //captura o RG digitado na pagina
		$hora = date("Hi"); //captura a hora do servidor para fazer o controle de hora permitida
		//funcao para substituir todos espacos em branco "()" e -
		$telefonePost = str_replace("-", "", str_replace(" ", "", str_replace(")", "", str_replace("(", "", $telefonePost))));

		//tenta montar o query com o mysql
		mysql_select_db($db_name);
		
		// Inicio testa black list
		// procura no banco se o telefone está na blaclist
		$queryBlacklist=mysql_query("SELECT telefone,id FROM blackList WHERE telefone='".$telefonePost."' LIMIT 1;");
		$row = mysql_fetch_row($queryBlacklist);
		// Se o telefone esta na lista de black list com o id 1, direciona para bagina de black list alergs
		if ($row[1]==1)
			{
			mysql_close($db_con);
			header("Location: statusBlacklistAlergs.php");
			die();
			}
		// Se o telefone esta na lista de black list com o id 2, direciona para bagina de black list particulares
		if ($row[1]==2)
			{
			mysql_close($db_con);
			header("Location: statusBlacklistParticular.php");
			die();
			}
		// fim testa black list
			
		// inicio testa abusado
		
		// Se for solicitado voucher entre 23h e 7h, o usuario entra na blacklist
		if (($hora > 2300) || ($hora < 700))
			{
				$doc="INSERT INTO blackList VALUES ('".$telefonePost."', '2')";
				$query = mysql_query($doc);
				mysql_close($db_con);
				header("Location: statusBlacklistParticular.php");
				die();
			}
		
		// verifica quantas vezes nos ultimos 20 dias o usuario solicitou voucher com o mesmo numero de telefone
		$query =mysql_query("SELECT COUNT(telefone) AS total_number FROM dados WHERE data >= DATE_SUB(CURDATE(), INTERVAL 20 DAY) AND telefone = '".$telefonePost."';");
		$result  = mysql_fetch_assoc($query);
		
		// se ele solicitou mais de 6 vouchers nos umtimos 20 dias, insere o usuario automaticamente na black list de particulares
		if ($result['total_number'] > 6)
			{
			$doc="INSERT INTO blackList VALUES ('".$telefonePost."', '2')";
			$query = mysql_query($doc);
			mysql_close($db_con);
			header("Location: statusBlacklistParticular.php");
			die();
			}
		// fim testa abusado
		
		// se o telefone passar pelos filtros
		//verifica qual voucher esta disponivel para ser enviado
		$query=mysql_query("SELECT voucher FROM dados WHERE telefone='' LIMIT 1");
		$voucherQuery = mysql_result($query, 0);
		//faz update do campos do voucher selecionado para ser enviado para o usuario
		$tel="UPDATE dados SET telefone='".$telefonePost."', nome='".$nomePost."', rg='".$rgfonePost."' WHERE voucher='".$voucherQuery."'";
		$query = mysql_query($tel);
		mysql_close($db_con);
		header("Location: statusRecebimento.php");
		die();
    }
unset($_SESSION['captcha']);
}
?>
