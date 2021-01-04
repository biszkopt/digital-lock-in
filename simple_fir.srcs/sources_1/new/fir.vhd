----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.01.2021 20:01:40
-- Design Name: 
-- Module Name: fir - Behavioral
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
entity fir is
 Port ( 
 clk: in std_logic;
 data_in: in unsigned(7 downto 0);
 data_out: out unsigned(7 downto 0);
 en: in std_logic;
 load: in std_logic;
 start: in std_logic;
 reset: in std_logic
 
 );
end fir;

architecture Behavioral of fir is

-- type coeff_array is array (0 to 7) of integer range 0 to 255;
constant reg_size: integer := 8;
type samples_reg is array (0 to reg_size-1) of unsigned(7 downto 0);

begin

process(clk, reset)
     
    -- variable coeffs: coeff_array := (0,0,0,0,0,0,0,0);
    --variable b0: unsigned(7 downto 0) := 8D"0";
    variable b0: unsigned(7 downto 0) := to_unsigned(0,8);
    variable b1: unsigned(7 downto 0) := to_unsigned(0,8);
    variable b2: unsigned(7 downto 0) := to_unsigned(0,8);
    variable samples: samples_reg := (others => (others => '0'));
    variable i: integer range 0 to reg_size := 0;
    -- variable reg_element:
    
    
    -- signal s1 : signed(47 downto 0) := 48D"46137344123";
    
    
    begin
    
    -- zero the counter
    if load = '0' and start = '0' then
        i := 0;
    end if;    
    
    
    if reset = '1' then
        data_out <= (others => '0');
        samples := (others => (others => '0'));
        i := 0;            

    -- synch part
    elsif rising_edge(clk) and en = '1' then
    

    
        -- loading data
        if load = '1' then
            samples(i) := data_in;
            
            i := i+1;
        end if;                      
        
        -- deloading data
        if start = '1' then
            data_out <= samples(i);
            i := i+1;     
        end if;
            
        -- reset counter
        if(i = reg_size) then
            i := 0;
        end if;    
                    
    end if;
    
 end process;


end Behavioral;
