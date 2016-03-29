#!/bin/sh
#####################################################
### Criado por Alessandro Librelato em 20/03/2015 ###
#####################################################################
# OBSERVACOES                                                       #
# SLES 12                                                           #
#####################################################################
#set -x
## variaveis globais ##
chave="?5bc3650926e7f0c7ef485805725f135153d25d5137743176f0365397681adec894b25c0c6d9784d8d5c81258b2be6b675d80082e4457d838b355b45994851352e3767717c245c806d7fa1f071272021a43a10d08b681498a87"
log=conclusao.log
cabecalho="

        --------------------------------------
        -- Powered by Alessandro Librelato  --
        -- Date: 20/03/2015                 --
        --------------------------------------
          Sitema de download do repositorio
  
         #### #    #####   ####     ##    ###
        #     #    #      #        # #       #
         ###  #    ###     ###       #     ##
            # #    #          #      #    #
        ####  #### #####  ####     #####  ####

                        x86_64

"
menu="
        Voce criou a lista dos repo abaixo?
    
    	- listaNoarch.txt
    	- listaNosrc.txt
    	- listaRepodata.txt
    	- listaSrc.txt
    	- listaX86_64.txt
	
        1 - Sim
        2 - Nao
"

## Inicio ##

function verificarArqvuios()
	{
		echo "${cabecalho}"
		echo "${menu}"
		echo -n "        Opcao: "
		read opcao
		if [ $opcao -eq 1 ]; then
			clear
			# Esse monte de if verificar se os arquivos listaRepo nao estao vazios #
			if [ -s listaNoarch.txt ]; then
				if [ -s listaNosrc.txt ]; then
					if [ -s listaRepodata.txt ]; then
						if [ -s listaSrc.txt ]; then
							if [ -s listaX86_64.txt ]; then
								echo "${cabecalho}"
								echo "        listaNoarch......[ OK ]"
								echo "        listaNosrc.......[ OK ]"
								echo "        listaRepodata....[ OK ]"
								echo "        listaSrc.........[ OK ]"
								echo "        listaX86_64......[ OK ]"
								sleep 4
							else
								clear
								echo "${cabecalho}";echo "        O arquivo listaX86_64.txt esta vazio";echo;echo;echo "        Bye Vini ;-)";echo
								exit 0
							fi
						else
							clear
							echo "${cabecalho}";echo "        O arquivo listaSrc.txt esta vazio";echo;echo;echo "        Bye Vini ;-)";echo
							exit 0
						fi
					else
						clear
						echo "${cabecalho}";echo "        O arquivo listaRepodata.txt esta vazio";echo;echo;echo "        Bye Vini ;-)";echo
						exit 0
					fi
				else
					clear
					echo "${cabecalho}";echo "        O arquivo listaNosrc.txt esta vazio";echo;echo;echo "        Bye Vini ;-)";echo
					exit 0
				fi
			else
				clear
				echo "${cabecalho}";echo "        O arquivo listaNoarch.txt esta vazio";echo;echo;echo "        Bye Vini ;-)";echo
				exit 0
			fi
			cat /dev/null > $log
			clear
			downloadNoarch
		elif [ $opcao -eq 2 ];then
			# Limpa a tela, monta o cacebalho, exibe a mensagem de saida e sai do script #
			clear
			echo "${cabecalho}"
			echo "        Bye Vini ;-)"
			echo
			echo
			exit 0
		# Caso o usuario digite uma opcao invalida #
		else
			# Limpa a tela e chama a funcao menu_invalido #
			clear
			menuInvalido
		fi
	}
function downloadNoarch()
	{
		# variaveis locais #
		siteNoarch="https://updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/noarch"
		listaPacotesNoarch=listaNoarch.txt
		noarch=/tmp/noarch.txt
		destinoNoarch=updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/noarch
		# ---------------- #
		# Cria o diretorio para fazer o download #
		mkdir -p $destinoNoarch
		# Apaga as 4 primeiras linhas da lista geral #
		sed -i 1,4d $listaPacotesNoarch
		# captura apenas o nome dos arquivos a serem baixados #
		cat $listaPacotesNoarch | tr -d '[TXT]' | sed 's/^ \+//' | cut -d " " -f1 | grep -v "Apache/2.2" > $noarch.tmp
		# apaga as linhas em branco para nao dar incosistencia no log #
		awk 'NF>0' $noarch.tmp > $noarch
		# remove o arquivo temporario #
		rm -f $noarch.tmp
		# Carrega a lista de pacotes para dentro de uma variavel #
		arquivos=( `cat "$noarch"` )
		# Lê linha a linha da lista de pacotes para fazer download #
		# Lê linha a linha da lista de pacotes para fazer download #
		for pacote in "${arquivos[@]}"; do
			# Faz download dos pacotes linha a linha ja renomeando o arquivo para o nome certo #
			wget -c $siteNoarch/$pacote$chave -O $destinoNoarch/$pacote
		done
		# verifica quantos arquivos existem na lista de download #
		arquivosLista=`grep -cv '$=' $noarch`
		# verifica quantos arquivos foram baixados #
		arquivosBaixados=`ls $destinoNoarch | wc -l`
		# Escrita no log #
		echo "- noarch -" >> $log
		echo "Total na lista = $arquivosLista" >> $log
		echo "Total baixado  = $arquivosBaixados" >> $log
		echo "------------------------" >> $log
		# remove o segundo arquivo temporario #
		rm -f $noarch
		# apaga o conteudo da lista geral para nao haver futuros enganos #
		cat /dev/null > $listaPacotesNoarch
		# chama o proximo download #
		downloadNosrc
	}
function downloadNosrc()
	{
		# variaveis locais #
		siteNosrc="https://updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/nosrc"
		listaPacotesNosrc=listaNosrc.txt
		nosrc=/tmp/nosrc.txt
		destinoNosrc=updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/nosrc
		# ---------------- #
		# Cria o diretorio para fazer o download #
		mkdir -p $destinoNosrc
		# Apaga as 4 primeiras linhas da lista geral #
		sed -i 1,4d $listaPacotesNosrc
		# captura apenas o nome dos arquivos a serem baixados #
		cat $listaPacotesNosrc | tr -d '[TXT]' | sed 's/^ \+//' | cut -d " " -f1 | grep -v "Apache/2.2" > $nosrc.tmp
		# apaga as linhas em branco para nao dar incosistencia no log #
		awk 'NF>0' $nosrc.tmp > $nosrc
		# remove o arquivo temporario #
		rm -f $nosrc.tmp
		# Carrega a lista de pacotes para dentro de uma variavel #
		arquivos=( `cat "$nosrc"` )
		# Lê linha a linha da lista de pacotes para fazer download #
		for pacote in "${arquivos[@]}"; do
			# Faz download dos pacotes linha a linha ja renomeando o arquivo para o nome certo #
			wget -c $siteNosrc/$pacote$chave -O $destinoNosrc/$pacote
		done
		# verifica quantos arquivos existem na lista de download #
		arquivosLista=`grep -cv '$=' $nosrc`
		# verifica quantos arquivos foram baixados #
		arquivosBaixados=`ls $destinoNosrc | wc -l`
		# Escrita no log #
		echo "- nosrc -" >> $log
		echo "Total na lista = $arquivosLista" >> $log
		echo "Total baixado  = $arquivosBaixados" >> $log
		echo "------------------------" >> $log
		# remove o segundo arquivo temporario #
		rm -f $nosrc
		# apaga o conteudo da lista geral para nao haver futuros enganos #
		cat /dev/null > $listaPacotesNosrc
		# chama o proximo download #
		downloadRepodata
	}
function downloadRepodata()
	{
		# variaveis locais #
		siteRepodata="https://updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/repodata"
		listaPacotesRepodata=listaRepodata.txt
		repodata=repodata.txt
		destinoRepodata=updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/repodata
		# ---------------- #
		# Cria o diretorio para fazer o download #
		mkdir -p $destinoRepodata
		# Apaga as 4 primeiras linhas da lista geral #
		sed -i 1,4d $listaPacotesRepodata
		# captura apenas o nome dos arquivos a serem baixados #
		cat $listaPacotesRepodata | tr -d '[TXT]' | sed 's/^ \+//' | cut -d " " -f1 | grep -v "Apache/2.2" > $repodata.tmp
		# apaga as linhas em branco para nao dar incosistencia no log #
		awk 'NF>0' $repodata.tmp > $repodata
		# remove o arquivo temporario #
		rm -f $repodata.tmp
		# Carrega a lista de pacotes para dentro de uma variavel #
		arquivos=( `cat "$repodata"` )
		# Lê linha a linha da lista de pacotes para fazer download #
		for pacote in "${arquivos[@]}"; do
			# Faz download dos pacotes linha a linha ja renomeando o arquivo para o nome certo #
			wget -c $siteRepodata/$pacote$chave -O $destinoRepodata/$pacote
		done
		# verifica quantos arquivos existem na lista de download #
		arquivosLista=`grep -cv '$=' $repodata`
		# verifica quantos arquivos foram baixados #
		arquivosBaixados=`ls $destinoRepodata | wc -l`
		# Escrita no log #
		echo "- repotada -" >> $log
		echo "Total na lista = $arquivosLista" >> $log
		echo "Total baixado  = $arquivosBaixados" >> $log
		echo "------------------------" >> $log
		# remove o segundo arquivo temporario #
		rm -f $repodata
		# apaga o conteudo da lista geral para nao haver futuros enganos #
		cat /dev/null > $listaPacotesRepodata
		# chama o proximo download #
		downloadSrc
	}
function downloadSrc()
	{
		# variaveis locais #
		siteSrc="https://updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/src"
		listaPacotesSrc=listaSrc.txt
		src=/tmp/src.txt
		destinoSrc=updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/src
		# ---------------- #
		# Cria o diretorio para fazer o download #
		mkdir -p $destinoSrc
		# Apaga as 4 primeiras linhas da lista geral #
		sed -i 1,4d $listaPacotesSrc
		# captura apenas o nome dos arquivos a serem baixados #
		cat $listaPacotesSrc | tr -d '[TXT]' | sed 's/^ \+//' | cut -d " " -f1 | grep -v "Apache/2.2" > $src.tmp
		# apaga as linhas em branco para nao dar incosistencia no log #
		awk 'NF>0' $src.tmp > $src
		# remove o arquivo temporario #
		rm -f $src.tmp
		# Carrega a lista de pacotes para dentro de uma variavel #
		arquivos=( `cat "$src"` )
		# Lê linha a linha da lista de pacotes para fazer download #
		for pacote in "${arquivos[@]}"; do
			# Faz download dos pacotes linha a linha ja renomeando o arquivo para o nome certo #
			wget -c $siteSrc/$pacote$chave -O $destinoSrc/$pacote
		done
		# verifica quantos arquivos existem na lista de download #
		arquivosLista=`grep -cv '$=' $src`
		# verifica quantos arquivos foram baixados #
		arquivosBaixados=`ls $destinoSrc | wc -l`
		# Escrita no log #
		echo "- src -" >> $log
		echo "Total na lista = $arquivosLista" >> $log
		echo "Total baixado  = $arquivosBaixados" >> $log
		echo "------------------------" >> $log
		# remove o segundo arquivo temporario #
		rm -f $src
		# apaga o conteudo da lista geral para nao haver futuros enganos #
		cat /dev/null > $listaPacotesSrc
		# chama o proximo download #
		downloadX86_64
	}
function downloadX86_64()
	{
		# variaveis locais #
		siteX86_64="https://updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/x86_64"
		listaPacotesX86_64=listaX86_64.txt
		x86_64=/tmp/x86_64.txt
		destinoX86_64=updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/x86_64
		# ---------------- #
		# Cria o diretorio para fazer o download #
		mkdir -p $destinoX86_64
		# Apaga as 4 primeiras linhas da lista geral #
		sed -i 1,4d $listaPacotesX86_64
		# captura apenas o nome dos arquivos a serem baixados #
		cat $listaPacotesX86_64 | tr -d '[TXT]' | sed 's/^ \+//' | cut -d " " -f1 | grep -v "Apache/2.2" > $x86_64.tmp
		# apaga as linhas em branco para nao dar incosistencia no log #
		awk 'NF>0' $x86_64.tmp > $x86_64
		# remove o arquivo temporario #
		rm -f $x86_64.tmp
		# Carrega a lista de pacotes para dentro de uma variavel #
		arquivos=( `cat "$x86_64"` )
		# Lê linha a linha da lista de pacotes para fazer download #
		for pacote in "${arquivos[@]}"; do
			# Faz download dos pacotes linha a linha ja renomeando o arquivo para o nome certo #
			wget -c $siteX86_64/$pacote$chave -O $destinoX86_64/$pacote
		done
		# verifica quantos arquivos existem na lista de download #
		arquivosLista=`grep -cv '$=' $x86_64`
		# verifica quantos arquivos foram baixados #
		arquivosBaixados=`ls $destinoX86_64 | wc -l`
		# Escrita no log #
		echo "- x86_64 -" >> $log
		echo "Total na lista = $arquivosLista" >> $log
		echo "Total baixado  = $arquivosBaixados" >> $log
		echo "------------------------" >> $log
		# remove o segundo arquivo temporario #
		rm -f $x86_64
		# apaga o conteudo da lista geral para nao haver futuros enganos #
		cat /dev/null > $listaPacotesX86_64
		# chama o proximo download #
		downloadRaiz
	}
function downloadRaiz()
	{
		# variaveis locais #
		siteRaiz="https://updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update/SUSE:Updates:SLE-SERVER:12:x86_64.repo"
		destinoRaiz=updates.suse.com/SUSE/Updates/SLE-SERVER/12/x86_64/update
		pacote="SUSE:Updates:SLE-SERVER:12:x86_64.repo"
		# Faz download do arquivo #
		wget -c --convert-links $siteRaiz/$pacote$chave -O $destinoRaiz/$pacote
		arquivosBaixados=`ls $destinoRaiz/SUSE:Updates:SLE-SERVER:12:x86_64.repo | wc -l`
		# Escrita no log #
		echo "- SUSE:Updates:SLE-SERVER:12:x86_64.repo -" >> $log
		echo "Total na lista = 1" >> $log
		echo "Total baixado  = $arquivosBaixados" >> $log
		echo "------------------------" >> $log
		clear
		echo "${cabecalho}"
		echo "        Download concluido com exito!!!"
		echo 
		echo "        Log do download"
		cat $log
		echo "        Bye Vini ;-)"
		echo
		exit 0
	}
function menuInvalido()
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "${cabecalho}"
		echo "        Opcao invalida"
		sleep 3
		clear
		verificarArqvuios
	}
clear
echo "

        --------------------------------------
        -- Powered by Alessandro Librelato  --
        -- Date: 20/03/2015                 --
        --------------------------------------
		
          #   #  #####  #      #       ####
          #   #  #      #      #      #    #
          #####  ###    #      #      #    #
          #   #  #      #      #      #    #
          #   #  #####  #####  #####   ####

          #       #  #####  ###     #  #####
          #       #    #    #  #    #    #
           #     #     #    #   #   #    #
            #   #      #    #    #  #    #
             ###     #####  #     ###  #####
"
sleep 4
clear
verificarArqvuios
