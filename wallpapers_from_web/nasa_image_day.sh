#!/bin/sh -x
#cambia lo sfondo del desktop
#mettendo l'immagine del giorno prelevata dal sito della nasa
#change wallpaper with nasa image day
DIR=$HOME/Immagini/WALL
if [ !  -d "$HOME/Immagini" ]; then
	mkdir "$HOME/Immagini"
		if [ ! -d "$DIR" ]; then
			mkdir "$DIR"
	fi
fi
NAME=`wget http://www.nasa.gov/rss/lg_image_of_the_day.rss -O - | grep -o 'http://www.nasa.gov/images/[^<]*' | head -n1 | awk -F / '{print $NF}'`
ls "$DIR" | grep "$NAME" 2> /dev/null
if [ "$?" = "0" ]; then
	exit 0
	else
	wget $(wget http://www.nasa.gov/rss/lg_image_of_the_day.rss -O - | grep -o 'http://www.nasa.gov/images/[^<]*' | head -n1) -O "$DIR/$NAME"
	#gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$DIR/$NAME"
fi


