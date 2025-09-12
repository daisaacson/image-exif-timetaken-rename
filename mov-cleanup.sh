#!/usr/bin/env bash

for mov in IMG*.MOV; do 
	if [[ -f ${mov/MOV/HEIC} ]]; then
		echo "${mov/MOV/HEIC} exists, delete ${mov}"
		rm "${mov}"
	else
		echo "${mov}"
	fi
done
