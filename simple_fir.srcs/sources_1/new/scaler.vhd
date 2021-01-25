----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2021 19:09:57
-- Design Name: 
-- Module Name: scaler - basic
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
use IEEE.math_real.all;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scaler is
    generic (
        INPUT_RESOLUTION : integer := 8;
        OUTPUT_RESOLUTION : integer := 8;
        DIVISION_FACTOR : std_logic_vector
        );
    Port ( 
        data_in : in signed(INPUT_RESOLUTION-1 downto 0);
        data_out : out signed(OUTPUT_RESOLUTION-1 downto 0)
    );
end scaler;

architecture basic of scaler is

begin

data_out <= RESIZE(data_in/signed(DIVISION_FACTOR),OUTPUT_RESOLUTION);

end basic;
