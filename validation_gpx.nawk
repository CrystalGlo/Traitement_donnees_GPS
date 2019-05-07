#
# Programme nawk pour valider la structure d'un document GPX
# Implantation d'une machine a etats finis pour la validation
# mars 2014
# (version utilisant une fonction utilisateur - v3)
#
#
# Auteur: T. Wong pour GPA435
#

BEGIN		{ sINITIAL = 0; sFINAL = 1; sGPX = 2; sWAYPOINT = 3; sROUTE = 4; sROUTEPOINT = 5;
		  sTRACK = 6; sTRACKSEGMENT = 7; sTRACKPOINT = 8; sERREUR = 9;
		  vEtat = sINITIAL;
		  vCause = "";
		  vNbLigne = 0;
		}

END		{ (vEtat == sFINAL) ? vOutput = "valide" : vOutput = "invalide";
		  printf("Le document GPX \"%s\" est: %s\n", FILENAME, vOutput);
		  printf("Traitement arrete a la ligne: %d\n", vNbLigne);
		  # Amelioration 
		  if (vEtat == sInitial) vCause = "Balise <gpx> introuvable";
		  printf("%s\n", vCause);
		}

#
# compteur de lignes et elimination du caractere \r (carriage return)
#
		# parfois le document GPX est traite sur un PC et les fins de ligne
		# ont les caracteres de controle \r\n. Il faut enlever \r puisque sous
		# Linux \n joue le role de CR/LF.
		{gsub(/\r/, "", $0); vNbLigne++ }

#
# etat actuel est sINITIAL
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
# etat actuel est sINITIAL
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
# etat actuel est sGPX
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
# etat actuel est sWAYPOINT
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
# etat actuel est sROUTE
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
# etat actuel est sROUTEPOINT
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
# etat actuel est sTRACK
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
# etat actuel est sTRACKSEGMENT
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
# etat actuel est sTRACKPOINT
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

