#!/bin/bash
############################################
## Por Alessandro Librelato em 08.04.2013 ##
############################################
## Versao 1.0 ##
################

##########################
## Variaveis do sistema ##
##########################

USER='usuario' #usuaro do banco
PASSWORD='senha' #senha do banco
DBHOST=localhost #onde esta o banco
LOGFILE=/opt/rt3/var/log/mysql_check.log #log
#MAILTO="dti.rede@al.rs.gov.br \ -c henrique.knorre@terc.al.rs.gov.br" #email com copia
MAILTO="email@dominio \ -c email@dominio" #email com copia
CORRUPT=no # assume que corrupt e no quando inicia
DBNAMES="nomeDoBanco" #nome do banco
DBTABLECONNECT="information_schema" #qual banco vai ser usada para conectar
DBTABLES="information_schema.tables" #de onde eh pega a lista de batelas

## Redirecionamento I/O ##
touch $LOGFILE 
exec 6>&1
exec > $LOGFILE	 # stdout redirecionado para $LOGFILE

## Cabecalho do log ##
echo -n "Logfile: "
date
echo "---------------------------------------------------------"
echo
for i in $DBNAMES; do 
	echo ""
	echo "Database: $i"
	echo "---------------------------------------------------------"
	# Caso o arquivo /tmp/dblista.txt exista, ele deve ser deletado antes do script rodar #
	if [ -e /tmp/dblista.txt ]; then
		rm -f /tmp/dblista.txt
	fi
	# Verifica as tabelmas e monta o comando sql check dentro do arquivo /tmp/dblista.txt #
	mysql -u$USER -p$PASSWORD $DBTABLECONNECT -s -N -e "select concat('check table ', table_name, ';') as cmdcheck from $DBTABLES where table_schema='$DBNAMES' and table_type = 'BASE TABLE';" > /tmp/dblista.txt
	# Verifica as tabelmas e concatena o comando sql optimize dentro do arquivo /tmp/dblista.txt #
	mysql -u$USER -p$PASSWORD $DBTABLECONNECT -s -N -e "select concat('optimize table ', table_name, ';') as cmdcheck from $DBTABLES where table_schema='$DBNAMES' and table_type = 'BASE TABLE';" >> /tmp/dblista.txt
	# Se o arquivo /tmp/dblista.txt existe, adiciona a frase abaixo no log e segue a execucao do script #
	if [ -e /tmp/dblista.txt ]; then
		echo ""
		echo ""
		echo "O aquivo /tmp/dblista.txt com os comandos SQL a serem executados foi criado com sucesso"
		echo "---------------------------------------------------------"
		echo ""
	# se o arquivo nao existe, adiciona a frase abaixo no log, manda email com o log e sai do script #
	else
		echo ""
		echo "O arquivo /tmp/dblista.txt com os comandos SQL a serem executados nao foi criado, o script nao foi executado corretamente"
		echo "---------------------------------------------------------"
		cat $LOGFILE | mail -s "Banco de dados RT [ERRO ENCONTRADO] para $HOSTNAME - `date`" $MAILTO
		exit 0
	fi
	# Executa os comandos sql que estao dentro do arquivo /tmp/dblista.txt #
	mysql -u$USER -p$PASSWORD $DBNAMES  < /tmp/dblista.txt --verbose
	echo ""
done
# Deleta o arquivo /tmp/dblista.txt #
rm -f /tmp/dblista.txt
# Restaura stdout e fecha o arquivo #
exec 1>&6 6>&-
# Testa se o log tem o status corrupt, verificado anteriormente #
for i in `cat $LOGFILE`; do
	if test $i = "warning"; then
		CORRUPT=yes
	elif test $i = "error"; then
		CORRUPT=yes
	fi
done
# Manda email conforme resultado #
if test $CORRUPT = "yes" ; then
	cat $LOGFILE | mail -s "Banco de dados RT [ERRO ENCONTRADO] para $HOSTNAME - `date`" $MAILTO
else
	cat $LOGFILE | mail -s "Banco de dados RT [TUDO OK] parar $HOSTNAME - `date`" $MAILTO
fi
exit 0
