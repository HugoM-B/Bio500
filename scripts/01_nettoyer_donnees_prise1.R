######################################################
# Script pour nettoyer et assembler les données
# Victor Cameron
# 15 mars 2023
######################################################
#setwd('C:/Users/foduf/OneDrive/Bureau/méthode')
setwd("C:/Users/Hugo/Documents/methode/Bio500")
#setwd("C:/Users/foduf/Desktop/methode/Bio500")
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

rm(collaboration_1,collaboration_2,collaboration_3,collaboration_4,collaboration_5,collaboration_6,collaboration_7,collaboration_8,collaboration_9,collaboration_10,cour_1,cour_2,cour_3,cour_4,cour_5,cour_6,cour_7,cour_8,cour_9,cour_10,etudiant_1,etudiant_2,etudiant_3,etudiant_4,etudiant_5,etudiant_6,etudiant_7,etudiant_8,etudiant_9,etudiant_10)
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

etudiant <- data.frame(lapply(etudiant, function(x) {
  gsub("<a0>", "", x) }))
collabo <- data.frame(lapply(collabo, function(x) {
  gsub("<a0>", "", x) }))

etudiant<-unique(etudiant)
cours<-unique(cours)
collabo<-unique(collabo)

etudiant <- subset(etudiant, complete.cases(etudiant$prenom_nom))
cours<- subset(cours, complete.cases(cours$sigle))
collabo <- subset(collabo, complete.cases(collabo$etudiant1))
etudiant <-as.data.frame(etudiant) 
cours <-as.data.frame(cours)
collabo <-as.data.frame(collabo)


###nettoyer cours
cours<-cours[!duplicated(cours$sigle),]

####nettoyer étudiant avec info vs pas info
etud<-subset(etudiant, complete.cases(etudiant$regime_coop))
etudnoinfo<-subset(etudiant, !complete.cases(etudiant$regime_coop))


etudnoinfo$doublons<-is.element(etudnoinfo$prenom_nom,etud$prenom_nom)
etudnoinfo<-subset(etudnoinfo,etudnoinfo$doublons==FALSE)
etudnoinfo<-etudnoinfo[,-9]
etudiant<-rbind(etud,etudnoinfo)
rm(etud,etudnoinfo)


collabo <- data.frame(lapply(collabo, function(x) {
  gsub("francis_bourrassa", "francis_bourassa", x)}))

etudiant<- data.frame(lapply(etudiant, function(x) {
  gsub("louis_philipe_raymond", "louis_philippe_raymond", x)}))

etudiant<- data.frame(lapply(etudiant, function(x) {
  gsub("madyson_mclean", "madyson_mcclean", x)}))

etudiant<- data.frame(lapply(etudiant, function(x) {
  gsub("mclean", "mcclean", x)}))

collabo <- data.frame(lapply(collabo, function(x) {
  gsub("frederick_laberge", "frederic_laberge", x)}))


###loader package stringr
library(stringr)

etudiant$patterna<-str_sub(etudiant$prenom_nom,1,-5)
etudiant$patternb<-str_sub(etudiant$prenom_nom,5,-1)
etudiant$patternc<-str_sub(etudiant$prenom_nom,1,13)
etudiant$patternd<-str_sub(etudiant$prenom_nom,-15,-1)

etudiant<-unique(etudiant[!duplicated(etudiant$patterna),])
etudiant<-unique(etudiant[!duplicated(etudiant$patternb),])
etudiant<-unique(etudiant[!duplicated(etudiant$patternc),])
etudiant<-unique(etudiant[!duplicated(etudiant$patternd),])



####Nettoyer collab
# Enlever collaboration avec soi-même
#-----------------------------------------------------
collabo <- subset(collabo, etudiant1 != etudiant2)


collabo$pata<-str_sub(collabo$etudiant1 ,1,-5)
collabo$patb<-str_sub(collabo$etudiant1,5,-1)
collabo$patc<-str_sub(collabo$etudiant1,1,13)
collabo$patd<-str_sub(collabo$etudiant1,-15,-1)

collabo$pata2<-str_sub(collabo$etudiant2 ,1,-5)
collabo$patb2<-str_sub(collabo$etudiant2,5,-1)
collabo$patc2<-str_sub(collabo$etudiant2,1,13)
collabo$patd2<-str_sub(collabo$etudiant2,-15,-1)

##etudiant 1
correspondance<-match(collabo$pata, etudiant$patterna)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$pata[k]<-etudiant$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patb, etudiant$patternb)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$patb[k]<-etudiant$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patc, etudiant$patternc)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$patc[k]<-etudiant$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patd, etudiant$patternd)
k<-seq(1,length(collabo$etudiant1),by=1)
collabo$patd[k]<-etudiant$prenom_nom[correspondance[k]]


##etudiant 2
correspondance<-match(collabo$pata2, etudiant$patterna)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$pata2[k]<-etudiant$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patb2, etudiant$patternb)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$patb2[k]<-etudiant$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patc2, etudiant$patternc)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$patc2[k]<-etudiant$prenom_nom[correspondance[k]]

correspondance<-match(collabo$patd2, etudiant$patternd)
k<-seq(1,length(collabo$etudiant2),by=1)
collabo$patd2[k]<-etudiant$prenom_nom[correspondance[k]]


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

rm(collaboNa,collaboSNA, collaboNasave, collaboNasave2)



#new_name<-c('maude_viens','eloise_bernier','karim_hamzaoui','naomie_morin','justine_lebelle','gabrielle_moreault','maxence_comyn')
#for(i in 1:7){
#etudiant_nom[1 + length(etudiant_nom),1]<-new_name[i] 
#}

etudiant<-etudiant[,-c(9:12)]

num<-seq(1,length(etudiant$prenom_nom),1)
etudiant[,9]<-num
etudiant <- subset(etudiant, prenom_nom != 'arianne_barette' & prenom_nom != 'mael_guerin' & prenom_nom != 'marie_burghin' & prenom_nom != 'penelope_robert' 	& prenom_nom != 'philippe_barette' & prenom_nom != 'phillippe_bourassa' & prenom_nom != 'yanick_sagneau' & prenom_nom != 'yannick_sageau' )
etudiant<-etudiant[,c(1:8)]


#-----------------------------------------------------
# Ajouter les lignes d'étudiants manquantes dans etudiant
#-----------------------------------------------------

# Voir qui il manque --------------------Pour la fin
unique_et1_c<-unique(collabo$etudiant1)
unique_etudiant<-unique(etudiant$prenom_nom)
nom_manquant1<-setdiff(unique_et1_c, unique_etudiant)

#Ajouter qui il manque----------------------------------- CHANGER LE CODE!!!!
donnees_abs <- c("eloise_bernier", "eloise", "bernier", NA, NA, NA, NA, NA, "naomie_morin", "naomie", "morin", NA, NA, NA, NA, NA, "karim_hamzaoui", "karim", "hamzaoui", NA, NA, NA, NA, NA, "gabrielle_moreault", "gabrielle", "moreault", NA, NA, NA, NA, NA, "maxence_comyn", "maxence", "comyn", NA, NA, NA, NA, NA, "maude_viens", "maude", "viens", NA, NA, NA, NA, NA, "louis_philippe_raymond", "louis-philippe", "raymond",NA, NA, NA, NA, NA)
etudiant_abs <- matrix(donnees_abs, nrow = 7, ncol = 8, byrow = TRUE)
colnames(etudiant_abs) <- c("prenom_nom", "prenom", "nom", "region_administrative", "regime_coop", "formation_prealable", "annee_debut", "programme")
etudiant <- rbind(etudiant, etudiant_abs)
rm(donnees_abs, etudiant_abs)

etudiant<-unique(etudiant)


unique_et1_c<-unique(collabofinal$etudiant1)
unique_etudiant<-unique(etudiant$prenom_nom)
nom_diff<-setdiff(unique_et1_c, unique_etudiant)
bon_nom<-c("yanick_sageau", "peneloppe_robert", "philippe_bourassa", "philippe_barrette","mael_gerin", "marie_bughin", "ariane_barette", "yanick_sageau", "madyson_mcclean", "justine_labelle", "sabrina_leclercq")
for (t in 1:length(nom_diff)) {
  collabofinal <- data.frame(lapply(collabofinal, function(x) {
    gsub(nom_diff[t], bon_nom[t], x)})) 
}

unique_cours_collab<-unique(collabofinal$sigle)
unique_cours<-unique(cours$sigle)
nom_diffcours<-setdiff(unique_cours_collab, unique_cours)
bon_nomcours<-c("GBI104", "1NA", "GAE550", "ECL404")
for (w in 1:length(nom_diffcours)) {
  collabofinal1 <- data.frame(lapply(collabofinal, function(x) {
    gsub(nom_diffcours[w], bon_nomcours[w], x)})) 
}

collabofinal<-collabofinal1
rm(collabofinal1)
collabofinal<-subset(collabofinal,collabofinal$sigle!="GBI105" & collabofinal!="GAE500")
collabofinal <- subset(collabofinal, complete.cases(collabofinal$etudiant1))
collabo<-unique(collabofinal)
rm(collabofinal)


#CRÉER LA BASE DE DONNÉES

con <- dbConnect(SQLite(), dbname="reseau511.db")

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

dbWriteTable(con, append = TRUE, name = "etudiant", value = etudiant, row.names = FALSE, na.rm = TRUE)
dbWriteTable(con, append = TRUE, name = "cours", value = cours, row.names = FALSE)
dbWriteTable(con, append = TRUE, name = "collabo", value =  collabo, row.names = FALSE)

#REQUÊTES
#nombre de liens par étudiants

sql_requete <- "
SELECT DISTINCT etudiant1,
 COUNT(etudiant1) AS liens_etudiant
 FROM collabo;"


liens <-dbGetQuery(con, sql_requete)
head(liens)

#Décompte de liens par paire d'étudiants
sql_requete <- "
SELECT DISTINCT etudiant1, etudiant2,
 COUNT(*) AS liens_paire
 FROM collabo
 GROUP BY etudiant1, etudiant2
 ;"

liens_paires <-dbGetQuery(con, sql_requete)
head(liens_paires)

#Requete pour savoir les Collaborations entre étudiants de la même chohorte
sql_requete <-
"SELECT c.etudiant1, c.etudiant2,
COUNT(*) AS nb_collaborations, e1.annee_debut, e2.annee_debut
FROM collabo c 
JOIN etudiant e1 ON c.etudiant1 = e1.prenom_nom 
JOIN etudiant e2 ON c.etudiant2 = e2.prenom_nom 
WHERE 
e1.annee_debut = e2.annee_debut
GROUP BY 
c.etudiant1, c.etudiant2, e1.annee_debut, e2.annee_debut
ORDER BY 
nb_collaborations DESC
;"
mm_ad_collabo  <-dbGetQuery(con, sql_requete)
head(mm_ad_collabo)

#requete pour savoir le nombre de collabo etre élèves PAS de la mm cohorte

sql_requete <-
  "SELECT c.etudiant1, c.etudiant2,
COUNT(*) AS nb_collaborations, e1.annee_debut, e2.annee_debut
FROM collabo c 
JOIN etudiant e1 ON c.etudiant1 = e1.prenom_nom 
JOIN etudiant e2 ON c.etudiant2 = e2.prenom_nom 
WHERE 
e1.annee_debut <> e2.annee_debut
GROUP BY 
c.etudiant1, c.etudiant2, e1.annee_debut, e2.annee_debut
ORDER BY 
nb_collaborations DESC
;"
pm_ad_collabo  <-dbGetQuery(con, sql_requete)
head(pm_ad_collabo)

#Requête pour la région administrative des élèves
#même région
sql_requete <- "
SELECT etudiant1, etudiant2,
COUNT(*) AS nb_collaborations, e1.region_administrative, e2.region_administrative
FROM collabo
JOIN etudiant e1 ON etudiant1 = e1.prenom_nom
JOIN etudiant e2 ON etudiant2 = e2.prenom_nom
WHERE
e1.region_administrative = e2.region_administrative
GROUP BY 
etudiant1, etudiant2, e1.region_administrative, e2.region_administrative
;"

mm_ra_collabo  <-dbGetQuery(con, sql_requete)
head(mm_ra_collabo)

#pas la même région

sql_requete <- "
SELECT etudiant1, etudiant2,
COUNT(*) AS nb_collaborations, e1.region_administrative, e2.region_administrative
FROM collabo
JOIN etudiant e1 ON etudiant1 = e1.prenom_nom
JOIN etudiant e2 ON etudiant2 = e2.prenom_nom
WHERE
e1.region_administrative <> e2.region_administrative
GROUP BY 
etudiant1, etudiant2, e1.region_administrative, e2.region_administrative
;"

pm_ra_collabo  <-dbGetQuery(con, sql_requete)
head(pm_ra_collabo)

#Graphique de centralité

plot(g, vertex.label=NA, edge.arrow.mode = 0,
     vertex.frame.color = NA,
     layout = layout.circle(g))

#-----------------------------------------------------

