#! /usr/bin/perl
#
# File       : change-generics.pl
# Description: Changes values for the NWP, NRP, AW, DW generic at the 
#              of "regfile_tb_tmpl.vhd" to much the specific values of the 
#              circuit under simulation.
#              The resulting file is renamed to "regfile_tb.vhd".
# Usage      : ./change-generics.pl <file.vhd> <nwp> <nrp> <aw> <dw>
#
# Author     : Nikolaos Kavvadias (c) 2009-2020
#

open(FILE1,"<$ARGV[0]")|| die "## cannot open file $ARGV[0]\n";

$nwp_ix = 0;
$nrp_ix = 0;
$aw_ix  = 0;
$dw_ix  = 0;

while ($line = <FILE1>)
{
  if ($line =~ m/.*NWP.*:.*integer.*1;/)
  {
    if ($nwp_ix < 1)
    {
      $line =~ s//    NWP           : integer :=  $ARGV[1];/;
      $nwp_ix = 1;
    }
  }
  if ($line =~ m/.*NRP.*:.*integer.*2;/)
  {
    if ($nrp_ix < 1)
    {
      $line =~ s//    NRP           : integer :=  $ARGV[2];/;
      $nrp_ix = 1;
    }
  }
  if ($line =~ m/.*AW.*:.*integer.*4;/)
  {
    if ($aw_ix < 1)
    {
      $line =~ s//    AW           : integer :=  $ARGV[3];/;
      $aw_ix = 1;
    }
  }
  if ($line =~ m/.*DW.*:.*integer.*8/)
  {
    if ($dw_ix < 1)
    {
      $line =~ s//    DW           : integer :=  $ARGV[4]/;
      $dw_ix = 1;
    }
  }

  print $line;
}
