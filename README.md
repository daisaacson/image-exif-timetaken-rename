## Prep

```bash
sudo apt install python3-pip python3-dateutil python3-pil ffmpeg
pip install piexif pyheif ffmpeg ffmpeg-python
```

Rename Images and Movies based on time media was created

Movies are save to GMT, need to fix to localtime

## image-exif-timetaken-rename.py

Outputs file format is YYYYMMDD-HHMMSS-0.ext

```bash
image-exif-timetaken-rename.py -c 2021-01-01 -p Kid_ -a ' Some Activity' -d new_fb923d81-9487-448a-9a20-da546660e467.jpg
```
renames file to Kid_20210630-163300-0 (5 Months) Some Activity.jpg

## add-exif.py

adds Timestamp to the following exif fields:

* 0th[306] - DateTime
* Exif[36867] - DateTimeOriginal
* Exif[36868] - DateTimeDigitized

```bash
add-exif.py fb923d81-9487-448a-9a20-da546660e467.jpg '2021:06:30 16:33:00'
Filename: fb923d81-9487-448a-9a20-da546660e467.jpg
exif: {'0th': {274: 1, 34665: 38, 306: b'2021:06:30 16:33:00'}, 'Exif': {40961: 1, 40962: 810, 40963: 1080, 36867: b'2021:06:30 16:33:00', 36868: b'2021:06:30 16:33:00'}, 'GPS': {}, 'Interop': {}, '1st': {}, 'thumbnail': None}
```

## script


```bash
date="2023:08:01"; i=100; for p in a.jpg b.jpg c.jpg;do ~/GIT/image-exif-timetaken-rename/add-exif.py $p "${date} 12:30:${i:1:2}" && rm $p; ~/GIT/image-exif-timetaken-rename/image-exif-timetaken-rename.py -c 2021-01-01 -p Kid_ -a ' Some Activity' new_${p}; i=$((i+1)); done
```

Renames files
* Kid_20230801-12:30:00-0 (2 Years) Some Activity.jpg
* Kid_20230801-12:30:01-0 (2 Years) Some Activity.jpg
* Kid_20230801-12:30:02-0 (2 Years) Some Activity.jpg

## fix-exif.py

Originally add-exif.py only added one DateTime tag

* 0th[306] - DateTime

piexif data would through warnings, so this copies the 0th[306] tag to

* Exif[36867] - DateTimeOriginal
* Exif[36868] - DateTimeDigitized