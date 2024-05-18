#!/usr/bin/env python3

import os, sys, time, datetime, pathlib
from dateutil.relativedelta import relativedelta
from optparse import OptionParser, OptionGroup
# Image files
from PIL import Image
# HEIC files from Apple Phones 
import piexif
import pyheif
# Video files
import ffmpeg

__version__ = '0.1'

#%%
def GetImageDate(fn):
    try:
        if pathlib.Path(fn).suffix.lower() == '.heic':
            if options.verbose: print("Input file is HEIC: %s" % fn) 
            heif = pyheif.read_heif(fn)
            for m in heif.metadata or []:
                if m['type'] == 'Exif':
                    heif_meta = piexif.load(m['data'])
            return time.strptime(heif_meta['0th'][306].decode('utf-8'),"%Y:%m:%d %H:%M:%S")
        if pathlib.Path(fn).suffix.lower() == '.mov' or pathlib.Path(fn).suffix.lower() == '.mp4':
            if options.verbose: print("Input file is vidio: %s" % fn)
            probe = ffmpeg.probe(fn)
            video_stream = next((stream for stream in probe['streams'] if stream['codec_type'] == 'video'), None)
            creation_time = video_stream['tags']['creation_time'] + "GMT"
            video_time = time.strptime(creation_time,"%Y-%m-%dT%H:%M:%S.000000Z%Z")
            if options.debug:
                print("Creation Time %s" % creation_time)
                g = datetime.datetime.fromtimestamp(time.mktime(time.strptime(creation_time,"%Y-%m-%dT%H:%M:%S.000000Z%Z")),tz=datetime.timezone.utc)
                c = time.localtime(time.mktime(time.strptime(creation_time,"%Y-%m-%dT%H:%M:%S.000000Z%Z")))
                print("GMT Time %s" % str(g))
                print("CDT Time %s" % str(c))
            return video_time
        return time.strptime(Image.open(fn)._getexif()[306],"%Y:%m:%d %H:%M:%S")
    except IOError:
        print ("File %s not found" % fn)
    #except TypeError:
    #    print ("File %s exif data not found" % fn)
#%%
def GetCompare(filedate, comparedate):
    d = datetime.datetime.strptime(filedate,"%Y%m%d-%H%M%S").date()
    c = datetime.datetime.strptime(comparedate,"%Y-%m-%d").date()
    r = relativedelta(d,c)
    if options.verbose: print ("%s %s %s" %(d,c,relativedelta(d,c)))
    if abs(r.years) >= 2:
        age = str(abs(r.years)) + " Years"
    else:
        if abs(r.years) >= 1:
            age = str(abs(r.months) + 12) + " Months"
        else:
            if abs(r.months) >= 2:
                age = str(abs(r.months)) + " Months"
            else:
                if abs(r.months) >= 1 or abs(r.days) >= 14:
                    age = str(abs((d - c)).days//7) + " Weeks"
                else:
                    if abs(r.days) > 1:
                        age = str(abs(r.days)) + " Days"
                    elif abs(r.days) == 1:
                        age = str(abs(r.days)) + " Day"
                    elif abs(r.days) == 0:
                        age = "Day " + str(abs(r.days))
                    else:
                        age = "error"
    if r.years < 0 or r.months < 0 or r.days < 0:
        age = "-" + age
    return age
#%%
def GetNewImageName(image, prefix, append):
    # The date-time string
    datetime = time.strftime(options.format,GetImageDate(image))
    if options.compare:
        compare = GetCompare(datetime,options.compare)
    # Add an index number to file incase more than 1 file as created in the same second
    for i in range(30):
        temp = datetime
        if options.prefix: temp = options.prefix + temp
        temp = temp + "-" + str(i)
        if options.compare: temp = temp + " (" + compare + ")"
        if options.append: temp = temp + options.append
        if os.path.dirname(image):
            test = os.path.dirname(image) + os.sep + temp + os.path.splitext(image)[1].lower()
        else:
            test = temp + os.path.splitext(image)[1].lower()
        if not os.path.isfile(test):
            newImage = test
            break
    return newImage
#%%
def main(args):
    for image in args:
        if options.verbose: print("Intput file: %s" % image) 
        newImage = GetNewImageName(image, options.prefix, options.append)
        if options.dry or options.verbose:
            print("%s --> %s" % (image, newImage))
        else:
            os.rename(image, newImage)
#%%

if __name__ == '__main__':
    description = "Image DateTime take renameer"
    usage = "usage: %prog [options] image [image...]"
    version = "%prog " + str(__version__)
    parser = OptionParser(usage=usage, description=description, version=version)
    epilog = "Rename image file with [prepend_]datetaken[_append].extension"
    parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
    parser.add_option("-a", "--append", action="store", type="string", help="Append string to filename")
    parser.add_option("-c", "--compare", action="store", type="string", help="Time differace to filename")
    parser.add_option("-f", "--format", action="store", type="string", help="Datetime Format", default="%Y%m%d-%H%M%S")
    parser.add_option("-p", "--prefix", action="store", type="string", help="Prefix string to filename")
    group = OptionGroup(parser, "Debug Options")
    group.add_option("-d", "--dry", action="store_true", help="Dry Run")
    group.add_option("-v", "--verbose", action="store_true", help="Print Verbose")
    group.add_option("-D", "--debug", action="store_true", help="Print debug")
    parser.add_option_group(group)
    (options, args) = parser.parse_args()
    if options.debug: options.verbose=True
    if options.debug: print("Input Options: %s" % options)
    if options.debug: print("Input Args :%s" % args)

    sys.exit(main(args))
