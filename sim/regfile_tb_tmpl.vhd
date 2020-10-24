--------------------------------------------------------------------------------
-- Filename: regfile_tb_tmpl.vhd
-- Purpose : Generic testbench for testing a multi-port register file.
-- Author  : Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com> 2007-2020
-- Date    : 24-Oct-2020
-- Version : 1.0.2
-- Revision: 1.0.2 (2020/10/24)
--           Use IEEE.numeric_std.
--           1.0.0 (2013/01/11)
--           Stable version.
-- License : Copyright (C) 2007-2020 Nikolaos Kavvadias
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regfile_tb is
  generic (
    NWP : integer :=  1;
    NRP : integer :=  2;
    AW  : integer :=  4;
    DW  : integer :=  8
  );
end regfile_tb;

architecture tb_arch of regfile_tb is
  component regfile
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
	end component;
  -- 
  signal clock        : std_logic;
  signal reset        : std_logic;
  signal enable       : std_logic;
  signal we_v         : std_logic_vector(NWP-1 downto 0);
  signal re_v         : std_logic_vector(NRP-1 downto 0);
  signal waddr_v      : std_logic_vector(NWP*AW-1 downto 0);
  signal raddr_v      : std_logic_vector(NRP*AW-1 downto 0);
  signal input_data_v : std_logic_vector(NWP*DW-1 downto 0);
  signal ram_output_v : std_logic_vector(NRP*DW-1 downto 0);
  --
  constant CLK_PERIOD : time := 10 ns;
  --
begin

  -- Unit Under Test port map
  regfile_uut : regfile
    generic map (
      NWP => NWP,
      NRP => NRP,
      AW  => AW,
      DW  => DW
    )
    port map (
    clock        => clock,
    reset        => reset,
    enable       => enable,
    we_v         => we_v,
    re_v         => re_v,
    waddr_v      => waddr_v,
    raddr_v      => raddr_v,
    input_data_v => input_data_v,
    ram_output_v => ram_output_v
);

  CLK_GEN_PROC: process(clock)
  begin
    if (clock = 'U') then 
      clock <= '1'; 
    else 
      clock <= not clock after CLK_PERIOD/2; 
    end if;
  end process CLK_GEN_PROC;
	
  DATA_INPUT: process
  begin
    enable <= '0';
    reset <= '0';
    we_v <= std_logic_vector(to_unsigned(0, NWP));
    re_v <= (others => '1');
    waddr_v <= std_logic_vector(to_unsigned(0, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(0, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(222, NWP*DW));
    wait for CLK_PERIOD;
    enable <= '1';
    reset <= '1';
    we_v <= std_logic_vector(to_unsigned(0, NWP));
    waddr_v <= std_logic_vector(to_unsigned(0, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(0, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(222, NWP*DW));
    wait for CLK_PERIOD;
    reset <= '0';
    we_v <= std_logic_vector(to_unsigned(0, NWP));
    waddr_v <= std_logic_vector(to_unsigned(0, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(0, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(222, NWP*DW));
    wait for CLK_PERIOD;
    we_v <= std_logic_vector(to_unsigned(1, NWP));
    waddr_v <= std_logic_vector(to_unsigned(0, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(0, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(222, NWP*DW));
    wait for CLK_PERIOD;
    we_v <= std_logic_vector(to_unsigned(1, NWP));
    waddr_v <= std_logic_vector(to_unsigned(1, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(1, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(173, NWP*DW));
    wait for CLK_PERIOD;
    we_v <= std_logic_vector(to_unsigned(1, NWP));
    waddr_v <= std_logic_vector(to_unsigned(3, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(4, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(190, NWP*DW));
    wait for CLK_PERIOD;
    we_v <= std_logic_vector(to_unsigned(1, NWP));
    waddr_v <= std_logic_vector(to_unsigned(5, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(7, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(239, NWP*DW));
    wait for CLK_PERIOD;
    we_v <= std_logic_vector(to_unsigned(0, NWP));
    waddr_v <= std_logic_vector(to_unsigned(6, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(7, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(85, NWP*DW));
    wait for CLK_PERIOD;
    we_v <= std_logic_vector(to_unsigned(0, NWP));
    waddr_v <= std_logic_vector(to_unsigned(9, NWP*AW));
    raddr_v <= std_logic_vector(to_unsigned(15, NRP*AW));
    input_data_v <= std_logic_vector(to_unsigned(170, NWP*DW));
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
  end process DATA_INPUT;

end tb_arch;
