#!/bin/sh

# Oracle Environment
LANG=ISO8859-1;                                    export LANG
DISPLAY=:0.0;                                      export DISPLAY
ORACLE_BASE=/opt/oracle;                           export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11gR2/db;         export ORACLE_HOME
ORACLE_SID=shb1;                                   export ORACLE_SID
ORACLE_TERM=xterm;                                 export ORACLE_TERM
NLS_LANG=PORTUGUESE_BRAZIL.WE8ISO8859P1;           export NLS_LANG
NLS_DATE_FORMAT=DD/MM/YYYY;                        export NLS_DATE_FORMAT
NLS_NUMERIC_CHARACTERS=',.';                       export NLS_NUMERIC_CHARACTERS
LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH; export LD_LIBRARY_PATH

# Set shell search paths:


PATH=$PATH:$ORACLE_HOME/bin:.;                     export PATH

#Exporta o binario php correto
PATH=$PATH:/usr/local/bin;			   export PATH

cd /srv/www/htdocs/botsb/motor

if [ ! -f ./exec_Motor_BotSB.ctl ];
then
   echo 'ativo' > /srv/www/htdocs/botsb/shellscript/exec_Motor_BotSB.ctl

   php -f motor.php > /srv/www/htdocs/botsb/shellscript/motor.log
    #SE TEVE BUSCA NAO AGUARDAR MUITO PARA PROXIMA
   VARSIZE=`du /srv/www/htdocs/botsb/shellscript/motor.log -b | cut -f1`
   if [ "$VARSIZE" == "0" ]
    then sleep 180
    else sleep 20
   fi

   php -f motor.php > /srv/www/htdocs/botsb/shellscript/motor.log
    #SE TEVE BUSCA NAO AGUARDAR MUITO PARA PROXIMA
   VARSIZE=`du /srv/www/htdocs/botsb/shellscript/motor.log -b | cut -f1`
   if [ "$VARSIZE" == "0" ]
    then sleep 180
    else sleep 20
   fi

   php -f motor.php > /srv/www/htdocs/botsb/shellscript/motor.log
    #SE TEVE BUSCA NAO AGUARDAR MUITO PARA PROXIMA
   VARSIZE=`du /srv/www/htdocs/botsb/shellscript/motor.log -b | cut -f1`
   if [ "$VARSIZE" == "0" ]
    then sleep 180
    else sleep 20
   fi

   php -f motor.php > /srv/www/htdocs/botsb/shellscript/motor.log
    #SE TEVE BUSCA NAO AGUARDAR MUITO PARA PROXIMA
   VARSIZE=`du /srv/www/htdocs/botsb/shellscript/motor.log -b | cut -f1`
   if [ "$VARSIZE" == "0" ]
    then sleep 180
    else sleep 20
   fi

   php -f motor.php > /srv/www/htdocs/botsb/shellscript/motor.log
    #SE TEVE BUSCA NAO AGUARDAR MUITO PARA PROXIMA
   VARSIZE=`du /srv/www/htdocs/botsb/shellscript/motor.log -b | cut -f1`
   if [ "$VARSIZE" == "0" ]
    then sleep 180
    else sleep 20
   fi

   rm /srv/www/htdocs/botsb/shellscript/exec_Motor_BotSB.ctl
else
   echo 'uma instância já está executando.'
fi

