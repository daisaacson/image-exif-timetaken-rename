# New Parent Path
$newParentPath = "E:\Family"

# Lets compress the Jpegs
Get-ChildItem -Recurse -Include "*.jpg", "*.jpeg", "*.png" -Exclude "*Day Care*" * | Foreach-Object {
	$fileHash = (Get-FileHash -Algorithm SHA256 $_).Hash.ToLower()
	$newFileName = "$newParentPath\$($fileHash.Substring(0,2))\$($fileHash.Substring(0,7))_$($_.basename).jpg"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host -Foreground Green "Converting: $($_.name)"
		If ( -Not (Test-Path -PathType Container $(Split-Path $newFileName)) ) {
			New-Item -ItemType Directory -Path $(Split-Path $newFileName) -Verbose
		}
		& ffmpeg.exe -i "$($_.fullname)" -codec:v mjpeg -qscale:v 3 "$newFileName"
	} else {
		Write-Host -Foreground Yellow "Skipping: $($_.name)"
	}
}

## Convert iPhone heic images to jpeg.  This currenlty fails and is in place in case it ever works in the future
## See commented out LINUX bash script below
#Get-ChildItem -Recurse -Include "*.heic" * | Foreach-Object {
#	$fileHash = (Get-FileHash -Algorithm SHA256 $_).Hash.ToLower()
#	$newFileName = "$newParentPath\$($fileHash.Substring(0,2))\$($fileHash.Substring(0,7))_$($_.basename).jpg"
#	if ( -Not (Test-Path $newFileName) ) {
#		Write-Host -Foreground Green "Converting: $($_.name)"
#		If ( -Not (Test-Path -PathType Container $(Split-Path $newFileName)) ) {
#			New-Item -ItemType Directory -Path $(Split-Path $newFileName) -Verbose
#		}
#		& ffmpeg.exe -i "$($_.fullname)" -codec:v mjpeg -movflags -qscale:v 3 "$($newFileName).jpg"
#	} else {
#		Write-Host -Foreground Yellow "Skipping: $($_.name)"
#	}
#}

# Copy Day Care photes, they are small, plus running them through ffmpeg causes the Aluratek Picture Frame to not show red colors
Get-ChildItem -Recurse -Include "*Day Care*" * | Foreach-Object {
	$fileHash = (Get-FileHash -Algorithm SHA256 $_).Hash.ToLower()
	$newFileName = "$newParentPath\$($fileHash.Substring(0,2))\$($fileHash.Substring(0,7))_$($_.name)"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host -Foreground Green "Copying: $($_.name)"
		If ( -Not (Test-Path -PathType Container $(Split-Path $newFileName)) ) {
			New-Item -ItemType Directory -Path $(Split-Path $newFileName) -Verbose
		}
		Copy-Item -Destination $newFileName $_.fullname
	} else {
		Write-Host -Foreground Yellow "Skipping: $($_.name)"
	}
}

## LINUX
## All images are not oriented correctly
#newParentPath="~/d/Family"
#find . -name "*.heic" | while read i; do 
#	echo "$i"
#	fileHash=$(sha256sum "$i" | cut -f1 -d' ')
#	baseName=$(basename "${i}")
#	newFileName="${newParentPath}/${fileHash:0:2}/${fileHash:0:7}_${baseName}.jpg"
#	if [ ! -f "$newFileName" ]; then
#		heif-convert "${i}" "${newFileName}"
#	fi
#done