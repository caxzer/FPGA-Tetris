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
    signal counter    : unsigned (7 downto 0) := (others => '0');  --8 bit counter
    signal tetrimino_reg : std_logic_vector (7 downto 0) := X"5A"; -- hex nonzero seed
    --signal random_val: unsigned(2 downto 0);
    signal mapped_result : std_logic_vector (2 downto 0):= "110";
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1; -- unsigned arithmetric operation, will wrap around
        end if;
    end process;
    
    process(clk, reset)
    begin
        if reset = '1' then
            tetrimino_reg <= std_logic_vector(unsigned(tetrimino_reg) xor unsigned(counter(7 downto 0)));  -- seed from counter
        elsif rising_edge(clk) then
            -- 8,6,5,4 taps for maximal period
            tetrimino_reg <= tetrimino_reg(6 downto 0) & (tetrimino_reg(7) xor tetrimino_reg(5) xor tetrimino_reg(4) xor tetrimino_reg(3));
        end if;
    end process;
    
    -- 7 available blocks but 8 possible numbers...
    mapped_result <= (tetrimino_reg(5) xor tetrimino_reg(2)) &
                 (tetrimino_reg(4) xor tetrimino_reg(1)) &
                 (tetrimino_reg(3) xor tetrimino_reg(0));
    tetrimino_piece <= mapped_result when mapped_result < 7 else "001"; -- If 7 (out of bounds, but rare to happen), use 1  line block
    
end Behavioral;
