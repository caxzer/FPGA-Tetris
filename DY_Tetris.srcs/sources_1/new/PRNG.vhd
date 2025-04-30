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


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PRNG is
Port (
    clk : in std_logic;
    reset : in std_logic;
    tetrimino_piece : out std_logic_vector(2 downto 0)
 );
end PRNG;

architecture Behavioral of PRNG is
signal counter    : std_logic_vector (7 downto 0) := (others => '0');  --8 bit counter
signal set_seed : bit := '1';
signal current_seed : std_logic_vector (7 downto 0) := (others => '0');  
signal tetrimino_reg : std_logic_vector (2 downto 0):= (others => '0');

begin

-- 
process(clk)
begin
    if rising_edge(clk) then
        counter <= counter + 1; -- unsigned arithmetric operation
    end if;
end process;

process(clk,reset)
begin
    if reset = '1' then
        set_seed <= '1';
    elsif rising_edge(clk) then
        if set_seed = '1' then
            current_seed <= counter;
            set_seed<= '0';
        else
            --bit mask LSB : 3 bits
            tetrimino_reg <= tetrimino_reg(2 downto 0) & (current_seed(0) xor current_seed(2) xor current_seed(3) xor current_seed(5));
        end if;
    end if;
    tetrimino_piece <= tetrimino_reg;
end process;


end Behavioral;
