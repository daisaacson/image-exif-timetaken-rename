# New Parent Path
$newParentPath = "E:\Family"
$ffmpeg = "~\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Shared_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-6.1.1-full_build-shared\bin\ffmpeg.exe"

$files = Get-ChildItem -Recurse -File * 
$i = 0

foreach ($file in $files) {
	$fileHash = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLower()
	$folder = "$($fileHash.Substring(0,2))"
	$prefix = "$($fileHash.Substring(0,8))_"
	$newFileName = "$newParentPath\$($folder)\$($prefix)$($file.basename).jpg"

	[int]$percentComplete = (($i+1)/$files.count)*100

	Write-Progress -Activity "Converting" -Status "$percentComplete%: $($file.basename)" -Id 0 -percentComplete $percentComplete

	if ( -Not (Test-Path $newFileName) ) {
		If ( -Not (Test-Path -PathType Container $(Split-Path $newFileName)) ) {
			[void](New-Item -ItemType Directory -Path $(Split-Path $newFileName))
		}
		
		switch -regex ($file) {
			".*Day Care.*" {
				# Copy Day Care photes, they are small, plus running them through ffmpeg causes the Aluratek Picture Frame to not show red colors
				[void](Copy-Item -Destination $newFileName $file.fullname)
				break
			}
			"\.jp.?g$" {
				# Lets compress the Jpegs
				& $ffmpeg -hide_banner -loglevel warning -i "$($file.fullname)" -update true -codec:v mjpeg -qscale:v 3 "$newFileName"
				break
			}
			"\.heic$" {
				# Convert iPhone heic images to jpeg.  This currenlty fails and is in place in case it ever works in the future
				& $ffmpeg -hide_banner -loglevel warning -i "$($file.fullname)" -update true -codec:v mjpeg -movflags -qscale:v 3 "$($newFileName).jpg"
				break
			}
		}
	} else {
		Write-Progress -Activity "Converting" -Status "$percentComplete%: Skipping $($file.basename)" -Id 0 -percentComplete $percentComplete
	}

	$i++
}

## LINUX
## All images are not oriented correctly
## sudo apt-get install libheif1 libheif-examples
#newParentPath="$HOME/d/Family"
#find . -name "*.heic" | while read i; do 
#	echo "$i"
#	fileHash=$(sha256sum "$i" | cut -f1 -d' ')
#	baseName=$(basename "${i}")
#	newFileName="${newParentPath}/${fileHash:0:2}/${fileHash:0:8}_${baseName}.jpg"
#	if [ ! -f "$newFileName" ]; then
#		heif-convert "${i}" "${newFileName}"
#	fi
#done