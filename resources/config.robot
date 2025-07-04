*** Settings ***
Library     Browser    
...    run_on_failure=Take Screenshot \ EMBED
...    retry_assertions_for=0:00:03
...    timeout=${TIMEOUT_BROWSER}
...    show_keyword_call_banner=${True}
...    language=${TYPE_LANG}
Library     RequestsLibrary
Library     JSONLibrary
Library     FakerLibrary        locale=pt-BR
Library     String
Library     Dialogs
Library     OperatingSystem
Library     Collections
Library     DateTime
Library     Process
Library     ExcelLibrary
Library     DatabaseLibrary

Resource    ./Keywords/geral.robot

*** Variables ***
${STORAGE}                           Storage
${BROWSER}                           chromium    #webkit    #firefox    #chromium
${BROWSER_LOCAL}                     chrome      #msedge    #chrome
${RESOLUCAO_BROWSER}                 {'width': 1600, 'height': 900}
${TYPE_LANG}                         pt-BR
${LANG}                              pt
${HEADLESS}                          ${True}
${ZOOM_BROWSER}                      90%
${DEFAUT_TIMEOUT}                    45s
${TIMEOUT_BROWSER}                   90s
${MENSAGEM_TIMEOUT}                  Falha ao esperar o elemento "{selector}" atingir o estado "{function}" dentro de {timeout}.
${DELAY_CLICK}                       1s
${DELAY_TEXT}                        40ms
${DELAY_SCREENSHOT}                  2s
${CONFIG_VIDEO}                      None    #{'dir': 'video', 'size':{'width': 1600, 'height': 900}}