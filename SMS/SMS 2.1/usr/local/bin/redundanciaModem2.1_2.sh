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

#intervalo entre envios.
# default 0
servidor=$(hostname) ## Nome do servidor
emailReport="alessandro.librelato@terc.al.rs.gov.br" ## Configuracao de e-mail
##################################
## Definicoes do banco de dados ##
##################################

servidorBanco="172.30.1.15"
usuarioBanco="smsuser"
senhaUsuarioBanco="sgrela"
dataBase="smsGateway_Halia"

while true; do

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

dia="$(date +%Y%m%d)"

####################################
##								  ##
## INICIO DO CONTROLE DE TROLLERS ##
##								  ##
####################################

############################################
## Verifica qual voucher deve ser enviado ##
############################################

consultaSQL=$(echo $(query "SELECT voucher,telefone FROM dados WHERE telefone != '' AND status = '' AND controle = '' LIMIT 1;"))
## Retira o numero do voucher da cunsulta SQL ##
voucherSQL=$(echo "${consultaSQL}" | cut -d " " -f 1 | sed "s/ //g" )
## Retira o numero do telefone da cunsulta SQL ##
telefoneSQL=$(echo "${consultaSQL}" | cut -d " " -f 2 | sed "s/ //g" )

query "UPDATE dados SET controle = 'send' WHERE voucher = '${voucherSQL}' AND telefone = '${telefoneSQL}';"

#############################################################################################
## Verfica se tem varios registros para o mesmo numero de telefone e sai limpando o banco  ##
#############################################################################################

consultaSqlTroller=$(echo $(query "SELECT voucher,telefone FROM dados WHERE telefone = '${telefoneSQL}' AND controle = '' LIMIT 1;"))
## Retira o numero do voucher da cunsulta SQL ##
voucherSqlTroller=$(echo "${consultaSqlTroller}" | cut -d " " -f 1 | sed "s/ //g" )
## Retira o numero do telefone da cunsulta SQL ##
telefoneSqlTroller=$(echo "${consultaSqlTroller}" | cut -d " " -f 2 | sed "s/ //g" )

## Enquanto tiver voucher para mandar com o numero repetido, apaga a ultima ocorrencia ##
	while [[ "$telefoneSqlTroller" = "$telefoneSQL" ]];do
		## Limpa o voucher repitido ##
		query "UPDATE dados SET telefone = '', nome = '' , rg = '' WHERE voucher='${voucherSqlTroller}';"
		## Verifica se o troller requisitou vouchers mais de uma vez por segundo ##
		consultaSqlTroller=$(echo $(query "SELECT voucher,telefone FROM dados WHERE telefone = '${telefoneSQL}' AND controle = '' LIMIT 1;"))
		## Retira o numero do voucher da cunsulta SQL ##
		voucherSqlTroller=$(echo "${consultaSqlTroller}" | cut -d " " -f 1 | sed "s/ //g" )
		## Retira o numero do telefone da cunsulta SQL ##
		telefoneSqlTroller=$(echo "${consultaSqlTroller}" | cut -d " " -f 2 | sed "s/ //g" )
	done

query "UPDATE dados SET controle = '' WHERE voucher = '${voucherSQL}' AND telefone = '${telefoneSQL}';"

###################################################################################################################################
## Para saber se o telefone ja esta cadastrado no banco e se ja solicitou voucher hoje, se solicitou hoje, manda o mesmo voucher ##
###################################################################################################################################

## Para saber se o o numero de telefone ja solicitou um voucher anteriormente (qualquer data) ##
consultaSqlRegistrado=$(echo $(query "SELECT telefone FROM dados WHERE telefone = '${telefoneSQL}' AND controle != ''LIMIT 1;"))
## Retira o numero do telefone da cunsulta SQL ##
telefoneSqlRegistrado=$(echo "${consultaSqlRegistrado}" | cut -d " " -f 1 | sed "s/ //g" )

	## Se o numero ja existe no banco de dados, entao... ##
	if [ ${telefoneSqlRegistrado} ];then
		## consulta se o telefone ja solicitou um voucher no dia de hoje ##
		consultaSqlHoje=$(echo $(query "SELECT telefone,dia FROM dados WHERE telefone = '${telefoneSQL}' AND dia = '${dia}' AND controle != ''LIMIT 1;"))
		## Retira o numero do telefone da cunsulta SQL ##
		telefoneSqlHoje=$(echo "${consultaSqlHoje}" | cut -d " " -f 1 | sed "s/ //g" )
		## Se o numero de telefone que esta solicitando voucher eh igual ao numero de telefone que ja solicoutou voucher hoje, entao... ##
		if [[ "${telefoneSqlHoje}" = "${telefoneSQL}" ]];then
			## Para saber se o o numero de telefone ja solicitou um voucher anteriormente ##
			consultaSqlHoje=$(echo $(query "SELECT voucher,telefone,envios,controle FROM dados WHERE telefone = '${telefoneSQL}' AND dia = '${dia}' AND controle != '';"))
			## Retira o numero do voucher da cunsulta SQL ##
			voucherSqlHoje=$(echo "${consultaSqlHoje}" | cut -d " " -f 1 | sed "s/ //g" )
			## Retira o numero do telefone da cunsulta SQL ##
			telefoneSqlHoje=$(echo "${consultaSqlHoje}" | cut -d " " -f 2 | sed "s/ //g" )
			## Saber quantas vezes o mesmo voucher foi enviado ##
			enviosSqlHoje=$(echo "${consultaSqlHoje}" | cut -d " " -f 3 | sed "s/ //g" )
			## Saber o controle ##
			controleSqlHoje=$(echo "${consultaSqlHoje}" | cut -d " " -f 4 | sed "s/ //g" )
			## Se o controle eh igual a +3, entao... ##
			if [[ ${controleSqlHoje} = '+3' ]];then
				## zera os campos do voucher para ser reutilizado ##
				query "UPDATE dados SET telefone = '', nome = '', rg = '', status = '', envios = '0' WHERE voucher = '${voucherSQL}';"
			fi
			## Se o numero de telefone que esta solicitando voucher eh igual ao numero de telefone que ja solicoutou voucher hoje, entao... ##
			if [[ "${telefoneSqlHoje}" = "${telefoneSQL}" ]];then
				## Se existe telefone para ser enviado (spam), entao... ##
				if [ ${telefoneSQL} ]; then
					## Se a contagem de envio eh menor que 3, entao... ##
					if [[ ${enviosSqlHoje} < 3 ]];then
						## Faz um update para liberar o novo voucher que o usuario pediu para enviar o voucher que o usuario ja havia pedido ##
						query "UPDATE dados SET telefone = '', nome = '', rg = '', status = '', envios = '0' WHERE voucher = '${voucherSQL}';"
						## Faz update no voucher ja enviado para a aplicacao enviar novamente para o usuario ##
						query "UPDATE dados SET status = '', controle = 'x' WHERE voucher = '${voucherSqlHoje}' AND telefone = '${telefoneSqlHoje}';"
					## Se nao a quantidade de voucher enviado eh maior que 3... ##
					else
						## Liberado o voucher requisitado (spam) para ser enviado denovo ##
						query "UPDATE dados SET telefone = '', nome = '', rg = '', status = '',envios = '' WHERE voucher = '${voucherSQL}';"
						## seta o valor de controle para +3 ##
						query "UPDATE dados SET status = '', controle = '+3' WHERE voucher = '${voucherSqlHoje}' AND telefone = '${telefoneSqlHoje}';"
						## Seta o status como enviado ##
						query "UPDATE dados SET status = 'Enviado' WHERE voucher = '${voucherSqlHoje}' AND telefone = '${telefoneSqlHoje}';"
						## Manda e-mail para o ADM ##
					##	echo "Data/Hora : $(date) --- MSG : O numero "${telefoneSQL} fez mais de tres solicitacoes de vouchers | mail -s "${servidor} - smsGataway (WARNING)" ${emailReport}
					fi
				fi
			fi
		else
			## Se nao, marca o voucher para ser enviado, pois o telefone solicitante ainda nao solicitou voucher hoje ##
			query "UPDATE dados SET controle = 'x' WHERE voucher = '${voucherSQL}' AND telefone = '${telefoneSQL}';"
		fi
	else
		## Se o telefone ainda nao existe no banco de dados, marca o voucher para ser enviado ##
		query "UPDATE dados SET controle = 'x' WHERE voucher = '${voucherSQL}' AND telefone = '${telefoneSQL}';"
	fi

#################################
##							   ##
## FIM DO CONTROLE DE TROLLERS ##
##							   ##
#################################

####################################################
## Verifica qual voucher deve ser enviado e envia ##
####################################################

## Testa se o processo sms1 ou sms2 estao em execucao ##
teste1=$(ps axu | grep sms1.sh | grep -v grep | wc -l)
#teste2=$(ps axu | grep sms2.sh | grep -v grep | wc -l)
	
	## Se o sms1 não esta em execucao, entao executa ##
	if [ ${teste1} -eq 0 ]; then
		## Captura o voucher que tem o campo controle setado com 'x' ##
		consultaSqlModemA=$(echo $(query "SELECT voucher,telefone FROM dados WHERE telefone != '' AND status = '' AND controle = 'x' LIMIT 1;"))
		## Retira o numero do voucher da cunsulta SQL ##
		voucherSqlModemA=$(echo "${consultaSqlModemA}" | cut -d " " -f 1 | sed "s/ //g" )
		## Retira o numero do telefone da cunsulta SQL ##
		telefoneSqlModemA=$(echo "${consultaSqlModemA}" | cut -d " " -f 2 | sed "s/ //g" )
		## Se existe um nomero de voucher e numero de telefone, executa ##
		if [ ! -z ${voucherSqlModemA} ] && [ ! -z ${telefoneSqlModemA} ]; then
			## faz update do campo controle para alterar de 'x' para '1' ##
			query "UPDATE dados SET controle = '1' WHERE voucher = '${voucherSqlModemA}' AND telefone = '${telefoneSqlModemA}';"
			## chama o scrip responsavem pelo modem 1 que vai verificar qual controle=1 para enviar o sms ##
			exec sms1.sh > /dev/null 2>&1 &
		fi
#	## Se o sms2 não esta em execucao, entao executa ##
#	elif [ ${teste2} -eq 0 ]; then
#		## Captura o voucher que tem o campo controle setado com 'x' ##
#		consultaSqlModemB=$(echo $(query "SELECT voucher,telefone FROM dados WHERE telefone != '' AND status = '' AND controle = 'x' LIMIT 1;"))
#		## Retira o numero do voucher da cunsulta SQL ##
#		voucherSqlModemB=$(echo "${consultaSqlModemB}" | cut -d " " -f 1 | sed "s/ //g" )
#		## Retira o numero do telefone da cunsulta SQL ##
#		telefoneSqlModemB=$(echo "${consultaSqlModemB}" | cut -d " " -f 2 | sed "s/ //g" )
#		## Se existe um nomero de voucher e numero de telefone, executa ##
#		if [ ! -z ${voucherSqlModemB} ] && [ ! -z ${telefoneSqlModemB} ]; then
#			## faz update do campo controle para alterar de 'x' para '2' ##
#			query "UPDATE dados SET controle = '2' WHERE voucher = '${voucherSqlModemB}' AND telefone = '${telefoneSqlModemB}';"
#			## chama o scrip responsavem pelo modem 1 que vai verificar qual controle=2 para enviar o sms ##
#			exec sms2.sh > /dev/null 2>&1 &
#		fi
	else
		sleep 0
	fi
done
