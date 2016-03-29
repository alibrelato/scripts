<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="">
	<meta name="author" content="">
	<link rel="shortcut icon" href="../../assets/ico/favicon.ico">
	<title>Rede WIFI Alergs</title>
	<!-- Bootstrap core CSS -->
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<!-- Custom styles for this template -->
	<link href="css/cover.css" rel="stylesheet">
	<!-- Just for debugging purposes. Don't actually copy this line! -->
	<!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
	<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
	<!--[if lt IE 9]>
		<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
		<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
	<![endif]-->
	<!-- Bootstrap core JavaScript
	================================================== -->
	<!-- Placed at the end of the document so the pages load faster -->

	<script src="js/jquery-1.11.0.min.js"></script>

	<script src="js/bootstrap.min.js"></script>

	<script type="text/javascript">

		function validaTelefone(campoTelefone, evtTeclado) {
			var keyCode = ('which' in evtTeclado) ? evtTeclado.which : evtTeclado.keyCode;

			var teclaNumerica = keyCode != 32 && (keyCode == 8 || keyCode == 37 || keyCode == 39 || keyCode == 46 ||
			(keyCode >= 48 && keyCode <= 57) || (keyCode >= 96 && keyCode <= 105) ||
			(campoTelefone.value.length >= 14 && keyCode == 13));
			var modificadores = (evtTeclado.altKey || evtTeclado.ctrlKey || evtTeclado.shiftKey);

			return teclaNumerica && !modificadores;
		}

		function mascaraTelefone(campoTelefone) {
			var btnEnviar = document.getElementById('accept');
			var valorCampo = campoTelefone.value;
			var tamanhoTotal = 0;

			//Coloca parênteses nos 2 dígitos iniciais do telefone
			valorCampo = valorCampo.replace(/([(]{1})/, "");
			valorCampo = valorCampo.replace(/([)]{1})/, "");
			valorCampo = valorCampo.replace(/(\s{1})/, "");
			valorCampo = valorCampo.replace(/^(\d{2})(\d{1,})/g, "($1) $2");

			//Coloca hífen no número do telefone
			valorCampo = valorCampo.replace(/([(]{1}\d{2}[)]{1}\s{1}\d{4})(\d)$/, "$1-$2");
			tamanhoTotal = valorCampo.length;

			//Ajusta o hífen conforme necessário
			if (tamanhoTotal >= 14) {
				valorCampo = valorCampo.replace(/([-]{1})/, "");

				if (tamanhoTotal == 14) {
					valorCampo = valorCampo.replace(/([(]{1}\d{2}[)]{1}\s{1}\d{4,})(\d{4})$/, "$1-$2");
				}
				else {
					valorCampo = valorCampo.replace(/([(]{1}\d{2}[)]{1}\s{1}\d{5,})(\d{4})$/, "$1-$2");
				}
			}

			//Se o campo tiver pelo menos 14 caracteres, habilita o botão de envio do form
			if (campoTelefone.value.length >= 14) {
				btnEnviar.disabled = false;
			}
			else {
				btnEnviar.disabled = true;
			}

			campoTelefone.value = valorCampo;
		}
	</script>

</head>
<body>
	<div class="site-wrapper">
		<div class="site-wrapper-inner">
			<div class="cover-container">
				<div class="masthead clearfix">
					<a><img class="img-responsive" src="images/topo_desktop.jpg" /></a>
					<div class="inner">
						<h3 class="masthead-brand">
						</h3>
					</div>
				</div>
				<div class="inner cover">
					<h1 class="cover-heading">
						Rede Wifi Alergs</h1>
					<p class="lead">
						Sistema de vouchers.
					</p>
					<p class="lead">
						Apenas arquivos CSV oriundos do PFSense serão aceitos.<br />
						Seja muito cuidadoso ao fazer upload dos novos vouchers.
					</p>
					<div class="panel-group" id="accordion">
						<div class="panel panel-default">
							<div class="panel-heading" data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
								<h4 class="panel-title">
									Fazer upload de voucher
								</h4>
							</div>
							<form action="upload_file.php" method="POST" enctype="multipart/form-data">
								<div id="collapseThree" class="panel-collapse collapse">
									<div class="panel-body">
										<input type="file" name="arquivo" size="20">
										<div class="btn-group">
											<button class="btn btn-default" name="accept" type="submit">
												Enviar</button>
										</div>
									</div>
								</div>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>