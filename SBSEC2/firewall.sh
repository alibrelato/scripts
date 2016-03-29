#!/bin/bash
echo ""
echo ""
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "| Script de Firewall - iptables                               |"
echo "| Criado por: Jorge Visentini em 01/04/15                     |"
echo "| Revisado por: Alessandro Librelato em 02/04/15              |"
echo "| Tecnologia da Informacao                                    |"
echo "| jorge.visentini@operalpha.com.br                            |"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo ""
echo ""

#####################################################################
################### VARIAVEIS DO SCRiptables ########################
#####################################################################

### Caminhos dos executaveis ###
iptables=/usr/sbin/iptables
modprobe=/sbin/modprobe

### Portas de conexao ###
sshPort="40242"
vncPort1="5800"
vncPort2="5900"
vncPort3="6000"
dnsPort="53"
httpPort="80"
httpsPort="443"
fwLogWatchPort="333"

### Redes externas confiaveis ###
redeInternaSB="10.1.1.0/24" # rede interna da shoppingbrasil
redeInternaCC="10.0.0.0/24" # Rede interna da Commcorp ETH1

### interface de rede ###
ethRedeExterna0="eth0"
ipRedeExterna0="192.168.1.2"
ethRedeExterna2="eth2"
ipRedeExterna2="192.168.2.2"

#####################################################################
############################# FIREWALL ##############################
#####################################################################

iniciar()
    {
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando os modulos................................."
        ### Carrega os módulos do Iptables ###
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
        echo "[ OK ]"

        ### Flush - Limpa tudo o que esta carregado ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Limpando as regras anteriores........................."
        $iptables -F
        $iptables -X
        $iptables -F -t nat
        $iptables -X -t nat
        $iptables -F -t mangle
        $iptables -X -t mangle
        $iptables -F -t filter
        $iptables -X -t filter
        echo "[ OK ]"

        ### Definindo a Politica Default das Cadeias ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando politicas.................................."
        $iptables -P INPUT DROP
        $iptables -P OUTPUT ACCEPT
        $iptables -P FORWARD DROP
        echo "[ OK ]"

        ### Habilitando o roteamento no kernel - Trafego da rede interna para a internet ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Habilitando roteamento................................"
        echo "1" > /proc/sys/net/ipv4/ip_forward
        echo "[ OK ]"

        ### Habilitando a protecao contra ip spoofing ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Habilitando protecao ip spoofing......................"
        echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
        echo "[ OK ]"
        
        ### Liberando entrada no firewall ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Liberando entradas...................................."
        # Conexoes estabelecidas e confiaves #
        $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        # rejeita conexoes invalidas #
        $iptables -A INPUT -m state --state INVALID -j REJECT
        # Loopback #
        $iptables -A INPUT -i lo -j ACCEPT
        # Ping #
        $iptables -A INPUT -p icmp -j ACCEPT
        # Porta SSH #
        $iptables -A INPUT -p tcp --dport $sshPort -j ACCEPT
        # Porta DNS #
        $iptables -A INPUT -p tcp --sport $dnsPort -j ACCEPT
        $iptables -A INPUT -p tcp --dport $dnsPort -j ACCEPT
        $iptables -A INPUT -p udp --sport $dnsPort -j ACCEPT
        $iptables -A INPUT -p udp --dport $dnsPort -j ACCEPT
        # Rede Interna Commcorp #
        $iptables -A INPUT -s $redeInternaCC -j ACCEPT
        $iptables -A INPUT -d $redeInternaCC -j ACCEPT
        # Rede Interna ShoppingBrasil #
        $iptables -A INPUT -s $redeInternaSB -j ACCEPT
        $iptables -A INPUT -d $redeInternaSB -j ACCEPT
        # Acesso VNC da rede da ShoppingBrasil no Firewal #
        $iptables -A INPUT -s $redeInternaSB -m multiport -p tcp --dport $vncPort1,$vncPort2,$vncPort3 -j ACCEPT
        # Registro de logs #
        $iptables -A INPUT -p tcp --dport $fwLogWatchPort --syn -j LOG --log-prefix="[TENTATIVA ACESSO FWLOGWATCH]"
        $iptables -A INPUT -p tcp --dport $sshPort --syn -j LOG --log-prefix="[TENTATIVA ACESSO sshPort]"
        echo "[ OK ]"

        ### Roteamentos ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando roteamentos................................"
        # Conexoes estabelecidas e confiaves #
        $iptables -A FORWARD -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT
        # Registro de logs #
        $iptables -A FORWARD -m multiport -p tcp --dport $vncPort1,$vncPort2,$vncPort3 -j LOG --log-prefix="[ACESSO VNC]"
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
        echo "[ OK ]"
        
        ### NAT ###
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Configurando NAT......................................"
        # Ativa o mascaramento de saida para a rede interna poder navegar pelos links #
        # Link de internet 1 #
        $iptables -A POSTROUTING -t nat -o $ethRedeExterna0 -j MASQUERADE
        # Link de internet 2 #
        $iptables -A POSTROUTING -t nat -o $ethRedeExterna2 -j MASQUERADE
        echo "[ OK ]"
		echo ""
		echo ""
    }

parar()
    {
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Desativando Firewall.................................."
        $iptables -F
        $iptables -X
        $iptables -F -t nat
        $iptables -X -t nat
        $iptables -F -t mangle
        $iptables -X -t mangle
        $iptables -F -t filter
        $iptables -X -t filter
        echo "[ OK ]"
    }

#####################################
### Opecoes de operacao do script ###
#####################################

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
echo "start|stop|restart"
esac
