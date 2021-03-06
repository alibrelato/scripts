#!/bin/bash
# Autor: Paulo Ricardo Kuhn
# Versao: V 1.1
# Data: 23/09/2014
#
cd /etc/openvpn/easy-rsa/2.0/
source ./vars
vermelho="\033[0;31m"
verde="\033[0;32m"
amarelo="\033[1;33m"
#echo -e "\033[01;32m$MENU\033[01;37m"
#
INICIO="sh /etc/openvpn/script/vpnadmin.sh" 
clear
MENU="
  OPCOES:

  1. CRIAR USUARIO
  2. REVOGAR ACESSO ( DELETAR )
  3. ALTERAR SENHA
  4. REENVIAR CERTIFICADO
  5. LISTAR USUARIOS CONECTADOS
  6. LISTAR USUARIOS COM ACESSO A VPN
  7. SAIR / CRTL+C
"
criar_usuario() {
    clear
	echo
    echo "  CRIAR USUARIO PARA ACESSO VPN"
	echo "  PADRAO DE USUARIO LETRAS MINUSCULAS EX: fulano.silva"
    echo
    if [ $(id -u) -eq 0 ]; then
		echo -n "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS: "
		read USUARIO
		ls /etc/openvpn/user_cert > /etc/openvpn/logs/log_users_cert/certificados_list
		egrep "^$USUARIO" /etc/openvpn/logs/log_users_cert/certificados_list >/dev/null
		if [ $? -eq 0 ]; then
			echo "  $USUARIO EXISTE, DESEJA REENVIAR OS CERTIFICADOS? "
			echo
			echo -n "  O $USUARIO EXISTE, DESEJA REENVIAR OS CERTIFICADOS?(s/n) "
			read text1
				case "$text1" in
					"s" | "S" | "sim" | "SIM")
					echo -n "  DIGITE O EMAIL PARA ENVIO DOS CERTIFICADOS: "
					read EMAIL
					#/etc/openvpn/script/sendcertified $EMAIL /etc/openvpn/user_cert/$USUARIO/certificados.zip
					mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/$USUARIO/certificados.zip $EMAIL  < /etc/openvpn/script/texto
					echo "  ENVIAND CERTIFICADO AO USUARIO...........OK"
					;;
					"n" | "N" | "nao" | "NAO" )
					echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
					read f
					$INICIO
					;;
					*) echo "  OPCAO DESCONHECIDA...TENTE NOVAMENTE." ; echo ; criar_usuario ;;
				esac
			echo
			echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO
		else
			echo
			echo "  CRIAR USUARIO PARA ACESSO VPN SB OU CONECTA?"
			echo
			echo
			if [ $(id -u) -eq 0 ]; then
			echo
			echo "  DESEJA CRIAR UM USUARIO SB OU CONECTA? (1 OU 2) "
			echo -n "  1 - SHOPPING | 2 - CONECTA:  "
			read text1
				case "$text1" in
					"1" | "UM" | "um" )
					cd /etc/openvpn/user_cert/
					#echo -n "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS EX: fulano.silva: "
					#read USUARIO
					echo -n "  DIGITE O EMAIL PARA ENVIO DO CERTIFICADOS: "
					read EMAIL
					#
					openssl req -nodes -new -keyout $USUARIO.key -out $USUARIO.csr -subj '/C=BR/ST=RS/L=POA/CN='$USUARIO'/O=SHOPPINGBRASIL/L=PORTOALEGRE/'
					#Assina o certificado
					openssl ca -out $USUARIO.crt -in $USUARIO.csr
					#
					cp $USUARIO.* /etc/openvpn/user_cert/
					cp /etc/openvpn/keys/dh1024.pem /etc/openvpn/user_cert
					cp /etc/openvpn/keys/ca.crt /etc/openvpn/user_cert
					cp /etc/openvpn/keys/chave.key /etc/openvpn/user_cert
					#
					echo "  GERANDO ARQUIVOS DE CONFIGURACAO DO USUARIO"
					#
					echo "dev tap" >> /etc/openvpn/user_cert/sb.ovpn
					echo "remote 187.103.103.33" >> /etc/openvpn/user_cert/sb.ovpn
					echo "route-method exe" >> /etc/openvpn/user_cert/sb.ovpn
					echo "route-delay 2" >> /etc/openvpn/user_cert/sb.ovpn
					echo "tls-client" >> /etc/openvpn/user_cert/sb.ovpn
					echo "ca ca.crt" >> /etc/openvpn/user_cert/sb.ovpn
					echo "cert $USUARIO.crt" >> /etc/openvpn/user_cert/sb.ovpn
					echo "key $USUARIO.key" >> /etc/openvpn/user_cert/sb.ovpn
					echo "dh dh1024.pem" >> /etc/openvpn/user_cert/sb.ovpn
					echo "tls-auth chave.key" >> /etc/openvpn/user_cert/sb.ovpn
					echo "port 9020" >> /etc/openvpn/user_cert/sb.ovpn
					echo "pull" >> /etc/openvpn/user_cert/sb.ovpn
					echo "persist-tun" >> /etc/openvpn/user_cert/sb.ovpn
					echo "persist-key" >> /etc/openvpn/user_cert/sb.ovpn
					echo "ping 15" >> /etc/openvpn/user_cert/sb.ovpn
					echo "verb 3" >> /etc/openvpn/user_cert/sb.ovpn
					#
					echo "  FAZENDO BACKUP DOS CERTIFICADOS DO USUARIO"
					mkdir /etc/openvpn/user_cert/$USUARIO
					cd /etc/openvpn/user_cert/
					cp $USUARIO.* /etc/openvpn/easy-rsa/2.0/keys
					zip certificados.zip $USUARIO.key $USUARIO.crt $USUARIO.csr ca.crt chave.key dh1024.pem sb.ovpn openvpn-2.2.1-install.exe LEIAME.doc
					cp certificados.zip  /etc/openvpn/user_cert/$USUARIO/
					rm /etc/openvpn/user_cert/$USUARIO.*
					rm /etc/openvpn/user_cert/ca.crt
					rm /etc/openvpn/user_cert/dh1024.pem
					rm /etc/openvpn/user_cert/certificados.zip
					rm /etc/openvpn/user_cert/chave.key
					rm /etc/openvpn/user_cert/sb.ovpn
					# Envia email
					echo "  ENVIAND CERTIFICADO AO USUARIO...........OK"
					#
					echo
					#/etc/openvpn/script/sendvpn $EMAIL /etc/openvpn/user_cert/$USUARIO/certificados.zip
					#grep . texto | mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/paulo.kuhn/certificados.zip paulork@operalpha.com.br < texto
					mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/$USUARIO/certificados.zip $EMAIL  < /etc/openvpn/script/texto
					echo "  ENTRAR EM CONTATO COM USUARIO E TESTAR!!!!!!!"
					echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
					read f
					$INICIO
					;;
					"2" | "dois" | "DOIS" )
					cd /etc/openvpn/user_cert/
					#echo -n "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS EX: fulano.silva: "
					#read USUARIO
					echo -n "  DIGITE O EMAIL PARA ENVIO DO CERTIFICADOS: "
					read EMAIL
					#
					openssl req -nodes -new -keyout $USUARIO.key -out $USUARIO.csr -subj '/C=BR/ST=RS/L=POA/CN='$USUARIO'/O=SHOPPINGBRASIL/L=PORTOALEGRE/'
					#Assina o certificado
					openssl ca -out $USUARIO.crt -in $USUARIO.csr
					#
					cp $USUARIO.* /etc/openvpn/user_cert/
					cp /etc/openvpn/keys/dh1024.pem /etc/openvpn/user_cert
					cp /etc/openvpn/keys/ca.crt /etc/openvpn/user_cert
					cp /etc/openvpn/keys/chave.key /etc/openvpn/user_cert
					#
					echo "  GERANDO ARQUIVOS DE CONFIGURACAO DO USUARIO"
					#
					echo "dev tap" >> /etc/openvpn/user_cert/sb.ovpn
					echo "remote 187.103.103.33" >> /etc/openvpn/user_cert/sb.ovpn
					echo "route-method exe" >> /etc/openvpn/user_cert/sb.ovpn
					echo "route-delay 2" >> /etc/openvpn/user_cert/sb.ovpn
					echo "tls-client" >> /etc/openvpn/user_cert/sb.ovpn
					echo "ca ca.crt" >> /etc/openvpn/user_cert/sb.ovpn
					echo "cert $USUARIO.crt" >> /etc/openvpn/user_cert/sb.ovpn
					echo "key $USUARIO.key" >> /etc/openvpn/user_cert/sb.ovpn
					echo "dh dh1024.pem" >> /etc/openvpn/user_cert/sb.ovpn
					echo "tls-auth chave.key" >> /etc/openvpn/user_cert/sb.ovpn
					echo "port 5001" >> /etc/openvpn/user_cert/sb.ovpn
					echo "pull" >> /etc/openvpn/user_cert/sb.ovpn
					echo "persist-tun" >> /etc/openvpn/user_cert/sb.ovpn
					echo "persist-key" >> /etc/openvpn/user_cert/sb.ovpn
					echo "ping 15" >> /etc/openvpn/user_cert/sb.ovpn
					echo "verb 3" >> /etc/openvpn/user_cert/sb.ovpn
					#
					echo "  FAZENDO BACKUP DOS CERTIFICADOS DO USUARIO"
					mkdir /etc/openvpn/user_cert/$USUARIO
					cd /etc/openvpn/user_cert/
					cp $USUARIO.* /etc/openvpn/easy-rsa/2.0/keys
					zip certificados.zip $USUARIO.key $USUARIO.crt $USUARIO.csr ca.crt chave.key dh1024.pem sb.ovpn openvpn-2.2.1-install.exe LEIAME.doc
					cp certificados.zip  /etc/openvpn/user_cert/$USUARIO/
					rm /etc/openvpn/user_cert/$USUARIO.*
					rm /etc/openvpn/user_cert/ca.crt
					rm /etc/openvpn/user_cert/dh1024.pem
					rm /etc/openvpn/user_cert/certificados.zip
					rm /etc/openvpn/user_cert/chave.key
					rm /etc/openvpn/user_cert/sb.ovpn
					# Envia email
					echo "  ENVIAND CERTIFICADO AO USUARIO...........OK"
					#
					echo
					#/etc/openvpn/script/sendcertified $EMAIL /etc/openvpn/user_cert/$USUARIO/certificados.zip
					mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/$USUARIO/certificados.zip $EMAIL  < /etc/openvpn/script/texto
					echo "  ENTRAR EM CONTATO COM USUARIO E TESTAR!!!!!!!"
					echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
					read f
					$INICIO	;;
					*) echo "  OPCAO DESCONHECIDA...TENTE NOVAMENTE." ; echo ; criar_usuario ;;
				esac
		fi
	fi
	fi
}
revoga_usuario() {
    clear
    clear
	echo
    echo "  REVOGA ACESSO DE USUARIO DA VPN "
    echo
    if [ $(id -u) -eq 0 ]; then
		echo "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS, "
		echo "  CASO TENHA DUVIDA QUANTO AO NOME DO USUARIO VOLTE AO MENU INICIAL E CONSUTE A OPE��O 6 "
		echo
		echo "  DESEJA PROCEGUIR OU DESEJA CONSUTAR O NOME DO USUARIO? (s/n) "
		echo -n "  SIM - PROCEGUIR | NAO - CONSULTAR O NOME DO USUARIO:  "
			read text1
				case "$text1" in
					"s" | "S" | "sim" | "SIM")
					echo -n "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS: "
					read USUARIO
					ls /etc/openvpn/user_cert > /etc/openvpn/logs/log_users_cert/certificados_list
					egrep "^$USUARIO" /etc/openvpn/logs/log_users_cert/certificados_list >/dev/null
					if [ $? -eq 0 ]; then
						echo "  O $USUARIO EXISTE, REVOGANDO ACESSO... "
						echo
						cd /etc/openvpn/easy-rsa/2.0
						./revoke-full $USUARIO
						echo
						echo "  ACESSO REVOGADO COM SUCESSO...........OK"
						echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
						read f
						$INICIO
					else
						echo
						echo "  OPS VOCE DIGITOU ALGO ERRADO OU O USUARIO NAO EXISTE!!!!!!!"
						echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
						read f
						$INICIO
					fi
					;;
					"n" | "N" | "nao" | "NAO" )
					echo
					echo "  VOCE ESCOLHEU VERIFICAR NOME DO USUARIOS "
					echo "  APERTE ENTER PARA CONSULTAR OS URUARIO COM ACESSO"
					read f
					$ista_usuario
					#echo ; lista_usuario ;;
					;;
					*) echo "  OPCAO DESCONHECIDA...TENTE NOVAMENTE." ; echo ; revoga_usuario ;;
				esac
	fi	
}
desativa_usuario() {
    clear
	echo
	echo
    echo "  FUNCAO DESATIVADA "
	echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
	read f
	$INICIO
}
altera_senha() {
    clear
	echo
	echo
    echo "  FUNCAO DESATIVADA "
	echo "  ESSA FUN��O SO SERA UTILIZADA APOS REEDUCAMOS OS USUARIOS ATUALMETE ELES ESTAO ACOSTUMADOS NO FORMATO ATUAL "
	echo "  ATUALMETE ELES ESTAO ACOSTUMADOS NO FORMATO ATUAL, ESSE ASSUNTO DEVE VOLTAR A SER DISCUTIDO "
	echo
	echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
	read f
	$INICIO
}
envia_cert(){
    clear
    clear
	echo
    echo "  REENVIAR CENTIFICADO DE USUARIO "
    echo
    if [ $(id -u) -eq 0 ]; then
		echo "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS, "
		echo "  CASO TENHA DUVIDA QUANTO AO NOME DO USUARIO VOLTE AO MENU INICIAL E CONSUTE A OPE��O 6 "
		echo
		echo "  DESEJA PROCEGUIR OU DESEJA CONSUTAR O NOME DO USUARIO? (s/n) "
		echo -n "  SIM - PROCEGUIR | NAO - CONSULTAR O NOME DO USUARIO:  "
			read text1
				case "$text1" in
					"s" | "S" | "sim" | "SIM")
					echo -n "  DIGITE O NOME DO USUARIO SEM ESPACOS E ACENTOS: "
					read USUARIO
					ls /etc/openvpn/user_cert > /etc/openvpn/logs/log_users_cert/certificados_list
					egrep "^$USUARIO" /etc/openvpn/logs/log_users_cert/certificados_list >/dev/null
					if [ $? -eq 0 ]; then
						echo "  O $USUARIO EXISTE, VAMOS ENVIAR... "
						echo
						echo -n "  DIGITE O EMAIL PARA ENVIO DOS CERTIFICADOS: "
						read EMAIL
						#/etc/openvpn/script/sendcertified $EMAIL /etc/openvpn/user_cert/$USUARIO/certificados.zip
						#/etc/openvpn/script/sendvpn $EMAIL /etc/openvpn/user_cert/$USUARIO/certificados.zip
						#cd /etc/openvpn/script
						#grep . texto | mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/$USUARIO/certificados.zip alphatec@shoppingbrasil.com.br < texto
						mail -s "Certificados VPN - SB" -a /etc/openvpn/user_cert/$USUARIO/certificados.zip $EMAIL  < /etc/openvpn/script/texto
						echo "  ENVIAND CERTIFICADO AO USUARIO...........OK"
						echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
						read f
						$INICIO
					else
						echo
						echo "  OPS VOCE DIGITOU ALGO ERRADO OU O USUARIO NAO EXISTE!!!!!!!"
						echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
						read f
						$INICIO
					fi
					;;
					"n" | "N" | "nao" | "NAO" )
					echo "  VOCE ESCOLHEU VERIFICAR NOME DO USUARIOS "
					echo "  APERTE ENTER PARA CONSULTAR OS URUARIO COM ACESSO"
					read f
					$ista_usuario
					#echo ; lista_usuario ;;
					;;
					*) echo "  OPCAO DESCONHECIDA...TENTE NOVAMENTE." ; echo ; envia_cert ;;
				esac
	fi			
}
lista_conectados(){
    echo
    echo "  LISTA DE USUARIOS CONECTADOS "
    echo
	#cat /etc/openvpn/logs/sbvpn.log | grep '^[a-z]' /etc/openvpn/logs/sbvpn.log | awk -F, '{print $3";"$4}' > /etc/openvpn/logs/log_users_cert/certificados_conectados
	cat /etc/openvpn/logs/sbvpn.log  > /etc/openvpn/logs/log_users_cert/certificados_conectados
	cat /etc/openvpn/logs/log_users_cert/certificados_conectados
	#cat /etc/openvpn/clientes.log | awk -F "Last Ref" '{print substr($2,1,4)}' > /etc/openvpn/logs/log_users_cert/certificados_conect_old
	#echo 
	#echo "logs"
	#echo
	#vpn_info=`egrep '^[a-z]' /etc/openvpn/clientes.log | awk -F Since '{print substr($2,1,4)}'`
	#echo "$vpn_info"
	echo
    echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL"
    read f
    $INICIO
}
lista_usuario(){
    clear
    echo
    echo "  LISTA DE USUARIOS COM ACESSO A VPN"
    echo
	ls /etc/openvpn/user_cert > /etc/openvpn/logs/log_users_cert/certificados_list
	#cat /etc/openvpn/user_cert/certificados 
	#sort /etc/openvpn/user_cert/certificados | awk -F "openvpn-install-2.3.3-I002-i686.exe" '{print substr($2,1,4)}' > /etc/openvpn/user_cert/certificados2
	cat /etc/openvpn/logs/log_users_cert/certificados_list | grep -v "openvpn-2.2.1-install.exe" /etc/openvpn/logs/log_users_cert/certificados_list > /etc/openvpn/logs/log_users_cert/certificados1
	cat /etc/openvpn/logs/log_users_cert/certificados1 | grep -v  "LEIAME.doc" /etc/openvpn/logs/log_users_cert/certificados1 > /etc/openvpn/logs/log_users_cert/certificados
	sort /etc/openvpn/logs/log_users_cert/certificados
	rm /etc/openvpn/logs/log_users_cert/certificados_list
	rm /etc/openvpn/logs/log_users_cert/certificados1
	#sed "s/openvpn-2.2.1-install.exe//g" /etc/openvpn/logs/log_users_cert/certificados_list > /etc/openvpn/logs/log_users_cert/certificados
	echo
	echo "  APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL"
    read f
    $INICIO
}
opcao_invalida(){
    echo
    echo " OPCAO INVALIDA "
    echo
    echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL"
    read f
    $INICIO
}
  cat /etc/openvpn/script/boasvindas 
  echo "$MENU"
  echo -n "   QUAL A OPCAO DESEJADA? "
  read opcao
  
if [ $opcao -eq 1 ]
then
    criar_usuario
    $INICIO
elif [ $opcao -eq 2 ]
then
    revoga_usuario
    $INICIO
elif [ $opcao -eq 3 ]
then
    altera_senha
    $INICIO
elif [ $opcao -eq 4 ]
then
    envia_cert
    $INICIO
elif [ $opcao -eq 5 ]
then
    lista_conectados
    $INICIO
elif [ $opcao -eq 6 ]
then
    lista_usuario
    $INICIO
elif [ $opcao -eq 7 ]
then
    exit 1
else
    opcao_invalida
    read
    $INICIO
fi