#!/bin/bash
# Variavel para formatar data
data=`date "+%d-%m-%Y"`
# Variavel que define o destino do armazenamento do backup
destino="/backup/bancos"
# Configuracao Servidor MySQL
mysqluser="root" #Usei o root para realizar o bkp de todos os bancos
mysqlpass="senha"
mysqlhost="localhost"
mysqlport="3306"
mysqlcharset="utf8"

# Variavel para contar o numero de backups
contador=`cat $destino/contador`

#Listando todos os Bancos
echo "show databases;" | mysql --user=$mysqluser --password=$mysqlpass --host=$mysqlhost | grep -v Database > $destino/bancos.txt
# Lendo arquivo gerado com todas as bases do Servidor
bancos=( `cat "$destino/bancos.txt" `)

#Quantidade de dias para manter
qtde=5
incluir=$(($contador+1))
excluir=$(($contador-$qtde))

# Corpo do log para envio de e-mail
/bin/echo "To: junior@sirius.com.br " > $destino/backup.log
/bin/echo "Subject: Rotina de Backup J&J" $data >> $destino/backup.log
/bin/echo "" >> $destino/backup.log
/bin/echo "=============================================" >> $destino/backup.log
/bin/echo "Inicio do Backup " >> $destino/backup.log
/bin/echo `date` >> $destino/backup.log

# Incrementa Variavel do Contador
/bin/echo $incluir > $destino/contador

# Exclui o diretorio de backup antigo
cd $destino
arquivoexcluir=*_$excluir
rm -rf $arquivoexcluir

# Cria o novo diretorio
arquivoincluir=$data"_"$incluir
/bin/mkdir -p $destino/$arquivoincluir

# Backup com mysqldump
cd $destino/$arquivoincluir
for banco in "${bancos[@]}"
do
mysqldump --user=$mysqluser --password=$mysqlpass --host=$mysqlhost $banco > backup_$(echo $banco)_$arquivoincluir.sql
done

# Compacta a copia de backup
cd $destino/$arquivoincluir
for banco in "${bancos[@]}"
do
tar zcfP backup_$(echo $banco)_$arquivoincluir.tgz backup_$(echo $banco)_$arquivoincluir.sql > /dev/null
done
/bin/echo "Final do Backup " >> $destino/backup.log
/bin/echo `date` >> $destino/backup.log
/bin/echo "Nome do arquivo" >> $destino/backup.log
for banco in "${bancos[@]}"
do
/bin/echo $destino/$arquivoincluir/backup_$(echo $banco)_$arquivoincluir.tgz >> $destino/backup.log
done
/bin/echo "Volume copiado para Backup" >> $destino/backup.log
for banco in "${bancos[@]}"
do
/bin/echo `du -sh $destino/$arquivoincluir/backup_$(echo $banco)_$arquivoincluir.tgz` >> $destino/backup.log
done
/bin/echo "==============================================" >> $destino/backup.log

## Removendo os arquivos desnecessários
rm $destino/$arquivoincluir/*.sql
rm $destino/bancos.txt
### Envia e-mail do Backup ###
sendmail email@email.com.br < $destino/backup.log