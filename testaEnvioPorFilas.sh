#!/bin/bash
#set -x
## Variaveis globais ##
contador=0 # Contador para o numero das filas #
hostname=`hostname` # nome do host #
emailOrigem="a.librelato@terra.com.br" # email de origem #
emailDestino="alibrelato@gmail.com" # email de destino #
listaDeIp=/tmp/ip.txt # Lista com os ips das filas #

# Apaga a antiga lista de ips #
if [ -e $listaDeIp ]; then
    rm -f $listaDeIp
fi
# Pega o nome das eth que tem filas #
eth=`ifconfig | awk '{print $1}' | grep eth1`
# Pega os ipts de cada fila #
for interface in $(echo $eth); do
    ifconfig $interface | head -n2 | tail -n1 | cut -d: -f2 | awk '{print $1}' >> $listaDeIp
done
# Envia o email de teste de acordo com a lista de ips #
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
done < $listaDeIp
if [ -e $listaDeIp ]; then
    rm -f $listaDeIp
fi
exit 0
