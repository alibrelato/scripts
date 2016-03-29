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

#PATH=$PATH:$ORACLE_HOME/bin:.;                     export PATH

#Exporta o binario php correto
PATH=$PATH:/usr/local/bin;			   export PATH

cd /srv/www/htdocs/botsb/updates

/usr/bin/php -f atualizaArquivos.php 


