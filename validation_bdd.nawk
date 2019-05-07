# HOUIMLI SAFA 		
# 
# Programme pour valider qu'un fichier est bien un fichier de type base de donnee pour les calculs gpx
#
# Initialise les variables
BEGIN							{ sVALIDATION = "VALIDE" 
							  sPOSITION = "INVALIDE" 
							  sLATITUDE = "INVALIDE" 
							  sLONGITUDE = "INVALIDE"
							  sELEVATION = "INVALIDE"
							  sTEMPS = "INVALIDE"
							  sCONTAMINEE = "FAUX"
							  sVERIF_ENTETE = "FAUX"
							}
#Verifie si il y a l'en-tete
sVERIF_ENTETE == "FAUX"					{ if (match($0, /Positions[[:space:]]+Latitude[[:space:]]+Longitude[[:space:]]+Elevation[[:space:]]+Temps/)) {
							  	sPOSITION = "VALIDE" 
							  	sLATITUDE = "VALIDE" 
							  	sLONGITUDE = "VALIDE"
							  	sELEVATION = "VALIDE"
							  	sTEMPS = "VALIDE"
							  }
							  else { 
								sVALIDATION = "ECHEC"
								exit
							  }
 	 						  sVERIF_ENTETE = "VRAI" 
							}

#Verifie la position
$1 ~ /^[1-9][0-9]*$/					{ sPOSITION = "VALIDE" }

#Verifie la latitude
$2 ~ /^[-]?[0-9]+[.][0-9][0-9][0-9][0-9][0-9][0-9]$/	{ sLATITUDE = "VALIDE" }

#Verifie la longitude
$3 ~ /^[-]?[0-9]+[.][0-9][0-9][0-9][0-9][0-9][0-9]$/	{ sLONGITUDE = "VALIDE" }

#Verifie l'elevation
$4 ~ /^[-]?[0-9]+[.]?[0-9]*$/				{ sELEVATION = "VALIDE" }

#Verifie le temps
$5 ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][Tt][0-9][0-9]:[0-9][0-9]:[0-9][0-9][Zz]$/	{ sTEMPS = "VALIDE"; }

#Verifie qu'il n'y a pas de contamination (des ajout de donnees aleatoires)
$6 !~ /^$/						{ sCONTAMINEE = "VRAI" }

#Verifie que tout correspond
							{ if (sCONTAMINEE == "VRAI" || sPOSITION == "INVALIDE" ||
							      sLONGITUDE == "INVALIDE" || sLATITUDE == "INVALIDE" ||
							      sELEVATION == "INVALIDE" || sTEMPS == "INVALIDE") 
							      {sVALIDATION = "ECHEC"; exit;}
							  else {
							      sVALIDATION = "VALIDE"
							      sPOSITION = "INVALIDE"
							      sLATITUDE = "INVALIDE"
							      sLONGITUDE = "INVALIDE"
							      sELEVATION = "INVALIDE"
							      sTEMPS = "INVALIDE"
							      sCONTAMINEE = "FAUX"}
							}

#Retourne le resultat
END							{
							  print(sVALIDATION) 
							}
