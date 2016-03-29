#!/bin/bash
######################################
######################################
##	Desenvolvido por :				##
##		Alessandro Librelato 		##
##		Roberto Fettuccia			##
##									##
##  OS : DEBIAN Whezzy				##
##	Data : 12/03/2014				##
##	Versao : 2.0					##
##									##
######################################
######################################
#set -x
#####################################
## Definicao das variaveis globais ##
#####################################

logFile=/var/log/sendvoucher.log ## Arquivo de log
gammuConfig=/etc/gammu1.conf ## Configuracao do Gammu
emailReport="alessandro.librelato@terc.al.rs.gov.br" ## Configuracao de e-mail
contagemErro=0
maxErrorCount=5
maxErrorCountModem=4   ## Maximo de erros para o modem e SIM desativado - envio de alerta via email. default 24 (+/- 3 minutos)
maxErrorCountModemSim=7 ## Maximo de erro para o cartao SIM sem creditos
intervalNextTry=35 ## Tempo seg para aguardar cada tentativa/sucesso. default [5]
servidor=$(hostname) ## Nome do servidor


##################################
## Definicoes do banco de dados ##
##################################

servidorBanco="172.30.1.15"
usuarioBanco="smsGateway_Halia"
senhaUsuarioBanco="dJi@#!327dwR"
dataBase="smsGateway_Halia"

######################################
## Funcao para fazer a QUERY no SQL ##
######################################

function query()
	{
	# recebe sql string de fora da function
	QUERY_SQL=${1} 
	# executa o SQL (SED -n 2p retira cabecalho da tabela)
	echo $(echo ${QUERY_SQL} | mysql --host=${servidorBanco} --user=${usuarioBanco} --password=${senhaUsuarioBanco} ${dataBase} | sed -n "2p")
	}

############
## Inicio ##
############

## Enquanto loop for = 1 e contagemErro diferente de maxErrorCount, executa ##
while [ ${contagemErro} -le ${maxErrorCount} ]; do
	## Faz consulta SQL para verificar qual campo voucher esta preenchido, campo telefone e emissao estao vaziu e atribui a variavel consultaSQL ##
	consultaSQL=$(echo $(query "SELECT voucher,telefone,envios FROM dados WHERE telefone != '' AND status = '' AND controle = '1' LIMIT 1;"))
	## Retira o numero do voucher da cunsulta SQL ##
	voucherSQL=$(echo "$consultaSQL" | cut -d " " -f 1 | sed "s/ //g" )
	## Retira o numero do telefone da cunsulta SQL ##
	telefoneSQL=$(echo "$consultaSQL" | cut -d " " -f 2 | sed "s/ //g" )
	## Quantas vezes o voucher foi enviado ##
	enviosSQL=$(echo "$consultaSQL" | cut -d " " -f 3 | sed "s/ //g" )
	
	## Se voucher diferente de vazio E telefone diferente de vazio envia o sms e grava no log a acao ##
	if [ ! -z ${voucherSQL} ] && [ ! -z ${telefoneSQL} ]; then
		horaEnvio="$(date +%H:%M:%S)"
		dataEnvio="$(date +%Y-%m-%d)"
		status="Enviado"
		
		filtroExecucao="$(echo 'Assembleia Legislativa RS    Codigo acesso: '${voucherSQL} |gammu -c ${gammuConfig} --sendsms TEXT ${telefoneSQL})"
		#filtroExecucao=$(echo "Assembleia Legislativa RS    Codigo acesso: ${voucherSQL}" | gammu -c /etc/gammu2.conf --sendsms TEXT ${telefoneSQL})
		
		## Se a variavel filtroExecucao tem a mensagem OK, faz update no banco dados com o telefone e a hora de envio usando a funcao query. ##
		if [[ $filtroExecucao = *"OK"* ]]; then
			enviosSQL=$((enviosSQL+1))
			query "UPDATE dados SET data = NOW(), status = '${status}', envios = '${enviosSQL}'  WHERE voucher = '${voucherSQL}' AND telefone = '${telefoneSQL}';"
			printf "${dataEnvio} ${horaEnvio} ${telefoneSQL} ${filtroExecucao} \n" >> ${logFile}
			printf "================================================ \n" >> ${logFile}
			exit 1
		
		## Se a variavel filtroExecucao nao tem a mensagem OK, entra no tratamento do erro ##
		elif [[ $filtroExecucao = *"500"* ]]; then
			printf "${horaEnvio} ${filtroExecucao} para modem 1 \n" >> ${logFile}
			#sleep ${intervalNextTry}
			sleep 5
			## se Contagem de erro >= maxErrorCountModemSim Notifica Por Email ##
		else
			contagemErro=$((contagemErro+1))
			printf "${horaEnvio} ${filtroExecucao} para modem 1 \n" >> ${logFile}
			sleep ${intervalNextTry}
			## se Contagem de erro >= maxErrorCountModem Notifica Por Email e mata o processo do script ##
			if [ ${contagemErro} -ge ${maxErrorCountModem} ]; then
				## quando a contagem de erro é maxErrorCountModemSim, faz a redundancia ##
				while true; do
					## verifica se o processo sms2 existe ##
					procA=`ps aux | grep sms2.sh | grep -v grep | wc -l`
					## Se o proce sms2 NAO existe, executa ##
					if [ ${procA} -eq 0 ]; then
						## Para o disparaSMS2 ##
						/etc/init.d/SMSD stop
						## Escreve o arquivo de redundancia no disparaSMS2 para nao executar mais ese script ##
						cat /usr/local/bin/redundanciaModem1.sh > /usr/local/bin/disparaSMS.sh
						## Faz update no banco para o disparaSMS2 saber que nao deve mais executar esse script ##
						query "UPDATE dados SET controle = 'x' WHERE voucher = '${voucherSQL}' AND telefone = '${telefoneSQL}';"
						## Escreve o erro no log ##
						printf "${horaEnvio} ${filtroExecucao} mais de 4 erros para modem 1 \n" >> ${logFile}
						printf "================================================ \n" >> ${logFile}
						## Manda o erro por SMS ##
						echo "halia.alergs.br -- O modem 1 esta com problemas" |gammu -c /etc/gammu2.conf --sendsms TEXT 5184011507
						#
						# ALTERAR PARA MANDAR O ERRO POR EMAIL ASSIM QUE POSSIVEL, JA ESTA TESTADO E FUNCIONA PERFEITAMENTE
						#
						#echo "Data/Hora : $(date) --- MSG : "${filtroExecucao} | mail -s "${servidor} - smsGataway (ERRO)" ${emailReport}
						## Inicia novamente o disparaSMS2 ##
						/etc/init.d/SMSD start
						## Sai do script ##
						exit 1
					else
						sleep 5
					fi
				done
			fi
		fi
	else
		## sai do loop ##
		exit 1
	fi
done

