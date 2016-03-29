<?php
include('conf.php');

/*
UPLOAD DE ARQUIVO
*/
// Pasta onde o arquivo vai ser feito upload
$_UP['pasta'] = '/tmp/';
 
// Array com a extensao de arquivo permitida
$_UP['extensoes'] = array('csv');
 
// Renomeia o arquivo? (Se true, o arquivo sera salvo como .csv e um nome padrao)
$_UP['renomeia'] = true;
 
// Array com os tipos de erros de upload do PHP
$_UP['erros'][0] = 'Nao houve erro';
$_UP['erros'][1] = 'O arquivo no upload eh maior do que o limite do PHP';
$_UP['erros'][2] = 'O arquivo ultrapassa o limite de tamanho especifiado no HTML';
$_UP['erros'][3] = 'O upload do arquivo foi feito parcialmente';
$_UP['erros'][4] = 'Nao foi feito o upload do arquivo';
 
// Verifica se houve algum erro com o upload. Se sim, exibe a mensagem do erro
if ($_FILES['arquivo']['error'] != 0) 
	{
	die("Nao foi possivel fazer o upload, erro:<br />" . $_UP['erros'][$_FILES['arquivo']['error']]);
	exit; // Para a execucao do script caso tenha erro
	}
	 
// Caso script chegue a esse ponto, nao houve erro com o upload e o PHP pode continuar
	 
// Faz a verificacao da extensao do arquivo
$extensao = strtolower(end(explode('.', $_FILES['arquivo']['name'])));
if (array_search($extensao, $_UP['extensoes']) === false)
	{
	//	se o arquivo nao eh .CSV direciona para a pagina de erro
	header("Location: statusInvalido.php");
	die();
	}
	 
// O arquivo passou em todas as verificacoes, hora de tentar move-lo para a pasta
else
	{
	// Primeiro verifica se deve trocar o nome do arquivo
	if ($_UP['renomeia'] == true)
		{
		// declaracao do nome que deve ficar o arquivo
		$nome_final = 'vouchers.csv';
		}
	}
// Depois verifica se eh possivel mover o arquivo para a pasta escolhida com o nome final "vouchers.csv"
if (move_uploaded_file($_FILES['arquivo']['tmp_name'], $_UP['pasta'] . $nome_final))
	{
	/*
	TRATAMENTO DO ARQUIVO
	*/
	$arquivo = "/tmp/vouchers.csv";
	$linha = 0;
		 
	// le o arquivo para um array
	$arr = file($arquivo);
			 
	// remove as 7 primeiras linhas
	while ($linha < 7)
		{
		unset($arr[$linha]);
		$linha ++;
		}

	// reindexa o array
	$arr = array_values($arr);

	//trata array para tirar espaços em branco e aspas desnecessarios em cada linha de $arr
	$arr_lf = array("\n", "\n\r", "\r\n");
	foreach($arr as $chave => $valor)
		{
		$arr[$chave] = str_replace(" ", "", $valor);
		$arr[$chave] = str_replace("\"", "", $arr[$chave]);
		$arr[$chave] = str_replace($arr_lf, "", $arr[$chave]);
		$sql_aux .= "('" . $arr[$chave] . "')";
		if ($chave < count($arr) - 1) { $sql_aux .= ", "; }
		}

	/*
	INSERT DO VOUCHERS NO BANCO 
	*/
	if ($sql_aux != "")
		{
		mysql_select_db($db_name);
		$str="INSERT INTO dados (voucher) VALUES " . $sql_aux;
		$query = mysql_query($str);
		mysql_close($db_con);
		}
	//deleta o arquivo, pois ja foi feito o insert no banco
	unlink("/tmp/vouchers.csv");
	//redireciona para a pagina de status
	header("Location: statusOk.php");
	die();
	// le devolta para o arquivo
	//file_put_contents($arquivo, implode($arr));;
	}
else
	{
	// Não foi possível fazer o upload
	header("Location: statusErro.php");
	die();
	}
?>