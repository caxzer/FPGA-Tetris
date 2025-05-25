library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Testbench is

end Testbench;

architecture sim of Testbench is

    -- Component under test (DUT)
    component VGA_Test is
        Port (
            clk    : in  STD_LOGIC;
            hsync  : out STD_LOGIC;
            vsync  : out STD_LOGIC;
            red    : out STD_LOGIC_VECTOR(3 downto 0);
            green  : out STD_LOGIC_VECTOR(3 downto 0);
            blue   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Signals
    signal clk     : STD_LOGIC := '0';
    signal hsync   : STD_LOGIC;
    signal vsync   : STD_LOGIC;
    signal red     : STD_LOGIC_VECTOR(3 downto 0);
    signal green   : STD_LOGIC_VECTOR(3 downto 0);
    signal blue    : STD_LOGIC_VECTOR(3 downto 0);

    -- Clock period
    constant clk_period : time := 40 ns;  -- 25 MHz

begin

    -- Instantiate the VGA controller
    DUT: VGA_Test
        port map (
            clk    => clk,
            hsync  => hsync,
            vsync  => vsync,
            red    => red,
            green  => green,
            blue   => blue
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 1 ms loop  -- simulate for 1 millisecond
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Monitoring output (optional text output)
    monitor_proc : process(clk)
    begin
        if rising_edge(clk) then
            report "Time: " & time'image(now) &
                   " | HSYNC=" & std_logic'image(hsync) &
                   " | VSYNC=" & std_logic'image(vsync) &
                   " | R=" & integer'image(to_integer(unsigned(red))) &
                   " G=" & integer'image(to_integer(unsigned(green))) &
                   " B=" & integer'image(to_integer(unsigned(blue)));
        end if;
    end process;
    end sim;