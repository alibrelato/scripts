#/bin/bash
##
## Por Alessandro Librelato em 05-05-2014
## Script para limpar a area publico do paleno
##
USUARIO="backup.service"
SENHA="backsrv!@06M"
DOMINIO="alergs.br"
SERVIDOR="172.30.1.50"
SERVIDOR_VNXCIFS="172.30.1.95"
DESTINO=/mnt/paleno
DESTINO_BACKUP=/mnt/backup

# Monta a pasta //paleno/publico dentro de /mnt/paleno
# sudo mount -t cifs -o user=admbkp,password=sgrela,domain=alergs.br //172.30.1.50/publico /mnt/paleno
sudo mount -t cifs -o user=${USUARIO},password=${SENHA},domain=${DOMINIO} //${SERVIDOR}/publico ${DESTINO}
sudo mount -t cifs -o user=${USUARIO},password=${SENHA},domain=${DOMINIO} //${SERVIDOR_VNXCIFS}/setoresroot$ ${DESTINO_BACKUP}

#sudo mount -t cifs -o user='backup.service',password='backsrv!@06M',domain=alergs.br //172.30.1.95/setoresroot$/Informatica/DTI/Rede/backupPublico /mnt/backup

# Procura pelos arquivos nao modificados nos ultimos 30 dias e os deleta
#sudo find ${DESTINO}/* -mtime +30 -exec rm -rif {} \; 

# -r = recursivo
# -f = force
# -v = verbose
# -p = preserva todos atributos
# --parents = com diretorios

## Faz backup dos arquivos com mais de 30 dias
sudo find ${DESTINO}/* -type f -a -mtime +30 -exec cp -rfp --parents {} /mnt/backup/Informatica/DTI/Rede/backupPublico \;

## Deleta os arquivos com mais de 30 dias
#sudo find ${DESTINO}/* -type f -a -mtime +30 -exec rm -f {} \;

## Deleta as pasta vazias 
#sudo find ${DESTINO}/* -empty -exec rm -rf {} \;

# Desmonta a pasta /paleno/publico dentro de /mnt/paleno
sudo umount ${DESTINO}
sudo umount ${DESTINO_BACKUP}
exit 0