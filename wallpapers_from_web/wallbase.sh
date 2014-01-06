#!/bin/bash
#
# This script gets the beautiful wallpapers from http://wallbase.cc
# This script is brought to you by 7sins@4geeksfromnet.com
#
# Revision 1.0
# Contributed by MacEarl
# 1. Added the much needed fixes for NSFW category
# 2. Updated the script with more options
# 3. Modified the script
#
# Revision 1.1
# Contributed by MacEarl
# 1. Added a Search Function
# 2. Added a check for already existing Files
# 3. Fixed a bug (imageshack mirrored files)
#
#
# Revision 1.1.1
# Contributed by Hab
# 1. Updated mkdir option with -p flag
#
# Wallpapers can be sorted according to
#
###############################
### Section 1 :: Resolution ###
###############################
#
# Resolution
#   Accepted values are 0 => All Standard
#       800x600 | 1024x768 | 1280x960 | 1280x1024 | 1400x1050 | 1600x1200 | 2560x2048
#   Widescreen
#       1024x600 | 1280x800 | 1366x768 | 1440x900 | 1600x900 | 1680x1050 | 1920x1080 | 1920x1200 | 2560x1440 | 2560x1600
#
#################################
### Section 2 :: Aspect Ratio ###
#################################
#
# Aspect Ratio
#   Accepted values are 0 => All
#   1.33 => 4:3
#   1.25 => 5:4
#   1.77 => 16:9
#   1.60 => 16:10
#   1.70 => Netbook
#   2.50 => Dual
#   3.20 => Dual Wide
#   0.99 => Portrait
#
###############################
### Section 3 :: Category   ###
###############################
#
# Category : SFW, Sketchy, NSFW
# Each being toggled by a 1/0 value
#   So to get only SFW use 100
#   To get all categories use 111
#   To get Sketchy and NSFW use 011
#
###############################
### Section 4 :: Topic      ###
###############################
#
# Topic : Anime/Manga, Wallpapers/General, High Resolution Images
#   To get Anime/Manga use 1
#   To get Wallpapers/General use 2
#   To get HR Images use 3
#   To get all use 123
#   To get only HR and WP use 23 and so on
#
###############################
### Section 5 :: Size       ###
###############################
#
# Size: at least and Exactly width x height
#   To get at least desired Resolution use gteq
#   To get exactly desired Resolution use eqeq
#
###############################
### Section 6 :: THPP       ###
###############################
#
# Thumbnails per page.
#  Accepted values are 20, 32, 40, 60
#
###############################
### Section 7 :: Location   ###
###############################
#
# The download location Foldername of desired Location e.g. "Wallpapers"
#
###############################
### Section 8 :: Best of    ###
###############################
#
# Best of:
#  All time = 0
#  3Months  = 3m
#  2Months  = 2m
#  1Month   = 1m
#  2Weeks   = 2w
#  1Week    = 1w
#  3Days    = 3d
#  1Day     = 1d
#
###############################
### Section 9 :: Type       ###
###############################
#
# Random    = 1
# Toplist   = 2
# Newest    = 3
# Search    = 4
#
###############################
### Section 10 :: Order     ###
###############################
#
# Date                  = date
# Amount of Views       = views
# Number of Favorites   = favs
# Relevancie            = relevance
#
###############################
### Section 11 :: OrderType ###
###############################
#
# The following two Options are possible:
#  Ascending    = asc
#  Descending   = desc
#
###############################
### Section 12 :: Search    ###
###############################
# Define your Search Query like this:
#  ./wallbase.sh Mario
#  For longer Search Queries you need to set QUERY manually
#  For Example set QUERY="Link OR Zelda OR Legend of Zelda OR OoT"
#  Accepted Operators are "AND" and "OR"
#
###############################
 
###############################
### Configuration Options   ###
###############################
 
# Define the maximum number of wallpapers that you would like to download MAX_RANGE=26460
MAX_RANGE=250
# For accepted values of resolution see Section 1
RESOLUTION=0
# For accepted values of aspect ratio see Section 2
ASPECTRATIO=0
# For accepted values of category see Section 3
CATEGORY=100
# For accepted values of topic see Section 4
TOPIC=123
# For accepted values for SIZE see Section 5
SIZE=gteq
# For accepted Thumbnails per page see Section 6
THPP=60
# For download location see Section 7
LOCATION=/location/to_your/wallpapers_folder
# Best of : see Section 8
TIME=0
# For Types see Section 9
TYPE=1
# For order Options see Section 10
ORDER=relevance
# See Section 11
ORDER_TYPE=desc
# See Section 12
QUERY="$1"
 
###############################
### Configuration Options   ###
###############################
 
mkdir -p $LOCATION
cd "$LOCATION"
 
wget --keep-session-cookies --save-cookies=cookies.txt --referer=wallbase.cc http://wallbase.cc/user/adult_confirm/1
 
if [ $TYPE == 1 ] ; then
 
    for (( count= 0; count< "$MAX_RANGE"; count=count+"$THPP" ));
        do
            wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc http://wallbase.cc/random/$TOPIC/$SIZE/$RESOLUTION/$ASPECTRATIO/$CATEGORY/$THPP
 
            URLSFORIMAGES="$(cat $THPP | grep -o "http:.*" | cut -d " " -f 1 | grep wallpaper)"
 
            for imgURL in $URLSFORIMAGES
                do
                    img="$(echo $imgURL | sed 's/.\{1\}$//')"
                        wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc $img
                    number="$(echo $img | sed  's .\{29\}  ')"
                    if [ -f *wallpaper-$number* ]
                                    then
                                        echo File already exists!
                                    else
                            cat $number | egrep -o "http:.*(gif|png|jpg)" | egrep 'wallbase2|imageshack.us' | wget -i -
                    fi
                rm $number $THPP
                done
        done
else
 
if [ $TYPE == 2 ] ; then
 
    for (( count= 0; count< "$MAX_RANGE"; count=count+"$THPP" ));
            do
                wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc http://wallbase.cc/toplist/$count/$TOPIC/$SIZE/$RESOLUTION/$ASPECTRATIO/$CATEGORY/$THPP/$TIME
                    URLSFORIMAGES="$(cat $TIME | grep -o "http:.*" | cut -d " " -f 1 | grep wallpaper)"
                    for imgURL in $URLSFORIMAGES
                    do
                    img="$(echo $imgURL | sed 's/.\{1\}$//')"
                        wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc $img
                    number="$(echo $img | sed  's .\{29\}  ')"
                    if [ -f *wallpaper-$number* ]
                                    then
                                        echo File already exists!
                        else
                            cat $number | egrep -o "http:.*(gif|png|jpg)" | egrep 'wallbase2|imageshack.us' | wget -i -
                    fi
                rm $number $TIME
                done
        done
else
 
if [ $TYPE == 3 ] ; then
 
    for (( count= 0; count< "$MAX_RANGE"; count=count+"$THPP" ));
            do
        wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc http://wallbase.cc/search/$count/$TOPIC/$SIZE/$RESOLUTION/$ASPECTRATIO/$CATEGORY/$THPP
        URLSFORIMAGES="$(cat $THPP | grep -o "http:.*" | cut -d " " -f 1 | grep wallpaper)"
        for imgURL in $URLSFORIMAGES
                do
                img="$(echo $imgURL | sed 's/.\{1\}$//')"
                    wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc $img
                number="$(echo $img | sed  's .\{29\}  ')"
                if [ -f *wallpaper-$number* ]
                            then
                                echo File already exists!
                            else
                    cat $number | egrep -o "http:.*(gif|png|jpg)" | egrep 'wallbase2|imageshack.us' | wget -i -
                fi
            rm $number $THPP
            done
    done
 
else
 
if [ $TYPE == 4 ] ; then
    echo "query=$QUERY&board=$TOPIC&nsfw=$CATEGORY&res=$RESOLUTION&res_opt=$SIZE&aspect=$ASPECTRATIO&orderby=$ORDER&orderby_opt=$ORDER_TYPE&thpp=$THPP&section=wallpapers&1=1" > data
    wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc/ --post-file=data http://wallbase.cc/search/
    URLSFORIMAGES="$(cat index.html | grep -o "http:.*" | cut -d " " -f 1 | grep wallpaper)"
    for imgURL in $URLSFORIMAGES
        do
        img="$(echo $imgURL | sed 's/.\{1\}$//')"
        wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc $img
        number="$(echo $img | sed  's .\{29\}  ')"
        if [ -f *wallpaper-$number* ]
        then
            echo File already exists!
        else
            cat $number | egrep -o "http:.*(gif|png|jpg)" | egrep 'wallbase2|imageshack.us' | wget -i -
        fi
    rm $number
    done
    rm index.html
 
    if [ $CATEGORY == 100 ] ; then
        nsfw_sfw=1
        nsfw_sketchy=0
        nsfw_nsfw=0
    else
    if [ $CATEGORY == 010 ] ; then
        nsfw_sfw=0
        nsfw_sketchy=1
        nsfw_nsfw=0
    else
    if [ $CATEGORY == 001 ] ; then
        nsfw_sfw=0
        nsfw_sketchy=0
        nsfw_nsfw=1
    else
    if [ $CATEGORY == 110 ] ; then
        nsfw_sfw=1
        nsfw_sketchy=1
        nsfw_nsfw=0
    else
    if [ $CATEGORY == 011 ] ; then
        nsfw_sfw=0
        nsfw_sketchy=1
        nsfw_nsfw=1
    else
    if [ $CATEGORY == 101 ] ; then
        nsfw_sfw=1
        nsfw_sketchy=0
        nsfw_nsfw=1
    else
    if [ $CATEGORY == 111 ] ; then
        nsfw_sfw=1
        nsfw_sketchy=1
        nsfw_nsfw=1
    else
    echo Error in Category
    fi
    fi
    fi
    fi
    fi
    fi
    fi
 
    for (( count= $THPP; count< "$MAX_RANGE"; count=count+"$THPP" ));
        do
            rm data
            echo "query=$QUERY&board=$TOPIC&res_opt=$SIZE&res=$RESOLUTION&aspect=$ASPECTRATIO&nsfw_sfw=$nsfw_sfw&nsfw_sketchy=$nsfw_sketchy&nsfw_nsfw=$nsfw_nsfw&thpp=$THPP&orderby=$ORDER&orderby_opt=$ORDER_TYPE&section=wallpapers&1=1" > data
            wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc/search --post-file=data http://wallbase.cc/search/$count
            URLSFORIMAGES="$(cat $count | grep -o "http:.*" | cut -d " " -f 1 | grep wallpaper)"
            for imgURL in $URLSFORIMAGES
                do
                    img="$(echo $imgURL | sed 's/.\{1\}$//')"
                        wget --keep-session-cookies --load-cookies=cookies.txt --referer=wallbase.cc $img
                    number="$(echo $img | sed  's .\{29\}  ')"
                    if [ -f *wallpaper-$number* ]
                                    then
                                        echo File already exists!
                                    else
                            cat $number | egrep -o "http:.*(gif|png|jpg)" | egrep 'wallbase2|imageshack.us' | wget -i -
                    fi
                rm $number $count
                done
        done
    rm data
 
else
echo error in TYPE please check Variable
 
fi
fi
fi
fi
 
rm "1" "cookies.txt"
