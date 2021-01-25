----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2021 21:20:21
-- Design Name: 
-- Module Name: phase_shifter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity phase_shifter is
    Generic (   INPUT_RESOLUTION : integer     := 8;
                SAMPLES_DELAY : integer        := 1);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           data_in : in signed(INPUT_RESOLUTION - 1 downto 0);
           data_out : out signed(INPUT_RESOLUTION - 1 downto 0));
end phase_shifter;

architecture basic of phase_shifter is

type DELAY_REG is array (0 to SAMPLES_DELAY) of signed(INPUT_RESOLUTION - 1 downto 0);

begin

process(clk, reset)

    variable delay_register : DELAY_REG := (others => (others => '0'));

begin
    if reset = '1' then
    
        delay_register := (others => (others => '0'));
        data_out <= (others => '0');

    elsif rising_edge(clk) then
        
        delay_register(0) := data_in; 
    
        for i in SAMPLES_DELAY downto 1 loop
            delay_register(i) := delay_register(i-1);
        end loop;
        
        data_out <= delay_register(SAMPLES_DELAY);
    
    else
    
        delay_register := delay_register;
        
    end if;
end process;

end basic;
