Language: French

*** Settings ***
Variables    ${EXEC_DIR}/variables/${ENV}/secrets.py
Library    Browser
Library    OperatingSystem
Ressource    ${EXEC_DIR}/resources/mydesk/mydesk.resource    

*** Variables ***
${ENV}      tst


*** Test Cases ***

Scénario: Authentification et configuration MyDesk
    Étant donné je m'identifie via MyDesk


Scénario: Exécuter SMJOB Mode 1
    [Documentation]    Le robot lance le SMJOB (UASCVRD) avec le paramètre en mode 1 (INPUT(FINPUT) = FICH1)
    Étant donné je suis déjà identifié via MyDesk
    Lorsque j'ouvre via MyDesk l'écran "SMJOB"
    Et tant que l'écran IMS ne contient pas "ROBOT ART 24" je tape "F8"
    Et je remplis le champs IMS précédant "ROBOT ART 24" avec "E{RETURN}"
    Et je remplis le champs IMS suivant "CODE MODE" avec "1{RETURN}"
    Alors j'attends que la ligne 24 de l'IMS contienne "PF1 : OK"
    Lorsque j'encode dans IMS "{F1}"
    Alors j'attends que la ligne 24 de l'IMS contienne "Demande bien reçue !"
    Et Take Screenshot

