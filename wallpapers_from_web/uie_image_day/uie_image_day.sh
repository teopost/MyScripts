#!/bin/sh
# Scarica dal cafe' la foto piu' recente e la mette come sfondo di gnome
# Prerequisiti: 
# 1. Installare xmlstarlet e imagemagik (Ubuntu:sudo apt-get install curl xmlstarlet imagemagick / Fedora:yum install xmlstarlet)
# 2. Mettere nel crontab (se si vuole)

# Note:
# http://www.ioncannon.net/linux/81/5-imagemagick-command-line-examples-part-1/
# http://www.fmwconcepts.com/imagemagick/autocaption/index.php
# http://imagemagick.org/script/color.php
# http://www.imagemagick.org/Usage/annotating/

WM_FONT_NORMAL="DejaVu-Sans-ExtraLight"
WM_FONT_BOLD="DejaVu-Sans-ExtraLight"
WM_TEXT="www.uielinux.org"
WM_TEXT_COLOR="gray78"

#WM_TEXT_COLOR="white"
#WM_UNDERCOLOR="#00000080" 

# Calcolo la risoluzione
WIDTH=$(xdpyinfo  | grep dimensions | awk '{print $2}' | cut -d "x" -f1)
HEIGHT=$(xdpyinfo  | grep dimensions | awk '{print $2}' | cut -d "x" -f2)

# Creo la dir in cui mettere le immagini
DIR=$HOME/Immagini/UIE-CAFE
test -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs && . ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs && DIR=${XDG_PICTURES_DIR}/UIE-CAFE
mkdir -p $DIR

# Estraggo titolo immagine dal feed
IMG_TITLE=$(curl -s http://uielinuxcafe.blogspot.com/feeds/posts/default|xmlstarlet  sel -N x="http://www.w3.org/2005/Atom" -t -m "/x:feed/x:entry/x:title" -v "." -n | head -1)
# Metto un paio di spazi prima e dopo il testo
IMG_TITLE=" ${IMG_TITLE} "
# Rendo visibili gli apici
IMG_TITLE=$(echo ${IMG_TITLE} | sed -e "s/'/\\\'/g")

# Estraggo url dell'immagine
URL_NAME=$(curl -s http://uielinuxcafe.blogspot.com/feeds/posts/default | xmlstarlet  sel -N x="http://www.w3.org/2005/Atom"  -t -m "/x:feed/x:entry" -n -v "." | grep -o 'href=\"http://[1-9].bp.blogspot.com/.*"' | sed -e 's/href="//' | cut -d'"' -f1 | head -1)

# Scarico il file e lo chiamo tmpname
wget -q $URL_NAME -O $DIR/tmpname

# Rinomino il file scaricato 
FILE_NAME=$(date +UIE-%Y%m%d-%H%M%S).$(file $DIR/tmpname | cut -d" " -f2 | tr [:upper:] [:lower:])
mv $DIR/tmpname $DIR/$FILE_NAME

# Estraggo width e height dall'immagine
IMG_WIDTH=$(identify -format '%w' $DIR/$FILE_NAME)
IMG_HEIGHT=$(identify -format '%h' $DIR/$FILE_NAME)

# Eseguo il resize proporzionale mettendo la larghezza dell'immagine a quella effettiva del monitor
mogrify -geometry $WIDTH $DIR/$FILE_NAME  

# Ritaglio l'immagine con la larghezza del mio monitor
mogrify -crop ${WIDTH}x${HEIGHT}+0+0 $DIR/$FILE_NAME

# Metto uno sfondo
#convert -size 100×100 xc:none -fill grey12 -draw 'circle 25,30 10,30' \
#-draw 'circle 75,30 90,30' -draw 'rectangle 25,15 75,45' $DIR/$FILE_NAME

# Aggiungo il watermark del titolo
# per sapere quali font puoi usare: convert -list font | grep Font
# -sepia-tone 85%% \ 
# -undercolor "$WM_UNDERCOLOR" \
convert $DIR/$FILE_NAME \
-font "$WM_FONT_BOLD" \
-fill "$WM_TEXT_COLOR" \
-stroke "$WM_TEXT_COLOR" \
-pointsize 30 \
-draw "gravity northwest text 100,45 '$IMG_TITLE'" $DIR/$FILE_NAME

# Aggiungo il watermark uielinux
convert $DIR/$FILE_NAME -font "$WM_FONT_BOLD" -pointsize 15 \
-draw "gravity southeast fill grey text 50,20 '$WM_TEXT'" $DIR/$FILE_NAME

#echo ">>> Nome file $FILE_NAME"
#echo ">>> Link: $URL_NAME"
#echo ">>> Path immagine: $DIR"

# Devo capire se sono su ubuntu, fedora oppure opensuse
#de=$(gconftool -v | cut -d'.' -f1)

utente=$(echo $USER)

case $utente in
	 'strippy')
		de=3
		;;
	 'teopost')
	        de=3
		;;
	*)
             	de=3
		;;
esac


case $de in
	 2)
             echo "Gnome 2. Imposto $DIR/$FILE_NAME"
             gconftool-2 -t string -s /desktop/gnome/background/picture_options zoom
             gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$DIR/$FILE_NAME"
	     ;;
	 3)
             echo "Gnome 3. Imposto $DIR/$FILE_NAME"
             gsettings set org.gnome.desktop.background picture-options zoom
             gsettings set org.gnome.desktop.background picture-uri "file:///$DIR/$FILE_NAME"
	     ;;
	 4)
	     echo "kde sux"
	     ;;
	 *)
	     echo "booo"
	     ;;
esac


