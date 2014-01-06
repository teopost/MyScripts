#!/bin/bash

# Questo script server per convertire in automatico, i files presenti
# nella cartella corrente, in formato MPEG4/MP3.

#####################################################################
if [ "${1}" == "--help" ]; then
    cat<<EOF
 Syntax: AutoConvert.sh [audio_format] [volume] [file]
 audio_format: mp2, mp3, ac3, vol, cpy, vob, dbg
   vol : non converte ne' video ne' audio, aumenta solo il volume e
         lo normalizza.
   mp3 : il valore del [volume] va da 0 a 10
   cpy : ignora [audio_format] e [volume], si limita a copiare lo
         stream e convertirlo in un avi leggibile.
   vob : conversione del formato vob.
   flv : conversione del formato flv.
   dbg : Riconverte un file tentando di sistemarlo
   dly : Il valore del [volume] viene usato per la sincronizzazione
EOF
    
    exit 0;
fi

#####################################################################
audio_format=${1:-mp3}
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
    packed_B_frames_detectead=$(cat input_file_data.tmp | grep -F 'Invalid and inefficient vfw-avi packed B frames detectead')
    
    rm -f input_file_data.tmp
    
    file_size_input=$(find . -name "${input_file}" -printf "%k\n")
    output_file=$(echo "Working/${input_file}" | sed 's@\.\([Mm][Pp][Gg]\|[Vv][Oo][Bb]\|[Ff][Ll][Vv]\|[Mm][Kk][Vv]\)$@.avi@')
    echo "Conversione di ${input_file} [ ${file_size_input}Kb ] in formato MPEG-4/${audio_format}:"
    if [ ${audio_format} == "mp3" ]; then
	if [ "${input_file_video}" == "mpeg4" ] && [ "${input_file_audio}" == "mp3" ]; then
	    if [ ${volume} == 0 ]; then
		mencoder ${input_file} -noskip -forceidx -ovc copy -oac copy -ffourcc DX50 -of avi -af volnorm=2:0.2 -o ${output_file}
	    else
		mencoder ${input_file} -noskip -forceidx -ovc copy -oac mp3lame -lameopts vol=${volume} -ffourcc DX50 -of avi -af volnorm=2:0.2 -o ${output_file}
	    fi
	else
	    mencoder ${input_file} -noskip -forceidx -ovc lavc -oac mp3lame -lavcopts vcodec=mpeg4:mbd=2:autoaspect -lameopts vol=${volume} -ofps 25 -ffourcc DX50 -of avi -mc 0 -af volnorm=2:0.2 -o ${output_file}
	fi
    elif [ ${audio_format} == "mp2" ]; then
	mencoder ${input_file} -noskip -forceidx -ovc lavc -oac lavc -lavcopts vcodec=mpeg4:mbd=2:autoaspect:acodec=mp2:abitrate=128 -ofps 25 -ffourcc DX50 -of avi -mc 0 -af volume=${volume}:0,volnorm=2:0.2 -o ${output_file}
    elif [ ${audio_format} == "ac3" ]; then
	mencoder ${input_file} -noskip -forceidx -ovc lavc -oac lavc -lavcopts vcodec=mpeg4:mbd=2:autoaspect:acodec=ac3 -ofps 25 -ffourcc DX50 -of avi -mc 0 -af volume=${volume}:0,volnorm=2:0.2 -o ${output_file}
    elif [ ${audio_format} == "vol" ]; then
	mencoder ${input_file} -noskip -forceidx -ovc copy -oac copy -ofps 25 -ffourcc DX50 -of avi -mc 0 -af volume=${volume}:0,volnorm=2:0.2 -o ${output_file}
    elif [ ${audio_format} == "cpy" ]; then
	mencoder ${input_file} -noskip -forceidx -ovc copy -oac copy -ffourcc DX50 -of avi -o ${output_file}
    elif [ ${audio_format} == "dly" ]; then
	mencoder ${input_file} -noskip -forceidx -ovc copy -oac copy -ffourcc DX50 -of avi -audio-delay ${volume} -o ${output_file}
    elif [ ${audio_format} == "vob" ]; then
	mencoder  ${input_file} -noskip -ovc lavc -oac mp3lame -lavcopts sc_factor=4 -lameopts vbr=3:q=0:aq=0:preset=standard:vol=${volume} -forceidx -ffourcc DX50 -of avi -o ${output_file}
    elif [ ${audio_format} == "flv" ]; then
	mencoder  ${input_file} -noskip -ovc lavc -oac mp3lame -lavcopts sc_factor=4 -lameopts vbr=3:q=0:aq=0:preset=standard:vol=${volume} -forceidx -ffourcc DX50 -of avi -o ${output_file}
    elif [ ${audio_format} == "dbg" ]; then
	mencoder ${input_file} -noskip -forceidx -ovc lavc -oac mp3lame -lavcopts vcodec=mpeg4:mbd=2:autoaspect -lameopts vol=${volume} -ofps 25 -ffourcc DX50 -of avi -mc 0 -af volnorm=2:0.2 -o ${output_file}
    else
	echo "ERRORE: Formato Audio non riconosciuto."
	exit 4;
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