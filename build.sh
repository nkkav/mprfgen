# Filename : build.sh
# Author   : Nikolaos Kavvadias 2007-2020
# Copyright: (C) 2007-2020 Nikolaos Kavvadias 

#!/bin/bash

##########################################################################
# Script for building mprfgen
# USAGE:
# ./build.sh $1
# where:
# $1: is the target operating system (WINDOWS or LINUX).
# Example:
# ./build.sh LINUX
##########################################################################

cd src
make clean
make
if [ "$1" == "WINDOWS" ]
then
  mkdir -p ../bin/win
  cp -f mprfgen.exe ../bin/win
fi
if [ "$1" == "LINUX" ]
then
  mkdir -p ../bin/lin
  cp -f mprfgen.exe ../bin/lin
fi
cd ..

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running for $SECONDS $units."
