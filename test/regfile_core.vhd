--------------------------------------------------------------------------------
-- Filename: regfile_core.vhd
-- Purpose : Single-read, single-write port memory model used by the generated 
--           memories (mandatory for inferred memory).
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

entity regfile_core is
  generic (
    AW  : integer :=  5;
    DW  : integer := 32
  );
  port (
    clock        : in  std_logic;
    reset        : in  std_logic;
    enable       : in  std_logic;
    we           : in  std_logic;
    re           : in  std_logic;
    waddr        : in  std_logic_vector(AW-1 downto 0);
    raddr        : in  std_logic_vector(AW-1 downto 0);
    input_data   : in  std_logic_vector(DW-1 downto 0);
    ram_output   : out std_logic_vector(DW-1 downto 0)
  );
end regfile_core;

architecture write_first of regfile_core is
  type mem_type is array ((2**AW-1) downto 0) of std_logic_vector(DW-1 downto 0);
  signal ram_name : mem_type := (others => (others => '0'));
begin
  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        if (we = '1') then
          ram_name(conv_integer(waddr)) <= input_data;
        end if;
      end if;
    end if;
  end process;

  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        ram_output <= ram_name(conv_integer(raddr));
      end if;
    end if;
  end process;
end write_first;

architecture read_async of regfile_core is
  type mem_type is array ((2**AW-1) downto 0) of  std_logic_vector(DW-1 downto 0);
  signal ram_name : mem_type := (others => (others => '0'));
begin
  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        if (we = '1') then
          ram_name(conv_integer(waddr)) <= input_data;
        end if;
      end if;
    end if;
  end process;

  ram_output <= ram_name(conv_integer(raddr));
end read_async;

architecture read_first of regfile_core is
  type mem_type is array ((2**AW-1) downto 0) of std_logic_vector(DW-1 downto 0);
  shared variable ram_name : mem_type := (others => (others => '0'));
  signal ram_output_b : std_logic_vector(DW-1 downto 0);
  signal we_a : std_logic;
begin
  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        ram_output <= ram_name(conv_integer(raddr));
        if (reset = '1') then
          ram_name(conv_integer(raddr)) := input_data;
        end if;
      end if;
    end if;
  end process;

  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        if (we = '1') then
          ram_name(conv_integer(waddr)) := input_data;
        end if;
        ram_output_b <= ram_name(conv_integer(waddr));
      end if;
    end if;
  end process;
end read_first;

architecture read_through of regfile_core is
  type mem_type is array ((2**AW-1) downto 0) of std_logic_vector(DW-1 downto 0);
  signal ram_name : mem_type := (others => (others => '0'));
  signal read_raddr : std_logic_vector(AW-1 downto 0);
begin

  process (clock)
  begin
    if (clock'EVENT and clock = '1') then
      if (enable = '1') then
        if (we = '1') then
          ram_name(conv_integer(waddr)) <= input_data;
        end if;
        read_raddr <= raddr;
      end if;
    end if;
  end process;
  ram_output <= ram_name(conv_integer(read_raddr));
end read_through;
