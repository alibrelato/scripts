###############################################################################
#
# Script para atualizcao automatica do horario de servidores Linux
# Autor: Erico Rocha
# e-mail: erico.rocha@al.rs.gov.br
# Data: 20110311
# Versao: 1.0
#
# -----------------------------------------------------------------------------

###############################################################################
# Objetivos
#
# Realizar o processo de atualizcao automatica de hora com intermedio do pacote
# ntpdate. 
# Para isso, este script aciona o ntpdate para sincronizar automaticamente com o
# servidor sinope.alergs.br
#
# -----------------------------------------------------------------------------

###############################################################################
# Requisitos
#
# 1) Instalacao do aplicativo ntpdate. Comando apt-get install ntpdate
# 2) Script atualiza-hora.sh deve estar configurado com direito de acesso 744;
# 3) Crontab deve estar configurado de modo a possibilitar a execucao do script 
# todo o dia as 6 horas da manha;
#       0       6       *       *       *       root    /usr/local/bin/atualiza-hora.sh >/dev/null
#

###############################################################################
# Codigo
#
# -----------------------------------------------------------------------------
/usr/sbin/ntpdate 172.30.1.60
