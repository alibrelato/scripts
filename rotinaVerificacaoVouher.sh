#!/bin/bash
######################################
######################################
##	Desenvolvido por :				##
##		Alessandro Librelato 		##
##									##
##  OS : DEBIAN Whezzy				##
##	Data : 12/03/2014				##
##	Versao : 1.0					##
##									##
######################################
######################################
#set -x

#######################
## variaveis globais ##
#######################

servidor=$(hostname) ## Nome do servidor
emailReport="dti.rede@al.rs.gov.br" ## Configuracao de e-mail

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

consultaSQL=$(echo $(query "SELECT COUNT(telefone) FROM dados WHERE telefone = '';"))
if [[ ${consultaSQL} -eq 200 ]];then
	# Se tiver menos do que 200 voucher da rede wi-fi para enviar, faz um report por e-mail
	echo ""Favor inserir mais vouchers no sistema de auto-atendimento da rede sem fio, para fazer isso, basta acessar http://halia.alergs.br/upload utilizando o login de rede admin. Temos apenas ${consultaSQL} vouchers para enviar. | mail -s "${servidor} - smsGataway (ALERTA - poucos vouchers)" ${emailReport}
fi
