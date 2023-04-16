getwd()
setwd("C:/Users/foduf/OneDrive/Bureau/méthode/BIO500")
library(targets)
library(tarchetypes)
source("fonction2.0.R")
list(
  tar_target(
    name = path, # Cible
    command = "./data", # Dossier contenant les fichiers de données
    format = "file" # Format de la cible
  ),
  tar_target(
    name = file_paths, # Cible
    command = list.files(path, full.names = TRUE) # Liste les fichiers dans le dossier
  ),
  #Lecture des données
  tar_target(table,import_function()),
  #correction des donnees
  tar_target(etudiant,gsub_trait_union(etudiant)),
)

