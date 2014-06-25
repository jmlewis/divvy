# Import and Export functions for Python and Divvy
# Written by Jeremy Karnowski 2014

import numpy
import struct
import sys

def divvytopython(filename):
    """
    Import a Divvy file into Python
    The first two numbers are the dimensions from Divvy: (samples, dimensions)
    """
    samples, dimensions = numpy.fromfile(filename, dtype=numpy.uint32)[0:2]
    data = numpy.fromfile(filename, dtype=numpy.float32)[2:]
    data = data.reshape((samples, dimensions)).T
    return data

def pythontodivvy(data, name):
    """
    Export a Python array into Divvy format
    The array should have dimensions in the rows and samples in the columns
    """
    dimensions, samples = data.shape
    filename = name + '.bin'
    fout = open(filename, 'wb')
    fout.write(struct.pack('<I', samples))
    fout.write(struct.pack('<I', dimensions))
    for datum in data.T.flatten():
        fout.write(struct.pack('<f', datum))
    fout.close()

if __name__=='__main__':
    """
    If using this file from the command line, it will create
    a Divvy .bin file with the same name as the Python .npy file
    Usage: python pythontodivvy.py datafile.npy
    """
    npyfile = sys.argv[1]
    pythondata = np.load(npyfile)
    pythontodivvy(pythondata,npyfile[:-4])