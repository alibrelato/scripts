#!/bin/bash
############################################
## Por Alessandro Librelato em 08.04.2013 ##
############################################
## Versao 1.0 ##
################

###########################
## VARIAVEIS DE AMBIENTE ##
###########################

log=/tmp/mysql_check.log #log
mailTo="email@dominio \ -c email@dominio" #email com copia
corrompido=no # assume que corrompido eh no quando inicia
tabelaDeConexao="information_schema" #qual banco vai ser usada para conectar
tabelas="information_schema.tables" #de onde eh pega a lista de batelas
listaBancos=/tmp/bancosCheck.txt #arquivos de lista de banco
comandos=/tmp/dblista.txt #aquivo com a lista de comando a ser executado
hostName=`hostname` # Captura o nome do host #
mysqlUser="usuario" # usuario do banco
mysqlPass="senha" # senha do banco
mysqlHost="localhost" # host onde esta o banco
mysqlPort="3306" # porta para conexao de host remoto

############
## INICIO ##
############

## Redirecionamento I/O para o log ##
touch $log 
exec 6>&1
exec > $log	 # stdout redirecionado para $log
## Cabecalho do log ##
echo -n "log: "
date
echo "---------------------------------------------------------"
# Caso o arquivo com a lista de bacos e comandos existam, ele deve ser deletado antes do script rodar #
if [ -e $comandos ]; then
	rm -f $comandos
fi
if [ -e $listaBancos ]; then
	rm -f $listaBancos
fi
# Pega a lista dos bancos a serem verificados com algumas excecoes
echo "show databases;" | mysql --user=$mysqlUser --password=$mysqlPass --host=$mysqlHost | egrep -v 'Database|mysql|information_schema|performance_schema|sys' > $listaBancos
#Lê a lista de bancos linha a linha e vai executando o check e a otimizacao de cada banco
bancos=( `cat "${listaBancos}"` )
# Backup com mysqldump lendo o arquivo com a lista de bancos linha a linha
for banco in "${bancos[@]}"; do
	echo "============================================================================"
	echo "=============================== BANCO $banco ==============================="
	# Verifica as tabelmas e monta o comando sql check dentro do arquivo com a lista de comandos #
	mysql -u$mysqlUser -p$mysqlPass $tabelaDeConexao -s -N -e "select concat('check table ', table_name, ';') as cmdcheck from $tabelas where table_schema='$banco' and table_type = 'BASE TABLE';" >> $comandos
	# Verifica as tabelmas e concatena o comando sql optimize dentro do arquivo com a lista de comandos #
	mysql -u$mysqlUser -p$mysqlPass $tabelaDeConexao -s -N -e "select concat('optimize table ', table_name, ';') as cmdcheck from $tabelas where table_schema='$banco' and table_type = 'BASE TABLE';" >> $comandos
	# Faz a verificacao e a otimizacao com os comandos dentro de $comandos
	mysql -u$mysqlUser -p$mysqlPass $banco  < $comandos --verbose
done
# Deleta o arquivo os arquivos desnecessarios #
rm -f $comandos
rm -f $listaBancos
# Restaura stdout e fecha o arquivo de log #
exec 1>&6 6>&-
# Testa se o log tem o status corrompido, verificado anteriormente #
for i in `cat $log`; do
	if test $i = "Warning"; then
		corrompido=yes
	elif test $i = "Error"; then
		corrompido=yes
	fi
done
# Manda email conforme resultado #
#if test $corrompido = "yes" ; then
#	cat $log | mail -s "Banco de dados RT [ERRO ENCONTRADO] para $hostName - `date`" $mailTo
#else
#	cat $log | mail -s "Banco de dados RT [TUDO OK] parar $hostName - `date`" $mailTo
#fi
exit 0
