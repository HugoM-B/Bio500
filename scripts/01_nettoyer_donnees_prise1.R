######################################################
# Script pour nettoyer et assembler les données
# Victor Cameron
# 15 mars 2023
######################################################

111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
######################################################
## Etapes (*À ADAPTER*)
# 1. Charger tous les donnees provenants du dossier data/raw
# 2. Pour chaque table (etudiant, cours, collaborations):
# 	- Vérifier si les noms de colonnes sont standardisés
# 	- Vérifier si chacune des valeurs pour chaque colonne respecte le formatage
# 	- Réparer les colonnes que ne respectent pas le format (travail manuel ici)
# 	- Autres vérifications dans et entre les groupes
# 	- Fusionner les donnees de chaque groupe en un seul data.frame
# 3. Sauvegarder les données fusionnées de chaque table dans le dossier data/clean
######################################################

shrekshrekshrekshrek
#-----------------------------------------------------
# 1. Charger les données
#
# Assumant que les données sont sauvées dans le 
# sous-répertoire data/raw
#-----------------------------------------------------
setwd("C:/Users/Hugo/Documents/methode")
# Extraire le nom des fichers de chaque groupe
allFiles <- dir('donnees_BIO500/raw/')

# Tables à fusioner
tabNames <- c('collaboration', 'cour', 'etudiant')

# Nombre de groupes
nbGroupe <- length(grep(tabNames[1], allFiles))

# Charger les donnees
for(tab in tabNames) {
    # prendre seulement les fichers de la table specifique `tab`
    tabFiles <- allFiles[grep(tab, allFiles)]
    
    for(groupe in 1:nbGroupe) {
        # Definir le nom de l'obj dans lequel sauver les donnees de la table `tab` du groupe `groupe`
        tabName <- paste0(tab, "_", groupe)

        # Avant  de charger les données, il faut savoir c'est quoi le séparateur utilisé car
        # il y a eu des données separées par "," et des autres separes par ";"
        ficher <- paste0('donnees_BIO500/raw/', tabFiles[groupe])
        L <- readLines(ficher, n = 1) # charger première ligne du donnée
        separateur <- ifelse(grepl(';', L), ';', ',') # S'il y a un ";", separateur est donc ";"

        # charger le donnée avec le bon séparateur et donner le nom `tabName`
        assign(tabName, read.csv(ficher, sep = separateur, stringsAsFactors = FALSE, na.strings=c(""," ","NA")))

    }
}

# nettoyer des objets temporaires utilisé dans la boucle
rm(list = c('allFiles', 'tab', 'tabFiles', 'tabName', 'ficher', 'groupe'))
i<-seq(1,11,1)
# combiner les tableaux
#collaboration
collaboration_7<-collaboration_7[,1:4]
#collab_name<-c("collaboration_1","collaboration_2","collaboration_3","collaboration_4","collaboration_5","collaboration_6","collaboration_7","collaboration_8","collaboration_9","collaboration_10")
#colnames(collab_name[i])<-c("etudiant1","etudiant2","sigle","session")
collabo<-rbind(collaboration_1,collaboration_2,collaboration_3,collaboration_4,collaboration_5,collaboration_6,collaboration_7,collaboration_8,collaboration_9,collaboration_10)
#cour
cour_7<-cour_7[,1:3]
cour_5<-cour_5[,1:3]
colnames(cour_4)<-c("sigle","optionnel","credits")
cours<-rbind(cour_1,cour_2,cour_3,cour_4,cour_5,cour_6,cour_7,cour_8,cour_9,cour_10)
#etudiant
etudiant_7<-etudiant_7[,1:8]
etudiant_3<-etudiant_3[,1:8]
etudiant_4<-etudiant_4[,1:8]
etudiant_9<-etudiant_9[,1:8]
colnames(etudiant_4)<-c('prenom_nom',"prenom" ,"nom","region_administrative","regime_coop","formation_prealable","annee_debut","programme")
etudiant<-rbind(etudiant_1,etudiant_2,etudiant_3,etudiant_4,etudiant_5,etudiant_6,etudiant_7,etudiant_8,etudiant_9,etudiant_10)

#-----------------------------------------------------
# 2.
library(RSQLite)

etudiant <- data.frame(lapply(etudiant, function(x) {
                    gsub("-", "_", x)
                }))
cours <- data.frame(lapply(cours, function(x) {
  gsub("-", "_", x)
}))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub("-", "_", x)
}))


etudiant_unique<-unique(etudiant)
cours_unique<-unique(cours)
collabo_unique<-unique(collabo)

etud_unique1 <- subset(etudiant_unique, complete.cases(etudiant_unique$prenom_nom))
cours_unique1 <- subset(cours_unique, complete.cases(cours_unique$sigle))
collabo_unique1 <- subset(collabo_unique, complete.cases(collabo_unique$etudiant1))

install.packages("stringr")








#CRÉER LA BASE DE DONNÉES

con <- dbConnect(SQLite(), dbname="reseau508.db")

tbl_etudiant <-"
CREATE TABLE etudiant (
  prenom_nom  VARCHAR(100),
  prenom      VARCHAR(50),
  nom         VARCHAR(50),
  region_administrative VARCHAR(100),
  regime_coop  VARCHAR(4),
  formation_prealable VARCHAR(50),
  annee_debut VARCHAR(5),
  programme VARCHAR(6),
  PRIMARY KEY (prenom_nom,region_administrative,regime_coop),
  FOREIGN KEY (prenom_nom) REFERENCES collabo(etudiant1),
  FOREIGN KEY (prenom_nom) REFERENCES collabo(etudiant2)
);"

dbSendQuery(con, tbl_etudiant)
dbListTables(con)

tbl_cours <-"
CREATE TABLE cours(
 sigle VARCHAR(6),
 optionnel VARCHAR(4),
 credits VARCHAR(1),
 PRIMARY KEY (sigle,optionnel, credits),
 FOREIGN KEY (sigle) REFERENCES collabo(sigle)
);"

dbSendQuery(con, tbl_cours)
dbListTables(con)

tbl_collabo <- "
CREATE TABLE collabo (
 etudiant1 VARCHAR(50),
 etudiant2 VARCHAR(50),
 sigle VARCHAR(6),
 session VARCHAR(5),
 PRIMARY KEY (etudiant1, etudiant2, sigle, session),
 FOREIGN KEY (sigle) REFERENCES cours(sigle)
);"

dbSendQuery(con, tbl_collabo)
dbListTables(con)

#INSÉRER LES DONNÉES DANS LES TABLES

#bd_etudiant <- read.cvs(file = )
#bd_cours <- read.cvs(file = )
#bd_collabo <- read.csv(file = )

dbWriteTable(con, append = TRUE, name = "etudiant", value = etud_unique1, row.names = FALSE, na.rm = TRUE)
dbWriteTable(con, append = TRUE, name = "cours", value = cours_unique1, row.names = FALSE)
dbWriteTable(con, append = TRUE, name = "collabo", value =  collabo_unique1, row.names = FALSE)

#REQUÊTES
#nombre de liens par étudiants
sql_requete <- "
SELECT etudiant1, 
 COUNT"

#-----------------------------------------------------
