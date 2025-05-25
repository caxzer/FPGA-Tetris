----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2025 05:44:02 PM
-- Design Name: 
-- Module Name: Tick_Counter - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tick_Counter is
    Port (
        clk : in  std_logic;
        reset: in  std_logic;
        tick: out std_logic
    );
end Tick_Counter;

architecture Behavioral of Tick_Counter is
    constant TICK_MAX : integer := 25170070;  -- 25.17007 MHz
    signal counter    : integer range 0 to TICK_MAX := 0;
    signal tick_reg   : std_logic := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter   <= 0;
            tick_reg  <= '0';
        elsif rising_edge(clk) then
            if counter = TICK_MAX - 1 then
                counter  <= 0;
                tick_reg <= '1';
            else
                counter  <= counter + 1; 
                tick_reg <= '0';
            end if;
        end if;
    end process;

    tick <= tick_reg;

end Behavioral;
