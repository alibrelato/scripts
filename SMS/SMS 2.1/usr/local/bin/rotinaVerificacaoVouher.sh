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
emailReport="alessandro.librelato@terc.al.rs.gov.br" ## Configuracao de e-mail

##################################
## Definicoes do banco de dados ##
##################################

servidorBanco="172.30.1.15"
usuarioBanco="smsuser"
senhaUsuarioBanco="sgrela"
dataBase="smsGateway_Halia"

function query()
	{
	# recebe sql string de fora da function
	QUERY_SQL=${1} 
	# executa o SQL (SED -n 2p retira cabecalho da tabela)
	echo $(echo ${QUERY_SQL} | mysql --host=${servidorBanco} --user=${usuarioBanco} --password=${senhaUsuarioBanco} ${dataBase} | sed -n "2p")
	}

consultaSQL=$(echo $(query "SELECT COUNT(telefone) FROM dados WHERE telefone = '';"))
if [[ ${consultaSQL} < 500 ]];then
	
	# DESCOMENTAR ESSA LINHA QUANDO O EMAIL ESTIVER FUNCIONANDO
	#echo ""Favor inserir mais vouchers no sistema de auto-atendimento da rede sem fio, para fazer isso, basta acessar http://halia.alergs.br/upload utilizando o login de rede. Temos apenas ${consultaSQL} vouchers para enviar. | mail -s "${servidor} - smsGataway (ALERTA - pouco vouchers)" ${emailReport}

	#
	# deixar report po email assim que possivel, depois que estiver funcionando, pode descomentar a linha de cima e apagar daqui ate o limite a baixo (email ja foi testado e esta funcionando)
	#
	teste1=$(ps axu | grep sms2.sh | grep -v grep | wc -l)
	while true; do
		## Se o sms1 não esta em execucao, entao executa ##
		if [ ${teste1} -eq 0 ]; then
			echo "Favor inserir mais vouchers no sistema de auto-atendimento da rede sem fio, http://halia.alergs.br/upload Temos apenas ${consultaSQL} vouchers para enviar." |gammu -c /etc/gammu2.conf --sendsms TEXT 5199091414
			exit 1
		else
			sleep 0
		fi
	done
		#
		# APAGAR ATE AQUI, DEIXA O FI ALI EM BAIXOA
		#
fi