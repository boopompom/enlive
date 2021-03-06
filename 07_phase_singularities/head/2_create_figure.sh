#!/usr/bin/env bash
set -euo pipefail

source ../../FONT.sh
source opts.sh
#first argument is both dir name and output name
DIR="$1"
cd ${DIR}

Y=$(identify -format "%[fx:h]" ./r_sm.png)
#set density. 72 means 1pt is 1 pxl
DENSITY=$( echo 'scale=5; 72/192*'$Y | bc)
FONTSIZE=$( echo 'scale=0; 192/6' | bc)
SPACING=$( echo 'scale=0; '${Y}'/48' | bc)
STRW=3

TMP=tmp
mkdir ${TMP} || true
cd $TMP

scale_and_text()
{
	IF="$1"
	T="$2"
	OF="$3"
	convert ${IF} -stroke red -strokewidth ${STRW} -fill none -draw "translate ${circle_x},${circle_y} circle 0,0 ${circle_r},0" tmp.png
	convert tmp.png -density ${DENSITY} -pointsize ${FONTSIZE} -font ${FONT} label:"${T}" -gravity Center -append ${OF}
	rm tmp.png

}


scale_and_text "../r_sm.png" "1 map" 1m.png 
scale_and_text "../r_mm.png" "2 maps" 2m.png 
scale_and_text "../r_sm_phase.png" "1 map phase" phase.png

scale_and_text ../r_mmu_map_0000.png "map #1" m0.png 
scale_and_text ../r_mmu_map_0001.png "map #2" m1.png 
montage -background none phase.png 1m.png 2m.png m0.png m1.png -tile 5x1 -geometry "1x1+${SPACING}+0<" tmp.png

#remove whitespace around final image:
convert tmp.png -density ${DENSITY} -units PixelsPerInch -crop +${SPACING}+0 +repage -crop -${SPACING}-0 +repage ../${DIR}.png

cd ..
rm -r ${TMP}
cd ..
