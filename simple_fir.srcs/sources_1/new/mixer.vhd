----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.01.2021 16:38:48
-- Design Name: 
-- Module Name: mixer - basic
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


entity mixer is
    Generic ( INPUT_RESOLUTION : integer := 15;
              OUTPUT_RESOLUTION : integer := 29);

    Port ( data_in : in signed(INPUT_RESOLUTION-1 downto 0);
           ref_in : in signed(INPUT_RESOLUTION-1 downto 0);
           data_out : out signed(OUTPUT_RESOLUTION-1 downto 0) );
end mixer;

architecture basic of mixer is

constant max_res: integer := (INPUT_RESOLUTION*2)-1;

signal data_processed : signed(max_res downto 0);

begin

    data_processed <= data_in * ref_in;
    data_out <= data_processed(OUTPUT_RESOLUTION-1 downto 0);

end basic;
