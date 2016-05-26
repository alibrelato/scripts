#/bin/bash
##
## Por Alessandro Librelato em 05-05-2014
## Script para limpar a area publico do paleno
##
USUARIO="usuario"
SENHA="senha"
DOMINIO="dominio.br"
SERVIDOR="ipOuHostname"
SERVIDOR_VNXCIFS="ipOuHostname"
DESTINO=/mnt/storage
DESTINO_BACKUP=/mnt/backup

# Monta a pasta //storage/publico dentro de /mnt/storage
sudo mount -t cifs -o user=${USUARIO},password=${SENHA},domain=${DOMINIO} //${SERVIDOR}/publico ${DESTINO}
sudo mount -t cifs -o user=${USUARIO},password=${SENHA},domain=${DOMINIO} //${SERVIDOR_VNXCIFS}/setoresroot$ ${DESTINO_BACKUP}

# Procura pelos arquivos nao modificados nos ultimos 30 dias e os deleta
#sudo find ${DESTINO}/* -mtime +30 -exec rm -rif {} \; 

# -r = recursivo
# -f = force
# -v = verbose
# -p = preserva todos atributos
# --parents = com diretorios

## Faz backup dos arquivos com mais de 30 dias dentro do storage morto
sudo find ${DESTINO}/* -type f -a -mtime +30 -exec cp -rfp --parents {} /mnt/backup/pastaBackupStorage \;

## Deleta os arquivos com mais de 30 dias
sudo find ${DESTINO}/* -type f -a -mtime +30 -exec rm -f {} \;

## Deleta as pasta vazias 
sudo find ${DESTINO}/* -empty -exec rm -rf {} \;

# Desmonta a pasta /paleno/publico dentro de /mnt/paleno
sudo umount ${DESTINO}
sudo umount ${DESTINO_BACKUP}
exit 0
