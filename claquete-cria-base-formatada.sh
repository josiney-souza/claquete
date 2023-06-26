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



echo -n "Criando base de dados formatada para o script... "

rm -f ${DADOS}
for BASE_USADA in ${DADOS_OUVINTES} ${DADOS_PALESTRANTES} \
    ${DADOS_MEDIADORES} ${DADOS_ORGANIZACAO}
do
    cat ${BASE_USADA} | while read PARTICIPANTE
    do
        NOME=$(echo $PARTICIPANTE | cut -d';' -f1)
        CPF=$(echo $PARTICIPANTE | cut -d';' -f2)
        TIPO=$(echo $PARTICIPANTE | cut -d';' -f3)
        HORAS=$(echo $PARTICIPANTE | cut -d';' -f4)
        EMAIL=$(echo $PARTICIPANTE | cut -d';' -f5)
        ADICIONAL=$(echo $PARTICIPANTE | cut -d';' -f6)

    echo "${NOME};${CPF};${TIPO};${HORAS};${EMAIL};${ADICIONAL}" >> ${DADOS}
    done
done

sleep 1s
echo "OK."

exit 0
