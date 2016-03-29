#!/bin/bash
# Autor: Paulo Ricardo Kuhn
# Versao: V 1.1
# Data: 02/09/2014
#
GRUPO_FTP=100
INICIO="sh /data_media/ftp/scripts/ftpadmin.sh"
clear
MENU="
  OPCOES:
  
  1. CRIAR USUARIO
  2. AJUSTAR USUARIO
  3. DELETAR USUARIO
  4. ALTERAR SENHA
  5. ALTERAR QUOTA
  6. LISTAR USUARIO
  7. SAIR / CRTL+C
"
criar_usuario() {
    clear
	echo
    echo " CRIAR USUARIO PARA ACESSO FTP"
	echo " PADRAO DE USUARIO FTP<USER> EX: ftpteste"
    echo
    echo -n " INFORME O NOME DO USUARIO: "
    read USERNAME
    echo " INFORME A SENHA DESEJADA: "
	# Criar Pasta para usuario e o um link simbolico pra /home
	mkdir /data_media/ftp/home/$USERNAME 
	ln -s /data_media/ftp/home/$USERNAME /home/$USERNAME
	# Adiciona usuario 
	useradd $USERNAME --home /home/$USERNAME
	# apos adiconar usuario salva em arquivo dados do usuario
	id $USERNAME > /data_media/ftp/logs/$USERNAME.txt
	# Salva em arquivo somente o ID do usuario, apos joga em uma variavel
	cat /data_media/ftp/logs/$USERNAME.txt | awk -F "uid=" '{print substr($2,1,4)}' > /data_media/ftp/logs/$USERNAME-id.txt
	ID=`cat /data_media/ftp/logs/$USERNAME-id.txt`
	# Adiciona usuario no pure-ftp e 
	pure-pw useradd $USERNAME -u $ID -g $GRUPO_FTP -d /home/$USERNAME -m
	echo " INFORME A SENHA DESEJADA NOVAMENTE: "
	passwd $USERNAME
	# Pergunta se o usuario precisa ter permissao de escrita ou somente leitura
    sleep 2
	echo -n "O USUARIO PRECISA TER PERMISSAO DE ESCRITA?(s/n) "
	read text1
	case "$text1" in
		"s" | "S" | "sim" | "SIM")
		 chown -R $USERNAME:ftpusers /home/$USERNAME
		 chown -R $USERNAME:ftpusers /data_media/ftp/home/$USERNAME
		 chmod -R 755 /data_media/ftp/home/$USERNAME
		 echo " PERMISSAO DE ESCRITA OK "
		;;
		"n" | "N" | "nao" | "NAO" )
		 chmod -R 555 /data_media/ftp/home/$USERNAME
		 echo " SEM PERMISSAO DE ESCRITA "
		;;
		*) echo "OPCAO DESCONHECIDA...TENTE NOVAMENTE." ; echo ; criar_usuario ;;
	esac
    echo
    echo " USUARIO $USERNAME CRIADO COM SUCESSO"
	echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
    read f
	$INICIO
}
ajusta_usuario() {
    clear
	echo
    echo " AJUSTAR USUARIOS QUE FORAM CRIADOS PELO YAST"
    echo
	if [ $(id -u) -eq 0 ]; then
		echo -n " INFORME O NOME DO USUARIO: "
		read USERNAME
		egrep "^$USERNAME" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; then
			echo " $USERNAME EXISTE, PROCEGUINDO..."
			echo " INFORME A SENHA DESEJADA: "
			# apos adiconar usuario salva em arquivo dados do usuario
			id $USERNAME > /data_media/ftp/logs/$USERNAME.txt
			# Salva em arquivo somente o ID do usuario, apos joga em uma variavel
			cat /data_media/ftp/logs/$USERNAME.txt | awk -F "uid=" '{print substr($2,1,4)}' > /data_media/ftp/logs/$USERNAME-id.txt
			ID=`cat /data_media/ftp/logs/$USERNAME-id.txt`
			# Adiciona usuario no pure-ftp e 
			pure-pw useradd $USERNAME -u $ID -g $GRUPO_FTP -d /home/$USERNAME -m
			echo " INFORME A SENHA DESEJADA NOVAMENTE: "
			passwd $USERNAME
			sleep 2
			echo -n "O USUARIO PRECISA TER PERMISSAO DE ESCRITA?(s/n) "
			read text1
				case "$text1" in
					"s" | "S" | "sim" | "SIM")
					chown -R $USERNAME:ftpusers /home/$USERNAME
					chown -R $USERNAME:ftpusers /data_media/ftp/home/$USERNAME
					chmod -R 755 /data_media/ftp/home/$USERNAME
					echo " PERMISSAO DE ESCRITA OK "
					;;
					"n" | "N" | "nao" | "NAO" )
					chmod -R 555 /data_media/ftp/home/$USERNAME
					echo " SEM PERMISSAO DE ESCRITA "
					;;
					*) echo "OPCAO DESCONHECIDA...TENTE NOVAMENTE." ; echo ; criar_usuario ;;
				esac
			echo
			echo " USUARIO $USERNAME INCLUIDO NO PURE-FTP COM SUCESSO"
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO
		else
			echo " $USERNAME NAO EXISTE, VALIDE A INFORMAÇÃO..."
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO
		fi
	fi
}
desativa_usuario() {
    clear
    echo " DELATAR USUARIO? "
    echo
	if [ $(id -u) -eq 0 ]; then
		echo -n " INFORME O NOME DO USUARIO: "
		read USERNAME
		egrep "^$USERNAME" /etc/pureftpd.passwd >/dev/null
		if [ $? -eq 0 ]; then
			echo " $USERNAME EXISTE, PROCEGUINDO..."
			pure-pw userdel $USERNAME
			mv /data_media/ftp/home/$USERNAME /data_media/ftp/home/$USERNAME-OLD
			mv /home/$USERNAME /home/$USERNAME-OLD
			echo " $USERNAME DELETADO "
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
	        $INICIO
		else
			echo " $USERNAME NAO EXISTE, VALIDE A INFORMAÇÃO..."
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO
		fi
	fi
}
altera_senha() {
	clear
	echo
    echo " ALTERAR SENHA DE USUARIO: "
    echo
	if [ $(id -u) -eq 0 ]; then
		echo -n " INFORME O NOME DO USUARIO: "
		read USERNAME
		egrep "^$USERNAME" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; then
			echo " $USERNAME EXISTE, PROCEGUINDO..."
			echo " INFORME A SENHA DESEJADA: "
			id $USERNAME > /data_media/ftp/logs/$USERNAME.txt
			cat /data_media/ftp/logs/$USERNAME.txt | awk -F "uid=" '{print substr($2,1,4)}' > /data_media/ftp/logs/$USERNAME-id.txt
			ID=`cat /data_media/ftp/logs/$USERNAME-id.txt`
			pure-pw useradd $USERNAME -u $ID -g $GRUPO_FTP -d /home/$USERNAME -m
			echo " INFORME A SENHA DESEJADA NOVAMENTE: "
			passwd $USERNAME
			sleep 2
			echo " SENHA DO USUARIO $USERNAME ALTERADA COM SUCESSO"
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO
		else
			echo " $USERNAME NAO EXISTE, VALIDE A INFORMAÇÃO..."
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO
		fi
	fi
}
altera_quota(){
    clear
    echo
	echo " ESSA FUNCAO NAO ESTA FUNCIONAL PRECISA SER TRATADA "
    echo -n" INFORME O USUARIO QUE DESEJA ALTERAR QUOTA: "
    read USERNAME
    echo -n " INFORME A NOVA QUOTA(MB): "
    read QUOTA
    sleep 3
    echo
    echo " QUOTA ALTERADA COM SUCESSO"
    read f
	$INICIO
}
lista_usuario(){
    clear
    echo
    echo " LISTA DE USUARIOS FTP"
    echo
	echo " TECLE 1 PARA: LISTAR TODOS OS USUARIO "
	echo
	echo " TECLE 2 PARA: LISTAR INFORMACOES DE UM USUARIO "
	echo 
	echo -n " QUAL A OPCAO? "
	read text1
		case "$text1" in
			"1" | "UM" | "um" )
			pure-pw list
			echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
			read f
			$INICIO;;
			"2" | "dois" | "DOIS" )
			echo -n " INFORME O NOME DO USUARIO: "
			read text
				egrep "^$text" /etc/passwd >/dev/null
				if [ $? -eq 0 ]; then
					echo " $USERNAME EXISTE, PROCEGUINDO..."
					pure-pw show $text
					echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
					read f
					$INICIO
				else 
					echo " $USERNAME NAO EXISTE, VALIDE A INFORMAÇÃO..."
					echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL OU CRTL+C PARA SAIR"
					read f
					$INICIO
				fi;;
					*) echo "OPCAO DESCONHECIDA...TENTE NOVAMENTE." ;;
		esac
}
opcao_invalida(){
    echo
    echo " OPCAO INVALIDA "
    echo
    echo " APERTE ENTER PARA VOLTAR AO MENU PRINCIPAL"
    read f
    $INICIO
}
  cat /data_media/ftp/scripts/boasvindas 
  echo "$MENU"
  echo -n "   QUAL A OPCAO DESEJADA? "
  read opcao
  
if [ $opcao -eq 1 ]
then
    criar_usuario
    $INICIO
elif [ $opcao -eq 2 ]
then
    ajusta_usuario
    $INICIO
elif [ $opcao -eq 3 ]
then
    desativa_usuario
    $INICIO
elif [ $opcao -eq 4 ]
then
    altera_senha
    $INICIO
elif [ $opcao -eq 5 ]
then
    altera_quota
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
