#!/bin/sh
#####################################################
### Criado por Alessandro Librelato em 02/03/2015 ###
#####################################################################
# OBSERVACOES                                                       #
# Esse script deve estar em /etc/rc.d/                              #
# Configurado na inicialização do SO "chkconfig limpaLock.sh on"    #
# Script para limpar os arquivos de controle na inicializacao do SO #
#####################################################################
#set -x

### VARIAVEIS DE AMBIENTE ###

hostname=`hostname`
log=/tmp/limpaLock.log
data=`date "+%d/%m/%Y %H:%M:%S"`
email="email@dominio"
listaArquivos=( `echo "
/home/controle.txt
/home/ativo.ctl
"` )

### INICIO ###

# Se o arquivo de log ja existe, deleta #
if [ -e $log ]; then
        rm -f $log
fi
# Escrita no log #
echo "Inicialização do servidor $hostname em $data " >> $log
echo "----------------------------------------------------" >> $log
echo "" >> $log
echo "Arquivos verificados" >> $log
echo "" >> $log
# Le linha a linha da lista de arquivos #
for arquivo in "${listaArquivos[@]}"; do
    # Se o arquivo existe, deleta
    if [ -e $arquivo ]; then
        rm -f $arquivo
        echo  "$arquivo (DELETADO)" >> $log
    # Se nao, apenas escreve no log #
    else
        echo  "$arquivo (NÃO ENCONTRADO)" >> $log
    fi
done
# Manda o log por email #
echo "Segue em anexo o log de limpesa na inicializacao do servidor $hostname." | mail -s "Inicializacao do servidor $hostname em $data" -a $log $email
# Remove o log #
rm -f $log
exit 0
