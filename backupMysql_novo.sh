#!/bin/bash
############################################
## Por Alessandro Librelato em 08.04.2013 ##
############################################
## Versao 1.0 ##
################
#set -x

###########################
## VARIAVEIS DE AMBIENTE ##
###########################

data=`date "+%d-%m-%Y"`
destino=/tmp # para onde sera mandado o backup #
log=/tmp/backup.log # onde sera criado o log #
mailTo="email@dominio \ -c email@dominio" # email com copia #
listaBancos=/tmp/bancos.txt # Arquivos onde eh criada a lista com os bancos #
hostName=`hostname` # Captura o nome do host #
## Configuracao Servidor MySQL ##
mysqlUser="usuario" # usuario do banco #
mysqlPass="senha" # senha do banco #
mysqlHost="localhost" # host onde esta o banco #
mysqlPort="3306" # porta de conexao do host remoto #

############
## INICIO ##
############

# Verifica se o arquivo com a lista dos bancos ja existe, se existe deleta ele #
if [ -e ${listaBancos} ]; then
	rm -f ${listaBancos}
fi
# Deleta todos backups antigos #
rm -f ${destino}/*.gz
# Listando todos os bancos que devem ser feito backup e armazena a lista no arquivo de lista de bancos #
echo "show databases;" | mysql --user=${mysqlUser} --password=${mysqlPass} --host=${mysqlHost} | egrep -v 'Database|mysql|information_schema|performance_schema|sys' > ${listaBancos}
# verifica se o arquivo com a lista dos bancos existe #
if [ -e ${listaBancos} ]; then
	# Le o arquivo gerado com todas as bases do Servidor para a variavel bancos #
	bancos=( `cat "${listaBancos}"` )
	# Efetua o backup com mysqldump e compacta as bases lendo a lista de bancos linha a linha #
	for banco in "${bancos[@]}"
	do
		mysqldump --user=${mysqlUser} --password=${mysqlPass} --host=${mysqlHost} ${banco} | gzip > ${destino}/${banco}.${data}.sql.gz
	done
	# Escreve os resultados no log # 
	echo "Final do Backup " >> ${log} ;	echo ${data} >> ${log} ; echo "Volume copiado para Backup" >> ${log} ; echo "" >> ${log}
	# Verifica o tamanho dos bancos feito backup e escreve no log #
	for banco in "${bancos[@]}"
	do
		echo `du -sh ${destino}/$(echo ${banco}.${data}).sql.gz` >> ${log}
	done
	echo "==============================================" >> ${log}; echo "" >> ${log} ; echo "" >> ${log}

	# Removendo os arquivos desnecessários #
	rm -f ${listaBancos}

	# Envia e-mail de sucesso do Backup #
	# cat $log | mail -s "SQL centralizado [BACKUP REALIZADO COM SUCESSO] para $hostName - `date`" $mailTo
	exit 0
else
	# Envia e-mail de erro do Backup #
	echo "" >> ${log} ; echo "O arqquivo com a lista dos bancos nao foi criada corretamente, por favor verifique" >> ${log} ; echo "" >> ${log}
	# cat $log | mail -s "SQL centralizado [ERRO, BACKUP NÃO REALIZADO] para $hostName - `date`" $mailTo
	exit 0
fi
