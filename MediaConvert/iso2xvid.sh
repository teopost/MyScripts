#!/bin/sh
if [ "$1"x = ""x ]; then
	echo "Sintassi non valida. Specificare il nome del file iso"
	exit 0
fi
mencoder $1 -ovc xvid -xvidencopts pass=1 -alang it -oac mp3lame -o video.avi
