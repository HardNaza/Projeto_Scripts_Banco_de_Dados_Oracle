########################################################################
## SHELL SCRIPT PARA REALIZAÇÃO DE BKP FULL UTILIZANDO EXPDP (LÓGICO) ##
########################################################################

################################################################
## CRIAÇÃO DO USUÁRIO E PERMISSÕES PARA EXECUÇÃO DO BKP EXPDP ##
################################################################
CREATE USER BACKUP IDENTIFIED BY BACKUP;
GRANT EXP_FULL_DATABASE TO BACKUP;
GRANT CONNECT TO BACKUP;
GRANT RESOURCE TO BACKUP;
CREATE DIRECTORY EXPDP AS '/caminho_do_diretório/'; # DIRECTORY EXPDP, PODE SER ALTERADO AJUSTAR NO SCRIPT
GRANT READ,WRITE ON DIRECTORY EXPDP TO BACKUP;

##################################################
## INSTRUÇÃO PARA AGENDAMENTO DO BKP EM CRONTAB ##
##################################################
## OBS  : NO EXEMPLO EXCUÇÃO ESTÁ AGENDADA DIARIAMENTE AS 19H, ALTERAR CAMINHOS DE ACORDO COM AS CONFIGURAÇÕES DE INSTALAÇÃO DO BANCO ##
## OBS2 : ALTERAR VÁRIAVEL (3) CONFORME DIRETÓRIO CRIADO ACIMA (CREATE DIRECTORY EXPDP AS '/CAMINHO_DO_DIRETÓRIO/';)
00 19 * * * /caminho_do_script/backup_expdp.sh dbname dbname /caminho_do_diretório/ /oracle_base/ /oracle_home/ 2

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
# 6 = DIAS DE RENTENÇÃO DO BKP

## EXPORTA AS VÁRIAVEIS PARA EXECUÇÃO DO EXPDP ##
export DT='date +%a_%d%m' ## COLETA A DATA ATUAL
export ORACLE_SID=$1 ## COLETA SID
export ORACLE_BASE=$4 ## COLETA ORACLE BASE DE ACORDO COM LINHA DE CONFIGURAÇÃO DO CRON
export ORACLE_HOME=$5 ## COLETA ORACLE HOME DE ACORDO COM LINHA DE CONFIGURAÇÃO DO CRON
export PATH=$ORACLE_HOME/bin:$PATH ## VARIÁVEL DE AMBIENTE QUE CONTÉM OS DIRETÓRIOS EM QUE O ORACLE DATABASE PROCURA POR EXECUTÁVEIS E ARQUIVOS DE BIBLIOTECA

## EXPORTA AS VÁRIAVEIS PARA RETENÇÃO DO EXPDP ##
export BKP_OLD=$3/bkp_antigo/expdp/$2 ## COLETA O CAMINHO DO BKP E SALVA NA VÁRIAVEL BKP_OLD -- $3 -> (/caminho_onde_será_salvo_bkp) bkp_antigo/expdp $2 -> (dbname)
export BKP_NEW=$3/bkp_novo/expdp/$2 ## COLETA O CAMINHO DO BKP E SALVA NA VÁRIAVEL BKP_NEW   -- $3 -> (/caminho_onde_será_salvo_bkp) bkp_novo/expdp $2 -> (dbname)

## EXEMPLO DO CAMINHO DE ACORDO COM OS PARAMETROS INFORMADOS ##
## CREATE DIRECTORY EXPDP AS '/caminho_do_diretório/';
## export BKP_OLD =$3/bkp_antigo/expdp/$2
## export BKP_NEW =$3/bkp_novo/expdp/$2

## CAMINHO: /caminho_do_diretório/bkp_antigo/expdp/dbname
## CAMINHO: /caminho_do_diretório/bkp_novo/expdp/dbname

## REALIZA O ACESSO AO DIRETÓRIO "bkp_antigo" ONDE ESTÁ LOCALIZADO A RETENÇÃO DO BKP UTILIZANDO A VARIÁVEL BKP_OLD ##
cd $BKP_OLD
find . -name "*.dmp" -type f ! -mtime -$6 -exec rm -f {} \; ## DELETA OS ARQUIVOS .DMP COM BASE NA VÁRIAVEL $6 -> 2 DIAS DE RENTENÇÃO DMP
find . -name "*.gz" -type f ! -mtime -$6 -exec rm -f {} \;  ## DELETA OS ARQUIVOS .GZ  COM BASE NA VÁRIAVEL $6 -> 2 DIAS DE RENTENÇÃO GZ
find . -name "*.log" -type f ! -mtime -$6 -exec rm -f {} \; ## DELETA OS ARQUIVOS .LOG COM BASE NA VÁRIAVEL $6 -> 2 DIAS DE RENTENÇÃO LOG

## REALIZA O ACESSO AO DIRETÓRIO ONDE ESTÁ LOCALIZADO O BKP ATUAL UTILIZANDO A VARIÁVEL BKP_NEW E REALIZA A MOVIMENTAÇÃO DOS ARQUIVOS .DMP .GZ .LOG PARA O DIRETÓRIO "bkp_antigo" ##
cd $BKP_NEW
mv *.dmp $REP/.
mv *.gz $REP/.
mv *.log $REP/.

## COMANDO PARA EXECUÇÃO DO BACKUP EXPDP ##
$ORACLE_HOME/bin/expdp userid=backup/backup full=Y filesize=10G directory=EXPDP dumpfile=exp%U_$2_$DT.dmp logfile=expfull_$2_$DT.log flashback_time=systimestamp

## %U     = NUMERA OS ARQUIVOS DE DUMP. exp01_dbname_seg3105.dmp, exp02_dbname_seg3105.dmp
## DT(%a) = NOME ABREVIADO DO DIA DA SEMANA. Dom, Seg, Ter

## USERID = INFORMAR USUÁRIO/SENHA
## FULL = REALIZA BKP EXPDP FULL DA BASE
## FILESIZE = REALIZA A DIVISÃO DOS ARQUIVOS .DMP EM 10G CADA
## DIRECTORY = DIRETÓRIO ONDE SERÁ REALIZADO O BKP (CREATE DIRECTORY EXPDP AS '/CAMINHO_DO_DIRETÓRIO/';)
## DUMPFILE = NOME DO ARQUIVO .DMP
## LOGFILE = NOME DO ARQUIVO DE LOG
## FLASHBACK_TIME = ESPECIFICAR UM PONTO NO TEMPO PARA RECUPERAÇÃO DE DADOS USANDO A TECNOLOGIA FLASHBACK (SYSTIMESTAMP -> COLETA O MOMENTO ATUAL DO SERVIDOR, PARA COLETAR OUTRO TEMPO UTILIZAR -> 'DD-MON-YYYY HH24:MI:SS')
## OBS: É IMPORTANTE OBSERVAR QUE O USO DO PARÂMETRO FLASHBACK_TIME REQUER QUE A FUNCIONALIDADE FLASHBACK ESTEJA HABILITADA NO BANCO DE DADOS ORACLE E QUE HAJA INFORMAÇÕES DE FLASHBACK SUFICIENTES DISPONÍVEIS PARA O PERÍODO DE TEMPO ESPECIFICADO.

## REALIZA A COMPACTAÇÃO DOS ARQUIVOS .DMP NO DIRETÓRIO "bkp_novo"
cd $BKP_NEW/
gzip -f *.dmp

## PARA MAIS INFORMAÇÕES, SEGUE DOCUMENTAÇÃO OFICIAL DA ORACLE
## https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_export.htm#SUTIL200