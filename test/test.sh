# Filename : test.sh
# Author   : Nikolaos Kavvadias 2007-2020
# Copyright: (C) 2007-2020 Nikolaos Kavvadias

#!/bin/bash

##########################################################################
# Script for testing mprfgen
# USAGE:
# ./test.sh
##########################################################################

# 1. Generate a 3-read, 2-write port generic register file (asynchronous read).
${MPRFGEN_BIN_PATH}/mprfgen.exe -infer -nwp 2 -nrp 3 test1.vhd
# Generate the corresponding testbench in the ../sim directory.
cd ../sim
./change-generics.pl regfile_tb_tmpl.vhd 2 3 10 16 > test1_regfile_tb.vhd
cd ../test

# 2. Generate a 1-read, 1-write port 32x2048 memory.
${MPRFGEN_BIN_PATH}/mprfgen.exe -infer -read-first -nwp 1 -nrp 1 -bw 32 -nregs 2048 test2.vhd
# Generate the corresponding testbench in the ../sim directory.
cd ../sim
./change-generics.pl regfile_tb_tmpl.vhd 1 1 11 32 > test2_regfile_tb.vhd
cd ../test

# 3. Generate a 2-read, 1-write port LUT-based register file.
${MPRFGEN_BIN_PATH}/mprfgen.exe -infer -read-async test3.vhd
# Generate the corresponding testbench in the ../sim directory.
cd ../sim
./change-generics.pl regfile_tb_tmpl.vhd 1 2 10 16 > test3_regfile_tb.vhd
cd ../test

# 4. Generate a 2-read, 1-write port block RAM register file with direct 
# instantiation.
${MPRFGEN_BIN_PATH}/mprfgen.exe -read-first test4.vhd
# No testbench to generate.

# 5. Generate a 2-read, 2-write port block RAM-based egister file.
${MPRFGEN_BIN_PATH}/mprfgen.exe -infer -read-first -nwp 2 -nrp 2 test5.vhd
# Generate the corresponding testbench in the ../sim directory.
cd ../sim
./change-generics.pl regfile_tb_tmpl.vhd 2 2 10 16 > test5_regfile_tb.vhd
cd ../test

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running for $SECONDS $units."
