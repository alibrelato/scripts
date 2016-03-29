DATAHORA=`date +%Y-%m-%d_%H%M%S`
cd /etc/firewall/backup_firewall
mkdir bkp_firewall_$DATAHORA
cp ../*  bkp_firewall_$DATAHORA/
tar --file=bkp_firewall_$DATAHORA.tar.gz --exclude=*.tar.gz -cvz  bkp_firewall_$DATAHORA
rm -r bkp_firewall_$DATAHORA
echo "SEGUE LOGS DE BKP DO FIREWALL DA MP" | mail -s "BKP ARQUIVOS FIREWALL MP"  -a bkp_firewall_$DATAHORA.tar.gz alphatec@shoppingbrasil.com.br
