#!/bin/bash
# this file is use to merge images into one image
# seems can accept pic in url , but must quote with '' not ""
# usage: merge.sh image_path0 image_path1 image_path2 output_path 

# note: this should set to array and do it within a loop

#judge and set
if [ $# -lt 4 ] ;
then 
    echo 'error : param count < 4'
    echo 'usage: merge.sh image_path0 image_path1 image_path2 output_path '
    exit
fi

image=$1
image2=$2
image3=$3
result=$4

#compute 1
width=`convert $image -format "%w" info:`
height=`convert $image -format "%h" info:`
                                                                                                                                                                                                                                                                                                                                               
let change_width=300*$width/$height

xoff=0
yoff=0
ww=$change_width
hh=300

#compute 2
width2=`convert $image2 -format "%w" info:`
height2=`convert $image2 -format "%h" info:`
let change_width2=300*$width2/$height2

xoff2=$ww
yoff2=0
ww2=$change_width2
hh2=300

#compute 3
width3=`convert $image3 -format "%w" info:`
height3=`convert $image3 -format "%h" info:`
let change_width3=300*$width3/$height3

let xoff3=$ww+$ww2
yoff3=0
ww3=$change_width3
hh3=300

#for debug output
echo $ww
echo $hh
echo $xoff
echo $yoff
echo ''

echo $ww2
echo $hh2
echo $xoff2
echo $yoff2
echo ''

echo $ww3
echo $hh3
echo $xoff3
echo $yoff3

#when width is too large, then should reaplace with a >> pic
if [ "$xoff3" -gt 500 ] 
then  
    echo "warning: yoff3 > 500, should replace with a  >> pic "
fi

#use convert command
convert -size 600x300 xc:white -background None $image -geometry ${ww}x${hh}+0+0 -composite $image2 -geometry ${ww2}x${hh2}+${xoff2}+0  -composite $image3 -geometry ${ww3}x${hh3}+${xoff3}+0 -composite $result

echo 'merge done'
