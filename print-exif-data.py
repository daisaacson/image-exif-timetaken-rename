#!/usr/bin/env python3

import sys, time
from PIL import Image, ImageFilter
import piexif
from pillow_heif import HeifImagePlugin

fn = sys.argv[1]

print ("Filename: %s"%(fn))
img = Image.open(fn)
try:
    exif_dict = piexif.load(img.info["exif"])
    for ifd in ("0th", "Exif", "GPS", "1st"):
        for tag in exif_dict[ifd]:
            print(" - " + ifd + "." + piexif.TAGS[ifd][tag]["name"], exif_dict[ifd][tag])
except KeyError:
    print ("no exif data?")