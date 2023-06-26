# claquete
Um sistema gerador e distribuidor de certificados de eventos usando scripts BASH

Funcionalidades:
- Gera certificados em lote usando arquivos LaTeX, CSV e BASH
- Permite o envio de certificados em lote via e-mail usando o Mutt
- Consegue criar mais de um certificado para a mesma pessoa em uma mesma categoria de participação

Limitações:
- Não possui código de validação dos PDFs gerados
- Requer conhecimentos em LaTeX e BASH para alterações

Download/Outros:
- Claquete v1.0 - https://drive.google.com/file/d/18ky7x8nVyyhqdckMSj5xqXYP4lfH4zcT/view?usp=sharing
- GitHub: https://github.com/josiney-souza/claquete
- Marca Registrada: Protocolo 926147102
- Vídeo: 

OBS.: O sistema está em processo de registro junto ao INPI.



## Pré-requisitos - programas/aplicativos

Para executar o sistema Claquete, antes é necessário ter:
- Bash
- Uma distribuição LaTeX instalada, por exemplo

```bash
sudo apt install abntex texlive-latex-extra texmaker
```



## Pré-requisitos - arquivos

Para executar o sistema Claquete, antes é necessário ter:

- Um arquivo [dados-inscricoes.csv](dados-inscricoes.csv), com as inscrições dos ouvintes do evento (obtidas, por exemplo, de um formulário on-line)

  No exemplo disponibilizado, o arquivo [dados-inscricoes.csv](dados-inscricoes.csv), que tem esta organização de campos (oriunda do Google Formulários) ...

  > 1. Data e hora da inscrição
  > 1. Endereço de e-mail
  > 1. Nome completo
  > 1. CPF
  > 1. Vínculo com o IFC (formas de participação no evento)
  > 1. Portador de necessidade especial?
  > 1. Se sim, qual a necessidade especial?

  ... é normalizado para estes outros campos e salvo no arquivo [dados-ouvintes.csv](dados-ouvintes.csv):

  > 1. Nome
  > 1. CPF
  > 1. Categoria de participação (neste caso, ouvinte)
  > 1. Quantidade de horas de participação (no evento de exemplo, foram até 24 horas de participação)
  > 1. E-mail

- Um arquivo `dados-CATEGORIA.csv`, com os dados dos demais participantes das diferentes categorias

  As outras categorias no exemplo disponibilizado:
  - [dados-mediadores.csv](dados-mediadores.csv): Mediadores (mediadores das atividades)
  - [dados-organizacao.csv](dados-organizacao.csv): Organização (membros da comissão de organização)
  - [dados-palestrantes.csv](dados-palestrantes.csv): Palestrantes (palestrantes)

  Esses arquivos `dados-CATEGORIA.csv` estão organizados com os seguintes campos:

  > 1. Nome
  > 1. CPF
  > 1. Categoria de participação (tipo de participante)
  > 1. Quantidade de horas de participação
  > 1. Campo adicional
  >    - Para a base de mediadores, é usado para indicar o título da atividade que mediou
  >    - Para a base de palestrantes, é usado para indiciar o título da palestra ministrada
  >    - Para a base de organizadores, não é usado



## Separador de campos

O separador de campos usados nas bases de dados é o `;` (ponto-e-vírgula)



## Execução

Para executar, em um terminal, dentro da pasta do sistema, digite:

```bash
./claquete-gera-certificados.sh
```

As ações executadas serão:
1. Apagar os arquivos gerados anteriormente (bases intermediárias, arquivos fonte LaTeX, arquivos PDF)
1. Cria a base de ouvintes normalizada [dados-ouvintes.csv](dados-ouvintes.csv) a partir da base externa [dados-inscricoes.csv](dados-inscricoes.csv)
1. Cria a base de dados formatada/normalizada com todas as categorias existentes: ouvintes, mediadores, organização, palestrantes (`dados.csv`)
1. Cria os arquivos fonte LaTeX de todos os participantes
1. Cria os arquivos PDF de todos os participantes

Abaixo, uma figura que apresenta os passos executados pelo sistema Claquete:
![Sistema Claquete](claquete.png)



## Diretórios/pastas

Os seguintes diretórios/pastas fazem parte do sistema Claquete:
- [certificados-pdf](certificados-pdf): para guardar os certificados em PDF finais da execução do sistema. Possui 4 arquivos no repositório, simbolizando um exemplo de cada categoria existente. Se rodar o script, gerarão todos os arquivos das bases;
- [dados](dados): para guardar as bases definitivas (no exemplo, `dados-inscricoes.csv`, `dados-mediadores.csv`, `dados-organizacao.csv`, `dados-palestrantes.csv`) e as bases intermediárias (no exemplo, `dados-ouvintes.csv`, `dados.csv`);
- [fontes-tex](fontes-tex): para guardar os arquivos .TEX que irão gerar os arquivos PDF após compilação. Posui 4 arquivos no repositório, simbolizando um exemplo de cada categoria existente. Se rodar o script, gerarão todos os arquivos das bases;
- [imagens](imagens): para guardar as imagens usadas nos certificados. No exemplo, são 3: a assinatura digitalizada do presidente da comissão organizadora, uma imagem de fundo dos certificados, uma imagem da grade de atividades realizadas no evento;
- [modelos](modelos): para guardar os textos de modelo de cada categoria.
> :warning: **Aviso:** para os textos funcionarem corretamente, devem estar em uma única linha.



## Tokens

Inicialmente os arquivos .TEX possuem *tokens* que são procurados pelos *scripts* e têm seus valores substituídos por algum dos campos das bases de dados.

Por padrão, são `ALGUMACOISA` e `P` no fim, para indicar que geralmente se trata de uma informação do **P**articipante. Foi escolhido não deixar apenas as palavras sem o `P` final para que o texto literal que deva aparecer no corpo do certificado não seja substituído pelos *scripts*.

Abaixo, os *tokens* usados nos arquivos específicos de cada categoria no exemplo disponibilizado e pelo quê serão substituído:
- NOMEP: campo de "Nome" do participante
- CPFP: campo de "CPF" do participante
- TIPOP: campo de "Categoria" do participante
- HORASP: campo de "Horas" de atividades do participante
- TITULOP: campo de "Título" da palestra do participante (exclusivo para categoria de palestrante)
- ASSUNTOP: campo de "Assunto" do mediador participante (exclusivo para categoria de mediador)
- ATIVIDADESP: campo de "Atividades" desenvolvidas pelo participante (exclusivo para categoria de organização - não usado atualmente)

Abaixo, os *tokens* usados no arquivo de base comum geral dos certificados e pelo quê serão substituídos:
- TEXTOCATEGORIAP: texto específico da categoria
- FUNDOP: endereço da imagem de fundo do certificado
- ASSINATURAP: endereço da imagem de assinatura digitalizada do presidente da comissão organizadora do evento
- GRADEP: endereço da imagem que contém a grade do evento



## Para incluir categorias

1. Criar um arquivo de bases com as informações necessárias (nome, cpf, tipo, horas, adicional) com os campos separados por `;` (ponto-e-vírgula) no diretório/pasta `dados`;
1. Criar uma nova linha DADOS_NOVACATEGORIA="${DIR_DADOS}/dados-NOVACATEGORIA.csv" após a linha 50 em `claquete-gera-certificados.sh`;
1. Adicionar `${DADOS_NOVACATEGORIA}` ao comando `for` da linha 98 em `claquete-gera-certificados.sh` (função `cria_base_formatada()`);
1. Adicionar novo condicional `elif [[ ${TIPO} == "NOVACATEGORIA" ]]` e todos seus comandos na cadeia de `if` em `claquete-gera-certificados.sh` (função `cria_fontes_tex()`).



## Para remover categorias

1. Remover o arquivo de base da categoria desejada no diretório/pasta `dados`;
1. Remover linha DADOS_NOVACATEGORIA="${DIR_DADOS}/dados-CATEGORIA.csv" após a linha 50 em `claquete-gera-certificados.sh`;
1. Remover `${DADOS_CATEGORIA}` do comando `for` da linha 98 em `claquete-gera-certificados.sh` (função `cria_base_formatada()`);
1. Remover condicional `elif [[ ${TIPO} == "CATEGORIA" ]]` e todos seus comandos na cadeia de `if` em `claquete-gera-certificados.sh` (função `cria_fontes_tex()`).
