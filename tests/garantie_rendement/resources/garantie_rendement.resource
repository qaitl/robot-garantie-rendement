Language: French

*** Settings ***
Documentation  Keywords et variables spécifique à la Test Suite Garantie Rendement  
Library        OperatingSystem
Library        DateTime


*** Variables ***
${input_file}        FICHDATA.CSV
${input_dir}         ${CURDIR}/../data
${output_dir}         ${CURDIR}/../output




*** Keywords ***
Un fichier "${filename}" existe dans le dossier "${dossier}"
    ${path}=    Join Path    ${EXECDIR}    ${dossier}    ${filename}
    Log    En attente du fichier ${path}    console=True
    Wait Until Keyword Succeeds    1 min    5 sec    File Should Exist    ${path}

Je copie le fichier "${source_file}" vers "${output_dir}" avec la date du jour suivi de "${suffix}"
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    ${dest}=    Join Path    ${output_dir}    FICHDATA_${date}${suffix}.CSV
    Create Directory    ${output_dir}
    Copy File    ${source_file}    ${dest}
    Set Test Variable    ${date}    ${date}

Le fichier "${path}" devrait exister
    File Should Exist    ${path}

je supprime le fichier "${input_file}"
    Log    Supperssion de ${input_file}    console=True
    Remove File     ${input_file}   