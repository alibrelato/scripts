#!/bin/bash
######################################
######################################
##  Desenvolvido por:               ##
##  Alessandro Librelato            ##
##  Data : 01/07/2015               ##
##  Versao : 1.0                    ##
######################################
######################################
#set -x

origemBackup=/data0/bkp_atualizacoes_portal/desenv_portal # de onde vem o backup a ser restaurado
destinoAtualizacao=/usr/local/apache/htdocs/desenv_portal # onde o pacote de backup sera restaurado
ambienteGeral="desenv_portal" # ambiente geral do pacote
log=/var/log/atualizacao_portal/restauracao_desenv.log # log do script
pacotesAtualizados=/usr/local/apache/uploads/atualizado_desenv # para onde move os pacotes apos serem atualizados
mailTo="alphatec@shoppingbrasil.com.br" # email de report
cabecalho="

        -------------------------------------
        -- Criado por Alessandro Librelato --
        -- Data: 29/05/2015                --
        -------------------------------------

         Restauracao de pacotes em ambiente
                
\e[36;1m                  DESENVOLVIMENTO
\e[m
"
function verificaPacote()
    {
        clear
        # Apaga o log caso ele exista #
        if [ -e $log ]; then
            sudo rm -f $log
        fi
        echo "======== Restauracao do portal para o ambiente $ambienteGeral ========" > $log
        echo -e "$cabecalho"
        echo
        echo
        echo -n "    Nome do Pacote: "
        read pacote
        echo "" >> $log
        echo "`date "+%d/%m/%Y   %H:%M:%S"`   atualizacao iniciada para o pacote $pacote" >> $log
        # Verifica se o pacote digitado existe #
        if [ -e $origemBackup/$pacote ]; then
            # Copia o pacote para o diretorio correto #
            cp $origemBackup/$pacote $destinoAtualizacao
            # Testa se o pacote foi devidamente copiado para o diretorio correto #
            if [ -e $destinoAtualizacao/$pacote ]; then
                # Ajusta as permissoes do pacote para execuxao #
                sudo chown desenv:nobody $destinoAtualizacao/$pacote
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   permissao do pacote $pacote ajustado para desenv:nobody" >> $log
                sudo chmod 771 $destinoAtualizacao/$pacote
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   permissao do pacote $pacote ajustado para 771" >> $log
                # Entra na funcao atualiza #
                atualiza
            else
                echo
                echo "    Nao foi possivel copiar o arquivo '$origemBackup/$pacote' para iniciar a restauracao!"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   restauracao falhou porque o pacote '$pacote' nao foi copiado corretamente de '$origemBackup' para '$destinoAtualizacao'" >> $log
                echo "Segue em anexo o log de erro da tentativa de restauracao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na restauracao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                exit 0
            fi
        else
            # Se o pacote nao existe, sai do script #
            echo
            echo "    O arquivo '$origemBackup/$pacote' nao existe!!!"
            echo "`date "+%d/%m/%Y   %H:%M:%S"`   restauracao falhou porque o pacote $origemBackup/$pacote nao existe" >> $log
            echo
            echo "Segue em anexo o log de erro da tentativa de restauracao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na restauracao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
            exit 0
        fi
    }

function atualiza()
    {
        echo
        echo -e "\e[36;1m    INICIANDo A RESTAURACAO \e[m"
        echo
        echo "`date "+%d/%m/%Y   %H:%M:%S"`   iniciando a atualizacao do pacote $pacote" >> $log
        # Verifica se esta no diretorio correto para fazer atualizacao, necessario por causa do TAR #
        verificaDiretorio=`pwd`
        if test "$verificaDiretorio" != "$destinoAtualizacao"; then
            cd $destinoAtualizacao
        fi
        # Verifica se o pacote foi de fato copiado para iniciar a restauracao #
        if [ -e $pacote ]; then
            # Se moveu corretamente o pacote faz a atualizacao #
            sudo tar -xvzf $pacote
            listaUpdate=`sudo tar -tvzf $pacote | cut -d: -f3 | cut -d' ' -f2 | grep '\.'`
            # Faz a alteracao de permissao linha a linha dos arquivos #
            for listaArquivos in $(echo $listaUpdate ); do
                sudo chown desenv:nobody $listaArquivos
                sudo chmod 771 $listaArquivos
                echo
                echo -e "    Permissao do arquivo $listaArquivos ajustado"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   permissao do arquivo $listaArquivos ajustado" >> $log
            done
            # Movimenta o pacote para a area dos pacotes atualizados #
            mv $pacote $pacotesAtualizados
            # Se o pacote foi movimentado com sucesso #
            if [ -e $pacotesAtualizados/$pacote ]; then
                echo
                echo -e "\e[32;1m    Atualizacao concluida! \e[m"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   atualizacao concluida com sucesso para o pacote $pacote" >> $log
                echo
                echo "Segue em anexo o log de restauracao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "Restauracao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                exit 0
            # Se o pacote nao foi movimentado com sucesso #
            else
                echo -e "\e[33;1m    A atualizacao foi feita com sucesso mas nao foi possivel mover o pacote para a pasta $pacotesAtualizados, por favor verifique! \e[m"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   restauracao feita com sucesso mas nao foi possivel mover o pacote $pacote para a pasta $pacotesAtualizados" >> $log
                echo
                echo "Segue em anexo o log de erro da tentativa de restauracao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na restauracao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                exit 0
            fi
        # Se o pacote nao foi movimentado para fazer a atualizacao #
        else
            echo
            echo -e "\e[31;1m    ERRO! \e[m"
            echo
            echo -e "\e[33;1m    Nao foi possivel copiar o pacote '$pacote' para o diretorio de atualizacao, por favor verifique! \e[m"
            echo "`date "+%d/%m/%Y   %H:%M:%S"`   nao foi possivel mover o pacote $pacote para iniciar a atualizacao" >> $log
            echo "Segue em anexo o log de erro da tentativa de restauracao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na restauracao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
            exit 0
        fi
    }
verificaPacote