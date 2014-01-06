#!/bin/sh
# Autore: Stefano Teodorani
# Licenza: Fateci quello che volete

usage()
{
nome_file=$(basename $0)

cat << EOF

sintassi: $nome_file opzione

Questo script, fatto appositamente per Pedro,
serve per trasferire un file con un comando batch

OPZIONI:
   -h      Mostra questo Help
   -u      Utente ftp
   -p      Password utente ftp
   -s      Server ftp remoto
   -f      Nome del file da trasferire
   -v      Mostra errori

ESEMPI:

$nome_file -u ftpuser -p ftppass -s servername -f filename -d cartella

$nome_file  -u utente@aruba.it  -p password -s ftp.uielinux.org -f ./Unicum-Google.png  -d www.uielinux.org

EOF
}

# Se non passi nemmeno un parametro do errore
if [ $# -eq 0 ]
then
  usage
  exit 3
fi

# Leggo i parametri
SERVER=
USER=
PASSWD=
REMOTE_DIR=
VERBOSE=0

while getopts "u:p:s:f:d:hv" OPZIONE
do
     case $OPZIONE in
         h|H)
             usage
             exit 1
             ;;
         u)
             USER=$OPTARG
             ;;
         p)
             PASSWD=$OPTARG
             ;;
         s)
             SERVER=$OPTARG
             ;;
         f)
             FILE=$OPTARG
             ;;
         d)
             REMOTE_DIR="cd $OPTARG"
             ;;
         v)
             VERBOSE=1
             ;;
         *)
             usage
             exit 2
             ;;
     esac
done

if [ -z $SERVER ] || [ -z $USER ] || [ -z $PASSWD ] || [ -z $FILE ]
then
     if [ $VERBOSE -eq 1 ]
     then
        echo ">>:" $SERVER
        echo ">>:" $USER
        echo ">>:" $PASSWD
        echo ">>:" $FILE
        echo ">>:" $REMOTE_DIR
        usage
        exit 1
     fi
fi

if [ $VERBOSE -eq 1 ]
then
  echo ">>:" $SERVER
  echo ">>:" $USER
  echo ">>:" $PASSWD
  echo ">>:" $FILE
  echo ">>:" $REMOTE_DIR
fi

# Inizio il trasferimento ftp vero e proprio
ftp -n $SERVER <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
$REMOTE_DIR
put $FILE
quit
END_SCRIPT
exit 0
