#!/bin/bash
############################################
## Por Alessandro Librelato em 24.04.2014 ##
############################################
## Versao 1.0 ##
################
#set -x

## Variaveis de ambiente
data=`date "+%d-%m-%Y"`
destino=/backup
log=/var/log/mysql/backup.log
mailTo="dti.rede@al.rs.gov.br \ -c alessandro.librelato@terc.al.rs.gov.br" #email com copia
hostName="ismenia"
altServer="temis"
listaBancos=/backup/bancos.txt
## Configuracao Servidor MySQL
mysqlUser="admbkp"
mysqlPass="sgrela"
mysqlHost="localhost"
mysqlPort="3306"

## Verifica se o arquivo /backup/bancos.txt ja existe, se existe deleta ele
if [ -e ${listaBancos} ]; then
	rm ${listaBancos}
fi
## Deleta todos backups antigos
rm ${destino}/*.gz

## Listando todos os Bancos que deve ser feito backup e armazena a lista no arquivo /backup/bancos.txt
echo "show databases;" | mysql --user=${mysqlUser} --password=${mysqlPass} --host=${mysqlHost} | grep -v Database > ${listaBancos}

## Se o arquivo /backup/bancos.txt existe, executa
if [ -e ${listaBancos} ]; then
	## Lendo arquivo gerado com todas as bases do Servidor
	bancos=( `cat "${listaBancos}"` )
	# Backup com mysqldump
	for banco in "${bancos[@]}"
	do
		/usr/bin/mysqldump --user=${mysqlUser} --password=${mysqlPass} --host=${mysqlHost} ${banco} --skip-lock-tables | gzip > ${destino}/${banco}.${data}.sql.gz
	done
	ssh root@temis "/usr/bin/mysqldump  -u rtuser -prtdbadm --all-databases --skip-lock-tables | gzip" > ${destino}/${altServer}.${data}.sql.gz
	
	## Escrita no log /var/log/mysql/backup.log
	/bin/echo "Final do Backup " >> ${log}
	/bin/echo ${data} >> ${log}
	/bin/echo "Volume copiado para Backup" >> ${log}
	/bin/echo "" >> ${log}

	for banco in "${bancos[@]}"
	do
		/bin/echo `du -sh ${destino}/$(echo ${banco}.${data}).sql.gz` >> ${log}
	done
	/bin/echo `du -sh ${destino}/$(echo ${altServer}.${data}).sql.gz` >> ${log}
	/bin/echo "==============================================" >> ${log}
	/bin/echo "" >> ${log}
	/bin/echo "" >> ${log}

	## Removendo os arquivos desnecessários
	rm ${listaBancos}

	### Envia e-mail do Backup ###
	# cat ${log} | mail -s "SQL centralizado [BACKUP REALIZADO COM SUCESSO] para ${hostName} - `date`" ${mailTo}
else
	### Envia e-mail do Backup ###
	# cat ${log} | mail -s "SQL centralizado [ERRO, BACKUP NÃO REALIZADO] para ${hostName} - `date`" ${mailTo}
	exit 0
fi
