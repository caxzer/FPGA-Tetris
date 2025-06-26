library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Tetris_Top is
end tb_Tetris_Top;

architecture Behavioral of tb_Tetris_Top is
    -- DUT ports
    signal clk100     : std_logic := '0';
    signal re_set     : std_logic := '1'; -- active low reset
    signal btnC       : std_logic := '0';
    signal btnU       : std_logic := '0';
    signal btnL       : std_logic := '0';
    signal btnR       : std_logic := '0';
    signal btnD       : std_logic := '0';
    signal vga_Red    : std_logic_vector(3 downto 0);
    signal vga_Blue   : std_logic_vector(3 downto 0);
    signal vga_Green  : std_logic_vector(3 downto 0);
    signal hsync      : std_logic;
    signal vsync      : std_logic;

begin

    -- DUT instantiation
    uut: entity work.Tetris_Top
        port map (
            clk100     => clk100,
            re_set     => re_set,
            btnC       => btnC,
            btnU       => btnU,
            btnL       => btnL,
            btnR       => btnR,
            btnD       => btnD,
            vga_Red    => vga_Red,
            vga_Blue   => vga_Blue,
            vga_Green  => vga_Green,
            hsync      => hsync,
            vsync      => vsync
        );

    -- Clock generation: 100 MHz (period = 10 ns)
    clk100_process : process
    begin
        while true loop
            clk100 <= '0';
            wait for 5 ns;
            clk100 <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- initial reset
        re_set <= '0';
        wait for 80 ns;
        re_set <= '1';

        -- wait for a while, then simulate button presses
        wait for 10000 ms;

        -- finish simulation
        assert false report "End of Simulation" severity failure;
    end process;

end Behavioral;
