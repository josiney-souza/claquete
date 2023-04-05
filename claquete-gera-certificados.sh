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

###############################################
##### Variaveis globais e de configuracao #####
###############################################

# Diretorios/pastas de destino dos arquivos gerados na execucao do sistema
DIR_FONTES_TEX="fontes-tex"
DIR_CERTIFICADOS_PDF="certificados-pdf"

############################
##### FUNCAO PRINCIPAL #####
############################

# Se receber "-rm" como o primeiro argumento, se encaminha para apagar os
# fontes LaTeX ou os PDFs anteriormente criados
#   Se o segundo argumento for "tex", apaga apenas o fontes LaTeX
#   Se o segundo argumento for "PDF", apaga apenas os PDFs
#   Se nao houver segundo argumento, apaga tanto os fontes LaTeX quanto os PDFs
# Senao, inicia o programa principal e as rotinas esperadas pelo sistema
if [[ $1 == "-rm" ]]
then
    if [[ $2 == "tex" ]]
    then
        cd ${DIR_FONTES_TEX} && rm -f ./* && cd - &> /dev/null
    elif [[ $2 == "pdf" ]]
    then
        cd ${DIR_CERTIFICADOS_PDF} && rm -f ./* && cd - &> /dev/null
    else
        cd ${DIR_FONTES_TEX} && rm -f ./* && cd - &> /dev/null
        cd ${DIR_CERTIFICADOS_PDF} && rm -f ./* && cd - &> /dev/null
    fi
else
    # Antes de se criar qualquer novo arquivo, apaga qualquer arquivo
    # remanescente da execucao anterior (fontes LaTeX e PDFs)
    cd ${DIR_FONTES_TEX} && rm -f ./* && cd - &> /dev/null
    cd ${DIR_CERTIFICADOS_PDF} && rm -f ./* && cd - &> /dev/null

    # A partir daqui, se inicia uma nova execucao do sistema
fi

exit 0
