############################################
## Por Alessandro Librelato em 05.02.2013 ##
############################################

#!/bin/bash

##########################
## Variaveis do sistema ##
##########################

USER=rtuser
PASSWORD=rtdbadm
DBHOST=localhost
LOGFILE=./mysql_check.log
MAILTO=alessandro.librelato@terc.al.rs.gov.br
TYPE1= # para parametros extras
TYPE2= 
CORRUPT=no # assume que corrupt e no quando inicia
DBNAMES="rt3" #nome do banco
DBEXCLUDE="" # lista tabelas a serem verificadas no caso de "" sao todas

##########################
## Redirecionamento I/O ##
##########################

touch $LOGFILE 
exec 6>&1
exec > $LOGFILE	 # stdout redirecionado para $LOGFILE

echo -n "Logfile: "
date
echo "---------------------------------------------------------"
echo

#########################
## Para enfeitar o Log ##
#########################

for i in $DBNAMES
do 
echo ""
echo "Database: $i"
echo "---------------------------------------------------------"

###########################################################################
## Captura para variavel DBTALBES quais as tabelas devem ser verificadas ##
###########################################################################

DBTABLES=`mysql -u$USER -p$PASSWORD information_schema -s -N -e "SELECT TABLE_NAME  FROM TABLES WHERE TABLE_TYPE = 'BASE TABLE'"`


for i in $DBEXCLUDE
do
DBTABLES=`echo $DBTABLES | sed "s/\b$i\b//g"`
done

###########################################################
## verifica e otimiza as tabelas verificadas em DBTABLES ##
###########################################################

for j in $DBTABLES
do
echo "CHECK TABLE $j $TYPE1 $TYPE2" | mysql -u$USER -p$PASSWORD $i --verbose
echo "OPTIMIZE TABLE $j $TYPE1 $TYPE2" | mysql -u$USER -p$PASSWORD $i --verbose
done
echo ""
done

exec 1>&6 6>&-	 # Restore stdout and close file descriptor #6

##############################################################################
## Testa se o log tem o status corrupt, verificado anteriormente pelo banco ##
##############################################################################

for i in `cat $LOGFILE`
do
if test $i = "warning" ; then
CORRUPT=yes
elif test $i = "error" ; then
CORRUPT=yes
fi
done

####################################
## Manda email conforme resultado ##
####################################

if test $CORRUPT = "yes" ; then
cat $LOGFILE | mail -s "Banco de dados RT [ERRO ENCONTRADO] para $HOSTNAME - `date`" $MAILTO
else
cat $LOGFILE | mail -s "Banco de dados RT [TUDO OK] parar $HOSTNAME - `date`" $MAILTO
fi
