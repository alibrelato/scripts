#!/bin/bash
######################################
######################################
##  Desenvolvido por :              ##
##  Alessandro Librelato            ##
##  Data : 21/04/2015               ##
##  Versao : 1.0                    ##
######################################
######################################
#set -x

#################
### Variaveis ###
#################
cabecalho="

        -------------------------------------
        -- Powered by Alessandro Librelato --
        -- Date: 21/01/2015                --
        -------------------------------------

          ##       ## ######  ###   ##
           ##     ##  ##   ## ####  ##
            ##   ##   ######  ## ## ##
             ## ##    ##      ##  ####
              ###     ##      ##   ### Admin



"
menu="
    Escolha uma opcao:

    1 - menu 1
    2 - menu 2
    7 - SAIR
"

#########################
### Funcoes do script ###
#########################

# Funcao que monta o menu #
function monta_menu()
	{
	# Escreve o menu na tela #
	echo "$cabecalho"
	echo "$menu"
	echo -n "    Opcao: "
	# Le a opcao desejada pelo usuario #
	read opcao
	# Caso seja a opcao 1 #
	if [ $opcao -eq 1 ]; then
		# Limpa a tela #
		clear
		# Chama o a funcao "menu1" #
		menu1
	# Caso seja a opcao 2 #
	elif [ $opcao -eq 2 ]; then
		# Limpa a tela #
		clear
		# Chama o a funcao "menu2" #
		menu2
	# Caso seja a opcao 7 #
	elif [ $opcao -eq 7 ];then
		# Limpa a tela #
		clear
		# Escreve o cabecalho na tela e a mensagem de saida #
		echo "$cabecalho"
		echo "    Ate logo"
		echo
		echo
		# Sai do script #
		exit 0
	# Se o usuario digitar uma opcao invalida #
	else
		# Limpa a tela #
		clear
		# Chama o a funcao "menu_invalido" #
		menu_invalido
	fi
	}
# Funcao "menu1" #
function menu1()
	{
	# Escreve o cabecalho e a mensagem desejada na tela  #
	echo "$cabecalho"
	echo "    voce entrou no menu 1"
	# Faz uma pausa de 3 segundos #
	sleep 3
	# Limpa a tela #
	clear
	# Chama a funcao "monta_menu" #
	monta_menu
	}
# Funcao "menu2" #
function menu2() 
	{
	# Escreve o cabecalho e a mensagem desejada na tela  #
	echo "$cabecalho"
	echo "    voce entrou no menu 2"
	# Faz uma pausa de 3 segundos #
	sleep 3
	# Limpa a tela #
	clear
	# Chama a funcao "monta_menu" #
	monta_menu
	}
# Funcao "menu_invalido" #
function menu_invalido()
	{
	# Escreve o cabecalho e a mensagem desejada na tela  #
	echo "$cabecalho"
	echo "    Opcao invalida"
	# Faz uma pausa de 3 segundos #
	sleep 3
	# Limpa a tela #
	clear
	# Chama a funcao "monta_menu" #
	monta_menu
	}

# Limpa tudo o que tem na tela para montar o menu #
clear
# Quando o script inicia, chama a funcao "monta_menu" #
monta_menu