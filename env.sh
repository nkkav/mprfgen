# Filename : env.sh
# Author   : Nikolaos Kavvadias 2012-2020
# Copyright: (C) 2012-2020 Nikolaos Kavvadias

#!/bin/bash

##########################################################################
# Script for setting up the runtime environment
# USAGE:
# $ source env.sh $1
# where:
# $1: is the target operating system (WINDOWS or LINUX).
# Example:
# source env.sh LINUX
##########################################################################

if [ "$1" == "WINDOWS" ]
then
  export MPRFGEN_BIN_PATH=`pwd`/bin/win
fi
if [ "$1" == "LINUX" ]
then
  export MPRFGEN_BIN_PATH=`pwd`/bin/lin
fi

echo "mprfgen has been setup."
