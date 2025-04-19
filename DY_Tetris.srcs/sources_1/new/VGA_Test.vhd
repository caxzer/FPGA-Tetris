library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Test is
    Port (
        clk      : in  STD_LOGIC;  -- 25 MHz clock
        hsync    : out STD_LOGIC;
        vsync    : out STD_LOGIC;
        red      : out STD_LOGIC_VECTOR(3 downto 0);
        green    : out STD_LOGIC_VECTOR(3 downto 0);
        blue     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end VGA_Test;

architecture Behavioral of VGA_Test is

    constant H_VISIBLE  : integer := 640;
    constant H_FRONT    : integer := 16;
    constant H_SYNC     : integer := 96;
    constant H_BACK     : integer := 48;
    constant H_TOTAL    : integer := H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    constant V_VISIBLE  : integer := 480;
    constant V_FRONT    : integer := 10;
    constant V_SYNC     : integer := 2;
    constant V_BACK     : integer := 33;
    constant V_TOTAL    : integer := V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    signal h_count : integer range 0 to H_TOTAL - 1 := 0;
    signal v_count : integer range 0 to V_TOTAL - 1 := 0;

    signal video_on : STD_LOGIC;

begin
    -- Horizontal and vertical counters
    process(clk)
begin
        if rising_edge(clk) then
            if h_count = H_TOTAL - 1 then
                h_count <= 0;
                if v_count = V_TOTAL - 1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- Sync signals
    hsync <= '0' when (h_count >= (H_VISIBLE + H_FRONT) and h_count < (H_VISIBLE + H_FRONT + H_SYNC)) else '1';
    vsync <= '0' when (v_count >= (V_VISIBLE + V_FRONT) and v_count < (V_VISIBLE + V_FRONT + V_SYNC)) else '1';

    video_on <= '1' when (h_count < H_VISIBLE and v_count < V_VISIBLE) else '0';

    -- Color output: rainbow gradient based on horizontal pixel position
    process(clk)
    begin
        if rising_edge(clk) then
            if video_on = '1' then
                red   <= std_logic_vector(to_unsigned((h_count / 80) mod 16, 4));
                green <= std_logic_vector(to_unsigned((h_count / 40) mod 16, 4));
                blue  <= std_logic_vector(to_unsigned((h_count / 20) mod 16, 4));
            else
                red   <= (others => '0');
                green <= (others => '0');
                blue  <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;