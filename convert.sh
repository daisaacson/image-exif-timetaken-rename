#!/usr/bin/env bash

src=$1
dst=$2

echo "${src} to ${dst}"
# full file name of source files
srcFilesPath=$(find ${src} -type f)
# basename of destination files
dstFilesBase=$(find ${dst} -type f -printf "%f\n" 2>/dev/null)
# Debug
#echo "${srcFiles}"
#echo "${dstFiles}"

# total files to process
total=$(echo "${srcFilesPath}" | wc -l)
# use for zero padding
length=$(echo -n "${total}" | wc -c)
# counter
i=1

echo "${srcFilesPath}" | while IFS= read -r srcFilePath; do
    # print progress
    printf "%${length}d/${total}:" ${i}

    # build destination file name
    dstFileBase="${srcFilePath##*/}"
    # change extension to .jpg
    dstFileBase="${dstFileBase%.*}.jpg"

    if { [[ ! "$srcFilePath" =~ \.(jpg|jpeg|heic|png)$ ]]; } || \
        echo "${dstFilesBase}" | grep "\w\{8\}_${dstFileBase}$" >/dev/null; then
        echo "done ${srcFilePath}"
    else
        fileHash=$(sha256sum "${srcFilePath}" | cut -f1 -d' ')
        mkdir -p ${dst}/${fileHash:0:2}
        dstFilePath="${dst}/${fileHash:0:2}/${fileHash:0:8}_${dstFileBase}"
        
        case "$srcFilePath" in
            *Day\ Care.jpg)
                echo "copy ${srcFilePath}"
                cp "${srcFilePath}" "${dstFilePath}"
                ;;
            *.jpg|*.jpeg|*.png)
                echo "xvrt ${srcFilePath}"
                magick -quality 92% -define jpeg:extent=512kb "${srcFilePath}" "${dstFilePath}"
                ;;
            *.heic)
                echo "todo convert heic ${srcFilePath}"
                ;;
            *)
                echo "skip ${srcFilePath}"
                ;;
        esac
    fi
    i=$((i+1))
done