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

destinoBackup=/data0/bkp_atualizacoes_portal/desenv_portal # onde o backup sera salvo
origemBackup=/usr/local/apache/htdocs/desenv_portal # de onde eh feito o backup
ambienteBackup="backup_desenv_portal" # nome do albiente de backup
ambienteGeral="desenv_portal" # ambiente geral do pacote
log=/var/log/atualizacao_portal/desenv.log # log do script
origemPacote=/usr/local/apache/uploads # de onde pega o pacote a ser atualizado
pacotesAtualizados=/usr/local/apache/uploads/atualizado_desenv # para onde move os pacotes apos serem atualizados
mailTo="alphatec@shoppingbrasil.com.br" # email de report

cabecalho="

        -------------------------------------
        -- Criado por Alessandro Librelato --
        -- Data: 29/05/2015                --
        -------------------------------------

         Atualizacao de pacotes em ambiente
                
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
        echo "======== Atualizacao do portal para o ambiente $ambienteGeral ========" > $log
        echo -e "$cabecalho"
        echo
        echo
        echo -n "    Nome do Pacote: "
        read pacote
        echo "" >> $log
        echo "`date "+%d/%m/%Y   %H:%M:%S"`   atualizacao iniciada para o pacote $pacote" >> $log
        # Verifica se o pacote digitado existe #
        if [ -e $pacote ]; then
            # Ajusta as permissoes do pacote para execuxao #
            sudo chown desenv:nobody $pacote
            echo "`date "+%d/%m/%Y   %H:%M:%S"`   permissao do pacote $pacote ajustado para desenv:nobody" >> $log
            sudo chmod 771 $pacote
            echo "`date "+%d/%m/%Y   %H:%M:%S"`   permissao do pacote $pacote ajustado para 771" >> $log
            # Entra na funcao backup #
            backup
        else
            # Se o pacote nao existe, manda o report por email e sai do script #
            echo
            echo "    O arquivo '$pacote' nao existe!!!"
            echo "`date "+%d/%m/%Y   %H:%M:%S"`   atualizacao falhou porque o pacote $pacote nao existe" >> $log
            echo
            echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
            exit 0
        fi
    }
function backup()
    {
        echo
        echo -e "\e[36;1m    INICIANDO O BACKUP \e[m"
        echo
        # Pega a lista de pacotes a serem atualizados #
        listaUpdate=`sudo tar -tvzf $pacote | cut -d: -f3 | cut -d' ' -f2 | grep '\.'`
        # Entra no diretorio para evitar problemas de bugs com o tar na hora de gerar o backup #
        cd $origemBackup
        # Verifica se o backup do pacote atual ja existe, para evitar perder backups antigos #
        if [ -e $destinoBackup/$ambienteBackup-$pacote ]; then
            # Se o backup do pacote atual ja existe, verifica se o usuario quer sobreencrever ele #
            echo -e "\e[33;1m    O backup '$ambienteBackup-$pacote' ja existe, deseja sobrescrever? \e[m"
            echo -n "    s/n: "
            read opcaoBackup
            case "$opcaoBackup" in
                # Se o usuario quer sobrescrever o antigo backup... #
                "s" | "S" | "sim" | "SIM")
                    echo "`date "+%d/%m/%Y   %H:%M:%S"`   o usuario optou por sobreencrever o backup que ja existe '$ambienteBackup-$pacote'" >> $log
                    # Deleta o antigo backup antes de iniciar o novo backup #
                    sudo rm -f $destinoBackup/$ambienteBackup-$pacote
                    # Caso o backup antigo nao tenha sido apagado. manda o report e sai do script #
                    if [ -e $destinoBackup/$ambienteBackup-$pacote ]; then
                        echo
                        echo -e "\e[31;1m    OPS... Nao foi possivel apagar o backup '$ambienteBackup-$pacote', pos favor verique! \e[m"
                        echo "`date "+%d/%m/%Y   %H:%M:%S"`   nao foi possivel apagar o backup '$ambienteBackup-$pacote' e o script encerrou a atualizacao" >> $log
                        echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                        echo
                        exit 0
                    else
                        # Se o backup foi apagado com sucesso... #
                        echo
                        echo -e "\e[32;1m    O antigo backup foi removido com sucesso! \e[m"
                        echo "`date "+%d/%m/%Y   %H:%M:%S"`   o backup '$ambienteBackup-$pacote' foi apagado com sucesso" >> $log
                        # Com o backup ja apagado, le linha a linha a lista de arquivos a se feito backup #
                        for listaArquivos in $(echo $listaUpdate ); do
                            # Verifica se o arquivo existe para fazer backup #
                            testaArquivo=`ls $listaArquivos`
                            # Testa se o arquivo atual em producao eh igual a o da lista de backup #
                            if test "$testaArquivo" = "$listaArquivos"; then
                                # Se esta tudo ok com o arquivo, faz backup #
                                echo "    O arquivo '$listaArquivos' esta ok para backup"
                                sudo tar rfP $destinoBackup/$ambienteBackup-$pacote $listaArquivos
                                echo "`date "+%d/%m/%Y   %H:%M:%S"`   feito backup do arquivo '$listaArquivos'" >> $log
                            else
                                # Se nao existe o arquivo para fazer backup... #
                                echo
                                echo -e "\e[33;1m    ATENCAO! O arquivo '$listaArquivos' NAO EXISTE para fazer backup, deseja prosseguir? \e[m"
                                echo -n "    s/n: "
                                read problemaBackup
                                case "$problemaBackup" in
                                    # Se o usuario quer seguir adiante mesmo nao existindo o arquivo para fazer backup, manda um aviso ao usuario #
                                    "s" | "S" | "sim" | "SIM")
                                        echo
                                        echo -e "\e[31;1m    O backup continuara sem o arquivo $listaArquivos \e[m"
                                        echo "`date "+%d/%m/%Y   %H:%M:%S"`   o arquivo $listaArquivos nao existe atualmente para fazer backup e o usuario quis seguir com o backup mesmo sem ele" >> $log
                                    ;;
                                    # Se o usuario nao quer seguir sem o backup do arquivo, manda o report por email e sai do script #
                                    "n" | "N" | "nao" | "NAO" )
                                        echo
                                        echo "    Saindo do script..."
                                        echo "`date "+%d/%m/%Y   %H:%M:%S"`   o arquivo $listaArquivos nao existe atualmente para fazer backup e o usuario NAO quis seguir adiante e o script encerrou a atualizacao" >> $log
                                        # Caso o TAR tenha sido criado, deleta antes de sair #
                                        if [ -e $destinoBackup/$ambienteBackup-$pacote ]; then
                                                sudo rm -f $destinoBackup/$ambienteBackup-$pacote
                                        fi
                                        echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                                        echo
                                        exit 0
                                    ;;
                                    *)
                                    # Se o usuario digitou uma opcao desconhecida, vai para o inicio do script #
                                    echo
                                    echo "    Opcao desconhecida, tente novamente..."
                                    sleep 3
                                    clear
                                    verificaPacote
                                    ;;
                                esac
                            fi
                        done
                        # Verifica se o backup foi criado corretamente, caso sim, entra na parte de atualizacao #
                        if [ -e $destinoBackup/$ambienteBackup-$pacote ]; then
                            # Ajusta a permissao do backup para o usuario desenv:nobody e 751 poder restaurar caso necessario #
                            sudo chmod 771 $destinoBackup/$ambienteBackup-$pacote
                            sudo chown desenv:nobody $destinoBackup/$ambienteBackup-$pacote
                            echo
                            echo -e "\e[32;1m    Permissoes do backup ajustadas \e[m"
                            echo -e "\e[32;1m    Backup criado com sucesso, proseguindo com a atualizacao! \e[m"
                            echo "`date "+%d/%m/%Y   %H:%M:%S"`   o backup foi criado com sucesso e as permissoes dele ajustadas para desenv:nobody e 771." >> $log
                            sleep 3
                            # Entra na funcao de atualizacao #
                            atualiza
                        # Caso nao tenha sido criado o backup, informa o erro, manda o report por email e sai do script #
                        else
                            echo
                            echo -e "\e[31;1m    ERRO! \e[m"
                            echo
                            echo -e "\e[33;1m    Nao foi possivel fazer backup do pacote, por favor verifique o problema! \e[m"
                            echo "O usuario optou por substituir o backup '$destinoBackup/$ambienteBackup-$pacote', mas por algum motivo o backup antigo foi apagado mas nao foi criado um novo" >> $log
                            echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                            echo
                            exit 0
                        fi
                    fi
                ;;
                # Caso o usuario nao queira sobreencrever o backup... #
                "n" | "N" | "nao" | "NAO" )
                    echo
                    echo -n "    Deseja atualizar mesmo sem fazer backup? s/n: "
                    read opcaoAtualiza
                    case "$opcaoAtualiza" in
                        # Caso o usuario queira atualizar sem o backup #
                        "s" | "S" | "sim" | "SIM")
                            echo
                            echo -e "\e[31;1m    ATENCAO! Atualizacao proseguira sem backup! \e[m"
                            echo "`date "+%d/%m/%Y   %H:%M:%S"`   o backup '$destinoBackup/$ambienteBackup-$pacote' ja existe e o usuario nao quis sobreescrevelo, mas quis continuar com a atualizacao sem fazer backup" >> $log
                            sleep 3
                            # Entra na funcao de atualizacao sem fazer backup por opcao do usuario #
                            atualiza
                            ;;
                        # Se o usuario nao quer atualizar porque o antigo backup ja existe, manda o report por email e sai do script #
                        "n" | "N" | "nao" | "NAO" )
                            echo
                            echo "    Atualizacao interrompida, o backup '$ambienteBackup-$pacote' ja existe e voce nao quis ir adiante"
                            echo "`date "+%d/%m/%Y   %H:%M:%S"`   atualizacao interrompida, o backup '$ambienteBackup-$pacote' ja existe e o usuario nao quis ir adiante" >> $log
                            sleep 3
                            echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                            echo
                            exit 0
                        ;;
                        *)
                        # Se o usuario digitou uma opcao desconhecida, vai para o inicio do script #
                        echo
                        echo "    Opcao desconhecida, tente novamente..."
                        sleep 3
                        clear
                        verificaPacote
                        ;;
                    esac
                ;;
                *)
                # Se o usuario digitou uma opcao desconhecida, vai para o inicio do script #
                echo
                echo "    Opcao desconhecida, tente novamente..."
                sleep 3
                clear
                echo -e "$cabecalho"
                verificaPacote
                ;;
            esac
        # Caso nao exista backup do pacote a ser rodado, cria um backup #
        else
            echo 
            # Le linha a linha os arquivos a serem feito backup #
            for listaArquivos in $(echo $listaUpdate ); do
                # Verifica se o arquivo existe #
                testaArquivo=`ls $listaArquivos`
                # Se o arquivo existe para ser feito backup, faz o TAR  #
                if test "$testaArquivo" = "$listaArquivos"; then
                    echo "    O arquivo '$listaArquivos' esta ok para backup"
                    sudo tar rfP $destinoBackup/$ambienteBackup-$pacote $listaArquivos
                    echo "`date "+%d/%m/%Y   %H:%M:%S"`   feito backup do arquivo '$listaArquivos'" >> $log
                # Se o arquivo a nao existe para fazer backup... #
                else
                    echo
                    echo -e "\e[33;1m    ATENCAO! O arquivo '$listaArquivos' NAO EXISTE, deseja prosseguir? \e[m"
                    echo -n "    s/n: "
                    read problemaBackup
                    case "$problemaBackup" in
                        # Se o usuario quer seguir adiante sem o backup do arquivo que nao existe na lista do pacote... #
                        "s" | "S" | "sim" | "SIM")
                            echo -e "\e[31;1m    O backup continuara sem o arquivo $listaArquivos \e[m"
                            echo "`date "+%d/%m/%Y   %H:%M:%S"`   o arquivo $listaArquivos nao existe atualmente para fazer backup e o usuario quis seguir com o backup mesmo sem ele" >> $log
                        ;;
                        # Se o usuario quer intenrromper o backup por causa do arquivo que nao existe na lista do pacote, sai do script #
                        "n" | "N" | "nao" | "NAO" )
                            echo
                            echo "    Saindo do script..."
                            echo "`date "+%d/%m/%Y   %H:%M:%S"`   o arquivo $listaArquivos nao existe atualmente para fazer backup e o usuario NAO quis seguir adiante e o script encerrou a atualizacao" >> $log
                            # Caso tenha sido criado o TAR do backup, apaga ele antes de sair #
                            if [ -e $destinoBackup/$ambienteBackup-$pacote ]; then
                                    sudo rm -f $destinoBackup/$ambienteBackup-$pacote
                            fi
                            echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                            echo
                            exit 0
                        ;;
                        *)
                        echo
                        echo "    Opcao desconhecida, tente novamente..."
                        sleep 3
                        clear
                        verificaPacote
                        ;;
                    esac
                fi
            done
            # Se o backup foi criado com sucesso, segue com a atualizacao #
            if [ -e $destinoBackup/$ambienteBackup-$pacote ]; then
                # Ajusta a permissao do backup para o usuario desenv:nobody porder restaurar caso necessario #
                sudo chmod 771 $destinoBackup/$ambienteBackup-$pacote
                sudo chown desenv:nobody $destinoBackup/$ambienteBackup-$pacote
                echo
                echo -e "\e[32;1m    Permissoes do backup ajustadas \e[m"
                echo -e "\e[32;1m    Backup criado com sucesso, proseguindo com a atualizacao! \e[m"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   o backup foi criado com sucesso e as permissoes dele ajustadas para desenv:nobody e 771." >> $log
                sleep 3
                # Entra na funcao de atualizacao #
                atualiza
            else
                # Se o backup nao foi criado, informa isso ao usuario e sai do script #
                echo
                echo -e "\e[31;1m    ERRO! \e[m"
                echo
                echo -e "\e[33;1m    Nao foi possivel fazer backup do pacote, por favor verifique o problema! \e[m"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   por algum motivo o backup '$destinoBackup/$ambienteBackup-$pacote' NAO foi criado e atualizacao nao aconteceu" >> $log
                echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                echo
                exit 0
            fi
        fi
    }
function atualiza()
    {
        echo
        echo -e "\e[36;1m    INICIANDO A ATUALIZACAO \e[m"
        echo
        echo "`date "+%d/%m/%Y   %H:%M:%S"`   iniciando a atualizacao do pacote '$pacote'" >> $log
        # Verifica se esta no diretorio correto para fazer atualizacao, necessario por causa do TAR #
        verificaDiretorio=`pwd`
        if test "$verificaDiretorio" != "$origemBackup"; then
            cd $origemBackup
        fi
        # Apos estar no diretorio correto, movimenta o tar para seguir com a atualizacao #
        mv $origemPacote/$pacote .
        if [ -e $pacote ]; then
            # Se moveu corretamente o pacote, faz a atualizacao #
            sudo tar -xvzf $pacote
            # Faz a alteracao de permissao linha a linha dos arquivos #
            echo
            for listaArquivos in $(echo $listaUpdate ); do
                sudo chown desenv:nobody $listaArquivos
                sudo chmod 771 $listaArquivos
                echo -e "    Permissao do arquivo $listaArquivos ajustado!"
            done
            # Movimenta o pacote para a area dos pacotes atualizados #
            mv $pacote $pacotesAtualizados
            # Se o pacote foi movimentado com sucesso #
            if [ -e $pacotesAtualizados/$pacote ]; then
                echo
                echo -e "\e[32;1m    Atualizacao concluida! \e[m"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   atualizacao concluida com sucesso para o pacote '$pacote'" >> $log
                echo "Segue em anexo o log de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "Atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                echo
                exit 0
            # Se o pacote nao foi movimentado com sucesso #
            else
                echo -e "\e[33;1m    A atualizacao foi feita com sucesso mas nao foi possivel mover o pacote para a pasta '$pacotesAtualizados', por favor verifique! \e[m"
                echo "`date "+%d/%m/%Y   %H:%M:%S"`   a atualizacao foi feita com sucesso mas nao foi possivel mover o pacote para a pasta '$pacotesAtualizados'" >> $log
                echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
                echo
                exit 0
            fi
        # Se o pacote nao foi movimentado para fazer a atualizacao #
        else
            echo
            echo -e "\e[31;1m    ERRO! \e[m"
            echo
            echo -e "\e[33;1m    Nao foi possivel copiar o pacote '$pacote' para o diretorio de atualizacao, por favor verifique! \e[m"
            echo "`date "+%d/%m/%Y   %H:%M:%S"`   nao foi possivel mover o pacote '$pacote' para iniciar a atualizacao" >> $log
            echo "Segue em anexo o log de erro da tentativa de atualizacao do $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" | mail -s "ERRO na atualizacao do ambiente $ambienteGeral em `date "+%d/%m/%Y as %H:%M:%S"`" -a $log $mailTo
            echo
            exit 0
        fi
    }
verificaPacote