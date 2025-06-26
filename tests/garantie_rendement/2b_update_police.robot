Language: French

*** Settings ***
Library    Browser
Library    DataDriver    file=data/policies.csv   
Resource    ${EXEC_DIR}/resources/mydesk/mydesk.resource       
Resource    ${EXEC_DIR}/resources/oasis/oasis.resource    
Variables    ${EXEC_DIR}/variables/${ENV}/secrets.py
Test Template       Fix policy

*** Variables ***
${ENV}      tst


*** Test Cases ***
Modification de la police    Policy

    

*** Keywords ***
Fix policy
    [Arguments]    ${policy}
    [Documentation]   Le robot met à jour les écrans de l'IMS pour la police pour chaque coassureur  (cfr: 3.5).  

    # Il ne s'agit pas d'un test à proprement parler, mais d'un process robotisé
    # Le mot-clé Given/When/Then est facultatif et n'a pas de sens ici
    
    je suis déjà identifié via MyDesk
    j'ouvre MyOasis
    j'ouvre le menu "Assurance"
    j'attends le titre "Messagerie du gestionnaire"
    j'ouvre l'onglet "CV"
    j'ouvre le menu "Police groupe / Gestion / Capitaux"
    je recherche la police "${policy}"
    je sélectionne la version "TOTAL"
    pour chaque coassureur, je valide les montants
    dans la frame de droite je clique sur le lien "Nouvelle recherche"



