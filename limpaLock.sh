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

### verificar esses arquivos para o WWW ###
#/usr/local/apache/htdocs/portal/shellscript/exec_Daemon_BotSB.ctl
#
#/usr/local/apache/htdocs/portal/shellscript/exec_Exportador_BotSB.sh
#/usr/local/apache/htdocs/portal/shellscript/exec_Exportador_BotSB.ctl
#
#/usr/local/apache/htdocs/portal/shellscript/exec_Clean_process_BotSB.sh
#/usr/local/apache/htdocs/portal/shellscript/exec_Clean_process_BotSB.ctl
#
#/usr/local/apache/htdocs/portal/shellscript/limpar_atvdvarj/limpar_atvdvarj.sh
#/usr/local/apache/htdocs/portal/shellscript/limpar_atvdvarj/limpar_atvdvarj.ctl
###
### NEWWDB
# /products/scripts/ativo.ctl


hostname=`hostname`
log=/tmp/limpaLock.log
data=`date "+%d/%m/%Y %H:%M:%S"`
email="alphatec@shoppingbrasil.com.br"
listaArquivos=( `echo "
/home/redimagem/imgs_digitalizacao/controle.txt
/home/interconect/imgs_digitalizacao/controle.txt
/data0/sb_digitalizacao/imgs_digitalizacao/controle.txt
/home/argentina/imgs_digitalizacao/controle.txt
/home/belohorizonte/imgs_digitalizacao/controle.txt
/home/brasilia/imgs_digitalizacao/controle.tx
/home/goiania/imgs_digitalizacao/controle.txt
/home/manaus/imgs_digitalizacao/controle.txt
/home/recife/imgs_digitalizacao/controle.txt
/home/riodejaneiro/imgs_digitalizacao/controle.txt
/home/monitora1/imgs_digitalizacao/controle.txt
/home/monitora2/imgs_digitalizacao/controle.txt
/home/monitora3/imgs_digitalizacao/controle.txt
/home/monitora-cdmp/imgs_digitalizacao/controle.txt
/data_media/ftp/home/centrodigi016/imgs_digitalizacao/controle.txt
/usr/local/apache/htdocs/portal/modules/integracoes/clientes/administracao_sb/ativo.ctl
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