import os, sys, time
from optparse import OptionParser, OptionGroup
from PIL import Image

__version__ = '0.1'

#%%
def GetImageDate(image):
    try:
        return time.strptime(Image.open(image)._getexif()[306],"%Y:%m:%d %H:%M:%S")
    except IOError:
        print ("File %s not found" % image)
#%%
def GetNewImageName(image, prefix, append):
    date = time.strftime(options.format,GetImageDate(image))
    for i in range(30):
        temp = date
        if options.prefix: temp = options.prefix + temp
        temp = temp + "-" + str(i)
        if options.append: temp = temp + options.append
        test = os.path.dirname(image) + os.sep + temp + os.path.splitext(image)[1].lower()
        if not os.path.isfile(test):
            newImage = test
            break
    return newImage
#%%
def main(args):
    for image in args:
        if options.verbose: print("Intput file: %s" % image) 
        newImage = GetNewImageName(image, options.prefix, options.append)
        if options.dry:
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