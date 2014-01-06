#!/bin/bash


for a in `seq 1 26`
do
res="1024"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/1107wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/1103wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/1027wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/1020wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/1014wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/1006wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0929wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0922wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0915wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0908wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0901wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0825wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0818wallpaper-"$a"_"$res".jpg"
		wget -U Mozilla "http://ngm.nationalgeographic.com/photo-contest/img/wallpaper/0811wallpaper-"$a"_"$res".jpg"


done
