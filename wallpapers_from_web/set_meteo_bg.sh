#!/bin/bash
# Title:	Web background
# Description:	Script che fonde un'immagine pescata dal web nel nostro wallpaper
# Author:	Wicker25
 
# Impostazioni dello script
url="http://www.sat24.com/images.php?country=it&type=slide";
#cmd_setbg="fbsetbg";
cmd_setbg="gconftool-2 -t string -s /desktop/gnome/background/picture_filename"; # GNOME
#cmd_setbg="xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s"; # XFCE
#cmd_setbg="dcop kdesktop KBackgroundIface setWallpaper"; # KDE
pause="15m";
 
wallpaper="$HOME/wallpaper.png";
 
img="$HOME/tmp.png";
img_pos=(80 20);
img_size="72%";
img_alpha="35%";
img_border_color="#FFFFFF";
img_border_width="1";
 
text="date +%H:%M:%S";
text_pos=(375 18);
text_color="#FFFFFF";
text_font="courier";
text_font_size="16";
 
while [ true ]; do
 
	# Log di lavoro
	echo -n $(date)": Updating... ";
 
	# Scarico l'immagine del satellite
	wget -q -O- "$url" | \
 
	# Preparo l'immagine
	convert	-resize $img_size \
		-contrast-stretch 7% \
		-bordercolor "$img_border_color" \
		-border "$img_border_width" \
		-fill "$text_color" \
		-stroke "$text_color" \
		-font "$text_font" \
		-pointsize "$text_font_size" \
		-draw "text ${text_pos[0]},${text_pos[1]} '`$text`'" \
		- - | \
 
	# Sovrappongo l'immagine al wallpaper scelto
	composite	-quality 100 \
			-dissolve $img_alpha \
			-geometry "+${img_pos[0]}+${img_pos[1]}" \
			- "$wallpaper" "$img";
 
	# Imposto il wallpaper nel desktop
	$cmd_setbg "$img";
 
	# Log di lavoro
	echo "done";
 
	# Attendo il prossimo aggiornamento
	sleep "$pause";
 
done;
