#!/bin/bash
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
### Inicio das Regras ###
# Definindo variaveis do Script
ETH_INVALID=eth0  
ETH_WAN=eth1                  ; export ETH_INVALID
ETH_DMZ=eth2
#IP_WAN=200.215.216.114
IP_WAN=187.112.54.17
IP_WWW_SHOPPING=192.168.7.254    ; export IP_WWW_SHOPPING 
IP_INFORMA=187.103.103.34
IP_FTP_SHOPPING=187.103.103.40
IP_FTP_TURQUIA=187.103.103.41
IP_FTP_INDIA=187.103.103.42
IP_MAIL_SHOPPING=187.103.103.45
IP_CHRISTIAN=10.1.1.122
IP_BRUNO=10.1.1.211
IP_INVALID=10.1.1.254
IP_CONECTA=186.215.138.234
IP_GVT=201.22.213.230 
IP_LP=200.192.133.129               ; export IP_LP
IP_LP2=200.192.133.131              ; export IP_LP2
IP_LP3=200.192.133.130              ; export IP_LP3
IP_UOL=200.192.132.167
ANY=0.0.0.0/0
NET=10.1.1.1/24
NET2=10.0.0.0/24
###ips/PORT SERVERS
PORT_DNS=53                         ; export PORT_DNS
PORT_FTP=21                         ; export PORT_FTP
PORT_NAGIOS=5666                    ; export PORT_NAGIOS
PORT_POSTGRES=5432                  ; export PORT_POSTGRES
PORT_SMTP=25                        ; export PORT_SMTP
PORT_SSH_DEFAULT=22                 ; export PORT_SSH_DEFAULT
PORT_HTTP_DEFAULT=80                ; export PORT_HTTP_DEFAULT
#REDIRECT
IP_REDIRECT=10.0.0.243
PORT_SSH_REDIRECT=60243
PORT_HTTP_REDIRECT=80
#WWW INFORMA
IP_WWW=10.0.0.2
PORT_HTTP_WWW=80
PORT_SSH_WWW=22402  
PORT_ORACLE_WWW=1521
#WWW INFONRMA DESENV
IP_IBDESENV=10.0.0.252
PORT_HTTP_IBDESENV=8052
PORT_SSH_IBDESENV=60252
#WWW INFONRMA 
IP_IB0=10.0.0.253
PORT_HTTP_IB0=80
PORT_SSH_IB0=60253
PORT_FTP_IB0=21
PORT_FTP2_IB0=20
#CGP
IP_CGP=10.0.0.100
PORT_SSH_CGP=8021
#MONITORA
IP_MONITORA=10.0.0.20
PORT_SSH_MONITORA=60020
#HYPER13
IP_HYPER13=10.0.0.127
#HYPER9
PORT_VNC_HYPER9=5901
#HYPER13
IP_HYPER9=10.0.0.64
PORT_VNC_HYPER13=5902
#HYPER19
IP_HYPER19=10.0.0.19
PORT_VNC_HYPER19=5919
PORT_SSH_HYPER19=60219
#LXBACKUP
IP_ICONNA=192.168.3.226
PORT_VNC_LXBACKUP=5951
#CHINA
IP_CHINA=10.0.0.101
PORT_SSH_CHINA=60101
PORT_ORACLE_CHINA=1101
#ANTISPAM - MAILSCANNER
IP_ANTISPAM=10.0.0.6
#INDIA
IP_INDIA=10.0.0.10
PORT_SSH_INDIA=22123 
PORT_HTTP_INDIA=8005 
PORT_FTP_INDIA=21 
PORT_FTP2_INDIA=20
#TURQUIA
IP_TURQUIA=10.0.0.41
PORT_SSH_TURQUIA=22
PORT_FTP_TURQUIA=21
#INDIAN
IP_INDIAN=10.0.0.9
PORT_SSH_INDIAN=22765
#NTPDD
IP_NTPDD=10.0.0.17
PORT_RDP_NTPDD=33999
#HYPER13
IP_HYPER13=10.0.0.127
#NEWCHINA
IP_NEWCHINA=10.0.0.101
#LX1DEV01
IP_LX1DEV01=10.0.0.129
PORT_HTTP_LX1DEV01=8881             ;
#LX1DEV02
IP_LX1DEV02=10.0.0.131
PORT_HTTP_LX1DEV02=80            ; 
#WWWDEV01
IP_WWWDEV01=10.0.0.130
PORT_HTTP_WWWDEV01=8892             ;
PORT_ORACLE_LXORA1=1523             ; 
PORT_ORACLE_LX1DEV01=1129       ;
PORT_ORACLE_LX1DEV02=1131        ;
PORT_ORACLE_WWWDEV01=1130         ;
PORT_ORACLE_NEWCHINA=1101          ;
PORT_SSH_LX1DEV01=60129
PORT_SSH_LX1DEV02=60131
PORT_SSH_WWWDEV01=60130
#WDB
IP_WDB=10.0.0.2
PORT_ORACLE_WDB=1534
PORT_ORACLE_WDB2=1521
PORT_SSH_WDB=22256
PORT_EMANAGER_WDB=1158   
PORT_OPMON_WDB=5656
PORT_WDB_MONITORA=8963 
#LXORA1
IP_LXORA1=10.0.0.33
PORT_ORACLE_LXORA1=1523
PORT_SSH_LXORA1=22636
#LX_PDD
IP_LXPDD=10.0.0.8  
PORT_SAMBA_LXPDD=139
PORT_SSH_LXPDD=60008
PORT_MS_LXPDD=445
#WWW
IP_WWW=10.0.0.2
PORT_SSH_WWW=22402
PORT_HTTP_WWW=80
#LX1
IP_LX1=10.0.0.22
PORT_SSH_LX1=60022
PORT_HTTP_LX1=80
PORT_FTP_LX1=21
PORT_FTP2_LX1=20
#SERVIDOR_MONITORA_IT
IP_NOTE_RICA=10.0.0.21
TUNEL2=209.59.219.31
#SERVIDOR HYPER13
IP_HYPER13=10.0.0.127
#svn
IP_SVN=10.0.0.80
PORT_VPN_SVN=5001
PORT_VPNT_SVN=15001
#CGP
IP_MAIL=10.1.1.6
PORT_HTTPA_MAIL=9010
PORT_HTTPWEB_MAIL=8000
PORT_IMAP_MAIL=143
PORT_POP_MAIL=110
PORT_POPS_MAIL=993
PORT_SMTPS_MAIL=587
#FONSECA SHOW
#IP_ROBERTO=10.0.0.13
#ROBOS =
#ROBOS=10.1.1.211-10.1.1.230
### Passo 1: Primeiro vamos arrumar a casa :) ###
# Limpando as Regras
iptables -F          # Limpa as cadeias INPUT, OUTPUT e FORWARD 
iptables -F -t nat   # Limpa a tabela de nat
iptables -F -t mangle
# Definindo a Politica Default das Cadeias
iptables -P INPUT DROP      # Protege o Firewall
iptables -P OUTPUT ACCEPT   # Na maioria das vezes, pode ser deixada aberta
iptables -P FORWARD DROP    # Protege a rede Local
### Passo 2: Antes de Servir, vamos nos proteger ! ###
# Desabilitando o trÃ¡fego IP Entre as Placas de Rede
echo "0" > /proc/sys/net/ipv4/ip_forward
# Configurando a ProteÃ§Ã£o anti-spoofing
echo " Setting anti-spoofing .....[ OK ]"
for spoofing in /proc/sys/net/ipv4/conf/*/rp_filter; do
        echo "1" > $spoofing
done
# Cadeia de Entrada. Esta cadeia, no iptables, sÃ³ vale para o prÃ³prio host
# Qualquer pacote Ip que venha do localhost, Ok.
iptables -A INPUT -i lo -j ACCEPT
# Aqui, falta uma regra
iptables -A INPUT -i $ETH_INVALID -j ACCEPT
iptables -A INPUT -i $NET -j ACCEPT
iptables -A INPUT -i $NET2 -j ACCEPT
# Regras icmp INPUT
iptables -A INPUT -p icmp -s $ANY --icmp-type 0 -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp -s $ANY --icmp-type 8 -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp -s $ANY --icmp-type 3 -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp -s $ANY --icmp-type 11 -m limit --limit 1/s -j ACCEPT
# Regras icmp
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
echo "1" > /proc/sys/net/ipv4/ip_dynaddr
# Fragmentacao de IP
iptables -A INPUT -f -j DROP
# Pacote Invalidos
iptables -A INPUT -p tcp -s $ANY -d $ANY -m state --state INVALID -j DROP
# Logs do iptables
iptables -A INPUT -j LOG    # muita "sujeira"
iptables -A FORWARD -j LOG    # muita "sujeira"
#iptables -A INPUT -s ! $net -d ! $net -j LOG  # um pouco menos
#iptables -A INPUT -j LOG --log-level notice  --log-prefix "Iptables Log" 
# Ativando o SSH para a rede externa
#SSH PEGA MALANDRO
iptables -I INPUT -p tcp -i $ETH_WAN --dport 22 -j LOG --log-level 3 --log-prefix "<SSH_ATACK> "
#iptables -I INPUT -p tcp -i $ETH_WAN --dport 60222 -j LOG --log-level 3 --log-prefix "<SSH_REAL> "

iptables -I INPUT -p udp -i $ETH_WAN --dport 5001 -m limit --limit 1/s -m state --state NEW -j ACCEPT
#iptables -I INPUT -p tcp -i $ETH_WAN --dport 60222 -m limit --limit 1/s -m state --state NEW -j ACCEPT
# No iptables, temos de dizer quais sockets sao validos em uma conexao
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#BLOQUEIOS GERAL
# IPs bloqueados
#iptables -A INPUT -i $ETH_WAN -s 78.109.164.20 -j DROP
#iptables -A INPUT -i $ETH_WAN -s 65.160.238.180 -j DROP
iptables -A INPUT -i $NET -s 10.0.0.0/24 -j ACCEPT
iptables -A INPUT -i $NET -s 10.1.1.0/24 -j ACCEPT
iptables -A INPUT -i $NET2 -s 10.0.0.0/24 -j ACCEPT
iptables -A INPUT -i $NET2 -s 10.1.1.0/24 -j ACCEPT
#####BLOQUEIO DE SCAN
iptables -N SCANNER                                                                                                                                 
iptables -A SCANNER -m limit --limit 15/m -j LOG --log-level 6 --log-prefix "<portScanner> "                                              
iptables -A SCANNER -j DROP                                                                                                                         
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -i $ETH_WAN -j SCANNER                                                                             
iptables -A INPUT -p tcp --tcp-flags ALL NONE -i $ETH_WAN -j SCANNER                                                                                    
iptables -A INPUT -p tcp --tcp-flags ALL ALL -i $ETH_WAN -j SCANNER                                                                                     
iptables -A INPUT -p tcp --tcp-flags ALL FIN,SYN -i $ETH_WAN -j SCANNER                                                                                 
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -i $ETH_WAN -j SCANNER                                                                     
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -i $ETH_WAN -j SCANNER                                                                             
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -i $ETH_WAN -j SCANNER                                                                             
 echo 'OK -> Port Scanner Protection...'                                                                                                             
     ## BLOQUEANDO PORT SCANNERS OCULTOS                                                                                                                 
     iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT                                                           
     echo 'OK -> Hidden Port Scanner Protection...'     
# Primeiro, vamos ativar o mascaramento ( nat ).
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o $ETH_WAN -j MASQUERADE
#
#iptables -A FORWARD -s $IP_CHRISTIAN -d 0/0 -j ACCEPT
#iptables -A FORWARD -s $IP_BRUNO -d 0/0 -j ACCEPT
#iptables -A FORWARD -s $IP_ICONNA -d 0/0 -j ACCEPT
#iptables -A FORWARD -s 0/0 -d $IP_ICONNA -j ACCEPT
iptables -A FORWARD -s 0/0 -d $NET -j ACCEPT
#iptables -A FORWARD -m iprange --src-range $ROBOS -d 0/0 -j ACCEPT
iptables -A FORWARD -o $ETH_INVALID -j ACCEPT
iptables -A FORWARD -p icmp -s $ANY --icmp-type 0 -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD -p icmp -s $ANY --icmp-type 8 -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD -p icmp -s $ANY --icmp-type 3 -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD -p icmp -s $ANY --icmp-type 11 -m limit --limit 1/s -j ACCEPT
# Aqui Falta outra Regra
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
### Finalmente, podemos "Ligar" os nossos clientes :) ###
# Habilitando o trÃ¡fego Ip, entre as Interfaces de rede
#echo "1" > /proc/sys/net/ipv4/ip_forward
#echo " Firewall OK ...............[ OK ]"
#route add -net 10.60.0.0 netmask 255.255.255.0 gw 10.1.1.1
#route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.1.1.1
#route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.0.0.240
#route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.60.0.6
#route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.60.0.6

