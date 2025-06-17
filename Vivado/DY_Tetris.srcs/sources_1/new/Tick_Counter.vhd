library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tick_Counter is
    Port (
        clk : in  std_logic;
        reset: in  std_logic;
        c_reset: in std_logic;
        counter_vector : out std_logic_vector (7 downto 0) --8-bit output
    );
end Tick_Counter;

architecture Behavioral of Tick_Counter is
    constant TICK_MAX : integer := 1258504;  -- 25.17007 MHz * 50ms/1000ms
    --constant TICK_MAX : integer := 10000;-- debug
    signal int_counter : integer range 0 to TICK_MAX := 0;
    signal count : unsigned(7 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' or c_reset = '1' then
            int_counter <= 0;
            count   <= (others => '0');
        elsif rising_edge(clk) then
            if int_counter = TICK_MAX - 1 then  --increase output counter_vector every 50ms (scalable)
                int_counter <= 0;
                count       <= count + 1;
            else
                int_counter <= int_counter + 1;
            end if;
        end if;
    end process;

    counter_vector <= std_logic_vector(count);

end Behavioral;
