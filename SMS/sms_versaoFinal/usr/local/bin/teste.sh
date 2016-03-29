#!/bin/bash

while true; do
	teste1=`ps aux | grep sms1.sh | grep -v grep | wc -l`
	echo "valor de teste1 = ${teste1}"
	teste12=`ps aux | grep sms1.sh | grep -v grep`
#	echo "escrita de teste 12 = ${teste12}"
#	echo "================================="
	teste2=`ps aux | grep sms2.sh | grep -v grep | wc -l`
        echo "valor de teste2 = ${teste2}"
	teste22=`ps aux | grep sms2.sh | grep -v grep`
#	echo "valor de teste 22 = ${teste22}"
	echo "================================="
	sleep 1 
done
