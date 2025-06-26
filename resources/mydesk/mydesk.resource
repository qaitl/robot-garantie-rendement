*** Settings ***
Library    Browser
Library    String
Library    OperatingSystem
Library    ${EXECDIR}/resources/common/browser/CustomBrowserKeywords.py

*** Variables ***
${IMS_SCREEN}    iframe#virtelEmulator >>> #viewport
# todo: 
# - global selectors (const)
# - preserve state
# - custom py

** Keywords ***
je m'identifie via MyDesk
    New Browser    chromium    headless=False    # Explicitly disable headless
    New Context    viewport={'width': 1200, 'height': 1080}
    New Page    ${URL}
    # Get Title    contains    Playwright
    Fill Text    input[formcontrolname="login"]   ${USERNAME}
    Fill Secret  input[formcontrolname="password"]   $PASSWORD
    Click   text=Me Connecter
    Wait For Navigation  ${URL}/home
    Go To  ${URL}/terminal?actionKey=S1GSI&actionType=100
    Sleep   2s
    Click   iframe#virtelEmulator >>> [title='Settings']
    Switch Page    NEW
    Click    css=label[for="P-147"]    #10
    Check Checkbox  input#Val-hiliteinput    # Highlight input fields
    Click   text=Key Mappings    # onglet Key Mappings
    Click    css=label[for="P-2"]    #Enter=Enter
    Click  button#btn-save

    # preserve state
    ${STATE_FILE}=    Save Storage State
    Copy File    ${STATE_FILE}    .private/state.json 

je suis déjà identifié via MyDesk
    New Browser    chromium    headless=False
    ${current_dir}=    Evaluate    os.getcwd()    os
    File Should Exist    ${current_dir}/.private/state.json    Impossible de trouver le fichier d'état Browser. Exécutez d'abord je m'identifie vie MyDesk.
    New context    storageState=${current_dir}/.private/state.json
    New Page     ${URL}


j'ouvre via MyDesk l'écran "${screen}"
    Go To  ${URL}/terminal?actionKey=${screen}&actionType=100
    j'attends que l'IMS soit prêt


j'attends que l'IMS soit prêt
#todo: optional parameter
    Wait For Elements State    //app-virtel     visible    timeout=10
    Wait For Elements State    css=app-loader     hidden    timeout=10
    Wait For Condition    Text    iframe#virtelEmulator >>> id=sb_status   contains    \xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0 

j'encode dans IMS "${sequence}"
    Type With Keys    ${IMS_SCREEN}    ${sequence}    clear=False
tant que l'écran IMS ne contient pas "${text}" je tape "${key}"    
    ${ims_screen}=    Get Element    ${IMS_SCREEN}
    ${encoded_text}=    Replace String    ${text}    ${SPACE}    \xa0
    ${max_attempts}=    Set Variable    50
    ${text_found}=    Set Variable    ${False}
    
    FOR    ${attempt}    IN RANGE    ${max_attempts}
        ${ims_content}=    Get Text    ${ims_screen}
        
        # Use Run Keyword And Return Status to safely check for text
        ${text_found}=    Run Keyword And Return Status    
        ...    Should Contain    ${ims_content}    ${encoded_text}
        
        Exit For Loop If    ${text_found} == ${True}
        # Exit For Loop If    ${text_found} == ${previous_content}
        
        # Press F8 to navigate
        Press Keys    ${ims_screen}    ${key}
        Sleep    1s
    END
    
    IF    ${text_found} == ${True}
        Log    Text "${text}" was found
    ELSE
        Fail    Text "${text}" was not found after ${max_attempts} attempts
    END

je remplis le champs IMS précédant "${text}" avec "${sequence}"
    ${span}=    Get Element   ${IMS_SCREEN} >> text=${text} >> xpath=preceding::span[@vt="I"][1]
    Click    ${span}    
    Type With Keys    ${span}    ${sequence}


je remplis le champs IMS suivant "${text}" avec "${sequence}"
    ${span}=    Get Element   ${IMS_SCREEN} >> text=${text} >> xpath=following::span[@vt="I"][1]
    Click    ${span}    
    Type With Keys    ${span}    ${sequence}

j'attends que la zone status de l'IMS contienne "${text}"
    ${line}=    Get Element    ${IMS_SCREEN} >> id=sb_status
    Wait For Condition    Text    ${line}   contains    ${text}

j'attends que la ligne ${vr} de l'IMS contienne "${text}"
# attends qu'une zone de laligne contienne...
# todo: double quote in ^text
    ${element}=    Get Element    ${IMS_SCREEN} >> span[vr="${vr}"]:has-text("${text}")
    Wait For Elements State    ${element}    visible




    # Wait For Elements State
    # ...    iframe#virtelEmulator >> nth=0 >> .. >> span[vr="24"] >> text="PF1 : OK"
    # ...    visible
    # ...    timeout=10s

