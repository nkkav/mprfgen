# Filename : ghdl.sh
# Author   : Nikolaos Kavvadias 2010-2020
# Copyright: (C) 2010-2020 Nikolaos Kavvadias 

#!/bin/bash

##########################################################################
# Script for running a GHDL simulation.
# USAGE:
# ./ghdl.sh $1
# where:
# $1: name of the file/entity containing a multi-port register file 
# (using inferred block RAM, only).
# Run with option -help for obtaining usage help.
##########################################################################

E_NOTFOUND=81
E_PRINTUSAGE=83

function print_usage () {
  echo "Script for running a GHDL simulation."
  echo "Author: Nikolaos Kavvadias (C) 2010-2020"
  echo "Copyright: (C) 2010-2020 Nikolaos Kavvadias"
  echo "Usage: ./ghdl.sh \$1"
  echo "where:"
  echo "  \$1: name of the multi-port register file/entity"
  echo ""
  echo "Run with option -help for obtaining usage help."
}

if [ "$1" == "-help" ]
then
  print_usage;
  exit $E_PRINTUSAGE
fi

filename=$1

if [ ! -f "../test/$filename.vhd" ] # Quoting $filename allows for possible spaces.
then
  echo "File $filename.vhd not found!" >&2 # Error message to stderr.
  print_usage;
  exit $E_NOTFOUND
fi

##########################################################################
make -f ghdl.mk MPRF=$1 clean
make -f ghdl.mk MPRF=$1 init
make -f ghdl.mk MPRF=$1 run
##########################################################################

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running for $SECONDS $units."
