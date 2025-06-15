----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2025 09:30:20 PM
-- Design Name: 
-- Module Name: Clock - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Clock is
    Port ( 
        clk100 : in std_logic;
        reset: in std_logic;
        clk:out std_logic
    );
end Clock;

architecture Behavioral of Clock is
    signal counter : unsigned(1 downto 0) := (others => '0');
    signal clk_reg : std_logic := '0';
begin
    process(clk100, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            clk_reg <= '0';
        elsif rising_edge(clk100) then
            counter <= counter + 1;
            if counter = "11" then    -- every 4th clock edge
                clk_reg <= not clk_reg;
            end if;
        end if;
    end process;

    clk <= clk_reg;

end Behavioral;
