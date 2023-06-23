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

# Diretorio/pasta das imagens usadas no certificado
DIR_IMAGENS="imagens"

# Diretorio/pasta das bases de dados usadas no sistema Claquete
DIR_DADOS="dados"

# Bases de dados dos tipos/categorias de participantes do evento
DADOS_INSCRICOES="${DIR_DADOS}/dados-inscricoes.csv"
DADOS_OUVINTES="${DIR_DADOS}/dados-ouvintes.csv"
DADOS_PALESTRANTES="${DIR_DADOS}/dados-palestrantes.csv"
DADOS_MEDIADORES="${DIR_DADOS}/dados-mediadores.csv"
DADOS_ORGANIZACAO="${DIR_DADOS}/dados-organizacao.csv"

# Base de dados unica que junta todas as demais bases
DADOS="${DIR_DADOS}/dados.txt"

# Bases de certificados em LaTeX para cada categoria que sera gerada
BASE_OUVINTE="base-ouvinte.tex"
BASE_PALESTRANTE="base-palestrante.tex"
BASE_MEDIADOR="base-mediador.tex"
BASE_ORGANIZACAO="base-organizacao.tex"

# Indicacao dos arquivos de imagens usados nos certificados
FUNDO="${DIR_IMAGENS}/imagem-fundo.jpg"
ASSINATURA="${DIR_IMAGENS}/assinatura-pb.png"
GRADE="${DIR_IMAGENS}/juncao-grades.png"

# Cor do texto no certificado
CONF_COR="black"

# Dados gerais do evento
EVENTO="III Semana Acadêmica de Informática do Instituto Federal \
Catarinense - Campus Brusque"
PERIODO="25\/10\/2017 a 27\/10\/2017"
DATA=$(date +"%d de %B de %Y")



########################################
##### FUNCAO: cria_base_ouvintes() #####
########################################
function cria_base_ouvintes () {
    echo -n "Criando base de dados de ouvintes a partir das inscricoes... "

    rm -f ${DADOS_OUVINTES}
    cat ${DADOS_INSCRICOES} | while read PARTICIPANTE
    do
        EMAIL=$(echo $PARTICIPANTE | cut -d';' -f2)
        NOME=$(echo $PARTICIPANTE | cut -d';' -f3)
        CPF=$(echo $PARTICIPANTE | cut -d';' -f4)

    echo "${NOME};${CPF};ouvinte;24;${EMAIL}" >> ${DADOS_OUVINTES}
    done

    sleep 1s
    echo "OK."
}



#########################################
##### FUNCAO: cria_base_formatada() #####
#########################################
function cria_base_formatada () {
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
                ADICIONAL=$(echo $PARTICIPANTE | cut -d';' -f6)

            echo "${NOME};${CPF};${TIPO};${HORAS};${ADICIONAL}" >> ${DADOS}
            done
    done

    sleep 1s
    echo "OK."
}



#####################################
##### FUNCAO: cria_fontes_tex() #####
#####################################
function cria_fontes_tex () {
    echo -n "Criando todos os fontes do tipo .TEX... "

    cat ${DADOS} | while read PARTICIPANTE
    do
        NOME=$(echo $PARTICIPANTE | cut -d';' -f1)
        CPF=$(echo $PARTICIPANTE | cut -d';' -f2)
        TIPO=$(echo $PARTICIPANTE | cut -d';' -f3)
        HORAS=$(echo $PARTICIPANTE | cut -d';' -f4)
        ADICIONAL=$(echo $PARTICIPANTE | cut -d';' -f5)

        # Obtem o nome do participante e substitui os espacos em branco por
        # sublinhados/underline/underscore
        NOME_COM_UNDERLINE=$(echo $NOME | sed -e "s/ /_/g")

        # Define que o nome do arquivo sera certificado-NOME-TIPO, onde
        # NOME: nome da pessoa que recebera o certificado
        # TIPO: tipo/categoria de participacao no evento
        NOME_ARQUIVO="certificado-${NOME_COM_UNDERLINE}-${TIPO}"

        # Verifica se uma pessoa possui mais de um certificado para o mesmo
        # tipo/categoria de participacao
        # Se sim, adiciona um numero/contador para anexar ao nome do arquivo
        # LaTeX (e tambem PDF depois)
        if [ -e ${DIR_FONTES_TEX}/${NOME_ARQUIVO}.tex ]
        then
            cd ${DIR_FONTES_TEX}
            NOME_ARQUIVO=$(ls -1 ${NOME_ARQUIVO}*.tex | sort -t- -k 4 | \
                tail -n 1 | cut -d'.' -f1)
            NUM_CERTIFICADO=$(echo ${NOME_ARQUIVO} | cut -d'-' -f4)
	        if [[ ${NUM_CERTIFICADO} == "" ]]
            then
                NUM_CERTIFICADO=1
            else
                ((NUM_CERTIFICADO = ${NUM_CERTIFICADO} + 1))
            fi
NOME_ARQUIVO="certificado-${NOME_COM_UNDERLINE}-${TIPO}-${NUM_CERTIFICADO}"
            cd - &> /dev/null
        fi

        # Escolhe a base do certificado em LaTeX correta a depender do tipo/
        # categoria de participacao
        if [[ ${TIPO} == "ouvinte" ]]
        then
            cp ${BASE_OUVINTE} ${NOME_ARQUIVO}.tex
        elif [[ ${TIPO} == "palestrante" ]]
        then
            cp ${BASE_PALESTRANTE} ${NOME_ARQUIVO}.tex
            sed -i -e "s/TITULOP/${ADICIONAL}/g" ${NOME_ARQUIVO}.tex
        elif [[ ${TIPO} == "mediador" ]]
        then
            cp ${BASE_MEDIADOR} ${NOME_ARQUIVO}.tex
            sed -i -e "s/ASSUNTOP/${ADICIONAL}/g" ${NOME_ARQUIVO}.tex
        elif [[ ${TIPO} == "organizacao" ]]
        then
            TIPO="membro da Comissão de Organização"
            cp ${BASE_ORGANIZACAO} ${NOME_ARQUIVO}.tex
            sed -i -e "s/ATIVIDADESP/organizador/g" ${NOME_ARQUIVO}.tex
        else
            echo "ERRO: tipo de participante nao existe"
            exit 1
        fi

        # Substitui as informacoes das bases de dados nos arquivos de base do
        # certificado em LaTeX escolhido logo acima
        sed -i -e "s/NOMEP/${NOME}/g" -e "s/CPFP/${CPF}/g" \
            -e "s/TIPOP/${TIPO}/g" -e "s/HORASP/${HORAS}/g" \
            -e "s/EVENTOP/${EVENTO}/g" -e "s/PERIODOP/${PERIODO}/g" \
            -e "s/DATAP/${DATA}/g" ${NOME_ARQUIVO}.tex

        # Define a cor do texto dos certificados com base na configuracao
        # definida no comeco do script
        sed -i -e "s/CONF_COR/${CONF_COR}/g" ${NOME_ARQUIVO}.tex

        # Altera os tokens das imagens pelo valor das variaveis globais
        # OBS.: eh importante que o separador do sed(1) aqui seja qualquer
        #   um que nao a barra, pois ela eh usada nos caminhos das imagens
        sed -i -e "s#FUNDOP#${FUNDO}#g" -e "s#ASSINATURAP#${ASSINATURA}#g" \
            -e "s#GRADEP#${GRADE}#g" ${NOME_ARQUIVO}.tex

        # Realoca o arquivo-fonte LaTeX gerado para a pasta mais adequada
        mv ${NOME_ARQUIVO}.tex ${DIR_FONTES_TEX}
    done

    sleep 1s
    echo "OK."
}	



#######################################
##### FUNCAO: cria_certificados() #####
#######################################
function cria_certificados () {
    echo -n "Criando todos os certificados em .PDF... "

    # Para cada arquivo-fonte LaTeX gerado, cria um arquivo PDF de
    # certificado e o guarda no diretorio/pasta de arquivos PDFs
    # Devido a caracteristica do LaTeX, onde alguns simbolos nao sao gerados
    # com uma unica compilacao, executa-se a compilacao duas vezes em
    # sequencia
    cd ${DIR_FONTES_TEX}
    for FONTE in $(ls)
    do
        pdflatex -output-directory ../${DIR_CERTIFICADOS_PDF} ${FONTE} &> /dev/null
        pdflatex -output-directory ../${DIR_CERTIFICADOS_PDF} ${FONTE} &> /dev/null
    done
    cd - &> /dev/null

    # Remove todos os arquivos auxiliares gerados durante a criacao do PDF
    rm -f ${DIR_CERTIFICADOS_PDF}/*.{aux,log}

    sleep 1s
    echo "OK."
}



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

    # Cria a base de dados de ouvintes a partir da lista de inscritos obtida
    # do formulario disponivel na Internet
    cria_base_ouvintes

    # Cria uma base de dados unica juntando todas as demais bases de dados
    cria_base_formatada

    # Cria os arquivos-fonte em LaTeX como passo intermediario antes de gerar
    # os arquivos PDF
    cria_fontes_tex

    # Cria os arquivos PDF dos certificados
    cria_certificados
fi

exit 0
