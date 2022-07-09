# Lets compress the Jpegs
Get-ChildItem -Include "*.jpg", "*.jpeg", "*.png" -Exclude "*Day Care*" * | Foreach-Object {
	$newFileName = "d:\Ezra\$($_.basename)_converted.jpg"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host -Foreground Green "Converting: $($_.name)"
		& \\nas\family\public\PortableApps\ffmpeg-n5.0-latest-win64-gpl-5.0\bin\ffmpeg.exe -i "$($_.name)" -c:v mjpeg -qmin 1 -q:v 1 "$newFileName"
	} else {
		Write-Host -Foreground Yellow "Skipping: $($_.name)"
	}
}

# Convert iPhone heic images to jpeg.  This currenlty fails and is in place in case it ever works in the future
# See commented out LINUX bash script below
Get-ChildItem -Include "*.heic" * | Foreach-Object {
	$newFileName = "d:\Ezra\$($_.basename)_converted.jpg"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host -Foreground Green "Converting: $($_.name)"
		& \\nas\family\public\PortableApps\ffmpeg-n5.0-latest-win64-gpl-5.0\bin\ffmpeg.exe -i "$($_.name)" -c:v mjpeg -movflags qt-faststart -pix_fmt rgb48 "$($newFileName).tiff"
	} else {
		Write-Host -Foreground Yellow "Skipping: $($_.name)"
	}
}

# Copy Day Care photes, they are small, plus running them through ffmpeg causes the Aluratek Picture Frame to not show red colors
Get-ChildItem -Include "*Day Care*" * | Foreach-Object {
	$newFileName = "d:\Ezra\$($_.name)"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host -Foreground Green "Copying: $($_.name)"
		Copy-Item -Destination $newFileName $_.name
	} else {
		Write-Host -Foreground Yellow "Skipping: $($_.name)"
	}
}

# LINUX
# All images are not oriented correctly
#for i in *.heic; do 
#	newName="/mnt/d/Ezra/${i/.heic/_heic-converted.jpg}"
#	if [ ! -f "$newName" ]; then
#		heif-convert "$i" "$newName"
#	fi
#done