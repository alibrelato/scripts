#!/bin/bash
######################################
######################################
##  Desenvolvido por :              ##
##  Alessandro Librelato            ##
##  Data : 25/02/2015               ##
##  Versao : 1.0                    ##
######################################
######################################
#set -x

### Variaveis do ambiente ###
montagem=/mnt/backup
hostname=`hostname`
servidorDestino=10.0.0.34
pastaDestino=/var/lib/xen/images/medias/BKP/
log="/tmp/backup.log"
email="alphatec@shoppingbrasil.com.br"
listaPasta="
/data0/pedidos/CbdIntegracao/
/home/
/data0/anexo/
/data0/automacaoftp/
/etc/
/data0/dexter/
/var/spool/cron/tabs/
/boot/
/root/
"
while true; do
	# verifica se o 10.0.0.34 esta montado, se estiver, desmonta #
	if mountpoint -q $montagem; then
		umount $montagem
	# Se o 10.0.0.34 nao estiver montado, inicia a rotina de backup #
	else
		# Se o arquivo de log existe, deleta #
		if [ -e $log ]; then
			rm -f $log
		fi
		echo "BACKUP DO SERVIDOR $hostname" >> $log
		echo "---------------------------------" >> $log
		echo "" >> $log
		# Se a pasta /mnt/backup existe #
		if [ -d $montagem ]; then
			# Monta o 10.0.0.34 #
			mount -t nfs $servidorDestino:$pastaDestino $montagem
			# Verifica se a pasta do ponto de montagem recem montado esta vazia #
			testePasta=`[[ $(ls -A $montagem) ]] && echo "cheio" || echo "vaziu"`
			# Se a pasta nao estiver vazia #
			if [ $testePasta = "cheio" ]; then
				# Deleta tudo que esta dentro do ponto de montagem #
				rm -rf $montagem/* 
				echo "Pasta de backup foi limpa" >> $log
				echo "---------------------------------" >> $log
			# Se a pasta ja estiver vazia, apenas escreve no log #
			else
				echo "A pasta de backup ja estava vazia" >> $log
				echo "---------------------------------" >> $log
			fi
		# Se a pasta /mnt/backup nao existe ainda #
		else
			# Cria a pasta /mnt/backup #
			mkdir $montagem
			echo "pasta $montagem criada" >> $log
			echo "---------------------------------" >> $log
			# Monta o 10.0.0.34 # 
			mount -t nfs $servidorDestino:$pastaDestino $montagem
			# Verifica se a pasta do ponto de montagem recem montado esta vazia #
			teste=`[[ $(ls -A $montagem) ]] && echo "cheio" || echo "vaziu"`
			# Se a pasta nao estiver vazia #
			if [ $teste = "cheio" ]; then
				# Deleta tudo que esta dentro do ponto de montagem #
				rm -rf $montagem/*
			# Se a pasta ja estiver vazia, apenas escreve no log #
			else
				echo "A pasta de backup ja estava vazia" >> $log
				echo "---------------------------------" >> $log
			fi
		fi
		# Feito os controles, inicia-se as copias #
		echo "Iniciando a copia dos arquivos" >> $log
		echo "" >> $log
		for arquivo in "${listaPasta[@]}"
			do
				cp -r --parents $arquivo $montagem
				echo "$arquivo" >> $log
				echo "" >> $log
			done
		echo "Arquivos copiados" >> $log
		echo "---------------------------------" >> $log
		# Apos copiar tudo, verifica o volume copiado #
		echo "Volume copiado" >> $log
		echo "" >> $log
		du -sh $montagem/* >> $log
		echo "" >> $log
		echo "TOTAL" >> $log
		du -sh $montagem/ >> $log
		echo "" >> $log
		echo "---------------------------------" >> $log
		# Desmonta o 10.0.0.34 #
		umount $montagem
		# Manda o log por email #
		cat $log | mail -s "BACKUP DO SERVIDOR $hostname" $email
		exit 0
	fi
done
