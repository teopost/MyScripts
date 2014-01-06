#!/bin/bash

# Questo script server per convertire in automatico, i files presenti
# nella cartella corrente, in formato MPEG4/MP3.

#####################################################################
if [ "${1}" == "--help" ]; then
    cat<<EOF
 Syntax: AutoConvert.sh [file]
EOF
    
    exit 0;
fi

#####################################################################
audio_format=${1:-mp3}
volume=${2:-0}

#####################################################################
IFS_OLD=${IFS}
IFS='
'

# Controllo programmi necessari alla decodifica.
if test "x$(mencoder 2> /dev/null)" == x; then echo "ERRORE: mencoder non trovato, devo abortire."; exit 1; else echo "mencoder: OK"; fi

# Controllo struttura directory
if test ! -d $HOME/Archivio; then
    mkdir $HOME/Archivio
fi
films_3gp_path="$HOME/Archivio/video/Films_3gp"
if test ! -d $HOME/Archivio/video/Films_3gp; then
    mkdir ${films_3gp_path}
fi

flag_remove_input=1
if [ "${1}" != "" ]; then
    input_list=${1}
    flag_remove_input=0
else
    input_list=$(find . -iname '*.avi' | cut -f2- -d'/')
    if [ "${input_list}" == "" ]; then
	input_list=$(find . -iname '*.mpg' | cut -f2- -d'/')
	if [ "${input_list}" == "" ]; then
	    input_list=$(find . -iname '*.vob' | cut -f2- -d'/')
	    if [ "${input_list}" == "" ]; then
		input_list=$(find . -iname '*.flv' | cut -f2- -d'/')
		if [ "${input_list}" == "" ]; then
		    input_list=$(find . -iname '*.mkv' | cut -f2- -d'/')
		fi
	    fi
	fi
    fi
fi

for input_file in ${input_list}; do
    output_file=$(echo "${input_file}" | sed 's@\..\{1,3\}$@.3gp@')
    if [ ! -f "${films_3gp_path}/${output_file}" ]; then
	ffmpeg -i "${input_file}" -s qcif -vcodec h263 -acodec libfaac -ac 1 -ar 8000 -r 25 -ab 12200 -y "${films_3gp_path}/${output_file}"
	if [ $? == 0 ]; then
	    if [ -h "${input_file}" ]; then
		rm -vf "${input_file}"
	    fi
	else
	    echo "ERRORE: Creazione di '${films_3gp_path}/${output_file}' fallita."
	fi
    else
	echo "ERRORE: File '${films_3gp_path}/${output_file}' gia' presente."
    fi
done

#####################################################################
IFS=${IFS_OLD}

exit 0;