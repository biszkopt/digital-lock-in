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
-- use IEEE.std_logic_arith.all;

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
 start: in std_logic;
 reset: in std_logic
 );
end fir;

architecture Behavioral of fir is

-- type coeff_array is array (0 to 7) of integer range 0 to 255;
-- constant reg_size: integer := 8;
constant filter_order: integer := 7;

type samples_reg is array (0 to filter_order) of unsigned(7 downto 0);
type coeffs_reg is array (0 to filter_order) of unsigned(7 downto 0);


begin

process(clk, reset)
     
    -- variable coeffs: coeff_array := (0,0,0,0,0,0,0,0);
    --variable b0: unsigned(7 downto 0) := 8D"0";
    variable b0: unsigned(7 downto 0) := to_unsigned(1,8);
    variable b1: unsigned(7 downto 0) := to_unsigned(2,8);
    variable b2: unsigned(7 downto 0) := to_unsigned(3,8);
    variable b3: unsigned(7 downto 0) := to_unsigned(4,8);
    variable b4: unsigned(7 downto 0) := to_unsigned(5,8);
    variable b5: unsigned(7 downto 0) := to_unsigned(6,8);
    variable b6: unsigned(7 downto 0) := to_unsigned(7,8);
    variable b7: unsigned(7 downto 0) := to_unsigned(8,8);
    
    --variable i: integer range 0 to filter_order := 0;
    --variable j: integer range 0 to filter_order := 0;
    
    variable samples: samples_reg := (others => (others => '0'));
    variable coeffs: coeffs_reg := (b0,b1,b2,b3,b4,b5,b6,b7);
    
    variable data_processed: unsigned(15 downto 0) := (others => '0');
    
       
    
    
    -- variable reg_element:
    
    -- signal s1 : signed(47 downto 0) := 48D"46137344123";
    
    begin    
    
    if reset = '1' then
         data_out <= (others => '0');
         samples := (others => (others => '0'));
         data_processed := (others => '0');
            

    -- synch part
    elsif rising_edge(clk) then
        if en = '1' then
        
            if start = '1' then
            
                -- draw sample in new cycle
                samples(0) := data_in;
                
                -- this has to be cleaned before new cycle or it'll add to previous filter output
                data_processed := (others => '0');
                
                -- actual FIR part
                for j in 0 to filter_order loop
                    data_processed := data_processed + samples(j)*coeffs(j);
                end loop;
                
                -- output truncated data
                data_out <= data_processed(7 downto 0);
                
                -- shifting sample registers
                for i in filter_order downto 1 loop
                    samples(i) := samples(i-1);
                end loop;
                
            else
                samples := samples;
                data_out <= (others => '0');
            end if;
            
        end if;
    end if;
    
 end process;


end Behavioral;
