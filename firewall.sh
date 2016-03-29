#!/bin/bash

#"------------------------------------------------------"
#"- Script de Firewall - iptables                      -"
#"- Criado por: Alessandro Librelato em 22/07/2015     -"
#"- Tecnologia da Informacao                           -"
#"- alibrelato@outlook.com                             -"
#"------------------------------------------------------"

###########################
##       VARIAVEIS       ##
###########################

### Cavecalho ###
cabecalho="
\e[31;2m
                      -------------------------------------
                      -- Criado por Alessandro Librelato --
                      -- Data: 21/01/2015                --
                      -------------------------------------
\e[m
\e[36;2m 
    ########  #######  ########   #####   ######   ##       #######   ######
       ##     ##    ##    ##     ##   ##  ##   ##  ##       ##       ##
       ##     #######     ##     ##   ##  ######   ##       #####     #####
       ##     ##          ##     #######  ##   ##  ##       ##            ##
    ########  ##          ##     ##   ##  ######   #######  #######  ######
\e[m
"
### Caminhos dos executaveis ###
iptables=/sbin/iptables
modprobe=/sbin/modprobe

### Portas de conexao ###
sshPort="22"
dnsPort="53"
httpPort="80"
httpsPort="443"
fwLogWatchPort="333"

### Redes externas confiaveis ###
redeInternaHosts="192.168.2.0/24" # rede interna rede VMs
redeInternaPC="192.168.1.0/24" # Rede externa PC

### interface de rede ###
ethRedeExterna="eth0"
ipRedeExterna="192.168.1.100"
ethRedeInterna="eth1"
ipRedeInterna="192.168.2.1"
ipFirewall="192.168.2.2"
ipWebServer="192.168.2.3"

######################
##      INICIO      ##
######################

iniciar()
    {
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Carregando os modulos..........................."
        ### Carrega os modulos do Iptables ###
        $modprobe ip_nat_ftp
        $modprobe ip_conntrack
        $modprobe ip_conntrack_ftp
        $modprobe ip_tables
        $modprobe iptable_nat    
        $modprobe ipt_mac
        $modprobe ipt_mark
        $modprobe ipt_multiport
        $modprobe ipt_LOG
        $modprobe ipt_REJECT
        $modprobe ipt_MASQUERADE
        echo -e "\e[32;2m[ OK ]\e[m"

        ### Definindo a politica Default das Cadeias ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Carregando politicas............................"
        $iptables -P INPUT DROP
        $iptables -P OUTPUT ACCEPT
        $iptables -P FORWARD DROP
        echo -e "\e[32;2m[ OK ]\e[m"

        ### Habilitando o roteamento no kernel - Trafego da rede interna para a internet ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Habilitando roteamento.........................."
        echo "1" > /proc/sys/net/ipv4/ip_forward
        echo -e "\e[32;2m[ OK ]\e[m"

        ### Habilitando a protecao contra ip spoofing ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Habilitando protecao ip spoofing................"
        echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
        echo -e "\e[32;2m[ OK ]\e[m"
        
        ### Liberando entrada no firewall ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Liberando entradas.............................."
        # Conexoes estabelecidas e confiaves #
        $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        # rejeita conexoes invalidas #
        $iptables -A INPUT -m state --state INVALID -j REJECT
        # Loopback #
        $iptables -A INPUT -i lo -j ACCEPT
        # Ping #
        $iptables -A INPUT -p icmp -j ACCEPT
        # Porta SSH #
        $iptables -I INPUT -p tcp --dport $sshPort -s $ipRedeExterna/24 -j ACCEPT
        $iptables -I INPUT -p tcp --dport $sshPort -s $ipRedeInterna/24 -j ACCEPT
        $iptables -A INPUT -p tcp --dport $sshPort -j REJECT
        # Porta DNS #
        $iptables -A INPUT -p tcp --sport $dnsPort -j ACCEPT
        $iptables -A INPUT -p tcp --dport $dnsPort -j ACCEPT
        $iptables -A INPUT -p udp --sport $dnsPort -j ACCEPT
        $iptables -A INPUT -p udp --dport $dnsPort -j ACCEPT
        # Minha rede #
        $iptables -A INPUT -s $ipRedeInterna -j ACCEPT
        $iptables -A INPUT -d $ipRedeInterna -j ACCEPT
        # Registro de logs #
        $iptables -A INPUT -p tcp --dport $fwLogWatchPort --syn -j LOG --log-prefix="[TENTATIVA ACESSO FWLOGWATCH]"
        $iptables -A INPUT -p tcp --dport $sshPort --syn -j LOG --log-prefix="[TENTATIVA ACESSO sshPort]"
        echo -e "\e[32;2m[ OK ]\e[m"

        ### Roteamentos ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Carregando roteamentos.........................."
        # Conexoes estabelecidas e confiaves #
        $iptables -A FORWARD -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT
        # Loopback #
        $iptables -A FORWARD -i lo -j ACCEPT
        $iptables -A FORWARD -o lo -j ACCEPT
        # Ping #
        $iptables -A FORWARD -p icmp -j ACCEPT
        # DNS #
        $iptables -A FORWARD -p tcp --sport $dnsPort -j ACCEPT
        $iptables -A FORWARD -p tcp --dport $dnsPort -j ACCEPT
        $iptables -A FORWARD -p udp --sport $dnsPort -j ACCEPT
        $iptables -A FORWARD -p udp --dport $dnsPort -j ACCEPT
        # HTTP #
        $iptables -A FORWARD -p tcp --dport $httpPort -j ACCEPT
        # HTTPS #
        $iptables -A FORWARD -p tcp --dport $httpsPort -j ACCEPT
        echo -e "\e[32;2m[ OK ]\e[m"
        
        ### NAT ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Configurando NAT................................"
        # Ativa o mascaramento de saida para a rede interna poder navegar pelos links #
        # Link de internet 1 #
        $iptables -A POSTROUTING -t nat -o $ethRedeExterna -j MASQUERADE
        # Link de internet 2 #
        $iptables -A POSTROUTING -t nat -o $ethRedeInterna -j MASQUERADE
        echo -e "\e[32;2m[ OK ]\e[m"

        ### Redirecionamento de porta ###
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Redirecionamento de porta......................."
        $iptables -t nat -A PREROUTING -d $ipFirewall -p tcp --dport $httpPort -j DNAT --to $ipWebServer:$httpPort
        echo -e "\e[32;2m[ OK ]\e[m"
		echo 
		echo 
    }

parar()
    {
        echo -n "[ `date "+%d/%m/%Y  %H:%M:%S"` ] Limpando as regrades de firewall................"
        $iptables -F
        $iptables -X
        $iptables -F -t nat
        $iptables -X -t nat
        $iptables -F -t mangle
        $iptables -X -t mangle
        $iptables -F -t filter
        $iptables -X -t filter
       echo -e "\e[32;2m[ OK ]\e[m"
    }

#####################################
### Opecoes de operacao do script ###
#####################################
clear
echo -e "$cabecalho";echo;echo

case "$1" in
    "start")
        iniciar
    ;;
    "stop")
        parar
    ;;
    "restart")
        parar;iniciar
    ;;
    *)
echo -e "\e[33;2m /etc/init.d/firewall start | stop | restart \e[m"
echo
esac
