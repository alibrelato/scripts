#!/bin/bash
# Faz backup para o NetBackup, 
# politica FS_MYSQL_ISMENIA, 
# schedule Full_Diario ou full_Mensal_Cofre, 
# a partir das 04hs
set -x
date
sched=$1

data=`date '+%d%m%Y'`
nome1="SQL.dump.Ismenia"
nome2="SQL.dump.Temis"
caminho="/var/lib/mysql/BKP"

# Apaga o arquivo de backup feito no dia anterior
rm ${caminho}/${nome1}.*.gz
rm ${caminho}/${nome2}.*.gz

# Faz dump do banco de dados e comprime on-the-fly
/usr/bin/mysqldump -u admbkp -psgrela --all-databases --skip-lock-tables | gzip >${caminho}/${nome1}.${data}.gz
date
# Precisa de autorizacao via SSH para fazer a conexao direta
ssh root@temis "/usr/bin/mysqldump  -u rtuser -prtdbadm --all-databases --skip-lock-tables | gzip" >${caminho}/${nome2}.${data}.gz
date


