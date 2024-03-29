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



#####################################
##### FUNCAO: cria_fontes_tex() #####
#####################################
function cria_fontes_tex () {
    echo -n "Criando todos os fontes do tipo .TEX... "

    cat ${DADOS} | while read PARTICIPANTE
    do
        # Para cada linha no arquivo ${CAMPO_TOKENS}, obtem os campos:
        # 1 - nome da variável a se usar neste script
        # 2 - campo correspondente na base de dados formatada e unica
        # 3 - token nos arquivos TEX relacionado aos dois primeiros campos
        #
        # Entao prepara a string da linha que deve ser executada, sendo
        # executada de fato a partir do comando eval (embutido do BASH)
        #
        # O controle do loop esta sobre a quantidade de linhas do arquivo
        QTDE_TOKENS=$(wc -l ${CAMPOS_TOKENS} | awk '{print $1}')
        for NUM_LINHA in $(seq 1 ${QTDE_TOKENS})
        do
            LINHA=$(sed -n ${NUM_LINHA}p ${CAMPOS_TOKENS})
            VARIAVEL=$(echo ${LINHA} | cut -d";" -f1)
            CAMPO=$(echo ${LINHA} | cut -d";" -f2)
            TOKEN=$(echo ${LINHA} | cut -d";" -f3)
            EXECUTAR="${VARIAVEL}=\"$(echo ${PARTICIPANTE} | cut -d';' \
                -f${CAMPO})\""
            eval ${EXECUTAR}
        done

        # Obtem o nome do participante e substitui os espacos em branco por
        # sublinhados/underline/underscore
        NOME_COM_UNDERLINE=$(echo $NOME | sed -e "s# #_#g")

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
        cp ${BASE_GERAL} ${NOME_ARQUIVO}.tex
        if [[ ${TIPO} == "ouvinte" ]]
        then
            CONTEUDO=$(cat ${BASE_OUVINTE})
        elif [[ ${TIPO} == "palestrante" ]]
        then
            CONTEUDO=$(cat ${BASE_PALESTRANTE})
        elif [[ ${TIPO} == "mediador" ]]
        then
            CONTEUDO=$(cat ${BASE_MEDIADOR})
        elif [[ ${TIPO} == "organizacao" ]]
        then
            TIPO="membro da Comissão de Organização"
            CONTEUDO=$(cat ${BASE_ORGANIZACAO})
        else
            echo "ERRO: tipo de participante nao existe"
            exit 1
        fi
        sed -i -e "s#TEXTOCATEGORIAP#${CONTEUDO}#g" ${NOME_ARQUIVO}.tex

        # Substitui as informacoes das bases de dados no arquivo fonte .TEX
        #
        # Para cada linha no arquivo ${CAMPO_TOKENS}, obtem os campos:
        # 1 - nome da variável a se usar neste script
        # 2 - campo correspondente na base de dados formatada e unica
        # 3 - token nos arquivos TEX relacionado aos dois primeiros campos
        #
        # Entao prepara a string da linha que deve ser executada, sendo
        # executada de fato a partir do comando eval (embutido do BASH)
        #
        # O controle do loop esta sobre a quantidade de linhas do arquivo
        QTDE_TOKENS=$(wc -l ${CAMPOS_TOKENS} | awk '{print $1}')
        for NUM_LINHA in $(seq 1 ${QTDE_TOKENS})
        do
            LINHA=$(sed -n ${NUM_LINHA}p ${CAMPOS_TOKENS})
            VARIAVEL=$(echo ${LINHA} | cut -d";" -f1)
            AUX1="\$${VARIAVEL}"
            VARIAVEL=$(eval "echo $AUX1")
            CAMPO=$(echo ${LINHA} | cut -d";" -f2)
            TOKEN=$(echo ${LINHA} | cut -d";" -f3)
            EXECUTAR="sed -i -e \"s#${TOKEN}#${VARIAVEL}#g\" ${NOME_ARQUIVO}.tex"
            eval ${EXECUTAR}
        done

        # Substitui informacoes gerais e comuns a todos os certificados,
        # como nome do evento, periodo de realizacao e data da emissao
        sed -i -e "s#EVENTOP#${EVENTO}#g" -e "s#PERIODOP#${PERIODO}#g" \
            -e "s#DATAP#${DATA}#g" ${NOME_ARQUIVO}.tex

        # Define a cor do texto dos certificados com base na configuracao
        # definida no comeco do script
        sed -i -e "s#CONF_COR#${CONF_COR}#g" ${NOME_ARQUIVO}.tex

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
elif [[ $1 == "ouvintes" ]]
then
    # Cria a base de dados de ouvintes a partir da lista de inscritos obtida
    # do formulario disponivel na Internet
    ./claquete-cria-base-ouvintes.sh
elif [[ $1 == "formatada" ]]
then
    # Cria uma base de dados unica juntando todas as demais bases de dados
    ./claquete-cria-base-formatada.sh
else
    # Antes de se criar qualquer novo arquivo, apaga qualquer arquivo
    # remanescente da execucao anterior (fontes LaTeX e PDFs)
    cd ${DIR_FONTES_TEX} && rm -f ./* && cd - &> /dev/null
    cd ${DIR_CERTIFICADOS_PDF} && rm -f ./* && cd - &> /dev/null

    # A partir daqui, se inicia uma nova execucao do sistema
    if [ ! -e ${DADOS} ]
    then
        echo "ERRO: Criar uma base de dados com os dados dos certificados"
        echo -n "- Nome da base: "
        basename ${DADOS}
        echo -n "- Localização: "
        dirname ${DADOS}
        echo "- Campos necessários (arquivo ${CAMPOS_TOKENS}):"
        cat ${CAMPOS_TOKENS}
        exit 1
    fi

    # Cria os arquivos-fonte em LaTeX como passo intermediario antes de gerar
    # os arquivos PDF
    cria_fontes_tex

    # Cria os arquivos PDF dos certificados
    cria_certificados
fi

exit 0
