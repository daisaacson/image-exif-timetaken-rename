#!/usr/bin/env python3

import sys, time
from PIL import Image
import piexif

fn = sys.argv[1]
taken = sys.argv[2]

print ("Filename: %s"%(fn))
img = Image.open(fn)
try:
    exif_dict = piexif.load(img.info["exif"])
    exif_dict["0th"][306] = bytes(taken,"UTF-8")    # DateTime
    exif_dict["Exif"][36867] = bytes(taken,"UTF-8") # DateTimeOriginal
    exif_dict["Exif"][36868] = bytes(taken,"UTF-8") # DateTimeDigitized
    exif_bytes = piexif.dump(exif_dict)
    img.save("new_" + fn, quality=100, subsampling=0, exif=exif_bytes)
except KeyError:
    exif_dict = {"0th":{}}
    w, h = img.size
    exif_dict["0th"][piexif.ImageIFD.XResolution] = (w, 1)
    exif_dict["0th"][piexif.ImageIFD.YResolution] = (h, 1)
    exif_dict["0th"][306] = bytes(taken,"UTF-8")
    exif_dict["Exif"][36867] = bytes(taken,"UTF-8")
    exif_dict["Exif"][36868] = bytes(taken,"UTF-8")
    exif_bytes = piexif.dump(exif_dict)
    img.save("new_" + fn, quality=100, subsampling=0, exif=exif_bytes)
print ("exif: %s"%(exif_dict))
