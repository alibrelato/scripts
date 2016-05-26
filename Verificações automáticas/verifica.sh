#!/bin/bash
######################################
######################################
##  Desenvolvido por:               ##
##  Alessandro Librelato            ##
##  Data : 22/05/2015               ##
##  Versao : 1.0                    ##
######################################
######################################
#set -x

### Variaveis globais do ambiente ###
data=`date "+%d-%m-%Y"`
hostName=`hostname`
log=/var/log/verificacao.log
mailTo="email@dominio"
messages=/var/log/messages
caminhoOcfs2=/etc/rc.d/ocfs2

##############
### INICIO ###
##############

# Se o arquivo de log ja existe, tenta deletar #
if [ -e $log ]; then
    rm -f $log
    # Caso nao seja possivel deletar o arquivo de log antigo, envia um alerta de erro por e-mail #
    if [ -e $log ]; then
        echo "Nao foi possivel apagar o log $log do servidor $hostName em $data para iniciar a verificacao basica, por favor verifique" | mail -s "ERRO na verificacao do servidor $hostName em $data" $mailTo
        exit 0
    fi
fi
# Apos deletar o log, cria ele denovo #
touch $log
if [ -e $log ]; then
    # Se estiver tudo certo com o log, seguimos adiante #
    echo "" >> $log
    echo "Log de verificacao do servidor $hostName em $data" > $log
    echo "" >> $log
    echo "" >> $log
    #############################
    ### Verifica as particoes ###
    #############################
    echo "===========================================" >> $log
    echo "=                  Disco                  =" >> $log
    echo "===========================================" >> $log
    echo "" >> $log
    df -ah >> $log
    echo "" >> $log
    ##########################
    ### Verifica a memoria ###
    ##########################
    echo "===========================================" >> $log
    echo "=                  Memoria                =" >> $log
    echo "===========================================" >> $log
    echo "" >> $log
    free -m -t >> $log
    echo "" >> $log
    #######################
    ### Verifica o RAID ###
    #######################
    raid=`cat /proc/mdstat | head -n2 | tail -n1 | cut -d: -f2 | awk '{print $1}'`
    # Caso nao exista RAID por software configurado, escreve essa informacao no log #
    if test $raid = "<none>"; then
        echo "===========================================" >> $log
        echo "=                  RAID                   =" >> $log
        echo "===========================================" >> $log
        echo "" >> $log
        echo "O servidor nao tem raid por software configurado" >> $log
        echo "" >> $log
    # Caso exista RAID por software, verifica o status #
    else
        echo "===========================================" >> $log
        echo "=                  RAID                   =" >> $log
        echo "===========================================" >> $log
        echo "" >> $log
        cat /proc/mdstat >> $log
        echo "" >> $log
    fi
    ########################################
    ### Verifica os mapeamentos do OCFS2 ###
    ########################################
    echo "===========================================" >> $log
    echo "=                  OCFS2                  =" >> $log
    echo "===========================================" >> $log
    echo "" >> $log
    # Teste se tem o ocfs no servidor #
    if [ -e $caminhoOcfs2 ]; then
        # Caso tenha o OCFS2 no servidor, testa se tem compartilhamento ativo #
        testeOcfs=`/etc/init.d/ocfs2 status | awk '{print $1}' | head -n1`
        # Se tem compartilhamento ativo, faz a leitura e escreve no log #
        if test "$testeOcfs" = "Configured"; then
        #if [ $testeOcfs ]; then
            /etc/init.d/ocfs2 status >> $log
            echo "" >> $log
        else
            # Caso o serivor tenha OCFS2 instalado mas nao tem nenhum compartilhamento ativo #
            echo "O servidor tem OCFS2 instalado mas nao esta sendo usado" >> $log
            echo "" >> $log
        fi
    # Caso NAO esteja instalado o OCFS2 #
    else
        echo "Servidor sem OCFS2 instalado" >> $log
        echo "" >> $log
    fi
    #######################################
    ### Verificacao dos logs do sistema ###
    #######################################
    # Se o log messages esta ok #
    if [ -e $messages ]; then
        # Verifica Verifica os WARNINGS do messeges #
        echo "===========================================" >> $log
        echo "= Alertas do sistema em /var/log/messeges =" >> $log
        echo "===========================================" >> $log
        echo "" >> $log
        cat $messages | grep WARN >> $log
        echo "" >> $log
        # Verifica Verifica os ERROR do messeges #
        echo "===========================================" >> $log
        echo "=  Erros do sistema em /var/log/messeges  =" >> $log
        echo "===========================================" >> $log
        echo "" >> $log
        cat $messages | grep ERRO >> $log
        echo "" >> $log
        echo "===========================================" >> $log
    # Se o arquivo messages nao esta ok, grava um alerta
    else
        echo "===========================================" >> $log
        echo "=             ALERTA DE ERRO              =" >> $log
        echo "===========================================" >> $log
        echo "O arquivo $messages nao existe, por favor verifique com urgencia" >> $log
        echo "" >> $log
        echo "===========================================" >> $log
    fi
    ##############################
    ### Envia o log por e-mail ###
    ##############################
    echo "Segue em anexo o log de verificacao do servidor $hostName em $data" | mail -s "Verificacao do servidor $hostName em $data" -a $log $mailTo
    exit 0
# Caso o log nao seja criado corretamente, envia um erro por email  #
else
    echo "Nao foi possivel criar o log $log do servidor $hostName em $data para iniciar a verificacao basica, por favor verifique" | mail -s "ERRO na verificacao do servidor $hostName em $data" $mailTo
fi
exit 0
