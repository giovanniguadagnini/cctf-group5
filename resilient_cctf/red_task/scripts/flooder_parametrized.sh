#!/bin/bash

SRCRND="1"

DST="10.1.5.2"
DSTMASK="255.255.255.255"
SRC="10.1.2.0"
SRCMASK="255.255.255.0"
#INTERFACE=
PROTO="17"
LENGTHMIN="0"
LENGTHMAX="0"

SPORTMIN="0"
SPORTMAX="65535"
DPORTMIN="0"
DPORTMAX="65535"
TCPFLAGS="SYN"

TYPEMIN="8"
TYPEMAX="8"
CODEMIN="0"
CODEMAX="0"

RATETYPE="flatrate"

LOWRATE="1"
HIGHRATE="1"
LOWTIME="0"
HIGHTIME="0"
RISETIME="0"
FALLTIME="0"
RISESHAPE="1.0"
FALLSHAPE="1.0"

if [ "$#" -ge 1 ];then
	SRCRND=$1
	if [ "$#" -ge 2 ];then
		DST=$2
		if [ "$#" -ge 3 ];then
			SRC=$3
			if [ "$#" -ge 4 ];then
				SRCMASK=$4
				if [ "$#" -ge 5 ];then
					RATETYPE=$5
				fi
			fi
		fi
	fi
fi

if [ "$SRCRND" -eq 1 ];then
	SRC="10.1.$((1 + $RANDOM % 5)).0"
fi

sudo flooder --dst $DST --dstmask $DSTMASK --src $SRC --srcmask $SRCMASK --proto $PROTO --lengthmin $LENGTHMIN  --lengthmax $LENGTHMAX --sportmin $SPORTMIN --sportmax $SPORTMAX --dportmin $DPORTMIN --dportmax $DPORTMAX --tcpflags $TCPFLAGS --typemin $TYPEMIN --typemax $TYPEMAX --codemin $CODEMIN --codemax $CODEMAX --ratetype $RATETYPE --lowrate $LOWRATE --highrate $HIGHRATE --lowtime $LOWTIME --hightime $HIGHTIME --risetime $RISETIME --falltime $FALLTIME --riseshape $RISESHAPE --fallshape $FALLSHAPE