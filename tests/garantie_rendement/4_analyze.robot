Language: French

*** Settings ***
Library    OperatingSystem
Library    resources/CSVComparator.py
Resource    resources/garantie_rendement.resource
Documentation    - Le robot copie FICHDATA sur le share1(à définir) et le renommera en FICHDATA2(à valider) 
...              - Le robot compare FICHDATA1 avec FICHDATA2 et produit FICHDATA-COMPARE (cfr3.7) qui contiendra les différences entre les deux fichiers. 
...              - Le robot déplace FICHDATA-COMPARE XXXX(Lieu à définir).

*** Variables ***
${input_file}        FICHDATA.CSV
${input_dir}         ${CURDIR}/data
${output_dir}         ${CURDIR}/output

*** Test Cases ***

Simulation de l'arrivée du ficher (2)
    [Documentation]    Copie d'un fichier de référence "imitant" le fichier de sortie IMS
    Copy File    ${CURDIR}/data/samples/mode2/FICHDATA.CSV    ${CURDIR}/data


Scénario: Copier le fichier DATA.CSV vers output avec la date du jour + _2
    [Documentation]    Attend le fichier DATA.CSV dans input et le copie vers output/DATA_{date}.CSV
    Lorsque un fichier "${input_file}" existe dans le dossier "${input_dir}"
    Et je copie le fichier "${input_dir}/${input_file}" vers "${output_dir}" avec la date du jour suivi de "_2"
    Alors le fichier "${output_dir}/FICHDATA_${date}_2.CSV" devrait exister 

Comparaison des fichiers
    ${report}=    Comparer les fichiers CSV    ${output_dir}    ouput_file=${output_dir}/comparaison.html
    Log    ${report}    html=True