*** Settings ***
Resource    ../../resources/config.robot

*** Test Cases ***

Teste para abrir navegador
    Abrir nabegador na pagina    https://front.serverest.dev/login     HEADLESS=${False}
    Wait And Type Text    xpath=//input[@id='email']   Robot Framework é o melhor!
    Sleep    10s