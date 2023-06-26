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

source variaveis.txt



########################################
##### FUNCAO: cria_base_ouvintes() #####
########################################
echo -n "Criando base de dados de ouvintes a partir das inscricoes... "

rm -f ${DADOS_OUVINTES}
cat ${DADOS_INSCRICOES} | while read PARTICIPANTE
do
    DATAHORA=$(echo $PARTICIPANTE | cut -d';' -f1)
    EMAIL=$(echo $PARTICIPANTE | cut -d';' -f2)
    NOME=$(echo $PARTICIPANTE | cut -d';' -f3)
    CPF=$(echo $PARTICIPANTE | cut -d';' -f4)
    VINCULO=$(echo $PARTICIPANTE | cut -d';' -f5)
    NECESSITA_NE=$(echo $PARTICIPANTE | cut -d';' -f6)
    NE=$(echo $PARTICIPANTE | cut -d';' -f7)

echo "${NOME};${CPF};ouvinte;24;${EMAIL};${VINCULO};$NECESSITA_NE;${NE};${DATAHORA}" >> ${DADOS_OUVINTES}
done

sleep 1s
echo "OK."

exit 0
