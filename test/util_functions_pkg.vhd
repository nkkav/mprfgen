--------------------------------------------------------------------------------
-- Filename: util_functions_pkg.vhd
-- Purpose : VHDL package with some useful functions.
-- Author  : Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com> 2002-2020
-- Date    : 10-Jan-2013
-- Version : 1.0.0
-- Revision: 1.0.0 (2013/01/10)
--           Stable version.
-- Revision History:
--           1.0.0 (2013/01/10)
--           Stable version
--           0.1.0 (2005/01/01)
--           int_to_str, hex_str_to_int, Shrink_line, bin_str_to_int removed.
--           0.0.3 (2002/05/10)
--           bin_str_to_int added for ROM Memory "Initialization".
--           0.0.2 (2002/04/27)
--           int_to_str, hex_str_to_int, Shrink_line functs/procs
--           added. Originally proposed in various LPM codes (of Altera).
--           0.0.1 (2002/04/26)
--           Added LOG2 function proposed by Ray Andraka.
--           Not correct (rounds at +1 int), corrected by Nikolaos Kavvadias.
--           LOGN function proposed by Nikolaos Kavvadias.
-- License : Copyright (C) 2002-2020 Nikolaos Kavvadias
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


package util_functions_pkg is
  function LOG2F(input: INTEGER) return INTEGER;
  function LOG2C(input: INTEGER) return INTEGER;
  function LOG2CTAB(input: INTEGER) return INTEGER;
  function NUMBITS(input: INTEGER) return INTEGER;
  function LOGNF(input: INTEGER; N: INTEGER) return INTEGER;
  function LOGNC(input: INTEGER; N: INTEGER) return INTEGER;
end util_functions_pkg;


package body util_functions_pkg is

  ----------------------------------------------------------------------------
  -- Base-2 logarithm function (LOG2F(x)) [rounds to floor]
  ----------------------------------------------------------------------------
  function LOG2F(input: INTEGER) return INTEGER is
    variable temp,log: INTEGER;
    begin
      temp := input;
      log := 0;
      while (temp > 1) loop
        temp := temp/2;
        log := log+1;
      end loop;
    return log;
  end function LOG2F;

----------------------------------------------------------------------------
-- Base-2 logarithm function (LOG2C(x)) [rounds to ceiling]
-- Adopted from Reto Zimmermann's "arith_lib" (was: log2ceil)
----------------------------------------------------------------------------
  function LOG2C(input: INTEGER) return INTEGER is
    variable temp,log: INTEGER;
    begin
      log := 0;
      temp := 1;
      for i in 0 to input loop
        if temp < input then
          log := log + 1;
          temp := temp * 2;
        end if;
      end loop;
    return (log);
  end function LOG2C;

  ----------------------------------------------------------------------------
  -- Base-2 logarithm function using a LUT.
  ----------------------------------------------------------------------------
  function LOG2CTAB(input: INTEGER) return INTEGER is
    variable log: INTEGER;
    begin
      case input is 
        when  0 to   1 => log := 0;
        when  2        => log := 1;
        when  3 to   4 => log := 2;
        when  5 to   8 => log := 3;
        when  9 to  16 => log := 4;
        when 17 to  32 => log := 5;
        when 33 to  64 => log := 6;
        when 65 to 128 => log := 7;
        when others    => log := 0;
      end case;
    return (log);
  end function LOG2CTAB;

  ----------------------------------------------------------------------------
  -- Calculates the number of bits needed for representing an integer.
  ----------------------------------------------------------------------------
  function NUMBITS(input: INTEGER) return INTEGER is
    variable temp   : INTEGER := input;
    variable result : INTEGER := 1;
    begin
      loop
        temp := temp/2;
        exit when temp = 0;
        result := result + 1;
      end loop;
    return result;
  end NUMBITS;

  ----------------------------------------------------------------------------
  -- Base-N logarithm function (LOGNF(x,N)) [rounds to floor]
  ----------------------------------------------------------------------------
  function LOGNF(input: INTEGER; N: INTEGER) return INTEGER is
    variable temp,log: INTEGER;
    begin
      temp := input;
      log := 0;
      while (temp >= N) loop
        temp := temp / N;
        log := log + 1;
      end loop;
    return log;
  end function LOGNF;

  ----------------------------------------------------------------------------
  -- Base-N logarithm function (LOGNC(x,N)) [rounds to ceiling]
  ----------------------------------------------------------------------------
  function LOGNC(input: INTEGER; N: INTEGER) return INTEGER is
    variable temp,log: INTEGER;
    begin
      temp := 1;
      log := 0;
      for i in 0 to input-1 loop
        exit when temp >= input;
        log := log + 1;
        temp := temp * N;
      end loop;
    return log;
  end function LOGNC;

end util_functions_pkg;

--
-- "The more i want something done, the less i call it work."
-- Richard Bach
--
