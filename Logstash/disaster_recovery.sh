#!/bin/bash -x

#set -x

## VARIÁVEIS
DATA=`date +%d%m%Y`
ONTEM=`date -d yesterday +%d%m%Y`
HOSTNAME=`uname -n`
DIRLOG1=/var/log
#DIRLOG2=COLOQUE AQUI O SEGUNDO DIRETORIO PARA BACKUP
#DIRLOG3=COLOQUE AQUI O TERCEIRO DIRETORIO PARA BACKUP

# MONTA PARTIÇÃO DO FEDRA
mount -t smbfs -o username="backup.service",password='backsrv!@06M' '//fedra/e$' /mnt_dr


#############################################################################
### COPIA INFORMAÇÕES REFERENTES À CONFIGURAÇÕES E APLICAÇÕES DO SERVIDOR ###
#############################################################################

cd /tmp/

## GERA LISTA DE APLICAÇÕES SOMENTE SE FOR DE DEBIAN 
dpkg -l>dpkg_list.txt
dpkg --get-selections >dpkg_get_selections.txt


## COPIA CONFIGURAÇÕES DA CRONTAB
cat /etc/crontab > Crontab.txt 


## COPIA INIT.D
tar cvf etc_init.tar /etc/init.d

## COPIA SCRIPTS DO /usr/local/bin
tar cvf Usr_local_bin.tar /usr/local/bin


## GERA ARQUIVO COM INFORMAÇÃO DE VERSÕES DO KERNEL, VERSÃO DO SERVIDOR DEBIAN (NÃO APLICÁVEL À OUTRAS DISTROS) e PARTICIONAMENTO
uname -a >sistema.txt
df >>sistema.txt
more /etc/debian_version >>sistema.txt


## JUNTA TODOS OS ARQUIVOS EM UM SÓ E REMOVE OS DEMAIS
tar czvf /mnt_dr/bkplinux/${HOSTNAME}/DisasterRecovery_$DATA.tgz dpkg_list.txt dpkg_get_selections.txt Crontab.txt etc_init.tar sistema.txt Usr_local_bin.tar
rm dpkg_list.txt dpkg_get_selections.txt Crontab.txt etc_init.tar sistema.txt Usr_local_bin.tar


## VERIFICA SE EXISTE DIRETÓRIO PARA MONTAR FEDRA E MOVE OS ARQUIVOS PARA FEDRA
if [ ! -d /mnt_dr ] ; then
        mkdir /mnt_dr
fi


#########################################################
#### FAZ BACKUP DE TODO O DIRETÓRIO DE LOGS - INICIO ####
#########################################################

## FAZ BACKUP SOMENTE DOS LOGS DE UM PERIODO DE TEMPO ESCOLHIDO (-mtime -X)
find /var/log/* -mtime -2 | tar -zcvf /mnt_dr/bkplinux/${HOSTNAME}/BkpLog-Geral-${HOSTNAME}-${ONTEM}.tgz -T -


######################################################
#### MONTA A PARTIÇÃO DO FEDRA E MOVE OS ARQUIVOS ####
######################################################

# SE NÃO EXISTIR DIRETÓRIO DO SERVIDOR NO FEDRA ELE CRIA
if [ ! -d /mnt_dr/bkplinux/`uname -n` ] ; then
        mkdir /mnt_dr/bkplinux/`uname -n`
fi


### DESMONTA /MNT_DR
umount /mnt_dr


