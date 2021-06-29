#!/usr/bin/env python3

import sys, time
from PIL import Image
import piexif

fn = sys.argv[1]

print ("Filename: %s"%(fn))
img = Image.open(fn)
try:
    exif_dict = piexif.load(img.info["exif"])
    taken = exif_dict["0th"][306]
    exif_dict["Exif"][36867] = taken
    exif_dict["Exif"][36868] = taken
    exif_bytes = piexif.dump(exif_dict)
    img.save("new_" + fn, quality=100, subsampling=0, exif=exif_bytes)
except KeyError:
    print ("no exif data?")