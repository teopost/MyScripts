#
# Script per rinominare i files e sostituire in essi una porzione di testo
#
# Autore: Stefano Teodorani 
#

export spooler_dir="/cygdrive/c/inetpub/ftproot/CIA/CassiereMIF/toCIA"
#nome_dir=$(date +%y%m%d)

if [ ! -d $spooler_dir ]; then
   echo "La directory non esiste"
   exit
fi

#echo "PP" >> $spooler_dir/uuu.txt

#exit

if [ -f $spooler_dir/EMAP.txt ]; then
   echo "File EMAP trovato. eseguo rename"
   python replace_mif.py -i $spooler_dir/EMAP.txt  -o  $spooler_dir/EMAP_$(date +%d_%m_%Y).307000.txt 
   #sed -b 's/307100/307000/g' $spooler_dir/EMAP.txt > $spooler_dir/EMAP_$(date +%d_%m_%Y).307000.txt
   mv $spooler_dir/EMAP.txt $spooler_dir/EMAP_$(date +%d_%m_%Y).txt
   cp $spooler_dir/EMAP_$(date +%d_%m_%Y).txt  $spooler_dir/DBA/EMAP_$(date +%d_%m_%Y).txt
fi


if [ -f $spooler_dir/EMAT.txt ]; then
   echo "File EMAT trovato. eseguo rename"
   python replace_mif.py -i $spooler_dir/EMAT.txt  -o  $spooler_dir/EMAT_$(date +%d_%m_%Y).307000.txt
   #sed -b 's/307100/307000/g' $spooler_dir/EMAT.txt > $spooler_dir/EMAT_$(date +%d_%m_%Y).307000.txt
   mv $spooler_dir/EMAT.txt $spooler_dir/EMAT_$(date +%d_%m_%Y).txt
   cp $spooler_dir/EMAT_$(date +%d_%m_%Y).txt  $spooler_dir/DBA/EMAT_$(date +%d_%m_%Y).txt
fi


if [ -f $spooler_dir/EMFE.txt ]; then
   echo "File EMFE trovato. eseguo rename"
   python replace_mif.py -i $spooler_dir/EMAT.txt  -o  $spooler_dir/EMAT_$(date +%d_%m_%Y).307000.txt
   #sed -b 's/307100/307000/g' $spooler_dir/EMFE.txt > $spooler_dir/EMFE_$(date +%d_%m_%Y).307000.txt
   mv $spooler_dir/EMFE.txt $spooler_dir/EMFE_$(date +%d_%m_%Y).txt
   cp $spooler_dir/EMFE_$(date +%d_%m_%Y).txt  $spooler_dir/DBA/EMFE_$(date +%d_%m_%Y).txt
fi
