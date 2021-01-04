-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity fir_tb is
end;

architecture bench of fir_tb is

  component fir
   Port ( 
   clk: in std_logic;
   data_in: in unsigned(7 downto 0);
   data_out: out unsigned(7 downto 0);
   en: in std_logic;
   load: in std_logic;
   start: in std_logic;
   reset: in std_logic
   );
  end component;

  signal clk: std_logic;
  signal data_in: unsigned(7 downto 0);
  signal data_out: unsigned(7 downto 0);
  signal en: std_logic;
  signal load: std_logic;
  signal start: std_logic;
  signal reset: std_logic ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: fir port map ( clk      => clk,
                      data_in  => data_in,
                      data_out => data_out,
                      en       => en,
                      load     => load,
                      start    => start,
                      reset    => reset );

  stimulus: process
  begin
  
    -- Put initialisation code here

    reset <= '1';
    en <= '1';
    load <= '0';
    start <= '0';
    data_in <= (others => '0');        
    wait for 5 ns;
    reset <= '0';
    wait for 10 ns;
    
    -- Put test bench stimulus code here
    load <= '1';
    wait for 10 ns;
    data_in <= "00000001";
    wait for 10 ns;
    data_in <= "00000010";
    wait for 10 ns;
    data_in <= "00000100";
    wait for 10 ns;
    data_in <= "00001000";
    wait for 10 ns;
    data_in <= "00010000";
    wait for 10 ns;
    data_in <= "00100000";
    wait for 10 ns;
    data_in <= "01000000";
    wait for 10 ns;
    data_in <= "10000000";
    wait for 10 ns;
    load <= '0';
    
    wait for 10 ns;
    start <= '1';
    wait for 100 ns;
    
    reset <= '1';
    wait for 5 ns;
    reset <= '0';
    wait for 30 ns;
    
    

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  