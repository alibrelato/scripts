#aaconsultaSQL=$(echo $(query "SELECT voucher,telefone,envios FROM dados WHERE telefone != '' AND status = '' AND controle = '2' LIMIT 1;"))
voucherSQL="sad231"
filtroExecucao=$(echo "Assembleia Legislativa RS    Codigo acesso: ${voucherSQL}" | gammu -c /etc/gammu2.conf --sendsms TEXT 5184158315)
#filtroExecucao="$(echo 'Assembleia Legislativa RS    Codigo acesso: sad231' |gammu -c /etc/gammu2.conf --sendsms TEXT 5184158315)"
		
		## Se a variavel filtroExecucao tem a mensagem OK, faz update no banco dados com o telefone e a hora de envio usando a funcao query. ##
		if [[ $filtroExecucao = *"OK"* ]]; then
			printf "mandou $filtroExecucao \n" >> /tmp/teste.log
			printf "================================================ \n" >> /tmp/teste.log
			exit 1
		else
			printf "nao mandou $filtroExecucao \n" >> /tmp/teste.log
			printf "================================================ \n" >> /tmp/teste.log
			exit 1
		fi
