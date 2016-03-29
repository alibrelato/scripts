#!/bin/bash
#!/bin/bash
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "| Script de Firewall - IPTABLES					     |"
echo "| Criado por: Paulo Ricardo kuhn				     |" 
echo "| Revisado por: Alessandro Librelato em 16/01/2015		     |" 
echo "| Seguranca da Informacao					     |"
echo "| alphatec@shoppingbrasil.com.br		                     |"
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
#INPUT conexoes de entrada
#FORWARD trafego de dados 
#OUTPUT conexao de saída

#####################################################################
######################## VARIAVEIS DO SCRIPT ########################
#####################################################################
### caminhos dos executaveis ###
iptables=/usr/sbin/iptables
modprobe=/sbin/modprobe
### portas de conexao ###
sshPort="60222"
traceroutePort="33434"
monitoraPort="8962"
fwLogWatchPort="333"
telnetPort="23"
vncPort1="5800"
vncPort2="5900"
vncPort3="6000"
### redes externas confiaveis ###
ipExternoSB="201.22.213.230" # rede externa da shoppingbrasil
ipExternoCC="187.103.103.33" # rede externa da commcorp
redeInternaSB="10.1.1.0/24" # rede interna da shoppingbrasil
redeInternaCC="10.0.0.0/24" # rede interna da commcorp
interfaceVPN="tap0"
any="0.0.0.0/0"
### interface de rede externo ###
ethRedeExterna="eth1"
ipRedeExterna="177.159.101.197"
### interface de rede interno ###
ethRedeInterna="eth0"
ipRedeInterna="192.168.0.0/24"
### Gateways do Link ###
ipGateway="177.159.101.193"

#####################################################################
########################## FIREWALL SCRIPT ##########################
#####################################################################

iniciar()
    {
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando os modulos....................."
        ### Carrega os módulos do iptables ###
        ${modprobe} ip_nat_ftp
        ${modprobe} ip_conntrack_ftp
        ${modprobe} ip_conntrack
        ${modprobe} ip_tables
        ${modprobe} iptable_nat
        ${modprobe} iptable_nat	
        ${modprobe} ipt_mac
        ${modprobe} ipt_mark
        ${modprobe} ipt_multiport
        ${modprobe} ip_conntrack_ftp
        ${modprobe} ip_nat_ftp
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Limpando as regras anteriores............."
        ### Flush - limpa tudo o que esta carregado ###
        ${iptables} -F          
        ${iptables} -F -t nat
        ${iptables} -F -t mangle
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Ativando regras do Firewall..............."
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando politicas......................"
        ### definindo a Politica Default das Cadeias ###
        ${iptables} -P INPUT DROP # bloqueia toda entrada de dados
        ${iptables} -P OUTPUT ACCEPT # libera toda saída
        ${iptables} -P FORWARD DROP # bloqueia passagem de dados
        ### habilitando o trafego IP entre as Interfaces de rede ###
        echo "1" > /proc/sys/net/ipv4/ip_forward
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Estabelecendo conexoes...................."
        ### Conexoes estabelecidas ###
        ${iptables} -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT	# aceita conexoes estabelecidas de entrada
        ${iptables} -A FORWARD -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT # aceita passagem de dados
        #${iptables} -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
        #
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Compartilhando a Internet................."
        ### compartilhando a internet ###
        ${iptables} -t nat -A POSTROUTING -o ${ethRedeExterna} -j MASQUERADE # compartilha com as demais interfaces a conexao de eth1
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando loopback......................."
        ### Loopback ###
        ${iptables} -A INPUT -i lo -j ACCEPT # liberando conexao para 127.0.0.1
        #${iptables} -A OUTPUT -o lo -j ACCEPT
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Abrindo porta SSH........................."
        ### liberando porta ssh ###
        ${iptables} -A INPUT -i ${ethRedeExterna} -p tcp --dport ${sshPort} -j ACCEPT # libera conexao sshPort vindo de ip externo
        ${iptables} -A INPUT -i ${ethRedeInterna} -p tcp --dport ${sshPort} -j ACCEPT # libera conexao sshPort vindo de ip interno
        ${iptables} -A INPUT -i ${interfaceVPN} -p tcp --dport ${sshPort} -j ACCEPT # libera conexao sshPort vindo de ip da vpn
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Abrindo porta traceroute.................."
        ### liberando porta para traceroute ###
        ${iptables} -A INPUT -p udp --dport ${traceroutePort} -j ACCEPT # libera traceroute de entrada
        ${iptables} -A OUTPUT -p udp --dport ${traceroutePort} -j ACCEPT # libera traceroute de saida
        ${iptables} -A FORWARD -p udp --dport ${traceroutePort} -j ACCEPT # # libera traceroute na passagem de rede por causa da VPN
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Abrindo porta monitora...................."
        ### liberando porta para o monitora ###
        ${iptables} -A INPUT -p tcp --dport ${monitoraPort} -j ACCEPT
        ${iptables} -A OUTPUT -p tcp --dport ${monitoraPort} -j ACCEPT
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando os servicos...................."
        ${iptables} -A INPUT -f -j DROP
        ${iptables} -A INPUT -p tcp -s ${any} -d ${any} -m state --state INVALID -j DROP
        #
        # Libera consulta a DNS (comentando pq o output esta em accept liberando todas saidas)
        #${iptables} -A INPUT -p udp -i $ethRedeInterna --dport 53 -j ACCEPT
        #${iptables} -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
        #${iptables} -t filter -A FORWARD -i $ethRedeInterna -p udp --dport 53 -j ACCEPT
        # Libera Ping para IP/Host especifico
        ${iptables} -A INPUT -s ${ipRedeInterna} -p icmp -j ACCEPT # Interna
        ${iptables} -A INPUT -s ${ipExternoSB} -p icmp -j ACCEPT # GVT_SB
        ${iptables} -A INPUT -s ${ipExternoCC} -p icmp -j ACCEPT # CC
        ${iptables} -A FORWARD -s ${ipRedeInterna} -p icmp -j ACCEPT # Interna
        ${iptables} -A FORWARD -s ${redeInternaSB} -p icmp -j ACCEPT
        ${iptables} -A FORWARD -s ${redeInternaCC} -p icmp -j ACCEPT
        ${iptables} -A OUTPUT -s ${ipRedeInterna} -p icmp -j ACCEPT # Interna
        ${iptables} -A INPUT -s ${redeInternaSB} -p icmp -j ACCEPT # SB
        ${iptables} -A INPUT -s ${redeInternaCC} -p icmp -j ACCEPT # CC
        ${iptables} -A INPUT -s ${ipRedeInterna} -p icmp --icmp-type 8 -j ACCEPT
        ${iptables} -A INPUT -p icmp -s ${any} --icmp-type 0 -m limit --limit 1/s -j ACCEPT
        ${iptables} -A INPUT -p icmp -s ${any} --icmp-type 8 -m limit --limit 1/s -j ACCEPT
        ${iptables} -A INPUT -p icmp -s ${any} --icmp-type 3 -m limit --limit 1/s -j ACCEPT
        ${iptables} -A INPUT -p icmp -s ${any} --icmp-type 11 -m limit --limit 1/s -j ACCEPT
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando as protecoes..................."
        # Protecoes contra ataques
        ${iptables} -A INPUT -m state --state INVALID -j REJECT # rejeita conexoes invalidas
        # Protege contra port scanners avançados (Ex.: nmap)
        ${iptables} -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
        ${iptables} -t filter -A INPUT -i ${ethRedeExterna} -m state --state new -j DROP
        #${iptables} -N scan
        #${iptables} -A scan -j DROP
        #${iptables} -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -i $ethRedeExterna -j scan
        #${iptables} -A INPUT -p tcp --tcp-flags ALL NONE -i $ethRedeExterna -j scan
        #${iptables} -A INPUT -p tcp --tcp-flags ALL ALL -i $ethRedeExterna -j scan
        #${iptables} -A INPUT -p tcp --tcp-flags ALL FIN,SYN -i $ethRedeExterna -j scan
        #${iptables} -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -i $ethRedeExterna -j scan
        #${iptables} -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -i $ethRedeExterna -j scan
        #${iptables} -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -i $ethRedeExterna -j scan
        for spoofing in /proc/sys/net/ipv4/conf/*/rp_filter; do
            echo "1" > ${spoofing}
        done
        # Bloqueio de scanners ocultos (Shealt Scan)
        ${iptables} -A FORWARD -p tcp --tcp-flags SYN,ACK, FIN,  -m limit --limit 1/s -j ACCEPT
        # Registro de logs
        ${iptables} -A INPUT -p tcp --dport ${fwLogWatchPort} --syn -j LOG --log-prefix="[TENTATIVA ACESSO FWLOGWATCH]"
        ${iptables} -A INPUT -p tcp --dport ${telnetPort} --syn -j LOG --log-prefix="[TENTATIVA ACESSO TELNET]"
        ${iptables} -A FORWARD -m multiport -p tcp --dport ${vncPort1},${vncPort2},${vncPort3} -j LOG --log-prefix="[ACESSO VNC]"
        ${iptables} -A INPUT -p tcp --dport ${sshPort} --syn -j LOG --log-prefix="[TENTATIVA ACESSO sshPort]"
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Carregando as restricoes de IP............"
        ### libera para ips especificos acessar o firewall ###
        #${iptables} -A FORWARD -p tcp --destination-port 80 -s 192.168.0.3 -j ACCEPT # proxy
        #iptables -A FORWARD -s 192.168.0.3 -p tcp -m tcp --dport 80 -j ACCEPT # proxy
        echo "[ OK ]"
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Firewall carregado........................"
        echo "[ OK ]"
    }
parar()
    {
        echo -n "[ $(date +%d/%m/%Y) $(date +%H:%M) ] Desativando Firewall......................"
        iptables -F -t nat
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