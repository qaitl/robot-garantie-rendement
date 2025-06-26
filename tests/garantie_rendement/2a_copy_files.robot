Language: French

*** Settings ***
Library    OperatingSystem
Library    DateTime
Resource    resources/garantie_rendement.resource


*** Test Cases ***

Simulation de l'arrivée du ficher (1)
    [Documentation]    Copie d'un fichier de référence "imitant" le fichier de sortie IMS
    Copy File    ${CURDIR}/data/samples/mode1/FICHDATA.CSV    ${CURDIR}/data


Scénario: Copier le fichier DATA.CSV vers output avec la date du jour + _1
    [Documentation]    Attend le fichier FICHDATA.CSV dans input et le copie vers output/FICHDATA{date}.CSV
    ...                Le fichier d'origine sera ensuite supprimé pour s'assurer d'attendre le nouveau à l'étape 4
    
    Lorsque un fichier "${input_file}" existe dans le dossier "${input_dir}"
    Et je copie le fichier "${input_dir}/${input_file}" vers "${output_dir}" avec la date du jour suivi de "_1"
    Alors le fichier "${output_dir}/FICHDATA_${date}_1.CSV" devrait exister 
    Et je supprime le fichier "${input_dir}/${input_file}"

