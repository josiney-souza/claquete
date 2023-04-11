#! /bin/bash

# This file is part of Claquete.

# Claquete is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Claquete is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Claquete.  If not, see <https://www.gnu.org/licenses/>

# Definicoes e configuracoes globais
DADOS_BASE_UNICA="dados-base-unica.txt"
DADOS_BASE_UNICA_FORMATADA="dados-base-unica-formatada.txt"
TITULO_EMAIL="Certificado da III Semana Acadêmica de Informática do IFC Brusque"
TEXTO_PADRAO="texto-padrao.txt"
DIR_CERTIFICADOS_PDF="certificados-pdf"
COMANDOS="comandos.txt"

# Cria uma base de dados unica de todas as categorias
cat dados-{mediadores,organizacao,ouvintes,palestrantes}.csv > ${DADOS_BASE_UNICA}

# Adequa a base de dados unica para conter apenas o nome completo e o e-mail
cat ${DADOS_BASE_UNICA} | cut -d';' -f1,5 | sort -u > ${DADOS_BASE_UNICA_FORMATADA}

# Escreve em um arquivo o comando que será utilizado para enviar os
# certificados
cat ${DADOS_BASE_UNICA_FORMATADA} | while read DADO
do
    DESTINATARIO=$(echo ${DADO} | cut -d';' -f1)
    DESTINATARIO_FORMATADO=$(echo ${DESTINATARIO} | sed -e "s/ /_/g")
    EMAIL_DESTINATARIO=$(echo ${DADO} | cut -d';' -f2)

    echo "mutt -x -s \"${TITULO_EMAIL}\" -i ${TEXTO_PADRAO} \
        -a ${DIR_CERTIFICADOS_PDF}/*${DESTINATARIO_FORMATADO}* \
        -- ${EMAIL_DESTINATARIO}" >> ${COMANDOS}
done

# Le o arquivo criado anteriormente e, para cada linha, a executa
TAM=$(wc -l ${COMANDOS} | cut -d' ' -f1)
ENVIAR=$(head -n 1 ${COMANDOS})
eval ${ENVIAR} <<< "."
for VALOR in $(seq 2 ${TAM})
do
    ENVIAR=$(head -n ${VALOR} ${COMANDOS} | tail -n 1)
    eval ${ENVIAR} <<< "."
done

# Remove os arquivos temporarios que foram criados
rm -f ${DADOS_BASE_UNICA} ${DADOS_BASE_UNICA_FORMATADA} ${COMANDOS}

exit 0
