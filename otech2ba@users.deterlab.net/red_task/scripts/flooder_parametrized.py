import sys
import subprocess
import random as random

SRCRND		="1"

DST			="10.1.5.2"
DSTMASK		="255.255.255.255"
SRC			="10.1.2.0"
SRCMASK		="255.255.255.0"
#INTERFACE	=
PROTO		="17"
LENGTHMIN	="0"
LENGTHMAX	="0"

SPORTMIN	="0"
SPORTMAX	="65535"
DPORTMIN	="0"
DPORTMAX	="65535"
TCPFLAGS	="SYN"

TYPEMIN		="8"
TYPEMAX		="8"
CODEMIN		="0"
CODEMAX		="0"

RATETYPE	="flatrate"

LOWRATE		="1"
HIGHRATE	="1"
LOWTIME		="0"
HIGHTIME	="0"
RISETIME	="0"
FALLTIME	="0"
RISESHAPE	="1.0"
FALLSHAPE	="1.0"

if __name__=="__main__":
	
	if len(sys.argv)>=2:
		SRCRND=sys.argv[1]
		if len(sys.argv)>=3:
			DST=sys.argv[2]
			if len(sys.argv)>=4:
				SRC=sys.argv[3]
				if len(sys.argv)>=5:
					SRCMASK=sys.argv[4]
					if len(sys.argv)>=6:
						RATETYPE=sys.argv[5]
	
	if SRCRND == "1":
		SRC = "10.1." + str(random.randint(1,5)) + ".0"
	
	line = ('flooder'
			' --dst '+DST+' --dstmask '+DSTMASK+' --src '+SRC+' --srcmask '+SRCMASK+' --proto '+PROTO+' --lengthmin '+LENGTHMIN+'  --lengthmax '+LENGTHMAX+#'  --interface '+INTERFACE+
			' --sportmin '+SPORTMIN+' --sportmax '+SPORTMAX+' --dportmin '+DPORTMIN+' --dportmax '+DPORTMAX+' --tcpflags '+TCPFLAGS+
			' --typemin '+TYPEMIN+' --typemax '+TYPEMAX+' --codemin '+CODEMIN+' --codemax '+CODEMAX+
			' --ratetype '+RATETYPE+
			' --lowrate '+LOWRATE+' --highrate '+HIGHRATE+' --lowtime '+LOWTIME+' --hightime '+HIGHTIME+' --risetime '+RISETIME+' --falltime '+FALLTIME+' --riseshape '+RISESHAPE+' --fallshape '+FALLSHAPE)
	
	cmd = line#['flooder', line]
	proc = subprocess.Popen(cmd, shell=True)

	o, e = proc.communicate()

	print('Output: ' + o.decode('ascii'))
	print('Error: '  + e.decode('ascii'))
	print('code: ' + str(proc.returncode))