#!/bin/sh
#set -x
######################################
######################################
##  Desenvolvido por :              ##
##  Alessandro Librelato            ##
##  Data : 16/03/2016               ##
##  Versao : 1.0                    ##
######################################
######################################

## Descrissao: Script para fazer consulta em massa no servidor de DNS ##

## IMPORTANTE ##
## O arquivo com a lista dos ips a ser consultado deve existir ##
 
## Variaveis de ambiente ##
log=/home/alessandro.librelato/dns.log
listaIp=/home/alessandro.librelato/listaIp.txt
listaDns=/home/alessandro.librelato/listaEntradas.txt
diretorioDns=/etc/namedb
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
        if [ -e $log ]; then
            rm -f $log
            echo
            echo -e "        Log antigo apagado com sucesso......................[\e[32;2m OK \e[m]"
        else
            echo
            echo -e "        Log antigo nao precisa ser apagado..................[\e[32;2m OK \e[m]"
        fi
        # Se o arquivo listaEntradas.txt ja existe, deleta #
        if [ -e $listaDns ]; then
            rm -f $listaDns
            echo -e "        Lista de entradas antiga apagada com sucesso........[\e[32;2m OK \e[m]"
        else
            echo -e "        Lista de entradas antiga............................[\e[32;2m OK \e[m]"
        fi
        # Verifica se o arquivo com a lista de IPs esta vazio #
        if [ -s $listaIp ]; then
            echo -e "        Preenchimento da lista de ips a ser consultado......[\e[32;2m OK \e[m]";echo
            sleep 5
        else
            clear
            echo;echo
            echo -e "\e[31;2m        ATENCAO \e[m";echo
            echo -e "        O arquivo \e[31;2m$listaIp\e[m esta vazio";echo
            echo "        Saindo...";echo
            exit 0
        fi
        # Le linha a linha da lista de IPs #
        while read ip; do
            # Escreve o IP a ser consultado no log #
            echo "consultando o ip $ip"
            echo "$ip" >> $log
            # Escreve o resultado da consulta das entradas no DNS no script #
            grep -r $ip $diretorioDns/* > $listaDns
            # Le linha a linha o resultado da pesquisa no DNS para o ip atual da lista #
            while read line; do
                # Captura o ip atual da lista de DNSs achados #
                leitura=( `echo  "$line" | awk ' { print $4 } '` )
                # Compara se o ip achado na lista de dns eh igual ao ip consultado #
                if [[ $ip = $leitura ]]; then
                    # se  o ip achado na lista de dns eh igual ao ip consultado escreve no log #
                    echo "$line" >> $log
                fi
            done < $listaDns
        done < $listaIp
        # Verifica se o arquivo com as entradas de dns existe para excluir #
        if [ -e $listaDns ]; then
            rm -f $listaDns
        fi
        # Limpa a lista de ips a ser verificado #
        clear
        cat /dev/null > $listaIp
        echo
        echo -e "        Seu log esta em\e[32;2m $log \e[m"
        echo
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