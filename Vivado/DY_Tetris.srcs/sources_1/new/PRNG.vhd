----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2025 12:44:52 PM
-- Design Name: Pseudorandom Number Generator
-- Module Name: PRNG - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PRNG is
Port (
    clk : in std_logic;
    reset : in std_logic;
    tetrimino_piece : out std_logic_vector(2 downto 0)
 );
end PRNG;

architecture Behavioral of PRNG is
signal counter    : unsigned (25 downto 0) := (others => '0');  --26 bit counter
signal tetrimino_reg : std_logic_vector (2 downto 0):= (others => '0');
signal feedback_bit : std_logic := '0';

begin
 tetrimino_piece <= tetrimino_reg; 
 
process(clk)
begin
    if rising_edge(clk) then
        counter <= counter + 1; -- unsigned arithmetric operation, will wrap around
    end if;
end process;

process(clk,reset)
begin
    if reset = '1' then
        tetrimino_reg <= std_logic_vector(counter(2 downto 0));
    elsif rising_edge(clk) then
       feedback_bit <= tetrimino_reg(2) xor counter(0);
       tetrimino_reg <= tetrimino_reg(1 downto 0) & feedback_bit;
    end if;
   
end process;

end Behavioral;
