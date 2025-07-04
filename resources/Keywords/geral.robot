*** Settings ***
Resource    ../config.robot

*** Keywords ***
Montar Navegador
    [Arguments]    ${BROWSER}=${BROWSER}    ${HEADLESS}=${HEADLESS}    ${TIMEOUT_BROWSER}=${TIMEOUT_BROWSER}
    
    @{ARGS_BROWSER}   Create List    
    ...    --window-position=0,0
    ...    --disable-notifications
    ...    --disable-infobars
    ...    --disable-extensions
    ...    --arc-disable-locale-sync=${True}
    ...    --accept-lang=${TYPE_LANG}
    ...    --lang=${LANG}
    ...    --force-time-zone=America/Sao_Paulo
    ...    --font-render-hinting=none
    
    IF    ${HEADLESS} == ${True}
        Append To List    ${ARGS_BROWSER}
        ...    --headless
        ...    --no-sandbox
        ...    --disable-dev-shm-usage
        ...    --disable-gpu
    END

    New Browser    
    ...           channel=${BROWSER_LOCAL}
    #...            browser=${BROWSER}
    ...            headless=${HEADLESS}
    ...            args=${ARGS_BROWSER}
    ...            timeout=${TIMEOUT_BROWSER}

Montar Contexto
    [Arguments]    ${FILE}=None     ${viewport}=${RESOLUCAO_BROWSER}  ${recordVideo}=${CONFIG_VIDEO}     ${timezoneId}=America/Sao_Paulo 

    &{CONTEXT_DIC}    Create Dictionary
    ...               viewport=${viewport}     
    ...               recordVideo=${recordVideo}       
    ...               timezoneId=${timezoneId} 
    ...               locale=${TYPE_LANG}
    ...               reducedMotion=reduce
    ...               geolocation={'latitude': -23.55052,'longitude': -46.63331,'accuracy': 100}
    IF  '${FILE}' != 'None'
        ${storageState}    Set Variable         ${EXECDIR}\\src\\${FILE}.json
        Set To Dictionary    ${CONTEXT_DIC}     storageState=${storageState}
    END
    Log                ${CONTEXT_DIC}
    New Context        &{CONTEXT_DIC}
    Grant Permissions  	    microphone

Finalização dos testes
    Run Keyword If Test Failed         Take Screenshot           filename=EMBED
    Set Selector Prefix                ${None}

Wait And Type Text
    [Arguments]    ${selector}    ${text}    ${timeout}=${DEFAUT_TIMEOUT}    ${DATE}=False    ${INPUT_DATE_FORMAT}=%d-%m-%Y    ${CNPJ_FORMART}=False    ${TELEFONE}=False    ${MODEDA}=False    ${PONTU}=False
    Wait For Elements State    ${selector}    visible     timeout=${timeout}    message=${MENSAGEM_TIMEOUT}
    Wait For Elements State    ${selector}    enabled     timeout=${timeout}    message=${MENSAGEM_TIMEOUT}
    Type Text    ${selector}    ${text}    delay=${DELAY_TEXT}

    ${status}         ${value}=         Run Keyword And Ignore Error    Get Property    ${selector}    value
    ${status_text}    ${value_text}=    Run Keyword And Ignore Error    Get Text        ${selector}

    IF    '${status}' == 'PASS'
        IF    '${DATE}' == 'True'    
            ${text}=    Convert Date    ${text}    date_format=${INPUT_DATE_FORMAT}    result_format=%Y-%m-%d
        ELSE IF   '${CNPJ_FORMART}' == 'True'
            ${text}=    Tratar CNPJ    ${text}
            ${value}=   Tratar CNPJ    ${value}
        ELSE IF  '${TELEFONE}' == 'True'
            ${text}=    Tratar Telefone    ${text}
            ${value}=   Tratar Telefone    ${value}
        ELSE IF  '${MODEDA}' == 'True'
            ${text}=    Formatar Valor Como Moeda Real    ${text}
        ELSE IF  '${PONTU}' == 'True'
            ${text}=    Formatar Valor Com Pontuacao    ${text}
        END
        Log    O valor do campo após digitação é: ${value} e o texto esperado é: ${text}
    ELSE IF     '${status_text}' == 'PASS'
        IF    '${DATE}' == 'True'
            ${text}=    Convert Date    ${text}    date_format=${INPUT_DATE_FORMAT}    result_format=%Y-%m-%d
        ELSE IF   '${CNPJ_FORMART}' == 'True'
            ${text}=    Tratar CNPJ    ${text}
            ${value}=   Tratar CNPJ    ${value}
        ELSE IF  '${TELEFONE}' == 'True'
            ${text}=    Tratar Telefone    ${text}
            ${value}=   Tratar Telefone    ${value}
        ELSE IF  '${MODEDA}' == 'True'
            ${text}=    Formatar Valor Como Moeda Real    ${text}
        ELSE IF  '${PONTU}' == 'True'
            ${text}=    Formatar Valor Com Pontuacao    ${text}
        END
        Log    O valor do campo após digitação é: ${value_text} e o texto esperado é: ${text}
    ELSE
        Fail    Falha ao obter valor do campo após digitação: ${text}
    END

Wait And Click
    [Arguments]                ${selector}    ${timeout}=${DEFAUT_TIMEOUT}    ${DELAY_CLICKED}=${DELAY_CLICK}    ${CLICKCOUNT}=1    ${FORCE}=${False}    ${TRIAL}=${False}  
    Wait For Elements State    ${selector}    visible     timeout=${timeout}    message=${MENSAGEM_TIMEOUT}
    Wait For Elements State    ${selector}    enabled     timeout=${timeout}    message=${MENSAGEM_TIMEOUT}
    Click With Options         ${selector}    delay=${DELAY_CLICKED}    force=${FORCE}    clickCount=${CLICKCOUNT}    trial=${TRIAL}

Tratar CNPJ
    [Arguments]    ${CNPJ}
    ${CNPJ}    Convert To String    ${CNPJ}
    Remove String    ${CNPJ}    . / -    result=${CNPJ}
    Log    CNPJ tratado: ${CNPJ}

Tratar Telefone
    [Arguments]    ${TELEFONE}
    ${telefone}=    Convert To String    ${TELEFONE}
    ${telefone}=    Replace String       ${TELEFONE}    (   ${EMPTY}
    ${telefone}=    Replace String       ${TELEFONE}    )   ${EMPTY}
    ${telefone}=    Replace String       ${TELEFONE}    ${SPACE}    ${EMPTY}
    ${telefone}=    Replace String       ${TELEFONE}    -   ${EMPTY}
    Log    Telefone tratado: ${TELEFONE}

Formatar Valor Como Moeda Real
    [Arguments]    ${valor}
    ${valor_float}=    Convert To Number    ${valor}
    ${valor_formatado}=    Evaluate     "R$ {0:,.2f}".format(${valor_float}).replace(",", "X").replace(".", ",").replace("X", "")
    Return From Keyword    ${valor_formatado}

Formatar Valor Com Pontuacao
    [Arguments]    ${valor}
    ${valor_float}=    Convert To Number    ${valor}
    ${valor_formatado}=    Evaluate    "{0:.2f}".format(${valor_float}).replace(".", ",")
    Return From Keyword    ${valor_formatado}

Remover Todos Os Itens Da Lista
    [Arguments]    ${MINHA_LISTA}
    ${tamanho}=    Get Length    ${MINHA_LISTA}
    Log    A lista tem inicialmente ${tamanho} itens.

    FOR    ${item}    IN    @{MINHA_LISTA}
        Remove From List    ${MINHA_LISTA}    0
        Log    Item removido: ${item}
        Log    Lista atual: ${MINHA_LISTA}
    END

    ${tamanho_final}=    Get Length    ${MINHA_LISTA}
    Log    Após a remoção, a lista tem ${tamanho_final} itens.

Abrir nabegador na pagina
    [Arguments]    ${URL}   ${BROWSER}=${BROWSER}    ${HEADLESS}=${HEADLESS}    ${TIMEOUT_BROWSER}=${TIMEOUT_BROWSER}   ${FILE}=None     ${viewport}=${RESOLUCAO_BROWSER}  ${recordVideo}=${CONFIG_VIDEO}     ${timezoneId}=America/Sao_Paulo 
    Montar Navegador    ${BROWSER}    ${HEADLESS}    ${TIMEOUT_BROWSER}
    Montar Contexto     ${FILE}     ${viewport}  ${recordVideo}     ${timezoneId}
    New Page    ${URL}

Criar arquivo Storage State
    [Arguments]             ${NOME_FILE_STATE}
    ${JSON_STATE}           Save Storage State
    ${STATE_STORAGE}        Load Json From File    ${JSON_STATE}
    Set Variable    ${NOME_FILE_STATE}
    Set Test Variable    ${NOME_FILE_STATE}
    Dump Json To File       ${EXECDIR}\\src\\${NOME_FILE_STATE}.json    ${STATE_STORAGE}