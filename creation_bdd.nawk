# HOUIMLI SAFA 		
# 
# Program gawk de Tony Wong modifie
# Detecte les differentes etats et creer une base de donnees avec un fichier gpx donne
# Decembre 2017

# Initialisation des variables, et compteur POINT, insert les entetes dans le fichier de base de donnees
BEGIN		{ sINITIAL = 0; sFINAL = 1; sGPX = 2; sWAYPOINT = 3; sROUTE = 4; sROUTEPOINT = 5;
		  sTRACK = 6; sTRACKSEGMENT = 7; sTRACKPOINT = 8; sERREUR = 9;
		  vEtat = sINITIAL;
		  vCause = "";
		  vNbLigne = 0;
		  POINT = 0
		  sFICHIER = FENTREE".bdd"
		  printf("Positions\tLatitude\tLongitude\tElevation\tTemps\n") > sFICHIER
		}
# Affiche message de fin apres le traitement
END		{ printf("Le traitement du fichier GPX %s est fini.\nLes resultats se retrouvent dans %s\n",FENTREE,sFICHIER); 
		}

#
# Compteur de lignes et elimination du caractere \r (carriage return)
#
		# parfois le document GPX est traite sur un PC et les fins de ligne
		# ont les caracteres de controle \r\n. Il faut enlever \r puisque sous
		# Linux \n joue le role de CR/LF.
		{gsub(/\r/, "", $0); vNbLigne++ }

#
# Etat actuel est sINITIAL
#
$0 ~ /<gpx .*/ ||
$0 ~ /<gpx$/	{ 
		  Ligne = detecte_elem($0)
		  if (Ligne == "")
		    exit;

		  # on a detecter le symbole >, cherchons les elements obligatoires...
		  if (!match(Ligne, /xmlns:xsi=/) || !match(Ligne, /xsi:schemaLocation=/) ||
                      !match(Ligne, /creator=/)   || !match(Ligne, /version=/) ||
		      !match(Ligne, /xmlns=/)) {
		    vCause = "Elementaires obligatoires de la balise <gpx> introuvable";
		    exit;
		  }


		  # Les elements obligatoires de <gpx> sont trouves
		  if (vEtat == sINITIAL) {
		    vEtat = sGPX; # print "sGPX";
		  }
		  else {
		    vCause = "Balise <gpx> illegale";
		    exit
		  }
		}

#
# Etat actuel est sINITIAL
#
/<\/gpx>/	{ if (vEtat == sGPX) { 
		    vEtat = sFINAL; # print "sFINAL";
		  }
		  else {
		    vCause = "Balise </gpx> illegale";
		    exit
		  }
		}

#
# Etat actuel est sGPX
#
$0 ~ /<wpt .*/ ||
$0 ~ /<wpt$/	{
		  Ligne = detecte_elem($0)
		  if (Ligne == "")
		    exit;

		  # on a detecter le symbole >, cherchons les elements obligatoires...
		  if (!match(Ligne, /lon=/) || !match(Ligne, /lat=/)) {
		    vCause = "Elementaires obligatoires de la balise <wpt> introuvable";
		    exit;
		  }


		  if (vEtat == sGPX) {
		    vEtat = sWAYPOINT; # print "sWAYPOINT"; 
		  }
		  else {
		    vCause = "Balise <wpt> illegale";
		    exit
		  }
		}


/<rte>/		{ if (vEtat == sGPX) {
		    vEtat = sROUTE; # print "sROUTE";
		  }
		  else {
		    vCause = "Balise <rte> illegale";
		    exit
		  }
		}


/<trk>/		{ if (vEtat == sGPX) {
		    vEtat = sTRACK; # print "sTRACK";
		  }
		  else {
		    vCause = "Balise <trk> illegale";
		    exit
		  }
		}

#
# Etat actuel est sWAYPOINT
#
/<\/wpt>/	{ if (vEtat == sWAYPOINT) {
		    vEtat = sGPX; # print "sGPX";
		  }
		  else {
		    vCause = "Balise </wpt> illegale";
		    exit
		  }
		}

#
# Etat actuel est sROUTE
#
$0 ~ /<rtept .*/ ||
$0 ~ /<rtept$/	{
		  Ligne = detecte_elem($0)
		  if (Ligne == "")
		    exit;

		  # on a detecter le symbole >, cherchons les elements obligatoires...
		  if (!match(Ligne, /lon=/) || !match(Ligne, /lat=/)) {
		    vCause = "Elementaires obligatoires de la balise <rtept> introuvable";
		    exit;
		  }


		  if (vEtat == sROUTE) {
		    vEtat = sROUTEPOINT; # print "sROUTEPOINT";
		  }
		  else {
		    vCause = "Balise <rtept> illegale";
		    exit
		  }
		}

/<\/rte>/	{ if (vEtat == sROUTE) {
		    vEtat = sGPX; # print "sGPX";
		  }
		  else {
		    vCause = "Balise </rte> illegale";
		    exit
		  }
		}

#
# Etat actuel est sROUTEPOINT
#
/<\/rtept>/	{ if (vEtat == sROUTEPOINT) {
		    vEtat = sROUTE; # print "sROUTE";
		  }
		  else {
		    vCause = "Balise </rtept> illegale";
		    exit
		  }
		}

#
# Etat actuel est sTRACK
#
/<trkseg>/	{ if (vEtat == sTRACK) {
		    vEtat = sTRACKSEGMENT; # print "sTRACKSEGMENT";
		  }
		  else {
		    vCause = "Balise <trkseg> illegale";
		    exit
		  }
		}

/<\/trk>/	{ if (vEtat == sTRACK) {
		    vEtat = sGPX; # print "sGPX";
		  }
		  else {
		    vCause = "Balise </trk> illegale";
		    exit
		  }
		}

#
# Etat actuel est sTRACKSEGMENT
#
$0 ~ /<trkpt .*/ ||
$0 ~ /<trkpt$/	{


		  Ligne = detecte_elem($0)
		  if (Ligne == "")
		    exit;

		  # on a detecter le symbole >, cherchons les elements obligatoires...
		  if (!match(Ligne, /lon=/) || !match(Ligne, /lat=/)) {
		    vCause = "Elementaires obligatoires de la balise <trkpt> introuvable";
		    exit;
		  }

		  if (vEtat == sTRACKSEGMENT) {
		    vEtat = sTRACKPOINT; # print "sTRACKPOINT";
		  }
		  else {
		    vCause = "Balise <trkpt> illegale";
		    exit
		  }

		  #Incremente le compteur du trackpoint trouve
	  	  POINT++

		  #Tant qu'on n'est pas a la fin du trackpoint, trouve les elements de latitude sur la ligne courante, envoie le resultat a la variable LAT et tri les objets non-voulu
		  while ($0 !~ /<\/trkpt>/){
		    if ($0 ~ /lat=\"[-]?[0-9]+\.[0-9]+\"/){
		      match($0, /lat=\"[-]?[0-9]+\.[0-9]+\"/,LAarr)
		      LAT = LAarr[0]
		      gsub(/[^0-9.-]*/,"",LAT)
  		    }

		    #Trouve les elements de longitude sur la ligne courante, envoie le resultat a la variable LON et tri les objets non-voulu
		    if ($0 ~ /lon=\"[-]?[0-9]+\.[0-9]+\"/){
		      match($0, /lon=\"[-]?[0-9]+\.[0-9]+\"/,LOarr)
		      LON = LOarr[0]
		      gsub(/[^0-9.-]*/,"",LON)
  		    } 	

		    #Trouve les elements d'elevation sur la ligne courante, envoie le resultat a la variable ELE
		    if ($0 ~ /<ele>.*<\/ele>/){
		      match($0, /[-]?[0-9]+[.]?[0-9]*/,Earr)
		      ELE = Earr[0]
  		    }

		    #Trouve les elements de temps sur la ligne courante, envoie le resultat a la variable TEMP
		    if ($0 ~ /<time>.*<\/time>/){
		      match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][Tt][0-9][0-9]:[0-9][0-9]:[0-9][0-9][Zz]/,Tarr)
		      TEMP = Tarr[0]
  		    }
		    #Change le $0 pour la ligne suivante
		    getline
		  }

		  #Envoies les elements du trackpoint dans la base de donnees
		  printf("%s\t\t%s\t%s\t%s\t\t%s\n",POINT,LAT,LON,ELE,TEMP) > sFICHIER 					 

		}

/<\/trkseg>/	{ if (vEtat == sTRACKSEGMENT) {
		    vEtat = sTRACK; # print "sTRACK";
		  }
		  else {
		    vCause = "Balise </trkseg> illegale";
		    exit
		  }
		}

#
# Etat actuel est sTRACKPOINT
#
/<\/trkpt>/	{ if (vEtat == sTRACKPOINT) {
		    vEtat = sTRACKSEGMENT; # print "sTRACKSEGMENT";
		  }
		  else {
		    vCause = "Balise </trkpt> illegale";
		    exit
		  }
		}

#
# Fonction utilisateur
#
function detecte_elem(lig)
{
  while (!match(lig, />/)) {
    if (getline X) {
      # enlever les codes de controle generes par Windows (au cas ou...)
      gsub(/[\r^M]/,"", lig)
      # ajouter (concatener) les caracteres lus dans la variable Ligne
      lig = (lig " " X);
      vNbLigne++;
      #printf("Ligne = %s\n", lig)
    }
    else {
      vCause = "fin du fichier et le symbole \">\" est introuvable";
      return "";
    }
  }

  return lig;
}

