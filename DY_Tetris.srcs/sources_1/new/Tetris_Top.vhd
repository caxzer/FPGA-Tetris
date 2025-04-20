----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 12:53:18 PM
-- Design Name: 
-- Module Name: Tetris_Top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity Tetris_Top is
--  Port ( );
    Port (
        clk     : in std_logic;     -- 40MHz
        reset   : in std_logic;
        red     : out std_logic_vector(3 downto 0); -- 12 bits per pixel
        green   : out std_logic_vector(3 downto 0);
        blue    : out std_logic_vector(3 downto 0)
    );
        
end Tetris_Top;

architecture Behavioral of Tetris_Top is
    -- Signals
    
    
    
begin


end Behavioral;
