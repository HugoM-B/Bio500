######################################################
# Script pour nettoyer et assembler les données
# Victor Cameron
# 15 mars 2023
######################################################
#setwd('C:/Users/foduf/OneDrive/Bureau/méthode/BIO500')
#setwd("C:/Users/Hugo/Documents/methode/Bio500")
setwd("C:/Users/foduf/Desktop/methode/Bio500")
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
#setwd("C:/Users/Hugo/Documents/methode/Bio500")
# Extraire le nom des fichers de chaque groupe
import_function<-function(x){
allFiles <- dir('donnees_BIO500/raw')

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
list_table<-list(etudiant = etudiant,cours = cours ,collabo = collabo)
return(list_table)
}
#-----------------------------------------------------

# 2.
nettoyage_function<-function(x){
  
etudiant<-x[[1]]
cours<-x[[2]]
collabo<-x[[3]]
 
library(RSQLite)
#retiré les traits d'union et les remplacer par des 'underscore'
etudiant <- data.frame(lapply(etudiant, function(x) {
  gsub("-", "_", x) }))
cours <- data.frame(lapply(cours, function(x) {
  gsub("-", "_", x)}))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub("-", "_", x)}))
#retrait des espaces
etudiant <- data.frame(lapply(etudiant, function(x) {
  gsub(" ", "", x) }))
etudiant <- data.frame(lapply(etudiant, function(x) {
  gsub("<a0>", "", x) }))
cours <- data.frame(lapply(cours, function(x) {
  gsub(" ", "", x)}))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub(" ", "", x)}))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub("<a0>", "", x)}))

#correction de certains noms 

#ajout de nom oublié dans la table étudiant
new_name<-c('maude_viens','eloise_bernier','karim_hamzaoui','naomie_morin','justine_lebelle','gabrielle_moreault','maxence_comyn')
for(i in 1:7){
  etudiant[i + 403,1]<-new_name[i] 
}

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("francis_bourrassa", "francis_bourassa", x)}))

etudiant<- data.frame(lapply(etudiant, function(x) {
  gsub("louis_philipe_raymond", "louis_philippe_raymond", x)}))

etudiant<- data.frame(lapply(etudiant, function(x) {
  gsub("madyson_mclean", "madyson_mcclean", x)}))

etudiant<- data.frame(lapply(etudiant, function(x) {
  gsub("mclean", "mcclean", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("madyson_mclean", "madyson_mcclean", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("mael_guerin", "mael_gerin", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("frederick_laberge", "frederic_laberge", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("arianne_barette", "	ariane_barrette", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("arianne_barette", "	ariane_barrette", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("marie_burghin", "marie_bughin", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("penelope_robert", "peneloppe_robert", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("philippe_barette", "philippe_barrette", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("phillippe_bourassa", "philippe_bourassa", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("yanick_sagneau", "yanick_sageau", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("yannick_sageau", "yanick_sageau", x)}))

#num<-seq(1,410,1)
#etudiant[,9]<-num
etudiant <- subset(etudiant, prenom_nom != 'arianne_barette' & prenom_nom != 'mael_guerin' & prenom_nom != 'marie_burghin' & prenom_nom != 'penelope_robert' 	& prenom_nom != 'philippe_barette' & prenom_nom != 'phillippe_bourassa' & prenom_nom != 'yanick_sagneau' & prenom_nom != 'yannick_sageau')
#etudiant<-etudiant[,-9]
etudiant_unique<-unique(etudiant)
cours_unique<-unique(cours)
collabo<-unique(collabo)

etud_unique1 <- subset(etudiant_unique, complete.cases(etudiant_unique$prenom_nom))
cours_unique1 <- subset(cours_unique, complete.cases(cours_unique$sigle))
collabo <- subset(collabo, complete.cases(collabo$etudiant1))
etud_unique1 <-as.data.frame(etud_unique1) 
cours_unique1 <-as.data.frame(unique(cours_unique1))
collabofinal <-as.data.frame(collabo)


###nettoyer cours
cours_unique1<-cours_unique1[!duplicated(cours_unique1$sigle),]

####nettoyer ?tudiant
testetud<-subset(etud_unique1, complete.cases(etud_unique1$regime_coop))
testetudnoinfo<-subset(etud_unique1, !complete.cases(etud_unique1$regime_coop))


testetudnoinfo$test<-is.element(testetudnoinfo$prenom_nom,testetud$prenom_nom)
testetudnoinfo<-subset(testetudnoinfo,testetudnoinfo$test==FALSE)
testetudnoinfo<-testetudnoinfo[,-9]
etudiant_nom<-rbind(testetud,testetudnoinfo)



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

#-----------------------------------------------------
# Ajouter les lignes d'étudiants manquantes dans etudiant
#-----------------------------------------------------

# Voir qui il manque --------------------Pour la fin
unique_et1_c<-unique(collabofinal$etudiant1)
unique_etudiant<-unique(etudiant_nom$prenom_nom)
setdiff(unique_et1_c, unique_etudiant)

#Ajouter qui il manque----------------------------------- CHANGER LE CODE!!!!
donnees_abs <- c("eloise_bernier", "eloise", "bernier", NA, NA, NA, NA, NA, "naomie_morin", "naomie", "morin", NA, NA, NA, NA, NA, "karim_hamzaoui", "karim", "hamzaoui", NA, NA, NA, NA, NA, "gabrielle_moreault", "gabrielle", "moreault", NA, NA, NA, NA, NA, "maxence_comyn", "maxence", "comyn", NA, NA, NA, NA, NA, "maude_viens", "maude", "viens", NA, NA, NA, NA, NA, "louis_philippe_raymond", "louis-philippe", "raymond",NA, NA, NA, NA, NA)
etudiant_abs <- matrix(donnees_abs, nrow = 7, ncol = 8, byrow = TRUE)
colnames(etudiant_abs) <- c("prenom_nom", "prenom", "nom", "region_administrative", "regime_coop", "formation_prealable", "annee_debut", "programme")
etudiant <- rbind(etudiant_nom, etudiant_abs)
rm(donnees_abs, etudiant_abs)

#-----------------------------------------------------
# Enlever fausses lignes de collaboration avec soi-même ----------------------CHANGERRR code
#-----------------------------------------------------
#collaboration <- subset(collaboration, etudiant1 != etudiant2)

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
  etudiant_nom[1 + length(etudiant_nom),1]<-new_name[i] 
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

#Ajouter qui il manque----------------------------------- CHANGER LE CODE!!!!
donnees_abs <- c("eloise_bernier", "eloise", "bernier", NA, NA, NA, NA, NA, "naomie_morin", "naomie", "morin", NA, NA, NA, NA, NA, "karim_hamzaoui", "karim", "hamzaoui", NA, NA, NA, NA, NA, "gabrielle_moreault", "gabrielle", "moreault", NA, NA, NA, NA, NA, "maxence_comyn", "maxence", "comyn", NA, NA, NA, NA, NA, "maude_viens", "maude", "viens", NA, NA, NA, NA, NA, "louis_philippe_raymond", "louis-philippe", "raymond",NA, NA, NA, NA, NA)
etudiant_abs <- matrix(donnees_abs, nrow = 7, ncol = 8, byrow = TRUE)
colnames(etudiant_abs) <- c("prenom_nom", "prenom", "nom", "region_administrative", "regime_coop", "formation_prealable", "annee_debut", "programme")
etudiant_nom<-etudiant_nom[,c(1:8)]
etudiant <- rbind(etudiant_nom, etudiant_abs)
rm(donnees_abs, etudiant_abs)

etudiant<-unique(etudiant)

# Enlever fausses lignes de collaboration avec soi-même ----------------------CHANGERRR code
#-----------------------------------------------------
collaboration <- subset(collaboration, etudiant1 != etudiant2)
}

nettoyage_function(etudiant,cours,collabo)
>>>>>>> 5db96eabf8e9520be9a42bddfba352547b2d726a
#CRÉER LA BASE DE DONNÉES

create_table_function<-function(etudiant,cours,collabo){
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
}


#REQUÊTES
#nombre de liens par étudiants
requête<-function(x){
sql_requete <- "
SELECT etudiant1, 
 COUNT"
}
#-----------------------------------------------------

