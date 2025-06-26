from pathlib import Path
from robot.api import logger
from robot.api.deco import keyword
import csv

class CSVComparator:
    """Bibliothèque RobotFramework pour comparer des fichiers CSV GARRD_FICHDATA.
    
    Cette bibliothèque permet de comparer des paires de fichiers CSV selon un format spécifique
    et génère un rapport HTML des différences.
    """
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0'
    

    
    @keyword("Comparer les fichiers CSV")
    def compare_csv_files(self, data_dir, ouput_file=None):
        """Compare les fichiers CSV GARRD_FICHDATA dans le répertoire spécifié.
        
        Args:
            data_dir (str): Chemin vers le répertoire contenant les fichiers CSV. 
                           exemple: './data/life'
            output_file (str): Chemin vers le rapport à produire. Si non précisé, le rapport sera uniquement joint au rapport RobotFramework
                           
        Returns:
            str: Rapport HTML des comparaisons
        """
        self.data_dir = data_dir
            
        data_path = Path(self.data_dir)
        logger.info(f"Recherche des fichiers CSV dans: {data_path.absolute()}")
        
        # Initialisation du rapport HTML
        html_output = []
        self._init_html_report(html_output)
        
        # Recherche des fichiers correspondants
        files = list(data_path.glob("FICHDATA_*_[12].CSV"))
        
        if len(files) < 2:
            error_msg = f"Impossible de trouver les fichiers CSV requis dans {data_path}"
            logger.error(error_msg)
            raise FileNotFoundError(error_msg)
            
        # Groupement des fichiers par leur partie commune
        file_groups = self._group_files_by_base(files)
        
        # Comparaison de chaque groupe de fichiers
        for base, group in file_groups.items():
            if len(group) != 2:
                continue
                
            group.sort()
            file1, file2 = group
            logger.info(f"\nComparaison des fichiers pour {base}:")
            logger.info(f"Fichier 1: {file1.name}")
            logger.info(f"Fichier 2: {file2.name}")
            
            # Lecture des données CSV
            data1 = self._read_csv_after_details(file1)
            data2 = self._read_csv_after_details(file2)
            
            # Vérification des en-têtes
            if data1[0] != data2[0]:
                logger.warn("Attention: Les en-têtes diffèrent entre les fichiers")
            
            # Comparaison des données
            self._compare_data(data1, data2, html_output)
        
        self._finalize_html_report(html_output)
        report = "\n".join(html_output)
        
        # Sauvegarde du rapport
        if ouput_file:
            report_path = Path(ouput_file)
            with open(report_path, "w") as f:
                f.write(report)
        
        logger.info(f"Rapport généré: {report_path.absolute()}", html=True)
        return report
    
    def _init_html_report(self, html_output):
        """Initialise le rapport HTML."""
        html_output.append('<table border="1" style="border-collapse: collapse; width: 100%;">')
        html_output.append("<tr><th>Statut</th><th>Police</th><th>Couche</th><th>Bloc</th><th>Détails</th></tr>")
    
    def _finalize_html_report(self, html_output):
        """Finalise le rapport HTML."""
        html_output.append("</table>")
        html_output.append("<i>Note: Ce rapport est une démonstration, certains cas particuliers ne sont pas gérés</i>")
    
    def _group_files_by_base(self, files):
        """Groupe les fichiers par leur partie commune (XXX dans le nom)."""
        file_groups = {}
        for f in files:
            base = f.name.split("_")[1]  # Récupère la partie XXX
            if base not in file_groups:
                file_groups[base] = []
            file_groups[base].append(f)
        return file_groups
    
    def _read_csv_after_details(self, filepath):
        """Lit un fichier CSV après la ligne 'DETAILS ;'."""
        data = []
        with open(filepath, "r", encoding='utf-8') as f:
            # Saute jusqu'à la ligne DETAILS
            for line in f:
                if line.strip() == "DETAILS ;":
                    break
            
            # Lit les lignes restantes comme CSV
            reader = csv.reader(f, delimiter=";")
            for row in reader:
                if row:  # Ignore les lignes vides
                    data.append(row)
        return data
    
    def _compare_data(self, data1, data2, html_output):
        """Compare les données des deux fichiers et ajoute les résultats au rapport HTML."""
        rows1 = self._make_row_dict(data1)
        rows2 = self._make_row_dict(data2)
        
        all_keys = set(rows1.keys()) | set(rows2.keys())
        
        for key in sorted(all_keys):
            policy, layer, block = key
            details = []
            row_color = ""
            
            if key not in rows1:
                status = "Seulement dans fichier 2"
                row_color = "red"
                details.append("Ligne seulement présente dans le second fichier")
            elif key not in rows2:
                status = "Seulement dans fichier 1"
                row_color = "blue"
                details.append("Ligne seulement présente dans le premier fichier")
            else:
                row1 = rows1[key]
                row2 = rows2[key]
                if row1 == row2:
                    status = "Aucune différence"
                    row_color = "green"
                    details.append("Aucune différence trouvée")
                else:
                    status = "Différences trouvées"
                    row_color = "orange"
                    for i, (val1, val2) in enumerate(zip(row1, row2)):
                        if val1 != val2:
                            field = data1[0][i] if i < len(data1[0]) else f"Colonne {i}"
                            if "DATE" in field:
                                details.append(f"{field}: {val1} → {val2} (changement DATE)")
                                row_color = "red"
                            else:
                                try:
                                    delta = float(val1.strip().replace(",", ".")) - float(
                                        val2.strip().replace(",", ".")
                                    )
                                    if delta > 0.01:
                                        row_color = "red"
                                        details.append(f"{field}: {val1} → {val2} (Δ={delta:.2f})")
                                    else:
                                        details.append(f"{field}: {val1} → {val2} (Δ={delta:.2f})")
                                except ValueError:
                                    details.append(f"{field}: {val1} → {val2} (différence textuelle)")
            
            # Ajout de la ligne au rapport HTML
            html_output.append(f'<tr style="background-color: {row_color};">')
            html_output.append(f"<td>{status}</td>")
            html_output.append(f"<td>{policy}</td>")
            html_output.append(f"<td>{layer}</td>")
            html_output.append(f"<td>{block}</td>")
            html_output.append(f"<td>{'<br>'.join(details)}</td>")
            html_output.append("</tr>")
    
    def _make_row_dict(self, data):
        """Crée un dictionnaire des lignes avec comme clé (police, couche, bloc)."""
        result = {}
        for row in data[1:]:  # Saute l'en-tête
            if len(row) >= 10:  # Vérifie que la ligne a assez de colonnes
                key = (row[0], row[5], row[9])  # Police, couche, bloc
                result[key] = row
        return result