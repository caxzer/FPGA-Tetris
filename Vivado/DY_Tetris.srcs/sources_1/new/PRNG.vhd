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
    signal counter    : unsigned (7 downto 0) := "11001110";  --8 bit counter
    signal tetrimino_reg : std_logic_vector (7 downto 0) := "01011000";
    signal last_valid : std_logic_vector (2 downto 0);
    signal mapped_result : std_logic_vector (2 downto 0):= "110";
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1; -- unsigned arithmetric operation, will wrap around
        end if;
    end process;
    
    process(clk, reset)
        variable next_tetrimino : std_logic_vector(7 downto 0);
        variable next_result : std_logic_vector(2 downto 0);
    begin
        if reset = '1' then
            tetrimino_reg <= std_logic_vector(unsigned(tetrimino_reg) xor unsigned(counter(7 downto 0)));  -- seed from counter
            last_valid <= "001";
        elsif rising_edge(clk) then
            -- 8,6,5,4 taps for maximal period
            next_tetrimino := tetrimino_reg(6 downto 0) & (tetrimino_reg(7) xor tetrimino_reg(3) xor tetrimino_reg(2) xor tetrimino_reg(0));
            tetrimino_reg <= next_tetrimino;
            
            next_result := (next_tetrimino(5) xor next_tetrimino(2)) &
                 (next_tetrimino(4) xor next_tetrimino(1)) &
                 (next_tetrimino(3) xor next_tetrimino(0));
            mapped_result <= next_result;
            -- accept only 0-6         
            if unsigned(next_result) < 7 then
                last_valid <= next_result;
            end if;
        end if;        
    end process;
    
    tetrimino_piece <= mapped_result when unsigned(mapped_result) < 7 else last_valid; -- If 7 (out of bounds, but rare to happen), use 1  line block
    
end Behavioral;
