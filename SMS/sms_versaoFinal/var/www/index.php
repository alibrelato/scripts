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
<body onload="document.getElementById('captcha-form').focus()">
	<div class="site-wrapper">
		<div class="site-wrapper-inner">
			<div class="cover-container">
				<div class="masthead clearfix">
					<div class="inner">
						<h3 class="masthead-brand">
						</h3>
					</div>
				</div>
				<div class="inner cover">
					<h1 class="cover-heading">
						Rede Wifi Alergs</h1>
					<p class="lead">
						Bem-vindo ao portal de acesso público à internet wireless da Assembleia Legislativa
						do Rio Grande do Sul.
					</p>
					<p class="lead">
						Se você não possui um código de acesso, solicite o seu no menu abaixo.<br />
						Se já possui seu código de acesso, utilize a segunda opção do menu.
					</p>
					<div class="panel-group" id="accordion">
						<div class="panel panel-default">
							<div class="panel-heading" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
								<h4 class="panel-title">
									Solicitar código de acesso
								</h4>
							</div>
							<div id="collapseOne" class="panel-collapse collapse">
								<div class="panel-body">
									<form action="acao.php" method="post" name="formulario" id="formulario">
										<p>
											Preencha os campos abaixo e aguarde o recebimento do seu código de acesso via SMS
											para acessar a rede wifi ALERGS PÚBLICO. <b>O código de acesso é válido por 12 horas</b>.</p>
										<div class="input-group">
											<span class="input-group-addon">Nome</span>
											<input type="text" name="nome" id="nome" class="form-control" placeholder="Nome">
										</div>
										<div class="input-group">
											<span class="input-group-addon">RG</span>
											<input type="text" name="RG" id="RG" class="form-control" placeholder="0000000000" maxlength="10">
										</div>
										<div class="input-group">
											<span class="input-group-addon">Celular</span>
											<input type="text" name="telefone" id="telefone" class="form-control" placeholder="(xx)0000-0000" maxlength="15" onkeydown="return validaTelefone(this, event);" onkeyup="mascaraTelefone(this);">
										</div>

										<!-- Inicio captcha -->
										<?php session_start(); ?>
										<img src="captcha.php" id="captcha" /><br/>
										<a href="#" onclick="
										document.getElementById('captcha').src='captcha.php?'+Math.random();
										document.getElementById('captcha-form').focus();"
										id="change-image">...ilegivel? Altere o texto...</a><br/><br/>
										<input type="text" name="captcha" id="captcha-form" autocomplete="off" /><br/>
										<!-- fim captcha -->
										
										<div class="btn-group">
											<br />
											<button class="btn btn-default" name="accept" id="accept" type="submit" disabled="true">SOLICITAR</button>
										</div>
									</form>
								</div>
							</div>
						</div>
						<div class="panel panel-default">
							<div class="panel-heading" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
								<h4 class="panel-title">
									Tenho um código de acesso
								</h4>
							</div>
							<div id="collapseTwo" class="panel-collapse collapse">
								<div class="panel-body">
									<form method="post" action="http://192.168.19.254:8000/">
									<input name="redirurl" type="hidden" value="http://www.al.rs.gov.br/">
										<form method="post" action="<?php echo $_POST['action']; ?>">
										<input name="redirurl" type="hidden" value="<?php echo $_POST['redirurl']; ?>">
											<div class="input-group">
												<span class="input-group-addon">Código</span>
												<input name="auth_voucher" id="auth_voucher" type="text" class="form-control" placeholder="Ex: E5B9XC10">
											</div>
											<div class="btn-group">
												<button class="btn btn-default" name="accept" type="submit" value="Log In">
													VALIDAR</button>
											</div>
										</form>
									</form>
								</div>
							</div>
						</div>
						<div class="panel panel-default">
							<div class="panel-heading" data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
								<h4 class="panel-title">
									Tenho login e senha
								</h4>
							</div>
							<div id="collapseThree" class="panel-collapse collapse">
								<div class="panel-body">
									<form method="post" action="http://192.168.19.254:8000/">
									<input name="redirurl" type="hidden" value="http://www.al.rs.gov.br/">
										<form method="post" action="<?php echo $_POST['action']; ?>">
										<input name="redirurl" type="hidden" value="<?php echo $_POST['redirurl']; ?>">
											<div class="input-group">
												<span class="input-group-addon">Usuário</span>
												<input name="auth_user" type="text" class="form-control" placeholder="usuario.de.rede">
											</div>
											<div class="input-group">
												<span class="input-group-addon">Senha</span>
												<input name="auth_pass" type="password" class="form-control" placeholder="Senha de rede">
											</div>
											<div class="btn-group">
												<button class="btn btn-default" name="accept" type="submit" value="Log In">
													ENTRAR</button>
											</div>
										</form>
									</form>
								</div>
							</div>
						</div>
						<div class="panel panel-default" style="border:none; -webkit-box-shadow:none; box-shadow:none;">
							<p>
								<a href="termosDeUso.php" target="_blank" >Termos de Uso</a>
							</p>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>