#!/bin/sh
#set -x
######################################
######################################
##  Desenvolvido por :              ##
##  Alessandro Librelato            ##
##  Data : 29/03/2016               ##
##  Versao : 1.0                    ##
######################################
######################################

## Descrissao: Script para fazer consulta em massa no servidor de DNS ##

## IMPORTANTE ##
## O arquivo com a lista dos ips a ser consultado deve existir ##
 
## Variaveis de ambiente ##
logOnline=/home/alessandro.librelato/online.log
logOffline=/home/alessandro.librelato/offline.log
listaIp=/home/alessandro.librelato/listaIp.txt
menu="

                  -------------------------------------
                  -- Criado por Alessandro Librelato --
                  -- Data: 18/03/2016                --
                  -------------------------------------
\e[32;2m
        Voce criou/preencheu a lista abaixo de IPs '$listaIp' a ser verificado?
    
        Sim / Nao
\e[m
"

##############
### INICIO ###
##############
iniciar()
    {
        # Se o arquivo de log ja existe, deleta #
        if [ -e $logOnline ]; then
            rm -f $logOnline
            echo
            echo -e "        Log1 antigo apagado com sucesso......................[\e[32;2m OK \e[m]"
        else
            echo
            echo -e "        Log1 antigo nao precisa ser apagado..................[\e[32;2m OK \e[m]"
        fi
        if [ -e $logOffline ]; then
            rm -f $logOffline
            echo -e "        Log2 antigo apagado com sucesso......................[\e[32;2m OK \e[m]"
        else
            echo -e "        Log2 antigo nao precisa ser apagado..................[\e[32;2m OK \e[m]"
        fi
        while read line; do
            # Captura o ip atual da lista de DNSs achados #
            leitura=( `ping -w 1 $line | grep "ttl="` )
            # Compara se o ip achado na lista de dns eh igual ao ip consultado #
            if [ $leitura ]; then
                # se  o ip achado na lista de dns eh igual ao ip consultado escreve no log #
                echo "$line" >> $logOnline
                echo "$line online"
            else
                echo "$line" >> $logOffline
                echo "$line offline"
            fi
        done < $listaIp
        clear
        cat /dev/null > $listaIp
        echo
        echo -e "        Seu log de IPs na rede esta em\e[32;2m $logOnline \e[m"
        echo -e "        Seu log de IPs fora da rede esta em\e[32;2m $logOffline \e[m"
        echo;echo
        exit 0
    }
sair()
    {
        clear
        echo
        echo -e "\e[33;2m        O arquivo com a lista de IPs deve estar em $listaIp \e[m"
        echo
        exit 0
    }
#####################################
### Opecoes de operacao do script ###
#####################################
clear
echo -e "$menu";echo;echo
echo -n "Opcao: "
read text1

case "$text1" in
    "sim"|"Sim"|"SIM"|"sIM"|"s"|"S")
        iniciar
    ;;
    "nao"|"Nao"|"NAO"|"nAO"|"n"|"N")
        sair
    ;;
    *)
    clear
    echo
    echo -e "\e[33;2m        OPCAO DESCONHECIDA...TENTE NOVAMENTE.\e[m"
    echo
    exit 0 ;;
esac