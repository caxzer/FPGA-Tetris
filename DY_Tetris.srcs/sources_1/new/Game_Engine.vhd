----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 01:30:27 PM
-- Design Name: 
-- Module Name: Game_Engine - Behavioral
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

entity Game_Engine is
--  Port ( );
    Port(
        clk : in std_logic;
        tick : in std_logic;
        block_x : in integer range 0 to 19;
        block_y : in integer range 0 to 19;
        block_color  : in std_logic_vector(3 downto 0)
        --field_x : out integer range 0 to 200;
        --field_y : out integer range 0 to 200 
        
    );
end Game_Engine;

architecture Behavioral of Game_Engine is
           
end Behavioral;
