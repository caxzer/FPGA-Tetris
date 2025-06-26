library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scoreboard is
    Port (
        clk : in std_logic;
        reset: in std_logic;
        score: in std_logic_vector(7 downto 0); -- max 255
        seg: out std_logic_vector (6 downto 0);
        digit_on: out std_logic_vector (3 downto 0)
    );
end Scoreboard;

architecture Behavioral of Scoreboard is
    signal digit1, digit2, digit3 : std_logic_vector(3 downto 0);
    signal mux : unsigned (1 downto 0) := (others => '0') ;
    signal mux_cnt : unsigned(16 downto 0) := (others => '0'); --big enough for div 
    constant MUX_DIV : integer := 25170; 
begin
    -- score to digits
    process(score)
        variable score_int : integer;   
    begin   -- integer division here!
        score_int := to_integer(unsigned(score));
        digit1 <= std_logic_vector(to_unsigned(score_int/100,4));
        digit2 <= std_logic_vector(to_unsigned((score_int mod 100)/10,4));
        digit3 <= std_logic_vector(to_unsigned(score_int mod 10,4));
    end process;
    
    -- multiplexing clock divider
    process(clk, reset)
    begin
        if reset = '1' then
            mux_cnt <= (others => '0');
            mux <= (others => '0');
        elsif rising_edge(clk) then
            if mux_cnt = MUX_DIV - 1 then
                mux_cnt <= (others => '0');
                mux <= mux + 1;
            else
                mux_cnt <= mux_cnt + 1;
            end if;
        end if;
    end process;
    
    -- displaying the digits
    process(mux, digit1, digit2, digit3, reset)
    variable thisDigit : std_logic_vector(3 downto 0);
    begin
        if reset = '1' then
            seg <= "0000000";
            digit_on <= "1111"; -- off all digits
        else
            case mux is
                when "00" =>
                    digit_on <= "1110"; -- rightmost digit ON (ones)
                    thisDigit := digit3; 
                when "01" =>
                    digit_on <= "1101"; -- 2nd digit from right ON (tens)
                    thisDigit := digit2;
                when "10" =>
                    digit_on <= "1011"; -- 3rd digit from right ON (hundreds)
                    thisDigit := digit1;
                when others =>
                    digit_on <= "1111"; -- leftmost digit OFF (blank)
                    thisDigit := "1111"; -- blank
            end case;
            
            case thisDigit is   --"gfedcba", active-low
                when "0000" => seg <= "1000000"; -- 0
                when "0001" => seg <= "1111001"; -- 1
                when "0010" => seg <= "0100100"; -- 2 
                when "0011" => seg <= "0110000"; -- 3
                when "0100" => seg <= "0011001"; -- 4
                when "0101" => seg <= "0010010"; -- 5
                when "0110" => seg <= "0000010"; -- 6
                when "0111" => seg <= "1111000"; -- 7
                when "1000" => seg <= "0000000"; -- 8
                when "1001" => seg <= "0010000"; -- 9
                when others => seg <= "1111111"; -- blank
            end case;
        end if;
    end process;
    
end Behavioral;
