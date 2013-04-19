#!/bin/bash

SERVICE_URL=http://cssminifier.com/raw
NEWFILE="c`date +"%d%m%y"`.css"

# Check if files to compile are provided
if [ $# -eq 0 ]
then
	echo 'Nothing to compile. Specify input files as command arguments. E.g.'
	echo './compresscss file1.css'
	exit
fi

cat /dev/null > ${NEWFILE} 

for f in $*
do
    if [ -r ${f} ]
    then
        curl -X POST -s --data-urlencode "input@$1" ${SERVICE_URL} >> ${NEWFILE}

    else
		echo "File ${f} does not exist or is not readable. Skipped."
    fi
done
