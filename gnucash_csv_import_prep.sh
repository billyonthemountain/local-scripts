#!/bin/bash

echo "Preparing $1 for import into GnuCash"

filename=$(basename "$1")
fileext="${filename##*.}"
filebase="${filename%.*}"
outdir=$(pwd)

xls_overhead=3
xls_overtail=1

# For Card 1, convert from xls to csv, cut away overhead
# tail and reformat from DD/MM/YY to YY-MM-DD
# Fixme: Detect presence of either libreoffice or ssconvert
# Fixme: Verify that outdir exists
if [[ $fileext == "xls" ]] || [[ $fileext == "xlsx" ]]; then
    echo "Converting from Excel"
    # apt-get install gnumeric --no-install-recommends
    # ssconvert $1 ${outdir}/${basefile}.csv > /dev/null 2>&1
    libreoffice --headless --convert-to csv $1 --outdir $outdir
    echo "Done, converting dates to a GnuCash friendly format"
    tail -n +$((xls_overhead+1)) ${outdir}/${filebase}.csv | \
	head -n -$((xls_overtail)) | \
	sed -e 's|\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\)|\3-\2-\1|g' > ${outdir}/tmp.csv
    mv -f ${outdir}/tmp.csv ${outdir}/${filebase}.csv

# For Card no 2, reformat dates from MM/DD/YYYY 00:00:00 to YYYY-MM-DD
# Fixme: if outfile = infile, then use sed -i (inplace)    
elif [[ $fileext == "csv" ]]; then
    echo "Adapting dates to a GnuCash friendly format"
    sed -e 's|\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\) 00:00:00|\3-\1-\2|g' $1 > ${outdir}/${filename}
fi
