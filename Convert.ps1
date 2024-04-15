# New Parent Path
$newParentPath = "E:\Family"
$magick = "C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe"

$files = Get-ChildItem -Recurse -File * 
$i = 0

foreach ($file in $files) {
	$fileHash = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLower()
	$folder = "$($fileHash.Substring(0,2))"
	$prefix = "$($fileHash.Substring(0,8))_"
	$newFileName = "$newParentPath\$($folder)\$($prefix)$($file.basename).jpg"

	[int]$percentComplete = [math]::floor((($i++)/$files.count)*100)

	if ( -Not (Test-Path $newFileName) ) {
		If ( -Not (Test-Path -PathType Container $(Split-Path $newFileName)) ) {
			[void](New-Item -ItemType Directory -Path $(Split-Path $newFileName))
		}
		
		switch -regex ($file) {
			".*Day Care.*" {
				Write-Progress -Activity "   Copying" -Status "$percentComplete%: $($file.basename)" -Id 0 -percentComplete $percentComplete
				# Copy Day Care photes, they are small, plus running them through ffmpeg causes the Aluratek Picture Frame to not show red colors
				[void](Copy-Item -Destination $newFileName $file.fullname)
				break
			}
			"\.(jp.?g|heic)$" {
				Write-Progress -Activity "Converting" -Status "$percentComplete%: $($file.basename)" -Id 0 -percentComplete $percentComplete
				# Lets compress the Jpegs
				& $magick -quality 92% -define jpeg:extent=1024kb "$($file.fullname)" "$($newFileName)"
				break
			}
		}
	} else {
		Write-Progress -Activity "  Skipping" -Status "$percentComplete%: $($file.basename)" -Id 0 -percentComplete $percentComplete
	}
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