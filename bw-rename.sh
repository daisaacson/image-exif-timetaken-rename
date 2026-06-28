#!/usr/bin/env bash

# Get options using getopt
OPTS=$(getopt -o "d:t:k:b:c:" -l "date:,time:,kid:,birthday:,comment:" -- "$@")
eval set -- "$OPTS"

FILES=()

while true; do
  case $1 in
    -d | --date) DATE=$2; shift 2;;
    -t | --time) TIME=$2; shift 2;;
    -k | --kid) KID=$2; shift 2;;
    -b | --birthday) BIRTH_DATE=$2; shift 2;;
    -c | --comment) COMMENT=$2; shift 2;;
    --) shift; break ;;
  esac
done
FILES=("$@")

i=100
for file in "${FILES[@]}"; do
  ~/git/image-exif-timetaken-rename/add-exif.py ${file} "${DATE} ${TIME}:${i:1:2}" && rm ${file}
  ~/git/image-exif-timetaken-rename/image-exif-timetaken-rename.py -c ${BIRTH_DATE} -p ${KID}_ -a " ${COMMENT}" new_${file}
  i=$((i+1))
done
