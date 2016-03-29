@echo off
REM ATENÇÃO
REM o arquivo ip.txt precisa existir no mesmo diretorio da bat com a lista dos ips a ser consultado
REM

cls
REM le linha a linha do arquivo ip.txt
FOR /F %%I IN (ip.txt) DO (
REM faz o teste de ping procurando pela string TTL oara saber se o servidor esta na rede
ping -n 1 %%I | find "TTL=" >nul
    if errorlevel 1 (
        REM se o NAO ip responde escreve o ip no arquivo online.txt
		echo %%I >> offline.txt
        ) else (
		REM se o ip responde escreve o ip no arquivo online.txt
        echo %%I >> online.txt
        )
)
pause
exit