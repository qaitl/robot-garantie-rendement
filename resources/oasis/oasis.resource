*** Settings ***
Library    Browser
Library    String
Library    OperatingSystem
Library    ${EXECDIR}/resources/common/browser/CustomBrowserKeywords.py

*** Variables ***
${FRAME_GAUCHE}    iframe#myOasisFrame >>> frame[name="gauche"] >>> body
${FRAME_DROITE}    iframe#myOasisFrame >>> frame[name="droite"] >>> body
${TAB_BAR}    iframe#myOasisFrame >>> frame[name="droite"] >>> body > form > table > tbody > tr:nth-child(1) > td > table > tbody > tr > td > table > tbody > tr:nth-child(2) > td > table > tbody > tr:nth-child(1) > td > table
${FRAME_DROITE_TITRE}     ${FRAME_DROITE} >> td.titre4 
${FRAME_DROITE_CONTENU}    iframe#myOasisFrame >>> frame[name="droite"] >>> body > form > table > tbody > tr:nth-child(2) > td > table

${BOUTON_VALIDER}    ${FRAME_DROITE_CONTENU} >> input[name="BT_VALI"]
${following_input}    xpath=/following::input[1]

** Keywords ***

j'ouvre MyOasis
    Go To    ${URL}/my-oasis
    j'attends le titre "Gestion des imprimantes"

j'ouvre le menu "${keywords}"

    @{parts}=    Split String    ${keywords}    separator=/
    
    FOR    ${part}    IN    @{parts}
    # todo: check status
        ${trimmed_part}=    Strip String    ${part}
        # use xpath allow to match entire text. visible=true relies on Playwroght visibility check
        Click    ${FRAME_GAUCHE} >> xpath=//*[text()="${trimmed_part}"] >> visible=true
    END
    

j'ouvre l'onglet "${keyword}"
    Click    ${TAB_BAR} >> text=${keyword}

je recherche la police "${policy}"
    Fill Text    ${FRAME_DROITE_CONTENU} >> text="Numéro de police" >> ${following_input}    ${policy}
    Click    ${BOUTON_VALIDER}

je sélectionne la version "${version}"
    ${list}=    Get Element    ${FRAME_DROITE_CONTENU} >> select[name="CDTYVIS"]
    Select Options By    ${list}    text    ${version}

pour chaque coassureur, je valide les montants
    ${coass_list}=    Get Element    ${FRAME_DROITE_CONTENU} >> select[name="NOIDCOA"]
    ${status_list}=    Get Element    ${FRAME_DROITE_CONTENU} >> select[name="CDSTCOA"]
    ${options}=    Get Select Options    ${coass_list}
    ${options_without_first}=    Evaluate    $options[1:]
    FOR    ${option}    IN    @{options_without_first}
        Select Options By    ${coass_list}    value    ${option}[value]
        Select Options By    ${status_list}    text    Actif

        Click    ${FRAME_DROITE_CONTENU} >> input[type="button"] >> text=Go
        Sleep     1s
        Click    ${FRAME_DROITE_CONTENU} >> input[type="button"] >> text=Rectifier(CVUPC)
        Click    ${FRAME_DROITE_CONTENU} >> input[type="button"] >> text=Valider
        Take Screenshot
    END

dans la frame de droite je clique sur le lien "${name}"
    Click   ${FRAME_DROITE} >> a >> text=Nouvelle recherche

j'attends le titre "${text}"
    Wait For Condition     Text    ${FRAME_DROITE_TITRE}   contains    ${text}
    Take Screenshot