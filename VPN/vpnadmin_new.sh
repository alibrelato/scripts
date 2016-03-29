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

  1 - Criar um usuario
  2 - Revogar acesso (DELETAR)
  3 - Reenviar certificado
  4 - Listar usuarios conectados
  5 - Listar usuarios com acesso a VPN
  9 - Sair
"
certificados=/etc/openvpn/user_cert
corpoEmail=/etc/openvpn/script/texto
arquivoPem=/etc/openvpn/keys/dh1024.pem
arquivoCrt=/etc/openvpn/keys/ca.crt
arquivoKey=/etc/openvpn/keys/chave.key
index=/etc/openvpn/easy-rsa/2.0/keys
#source ./vars # por causa do script /etc/openvpn/easy-rsa/2.0/revoke-full

### Funcoes do script INICIO ###

# Funcao que monta o menu #
function montaMenu()
	{
		# Monta o cabecalho, menu e le a opcao digitada pelo usuario #
		echo "$cabecalho"
		echo "$menu"
		echo -n "    Opcao: "
		read opcao
		# Caso o usuario digite a opcao 1 #
		if [ $opcao -eq 1 ]; then
			# Limpa a tela e chama a funcao criarUsuario #
			clear
			echo "$cabecalho"
			criarUsuario
		# Caso o usuario digite a opcao 2 #
		elif [ $opcao -eq 2 ]; then
			# Limpa a tela e chama a funcao revogaUsuario #
			clear
			echo "$cabecalho"
			revogaUsuario
		elif [ $opcao -eq 3 ]; then
		# Limpa a tela e chama a funcao reenviaCertificado #
			clear
			echo "$cabecalho"
			reenviaCertificado
		elif [ $opcao -eq 4 ]; then
		# Limpa a tela e chama a funcao listaConectados #
			clear
			echo "$cabecalho"
			listaConectados
		elif [ $opcao -eq 5 ]; then
		# Limpa a tela e chama a funcao listaUsuario #
			clear
			echo "$cabecalho"
			listaUsuario
		# Caso o usuario digite a opcao 7 #
		elif [ $opcao -eq 9 ];then
			# Limpa a tela, monta o cacebalho, exibe a mensagem de saida e sai do script #
			clear
			echo "$cabecalho"
			echo "    Ate logo"
			echo
			echo
			exit 1
		# Caso o usuario digite uma opcao invalida #
		else
			# Limpa a tela e chama a funcao menu_invalido #
			clear
			menuInvalido
		fi
	}
# Funcao "criarUsuario" #
function criarUsuario()
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "    CRIACAO DE USUARIO"
		echo
		echo "    O usuario deve conter letras minusculas, sem acentos e nome.sobrenome. Ex: roger.waters"
		echo
		echo -n "    Nome do usuario: "
		read usuario
		buscaUsuario=`ls $certificados | grep "$usuario"`
		if [[ $usuario = $buscaUsuario ]]; then
			clear
			echo "$menu"
			echo -n "    O usuario $usuario ja existe, deseja reenviar o certificado?(s/n) "
			read opcao
			case "$opcao" in
				"s" | "S" | "sim" | "SIM")
				clear
				echo "$cabecalho"
				reenviaCertificado
				;;
				"n" | "N" | "nao" | "NAO" )
				echo
				echo "    Voce ira para o menu principal"
				sleep 3
				clear
				montaMenu
				;;
				*)
				echo
				echo "    Opcao desconhecida, tente novamente..."
				sleep 3
				clear
				criarUsuario
				;;
			esac
		else
			echo
			echo "    Gerando os arquivos de configuracao do usuario $usuario"
			mkdir $certificados/$usuario
			openssl req -nodes -new -keyout $certificados/$usuario/$usuario.key -out $certificados/$usuario/$usuario.csr -subj '/C=BR/ST=RS/L=POA/CN='$usuario'/O=SHOPPINGBRASIL/L=PORTOALEGRE/'
			#Assina o certificado
			openssl ca -out $certificados/$usuario/$usuario.crt -in $certificados/$usuario/$usuario.csr
			echo "dev tap" >> $certificados/$usuario/sb.ovpn
			echo "remote 187.103.103.33" >> $certificados/$usuario/sb.ovpn
			echo "route-method exe" >> $certificados/$usuario/sb.ovpn
			echo "route-delay 2" >> $certificados/$usuario/sb.ovpn
			echo "tls-client" >> $certificados/$usuario/sb.ovpn
			echo "ca ca.crt" >> $certificados/$usuario/sb.ovpn
			echo "cert $USUARIO.crt" >> $certificados/$usuario/sb.ovpn
			echo "key $USUARIO.key" >> $certificados/$usuario/sb.ovpn
			echo "dh dh1024.pem" >> $certificados/$usuario/sb.ovpn
			echo "tls-auth chave.key" >> $certificados/$usuario/sb.ovpn
			echo
			echo 
			echo "    O usuario $usuario trabalha para ShoppingBrasil ou ConectaIT?"
			echo
			echo -n "    1 - ShoppingBrasil | 2 - ConectaIT: "
			read opcao
			case "$opcao" in
				"1" | "UM" | "um" | "ShoppingBrasil" | "shoppingbrasil" )
				echo "port 9020" >> $certificados/$usuario/sb.ovpn
				;;
				"2" | "dois" | "DOIS" | "ConectaIT" | "conectait" )
				echo "port 5001" >> $certificados/$usuario/sb.ovpn
				;;
				*)
				clear
				echo "$menu"
				echo "    CRIACAO DE USUARIO"
				echo
				echo "    Opcao invalida, tente novamente..."
				sleep 3
				clear
				rm -rf $certificados/$usuario
				usuario=/dev/null
				criarUsuario
				;;
			esac
			echo "pull" >> $certificados/$usuario/sb.ovpn
			echo "persist-tun" >> $certificados/$usuario/sb.ovpn
			echo "persist-key" >> $certificados/$usuario/sb.ovpn
			echo "ping 15" >> $certificados/$usuario/sb.ovpn
			echo "verb 3" >> $certificados/$usuario/sb.ovpn
			cp $certificados/$usuario.* /etc/openvpn/easy-rsa/2.0/keys
			echo
			echo "    Certificado gerado."
			echo
			echo "    Fazendo backup dos arquivos do usuario"
			#zip $certificados/$usuario/certificados.zip $certificados/$usuario/$usuario.key $certificados/$usuario/$usuario.crt $certificados/$usuario/$usuario.csr $certificados/$usuario/ca.crt $certificados/$usuario/chave.key $certificados/$usuario/dh1024.pem $certificados/$usuario/sb.ovpn $certificados/openvpn-2.2.1-install.exe $certificados/LEIAME.doc
			zip $certificados/$usuario/certificados.zip $certificados/$usuario/* $certificados/*.exe $certificados/*.doc $arquivoPem $arquivoCrt $arquivoKey
			rm $certificados/$usuario/$usuario.key $certificados/$usuario/$usuario.crt $certificados/$usuario/$usuario.csr $certificados/$usuario/sb.ovpn
			# Envia email
			echo
			echo "    Digite o e-mail para envio do certificado do usuario $usuario"
			echo
			echo -n "    E-mail: "
			read email
			mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/$usuario/certificados.zip $email  < $corpoEmail
			echo
			echo "    Certificado enviado..."
			sleep 3
			clear
			montaMenu
		fi
	}
# Funcao "menu2" #
function revogaUsuario() 
	{
		echo "  REVOGA ACESSO DE USUARIO DA VPN "
		echo
		echo -n "    Voce sabe o nome do usuario?(s/n)"
		read opcao
		case "$opcao" in
			"s" | "S" | "sim" | "SIM")
			echo
			echo "    Digite o nome do usuario com letras minusculas e sem acentos. Ex: angus.young"
			echo
			echo -n "    Nome do usuario: "
			read usuario
			buscaUsuario=`ls $certificados | grep "$usuario"`
			if [[ $usuario = $buscaUsuario ]]; then
				echo
				echo "    Revogando o acesso do usuario $usuario"
				cd /etc/openvpn/easy-rsa/2.0/
				source ./vars
				bash revoke-full $usuario
				rm -rf $certificados/$usuario
				dataHora=`date +%d/%m/%Y-%H:%M:%S`
				cp $index/index.txt $index/index_$dataHora.txt
				exec 3< $index/index.txt  # associa lista_arquivos ao descritor 3
				while read banco <&3; do   # Lê uma linha de cada vez do descritor 3.
					usuarioAtivo=( `echo ${banco} | awk ' { print $1 } ' | grep V` )
					if [[ $usuarioAtivo = V  ]]; then
						echo $banco >> $index/index_novo.txt
					fi
				done
				exec 3<&-  # libera descritor 3
				cat $index/index_novo.txt > $index/index.txt
				rm $index/index_novo.txt
				rm $index/$usuario.*
				echo
				echo "    Acesso do usuario $usuario revogado com sucesso"
				sleep 6
				clear
				montaMenu
			else
				echo
				echo "    O usuario $usuario nao existe"
				sleep 3
				clear
				montaMenu
			fi
			;;
			"n" | "N" | "nao" | "NAO" )
			clear
			echo "$cabecalho"
			listaUsuario
			;;
			*)
			echo "    Opcao invalida, tente novamente..."
			sleep 3
			clear
			montaMenu
		esac
	}
function reenviaCertificado() 
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "    REENVIO DE CERTIFICADO: "
		echo
		echo "    O usuario deve conter letras minusculas, sem acentos e nome.sobrenome. Ex: robert.plant"
		echo
		echo -n "    Nome do usuario: "
		read usuario
		buscaUsuario=`ls $certificados | grep "$usuario"`
		if [[ $usuario = $buscaUsuario ]]; then
			echo "    Digite o e-mail do usuario $usuario para o reenvio do certificado"
			echo
			echo -n "    E-mail: "
			read email
			mail -s "Certificados VPN - SB" -a $certificados/$usario/certificados.zip $email  < $corpoEmail
			clear
			echo "$menu"
			echo "    Certificado enviado ao usuario"
			sleep 6
			clear
			montaMenu
		else
			echo
			echo -n "    O usuario $usuario nao existe, deseja criar-lo?(s/n): "
			read opcao
			case "$opcao" in
				"s" | "S" | "sim" | "SIM")
				clear
				criarUsuario
				;;
				"n" | "N" | "nao" | "NAO" )
				echo
				echo "    Voce ira para o menu principal"
				sleep 5
				clear
				montaMenu
				;;
				*)
				echo
				echo "    Opcao desconhecida, tente novamente..."
				sleep 5
				clear
				echo "$cabecalho"
				reenviaCertificado
				;;
			esac
		fi
	}
function listaConectados() 
	{
		clear
		echo "    LISTA DE USUARIOS CONECTADOS"
		echo
		cat /etc/openvpn/logs/sbvpn.log
		echo
		echo "    APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL"
		read f
		clear
		montaMenu
	}
function listaUsuario() 
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		clear
		if [ -e $index/index.txt ]; then
			echo "$cabecalho"
			echo "    LISTA DE USUARIOS COM ACESSO A VPN"
			echo
			echo "    Voce deseja procurar um usuario ou listar todos usuarios?"
			echo "    1 - Procurar | 2 - Listar todos"
			echo
			echo -n "    Opcao: "
			read opcao
			case "$opcao" in
				"1" | "01" | "um" | "UM")
				clear
				echo "$cabecalho"
				echo "    PROCURANDO POR UM USUARIO ESPECIFICO"
				echo

				echo -n "    Nome do usuario: "
				read usuario
				usuarioPesquisa=( `cat $index/index.txt | awk ' { print $5 } ' | sed "s/\/C=BR\/ST=RS\/O=SHOPPINGBRASIL\/CN=//" | grep $usuario`)
				usuarioValido=( `cat $index/index.txt | grep $usuario | awk ' { print $1 } ' | grep V ` )
				if [[ $usuarioValido = V && $usuario = $usuarioPesquisa  ]]; then
					echo
					echo "    Usuario $usuario esta ativo ativo"
				else
					echo
					echo "    Usuario $usuario nao existe"
				fi
			
				sleep 6
				clear
				montaMenu
				;;
				"2" | "02" | "dois" | "DOIS" )
				exec 3< $index/index.txt  # associa lista_arquivos ao descritor 3
				while read banco <&3; do   # Lê uma linha de cada vez do descritor 3.
					usuarioAtivo=( `echo ${banco} | awk ' { print $1 } ' | grep V` )
					if [[ $usuarioAtivo = V  ]]; then
						echo $banco | cut -d " " -f 5 | sed "s/\/C=BR\/ST=RS\/O=SHOPPINGBRASIL\/CN=//"
					fi
				done
				
				
				echo
				echo "    Pressione qualquer tecla para voltar ao menu inicial"
				read f
				clear
				montaMenu
				;;
				*)
				echo
				echo "    Opcao desconhecida, tente novamente..."
				sleep 6
				clear
				montaMenu
				;;
			esac
		else
			echo "OPS!!! o arquivo $index/index.txt NAO existe, favor contatar o ADM"
		fi
	}
function menuInvalido()
	{
		# Escreve na tela o cabecalho, mensagem, faz uma pausa, limpa a tela e chama a funcao monta_menu #
		echo "$cabecalho"
		echo "    Opcao invalida"
		sleep 3
		clear
		montaMenu
	}
### Funcoes do script FIM ###

# Ao iniciar o script, limpa a tela e chama a funcao monta_menu #
clear
montaMenu