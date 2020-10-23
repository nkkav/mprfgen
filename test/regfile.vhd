--------------------------------------------------------------------------------
-- Filename: regfile.vhd
-- Purpose : Generic implementation of a multi-port register file.
-- Author  : Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com> 2007-2020
-- Date    : 10-Jan-2013
-- Version : 1.0.0
-- Revision: 1.0.0 (2013/01/10)
--           Stable version.
-- License : Copyright (C) 2007-2020 Nikolaos Kavvadias
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity regfile is
  generic (
    NWP : integer :=  1;
    NRP : integer :=  2;
    AW  : integer :=  8;
    DW  : integer := 32
  );
  port (
    clock        : in  std_logic;
    reset        : in  std_logic;
    enable       : in  std_logic;
    we_v         : in  std_logic_vector(NWP-1 downto 0);
    re_v         : in  std_logic_vector(NRP-1 downto 0);    
    waddr_v      : in  std_logic_vector(NWP*AW-1 downto 0);
    raddr_v      : in  std_logic_vector(NRP*AW-1 downto 0);
    input_data_v : in  std_logic_vector(NWP*DW-1 downto 0);
    ram_output_v : out std_logic_vector(NRP*DW-1 downto 0)
  );
end regfile;

architecture synth of regfile is
  type mem_type is array ((2**AW-1) downto 0) of 
    std_logic_vector(DW-1 downto 0);
  signal ram_name : mem_type := (others => (others => '0'));
begin
  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        for i in 0 to NWP-1 loop
          if ((we_v(i) = '1')) then
            ram_name(conv_integer(waddr_v(AW*(i+1)-1 downto AW*i))) <= 
            input_data_v(DW*(i+1)-1 downto DW*i);
          end if;
        end loop;
      end if;
    end if;
  end process;

  G_DO_NRP: for i in 0 to NRP-1 generate
   ram_output_v(DW*(i+1)-1 downto DW*i) <= 
   ram_name(conv_integer(raddr_v(AW*(i+1)-1 downto AW*i))) when (re_v(i) = '1') else
   (others => 'Z');
  end generate;
	
end synth;
