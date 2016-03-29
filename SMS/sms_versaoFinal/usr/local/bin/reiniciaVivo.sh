#!/bin/bash
#set -x
### Para reiniciar o servico de driver da vivo "HWActivator" ###
dia="$(date +%Y-%m-%d)"

tentativa1=$(ps aux | grep HWActivator | grep -v grep  | awk '{print $2}')
kill ${tentativa1}
hora="$(date +%H:%M:%S)"
sleep 5
tentativa2=$(ps aux | grep HWActivator | grep -v grep  | awk '{print $2}')
if [ ${tentativa2} ]; then
	killall HWActivator
	sleep 5
	hora="$(date +%H:%M:%S)"
	tentativa3=$(ps aux | grep HWActivator | grep -v grep  | awk '{print $2}')
	if [ -z ${tentativa3} ]; then
		echo "processo runhwacticator encerrado com sucesso na segunda tentativa as ${hora} do dia ${dia}"  >> /var/log/reiniciaVivo.log
		/etc/init.d/runhwactivator start >> /var/log/reiniciaVivo.log
		hora="$(date +%H:%M:%S)"
		echo "processo runhwacticator reiniciado com sucesso as ${hora} do dia ${dia}" >> /var/log/reiniciaVivo.log
	else
		echo "Nao foi possivel encerrar o processo HWActivator as ${hora} do dia ${dia}"  >> /var/log/reiniciaVivo.log
	fi
else
	echo "processo HWActivator encerrado com sucesso na primeira tentativa as ${hora} do dia ${dia}" >> /var/log/reiniciaVivo.log
	/etc/init.d/runhwactivator start >> /var/log/reiniciaVivo.log
	hora="$(date +%H:%M:%S)"
	echo "processo runhwacticator reiniciado com sucesso as ${hora} do dia ${dia}" >> /var/log/reiniciaVivo.log
fi

## agendamento no crontab
## 0  12   * * *   root    /usr/local/bin/reiniciaVivo.sh >/dev/null 2>&1
## 0  23   * * *   root    /usr/local/bin/reiniciaVivo.sh >/dev/null 2>&1