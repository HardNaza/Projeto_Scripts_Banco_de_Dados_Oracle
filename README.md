Projeto de Scripts para Banco de Dados Oracle

Este projeto consiste em quatro scripts relacionados ao banco de dados Oracle. Responsável pela realização de exportação e importação de dados usando o utilitário 'expdp' e 'impdp' e backup e restauração do banco de dados utilizando o utilitário 'Rman'.

## Script de Exportação e Importação (expdp/impdp)

### Pré-requisitos

- Oracle Database instalado e configurado corretamente.
- Direitos de acesso necessários para executar as operações de exportação e importação.

### Funcionalidades

O script 'backup_expdp.sh' permite a realização de exportações de dados em um banco de dados Oracle. Ele possui as seguintes funcionalidades:

- Exportação completa (Full).
- Exportação com compressão.

O script 'restore_impdp.sh' permite a realização de importações de dados em um banco de dados Oracle. Ele possui as seguintes funcionalidades:

- Importação completa (Full).

## Script de Backup e Restauração (Rman)

### Pré-requisitos

- Oracle Database instalado e configurado corretamente.
- Direitos de acesso necessários para executar operações de backup e restauração.

### Funcionalidades

O script 'backup_rman.sh' permite realizar backups de um banco de dados Oracle usando o utilitário `Rman`. Ele possui as seguintes funcionalidades:

- Backup completo do banco de dados.

O script 'restore_rman.sh' permite realizar restaurações de um banco de dados Oracle usando o utilitário `Rman`. Ele possui as seguintes funcionalidades:

- Restauração completa do banco de dados.

Certifique-se de fornecer as informações corretas e seguir as instruções apresentadas pelo script para realizar o backup ou restauração adequados.