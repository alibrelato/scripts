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

### Variaveis do ambiente ###

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

### Funcoes do script INICIO ###

# Funcao que monta o menu #
function monta_menu()
	{
		# Monta o cabecalho, menu e le a opcao digitada pelo usuario #
		echo "${cabecalho}"
		echo "${menu}"
		echo -n "    Opcao: "
		read opcao
		# Caso o usuario digite a opcao 1 #
		if [ ${opcao} -eq 1 ]; then
			# Limpa a tela e chama a funcao menu1 #
			clear
			menu1
		# Caso o usuario digite a opcao 2 #
		elif [ ${opcao} -eq 2 ]; then
			# Limpa a tela e chama a funcao menu2 #
			clear
			menu2
		# Caso o usuario digite a opcao 7 #
		elif [ ${opcao} -eq 7 ];then
			# Limpa a tela, monta o cacebalho, exibe a mensagem de saida e sai do script #
			clear
			echo "${cabecalho}"
			echo "    Ate logo"
			echo
			echo
			exit 0
		# Caso o usuario digite uma opcao invalida #
		else
			# Limpa a tela e chama a funcao menu_invalido #
			clear
			menu_invalido
		fi
	}
# Funcao "menu1" #
function menu1()
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "${cabecalho}"
		echo "    voce entrou no menu 1"
		sleep 3
		clear
		monta_menu
	}
# Funcao "menu2" #
function menu2() 
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "${cabecalho}"
		echo "    voce entrou no menu 2"
		sleep 3
		clear
		monta_menu
	}
# Funcao "menu_invalido" #
	function menu_invalido()
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "${cabecalho}"
		echo "    Opcao invalida"
		sleep 3
		clear
		monta_menu
	}
### Funcoes do script FIM ###

# Ao iniciar o script, limpa a tela e chama a funcao monta_menu #
clear
monta_menu