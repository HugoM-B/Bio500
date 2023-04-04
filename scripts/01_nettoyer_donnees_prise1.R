######################################################
# Script pour nettoyer et assembler les données
# Victor Cameron
# 15 mars 2023
######################################################
setwd('C:/Users/foduf/OneDrive/Bureau/méthode')

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


#-----------------------------------------------------
# 1. Charger les données
#
# Assumant que les données sont sauvées dans le 
# sous-répertoire data/raw
#-----------------------------------------------------

# Extraire le nom des fichers de chaque groupe
allFiles <- dir('data/raw/donnees_BIO500')

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
    ficher <- paste0('data/raw/donnees_BIO500/', tabFiles[groupe])
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
  gsub("-", "_", x) }))
cours <- data.frame(lapply(cours, function(x) {
  gsub("-", "_", x)}))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub("-", "_", x)}))

etudiant <- data.frame(lapply(etudiant, function(x) {
  gsub(" ", "", x) }))
cours <- data.frame(lapply(cours, function(x) {
  gsub(" ", "", x)}))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub(" ", "", x)}))

etudiant_unique<-unique(etudiant)
cours_unique<-unique(cours)
collabo<-unique(collabo)

etud_unique1 <- subset(etudiant_unique, complete.cases(etudiant_unique$prenom_nom))
cours_unique1 <- subset(cours_unique, complete.cases(cours_unique$sigle))
collabo <- subset(collabo, complete.cases(collabo$etudiant1))
etud_unique1 <-as.data.frame(etud_unique1) 
cours_unique1 <-as.data.frame(unique(cours_unique1))
collabo <-as.data.frame(collabo)


###nettoyer cours
cours_unique1<-cours_unique1[!duplicated(cours_unique1$sigle),]

####nettoyer ?tudiant
testetud<-subset(etud_unique1, complete.cases(etud_unique1$regime_coop))
testetudnoinfo<-subset(etud_unique1, !complete.cases(etud_unique1$regime_coop))


testetudnoinfo$test<-is.element(testetudnoinfo$prenom_nom,testetud$prenom_nom)
testetudnoinfo<-subset(testetudnoinfo,testetudnoinfo$test==FALSE)
testetudnoinfo<-testetudnoinfo[,-9]
etudiant_nom<-rbind(testetud,testetudnoinfo)

###loader package stringr
library(stringr)

etudiant_nom$patterna<-str_sub(etudiant_nom$prenom_nom,1,-5)
etudiant_nom$patternb<-str_sub(etudiant_nom$prenom_nom,7,-1)
etudiant_nom$patternc<-str_sub(etudiant_nom$prenom_nom,1,13)
etudiant_nom$patternd<-str_sub(etudiant_nom$prenom_nom,-15,-1)

etudiant_nom<-unique(etudiant_nom[!duplicated(etudiant_nom$patterna),])
etudiant_nom<-unique(etudiant_nom[!duplicated(etudiant_nom$patternb),])
etudiant_nom<-unique(etudiant_nom[!duplicated(etudiant_nom$patternc),])
etudiant_nom<-unique(etudiant_nom[!duplicated(etudiant_nom$patternd),])

#etudiant_nom<-etudiant_nom[,-c(9,12)]

####Nettoyer collab

collabo$pata<-str_sub(collabo$etudiant1 ,1,-5)
collabo$patb<-str_sub(collabo$etudiant1,7,-1)
collabo$patc<-str_sub(collabo$etudiant1,1,13)
collabo$patd<-str_sub(collabo$etudiant1,-15,-1)

collabo$pata2<-str_sub(collabo$etudiant2 ,1,-5)
collabo$patb2<-str_sub(collabo$etudiant2,7,-1)
collabo$patc2<-str_sub(collabo$etudiant2,1,13)
collabo$patd2<-str_sub(collabo$etudiant2,-15,-1)

##etudiant 1
correspondance<-match(collabo$pata, etudiant_nom$patterna)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$pata[k]<-etudiant_nom$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patb, etudiant_nom$patternb)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$patb[k]<-etudiant_nom$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patc, etudiant_nom$patternc)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$patc[k]<-etudiant_nom$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patd, etudiant_nom$patternd)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$patd[k]<-etudiant_nom$prenom_nom[correspondance[k]]


##etudiant 2
correspondance<-match(collabo$pata2, etudiant_nom$patterna)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$pata2[k]<-etudiant_nom$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patb2, etudiant_nom$patternb)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$patb2[k]<-etudiant_nom$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patc2, etudiant_nom$patternc)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$patc2[k]<-etudiant_nom$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patd2, etudiant_nom$patternd)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$patd2[k]<-etudiant_nom$prenom_nom[correspondance[k]]


###remplacer les valeurs
collabo$etudiant10<-collabo$pata
collaboNa<-subset(collabo, !complete.cases(collabo$etudiant10))
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant10))
collaboNa$etudiant10<-collaboNa$patb
collabo<-rbind(collaboSNA,collaboNa)

collaboNa<-subset(collabo, !complete.cases(collabo$etudiant10))
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant10))
collaboNa$etudiant10<-collaboNa$patc
collabo<-rbind(collaboSNA,collaboNa)

collaboNa<-subset(collabo, !complete.cases(collabo$etudiant10))
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant10))
collaboNa$etudiant10<-collaboNa$patd
collabo<-rbind(collaboSNA,collaboNa)

collaboNa<-subset(collabo, !complete.cases(collabo$etudiant10))
collaboNasave<-subset(collabo, !complete.cases(collabo$etudiant10)) ### erreur bizzare ici
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant10))
collaboNa$etudiant10<-collaboNa$etudiant1
collabo<-rbind(collaboSNA,collaboNa)

collabo$etudiant1<-collabo$etudiant10

####etudiant 2

collabo$etudiant11<-collabo$pata2
collaboNa<-subset(collabo, !complete.cases(collabo$etudiant11))
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant11))
collaboNa$etudiant11<-collaboNa$patb2
collabo<-rbind(collaboSNA,collaboNa)

collaboNa<-subset(collabo, !complete.cases(collabo$etudiant11))
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant11))
collaboNa$etudiant11<-collaboNa$patc2
collabo<-rbind(collaboSNA,collaboNa)

collaboNa<-subset(collabo, !complete.cases(collabo$etudiant11))
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant11))
collaboNa$etudiant11<-collaboNa$patd2
collabo<-rbind(collaboSNA,collaboNa)

collaboNa<-subset(collabo, !complete.cases(collabo$etudiant11))
collaboNasave2<-subset(collabo, !complete.cases(collabo$etudiant11)) ### erreur bizzare ici
collaboSNA<-subset(collabo, complete.cases(collabo$etudiant11))
collaboNa$etudiant11<-collaboNa$etudiant2
collabo<-rbind(collaboSNA,collaboNa)

collabo$etudiant2<-collabo$etudiant11
collabofinal<-collabo[,c(1:4)]
collabofinal<- unique(collabofinal)

new_name<-c('maude_viens','eloise_bernier','karim_hamzaoui','naomie_morin','justine_lebelle','gabrielle_moreault','maxence_comyn')
for(i in 1:7){
etudiant_nom[i + 163,1]<-new_name[i] 
}

num<-seq(1,170,1)
etudiant_nom[,13]<-num
etudiant_nom <- subset(etudiant_nom, prenom_nom != 'arianne_barette' & prenom_nom != 'mael_guerin' & prenom_nom != 'marie_burghin' & prenom_nom != 'penelope_robert' 	& prenom_nom != 'philippe_barette' & prenom_nom != 'phillippe_bourassa' & prenom_nom != 'yanick_sagneau' & prenom_nom != 'yannick_sageau' & V13 != 121)



collabofinal <- data.frame(lapply(collabofinal, function(x) {
  gsub("francis_bourrassa", "francis_bourassa", x)}))

etudiant_nom<- data.frame(lapply(etudiant_nom, function(x) {
  gsub("louis_philipe_raymond", "louis_philippe_raymond", x)}))

etudiant_nom<- data.frame(lapply(etudiant_nom, function(x) {
  gsub("madyson_mclean", "madyson_mcclean", x)}))

etudiant_nom<- data.frame(lapply(etudiant_nom, function(x) {
  gsub("mclean", "mcclean", x)}))

collabofinal <- data.frame(lapply(collabofinal, function(x) {
  gsub("frederick_laberge", "frederic_laberge", x)}))




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
hg help
