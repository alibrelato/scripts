#/bin/bash
#set -x
##
## Por Alessandro Librelato em 05-05-2014
## Script para limpar a area publico do paleno
##
USUARIO="usuario"
SENHA="senha"
DOMINIO="dominio.br"
SERVIDOR_VNXCIFS="ipOuHostname"
DESTINO=/mnt/storage
EXCECAO=/mnt/storage/publico

######################################################################################################################
## IMPORTANTE																										##
## A variavel EXCECAO foi criada por uma solicitacao da taquigrafia, pois eles mesmo fazem a limpesa periodicamente ##
######################################################################################################################

## Monta a pasta //storage/publico dentro de /mnt/storage
mount -t cifs -o user=${USUARIO},password=${SENHA},domain=${DOMINIO} //${SERVIDOR_VNXCIFS}/setoresroot$  ${DESTINO}

# -r = recursivo
# -f = force
# -p = preserva todos atributos
# --parents = com diretorios

## Deleta os arquivos com mais de 60 dias, com excecao da pasta Taquigrafia
find ${DESTINO}/informatica/Publico/* -path ${EXCECAO} -prune -o -type f -a -mtime +60 -exec chmod 777 {} \;
##find ${DESTINO}/informatica/Publico/* -type f -a -mtime +60 -exec chmod 777 {} \;
find ${DESTINO}/informatica/Publico/* -path ${EXCECAO} -prune -o -type f -a -mtime +60 -exec rm -f {} \;
##find ${DESTINO}/informatica/Publico/* -type f -a -mtime +60 -exec rm -f {} \;

## Deleta as pasta vazias 
find ${DESTINO}/informatica/Publico/* -depth -type d -empty -exec chmod -R 777 {} \;
find ${DESTINO}/informatica/Publico/* -depth -type d -empty -exec rmdir {} \;

# Desmonta a pasta /paleno/publico dentro de /mnt/paleno
umount ${DESTINO}
exit 0
