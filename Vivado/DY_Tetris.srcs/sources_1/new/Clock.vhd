library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
                counter <= (others => '0');
            end if;
        end if;
    end process;

    clk <= clk_reg;

end Behavioral;
