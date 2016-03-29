#!/bin/bash
# Script de limpeza dos logs de busca dos robos
# By Leonardo Oliveira
# 24.09.2013

find /srv/www/htdocs/botsb/log -maxdepth 1 -name '*' -daystart ! -mtime -3 -exec rm {} \;


