
#setwd("C:/Users/foduf/OneDrive/Bureau/méthode/BIO500")
#setwd("C:/Users/foduf/Desktop/methode/Bio500")
library(targets)
library(tarchetypes) # Utilisé pour render le rapport (tar_render)

tar_option_set(packages = c("rmarkdown","knitr","stringr","RSQLite")) # Charger les libraries dans l'environnement global
source("scripts/fonction2.0.R")
list(
  tar_target(
    name = path, # Cible
    command = "donnees_BIO500/raw", # Dossier contenant les fichiers de données
    format = "file" # Format de la cible
  ),
  tar_target(
    name = file_paths, # Cible
    command = list.files(path, full.names = TRUE) # Liste les fichiers dans le dossier
  ),
 tar_target(
   name = list_table_avant_nettoyage, # Cible
   command = import_function(path,file_paths)
 ),
 tar_target(
   name = list_table_apres_nettoyage, # Cible
   command = nettoyage_function(list_table_avant_nettoyage)
 ),
 tar_target(
   name = con,  #retourner con pour les requêtes à venir
   command = create_data.base_func(list_table_apres_nettoyage)
 ),
 tar_render(
   name = rapport, # Cible du rapport
   path = "rapport/rapport.Rmd" # Le path du rapport à renderiser
)
)




