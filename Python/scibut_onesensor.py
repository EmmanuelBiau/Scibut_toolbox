#!/usr/bin/env python

"""
scibut_onesensor.py 
Reads six 8bit messages from the Serial port (see below).
The first ("B") and last ("E") byte indicate the start and end of a sequence.
Bytes 2 and 3 = Low and high byte of Arduino clock (ms)
Bytes 4 and 5 = Low and high byte of the Photodiode reading

INPUTS:
1. filename = Filename for the resulting text file (default = "TEST.txt")
2. comm_port 	= The COM/Serial port to be read (check devices; default = "COM9")
3. duration		= Recording duration (default = Inf)

OUTPUT:
Text file containing (in columns 1 to 3)
1. Arduino timestamp (ms)
2. Photodiode reading
3. Python timestamp (secs)

Part of the Schultz Cigarette Burn Toolbox (2019)
Benjamin Schultz (benjamin.glenn.schultz@gmail.com)
"""

__author__ = "Benjamin Schultz"
__copyright__ = "Part of the Schultz Cigarette Burn Toolbox, Copyright 2019"
__credits__ = ["Benjamin Schultz","Floris van Vugt"]
__license__ = "GNU"
__version__ = "1.0.1"
__maintainer__ = "Benjamin Schultz"
__email__ = "benjamin.glenn.schultz@gmail.com"
__status__ = "Production"

#### IMPORT MODULES/LIBRARIES ####
# standard libraries
import sys, time, os, datetime 
# 3rd party libraries
import serial # from https://pythonhosted.org/pyserial/

#### CHECK INPUTS ####
try:
    filename = sys.argv[1]
except:
    filename = "TEST.txt"
    print("Default filename used: %s"%filename)

try:
    comm_port = sys.argv[2]
except:
    comm_port = "COM7"
    print("Comm port %s will be used"%comm_port)

try:
    duration = float(sys.argv[3])
except:
    duration = float("inf")
    print("Trial requires manual termination\n")

#### PREDEFINE VARIABLES ####
baudrate = 115200 # define communication port bps
PACKET_LENGTH = 5
timeDelay = 1 # give time delay
i=0

#### FUNCTIONS ####
def report_package(r,dumpfile,time_now):
    """ Given a packet that we just read from the serial port,
    extract the package contents and write them to the output file.
    """
    b1 = ord(r[0])+256*ord(r[1]) # Timestamp
    b2 = ord(r[2])+256*ord(r[3]) # Photodiode    
    b3 = r[4]

    #print b1,b2 # for debugging
    output = "%i %i %f\n"%(b1,b2,time_now) # preset row
    dumpfile.write(output) # write output to text files

    if True:
        print output, # for visualisation or debugging

def process_packets(comm_port,dumpfile):
    """ Process the packages that might have been sent to the comm_port,
    and report them if they have."""

    # Read input
    r = comm_port.read(1)

    if True:
        if r=="B": # Start of packet found
            #print "Got a B" # for debugging
            time_now = time.clock() #get time immediately for stamping
            avail=0 # how many bytes are available
            while avail<PACKET_LENGTH: # wait for full packet
                avail=comm_port.inWaiting()

            # Read full packet
            r = comm_port.read(PACKET_LENGTH) # read the whole thing straight away

            # Check for end of packet
            if len(r)==PACKET_LENGTH and r[-1]=="E": # if we have the correct ending also
                report_package(r,dumpfile,time_now) #report

            else: # reject packet
                if len(r)>0:
                    print "rejected",r

        else: # reject packet
            if r=="\n":
                pass
            else:
                print "rejected non-B",r
#### END OF FUNCTIONS ####

#### RUN THE SCRIPT #### 
if True:        
    
    # Check COM/Serial port
    try:
        comm = serial.Serial(comm_port, baudrate, timeout=0.25)
    except:
        print "Cannot open USB port %s. Is the device connected?\n"%comm_port
        sys.exit(-1)

    dumpfile = open(filename,'w') # start writing to text files

    # set end time for reading
    do_continue=True	
    timeStart = time.clock() #time now
    endTime = timeStart+timeDelay+duration # end time

    # loop for reading
    while do_continue:
                
        # Read from port
        process_packets(comm,dumpfile)
        
        if time.clock()>endTime:
            #print("exiting")
            # stop and quit
            sys.exit(0)