#!/bin/bash
##############################################################
# Envia os e-mails conforme a quantidade de filas do postfix #
##############################################################
#set-x
contador=0 # Contador para o numero das filas
hostname=`hostname`
emailOrigem="usuario@dominio"
emailDestino="usuario@dominio"

# Se o arquivo ip.txt existe, apaga #
if [ -e ip.txt ]; then
        rm -f ip.txt
fi
# Pega o ip da interface eth1 #
ifconfig eth1 | head -n2 | tail -n1 | cut -d: -f2 | awk '{print $1}' >> ip.txt
# Pega o ip da interface eth1:1 ate a eth1:9 #
for i in $(seq 1 9); do
ifconfig eth1:0$i | head -n2 | tail -n1 | cut -d: -f2 | awk '{print $1}' >> ip.txt
done
# Pega o ip da interface eth1:10 ate a eth1:11 #
for i in $(seq 10 11); do
ifconfig eth1:$i | head -n2 | tail -n1 | cut -d: -f2 | awk '{print $1}' >> ip.txt
done
# Le a lista de ip e manda os emails #
while read ip; do
(
echo "helo terra.com.br";
sleep 1;
echo "MAIL FROM: <$emailOrigem>";
sleep 1;
echo "RCPT TO: <$emailDestino>";
sleep 1;
echo "DATA";
sleep 1;
echo -e "Subject: Fila $contador";
echo -e "host $hostname";
echo -e "ip $ip";
echo -e ".";
sleep 2;
echo -e "quit";
) | telnet $ip 25
# Incrementa o contador em 1 #
let contador=$contador+1;
done < ip.txt
