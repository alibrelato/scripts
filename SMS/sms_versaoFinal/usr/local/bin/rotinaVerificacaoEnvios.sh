#!/bin/bash
######################################
######################################
##	Desenvolvido por :				##
##		Alessandro Librelato 		##
##									##
##  OS : DEBIAN Whezzy				##
##	Data : 12/03/2014				##
##	Versao : 2.0					##
##									##
######################################
######################################
#set -x

#######################
## variaveis globais ##
#######################

servidor=$(hostname) ## Nome do servidor
emailReport="dti.rede@al.rs.gov.br" ## Configuracao de e-mail
dia="$(date +%Y-%m-%d)"
##################################
## Definicoes do banco de dados ##
##################################

servidorBanco="172.30.1.15"
usuarioBanco="smsGateway_Halia"
senhaUsuarioBanco="dJi@#!327dwR"
dataBase="smsGateway_Halia"

function query()
	{
	# recebe sql string de fora da function
	QUERY_SQL=${1} 
	# executa o SQL (SED -n 2p retira cabecalho da tabela)
	echo $(echo ${QUERY_SQL} | mysql --host=${servidorBanco} --user=${usuarioBanco} --password=${senhaUsuarioBanco} ${dataBase} | sed -n "2p")
	}

consultaSQL=$(echo $(query "SELECT COUNT(data) FROM dados WHERE DATE(data) = '${dia}';"))
if [[ ${consultaSQL} > 150 ]];then
	
	# DESCOMENTAR ESSA LINHA QUANDO O EMAIL ESTIVER FUNCIONANDO
	
	echo ""Ja foram enviados ${consultaSQL} vocuhers hoje, verifique se nao temos um troller tentando sacanear-nos | mail -s "${servidor} - smsGataway (ALERTA - pouco vouchers)" ${emailReport}

	#
	# deixar report po email assim que possivel, depois que estiver funcionando, pode descomentar a linha de cima e apagar daqui ate o limite a baixo (email ja foi testado e esta funcionando)
	#
#	teste1=$(ps axu | grep sms2.sh | grep -v grep | wc -l)
#	while true; do
#		## Se o sms1 não esta em execucao, entao executa ##
#		if [ ${teste1} -eq 0 ]; then
#			echo "Ja foram enviados ${consultaSQL} vocuhers hoje" |gammu -c /etc/gammu2.conf --sendsms TEXT 5199091414
#			exit 1
#		else
#			sleep 0
#		fi
#	done
		#
		# APAGAR ATE AQUI, DEIXA O FI ALI EM BAIXOA
		#
fi