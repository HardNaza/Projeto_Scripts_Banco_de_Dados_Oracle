################################################################################
## SHELL SCRIPT PARA REALIZAÇÃO DA RESTAURAÇÃO FULL UTILIZANDO IMPDP (LÓGICO) ##
################################################################################

################################################################
## CRIAÇÃO DO USUÁRIO E PERMISSÕES PARA EXECUÇÃO DO BKP EXPDP ##
################################################################
CREATE USER BACKUP IDENTIFIED BY BACKUP;
GRANT EXP_FULL_DATABASE TO BACKUP;
GRANT CONNECT TO BACKUP;
GRANT RESOURCE TO BACKUP;
CREATE DIRECTORY EXPDP AS '/caminho_do_diretório/'; # DIRECTORY EXPDP, PODE SER ALTERADO, AJUSTAR NO SCRIPT
GRANT READ,WRITE ON DIRECTORY EXPDP TO BACKUP;

##################################################
## INSTRUÇÃO PARA AGENDAMENTO DO BKP EM CRONTAB ##
##################################################
## OBS  : NO EXEMPLO EXCUÇÃO ESTÁ AGENDADA DIARIAMENTE AS 19H, ALTERAR CAMINHOS DE ACORDO COM AS CONFIGURAÇÕES DE INSTALAÇÃO DO BANCO ##
## OBS2 : ALTERAR VÁRIAVEL (3) CONFORME DIRETÓRIO CRIADO ACIMA (CREATE DIRECTORY EXPDP AS '/CAMINHO_DO_DIRETÓRIO/';)
00 19 * * * /caminho_do_script/restore_impdp.sh dbname dbname /caminho_do_diretório/ /oracle_base/ /oracle_home/

###############################################
## CRIAÇÃO DO SHELL SCRIPT "BACKUP_EXPDP.SH" ##
###############################################
#!/bin/bash

# PARAMETROS
# 1 = INSTÂNCIA
# 2 = NOME DO BANCO
# 3 = LOCAL BKP
# 4 = ORACLE BASE
# 5 = ORACLE HOME

## EXPORTA AS VÁRIAVEIS PARA EXECUÇÃO DO IMPDP ##
export DT='date +%a_%d%m' ## COLETA A DATA ATUAL
export ORACLE_SID=$1 ## COLETA SID
export ORACLE_BASE=$4 ## COLETA ORACLE BASE DE ACORDO COM LINHA DE CONFIGURAÇÃO DO CRON
export ORACLE_HOME=$5 ## COLETA ORACLE HOME DE ACORDO COM LINHA DE CONFIGURAÇÃO DO CRON
export PATH=$ORACLE_HOME/bin:$PATH ## VARIÁVEL DE AMBIENTE QUE CONTÉM OS DIRETÓRIOS EM QUE O ORACLE DATABASE PROCURA POR EXECUTÁVEIS E ARQUIVOS DE BIBLIOTECA


## COMANDO PARA EXECUÇÃO DA RESTAURAÇÃO IMPDP ##
$ORACLE_HOME/bin/impdp userid=backup/backup full=Y directory=EXPDP dumpfile=exp%U_$2_$DT.dmp logfile=imp_$2_$DT.log

## OBS: DUMPFILE AJUSTAR DE ACORDO COM O NOME DO ARQUIVO .DMP GERADO NO BKP

## USERID = INFORMAR USUÁRIO/SENHA
## FULL = REALIZA IMPDP FULL DA BASE
## DIRECTORY = DIRETÓRIO ONDE ESTÁ O ARQUIVO .DMP
## DUMPFILE = NOME DO ARQUIVO .DMP, MODIFICAR DE ACORDO COM O NOME GERADO NO BKP
## LOGFILE = NOME DO ARQUIVO DE LOG

## PARA MAIS INFORMAÇÕES, SEGUE DOCUMENTAÇÃO OFICIAL DA ORACLE
## https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_import.htm#SUTIL300