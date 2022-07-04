Get-ChildItem -Include "*.jpg", "*.jpeg", "*.png" * | Foreach-Object {
	$newFileName = "f:\Ezra\$($_.basename)_converted.jpg"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host "Converting: $($_.name)"
		& \\nas\family\public\PortableApps\ffmpeg-n5.0-latest-win64-gpl-5.0\bin\ffmpeg.exe -i "$($_.name)" -c:v mjpeg -qmin 1 -q:v 1 "$newFileName"
	} else {
		Write-Host "Skipping: $($_.name)"
	}
}




Get-ChildItem -Include "*.heic" * | Foreach-Object {
	$newFileName = "f:\Ezra\$($_.basename)_converted.jpg"
	if ( -Not (Test-Path $newFileName) ) {
		Write-Host "Converting: $($_.name)"
		& \\nas\family\public\PortableApps\ffmpeg-n5.0-latest-win64-gpl-5.0\bin\ffmpeg.exe -i "$($_.name)" -c:v mjpeg -movflags qt-faststart -pix_fmt rgb48 "$($newFileName).tiff"
	} else {
		Write-Host "Skipping: $($_.name)"
	}
}

# LINUX
#for i in *.heic; do 
#	newName="/mnt/f/Ezra/${i/.heic/_heic-converted.jpg}"
#	if [ ! -f "$newName" ]; then
#		heif-convert "$i" "$newName"
#	fi
#done