#!/bin/bash

# Questo script server per convertire in automatico, i files presenti
# nella cartella corrente, in formato MPEG2/MP2.

#####################################################################
if [ "${1}" == "--help" ]; then
    cat<<EOF
 Syntax: AutoConvert.sh [audio_format] [volume] [file]
 audio_format: mp2
   vol : non converte ne' video ne' audio, aumenta solo il volume e
         lo normalizza.
   mp2 : il valore del [volume] va da 0 a 10
EOF
    
    exit 0;
fi

#####################################################################
audio_format=${1:-mp2}
volume=${2:-0}

#####################################################################
IFS_OLD=${IFS}
IFS=$'\n'

# Controllo programmi necessari alla decodifica.
if test "x$(mencoder 2> /dev/null)" == x; then echo "ERRORE: mencoder non trovato, devo abortire."; exit 1; else echo "mencoder: OK"; fi

# Controllo struttura directory
if test ! -d $HOME/Archivio; then
    mkdir $HOME/Archivio
fi
if test ! -d $HOME/Archivio/video; then
    mkdir $HOME/Archivio/video
fi
if test ! -d $HOME/Archivio/video/Convertire; then
    mkdir $HOME/Archivio/video/Convertire
fi
cd $HOME/Archivio/video/Convertire
if test ! -d $HOME/Archivio/video/Convertire/Working; then
    mkdir $HOME/Archivio/video/Convertire/Working
fi
if test ! -d $HOME/Archivio/video/Archiviare; then
    mkdir $HOME/Archivio/video/Archiviare
fi
if test ! -d $HOME/Archivio/video/Archiviati; then
    mkdir $HOME/Archivio/video/Archiviati
fi

flag_remove_input=1
if [ "${3}" != "" ]; then
    input_list=${3}
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
    ffmpeg -i ${input_file} 2> input_file_data.tmp
    input_file_video=$(cat input_file_data.tmp | grep -F 'Stream #' | grep -F 'Video: ' | awk -F' ' '{print $4}' | cut -f1 -d',' | head -n1)
    input_file_audio=$(cat input_file_data.tmp | grep -F 'Stream #' | grep -F 'Audio: ' | awk -F' ' '{print $4}' | cut -f1 -d',' | head -n1)
    input_file_audio_bitrate=$(cat input_file_data.tmp | grep -F 'Stream #' | grep -F 'Audio: ' | awk -F' ' '{print $10}' | cut -f1 -d',' | head -n1)
    input_file_aspect_size=$(cat input_file_data.tmp | grep -F 'Stream #' | grep -F 'Video: ' | grep -o '[0-9]*x[0-9]*' | head -n1)
    input_file_aspect_size_X=$(echo "${input_file_aspect_size}" | awk -F'x' '{print $1}')
    input_file_aspect_size_Y=$(echo "${input_file_aspect_size}" | awk -F'x' '{print $2}')
    input_file_aspect_ratio=$(($((${input_file_aspect_size_X:-16} * 10)) / ${input_file_aspect_size_Y:-9}))
    if [ ${input_file_aspect_ratio:-17} -le 15 ]; then
	input_file_aspect_ratio='4:3'
	output_aspect_size='768x576'
    else
	input_file_aspect_ratio='16:9'
	output_aspect_size='768x432'
    fi
    printf 'ASPECT RATIO SET TO: %s\n' "${input_file_aspect_ratio}"
    
    rm -f input_file_data.tmp
    
    file_size_input=$(find . -name "${input_file}" -printf "%k\n")
    output_file=$(echo "Working/${input_file}" | sed 's@\.\([Aa][Vv][Ii]\|[Vv][Oo][Bb]\|[Ff][Ll][Vv]\|[Mm][Kk][Vv]\)$@.mpg@')
    echo "Conversione di ${input_file} [ ${file_size_input}Kb ] in formato MPEG-2/${audio_format} [${input_file_audio_bitrate:-192}Kbs]:"
    if [ "${input_file_video}" == "mpeg2video" ] && [ "${input_file_audio}" == "mp2" ]; then
	if [ ${volume} == 0 ]; then
	    mencoder ${input_file} -noskip -forceidx -ovc copy -oac copy -ffourcc MPEG2 -of mpeg -af volnorm=2:0.2 -o ${output_file}
	else
	    mencoder ${input_file} -noskip -forceidx -ovc copy -oac copy -ffourcc MPEG2 -of mpeg -af volume=${volume}:0,volnorm=2:0.2 -o ${output_file}
	fi
    else
	ffmpeg -threads 2 -s ${output_aspect_size:-xga} -i "${input_file}" -target vcd -vcodec mpeg2video -isync -sameq -aspect ${input_file_aspect_ratio:-16:9} "${output_file}"
    fi
    exit_code=$?
    
    if [ ${exit_code} == 0 ]; then
	if [ -f "${output_file}" ]; then
	    output_file_size=$(find Working/ -name "$(echo "${output_file}" | cut -f2- -d'/')" -printf "%k\n")
	    min_output_file_size=$(($((${file_size_input:-0} * 10)) / 15))
	    if [ ${output_file_size} -lt ${min_output_file_size} ]; then
		echo "ATTENZIONE: La dimensione del file in formato MPG4/${audio_format} (${output_file_size}Kb) e' troppo inferiore a quella del file originale (${file_size_input}Kb). Evito di spostarlo, controllare il file"
	    else
		if [ ${flag_remove_input} == 1 ]; then
		    rm -vf ${input_file}
		fi
		
		if [ ! -f ../Archiviare/${output_file} ]; then
		    mv -vf ${output_file} ../Archiviare/
		else
		    echo "ATTENZIONE: In archivio e' gia' presente il file, evito di spostarlo."
		    exit 3;
		fi
	    fi
	else
	    echo "ERRORE: La conversione del file ${input_file} risulta fallita."
	    exit 2;
	fi
    else
	echo "ERRORE: MEncoder e' uscito con il codice ${exit_code} ."
	exit 1;
    fi
done

#####################################################################
IFS=${IFS_OLD}

exit 0;