library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Top is
    Port (
        clk        : in  std_logic;          -- 100 MHz onboard clock (Basys3)
        reset_btn  : in  std_logic;          -- active-high button
        hsync      : out std_logic;
        vsync      : out std_logic;
        vga_red    : out std_logic_vector(3 downto 0);
        vga_green  : out std_logic_vector(3 downto 0);
        vga_blue   : out std_logic_vector(3 downto 0)
    );
end VGA_Top;

architecture Behavioral of VGA_Top is

    -- Clock divider: divide 100MHz to 25MHz
    signal clk25        : std_logic := '0';
    signal clk_div      : std_logic_vector(1 downto 0) := (others => '0');

    -- VGA signals
    signal pixel_x      : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y      : std_logic_vector(8 downto 0) := (others => '0');
    signal disp_ena     : std_logic;
    signal reset_n      : std_logic;
    
    signal field : std_logic_vector(200 downto 1) := (others => '1');    
begin

    -- Generate 25MHz pixel clock from 100MHz input
    process(clk)
    begin
        if rising_edge(clk) then
            clk_div <= std_logic_vector(unsigned(clk_div) + 1);
            clk25 <= clk_div(1);  -- divide by 4: 100MHz / 4 = 25MHz
        end if;
    end process;

    reset_n <= not reset_btn;  -- active-low reset

    -- Instantiate VGA Controller
    vga_inst : entity work.VGA_Controller
        port map (
            pixel_clk => clk25,
            reset_n   => reset_n,
            hsync     => hsync,
            vsync     => vsync,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            disp_ena  => disp_ena
        );
        
    v_renderer_inst : entity work.Video_Renderer
        port map(
            clk         => clk25,
            reset       => reset_n,
            field       => field,
            pixel_x     => pixel_x,
            pixel_y     => pixel_y,
            disp_ena    => disp_ena,
            
            -- output for color
            red         => vga_red,
            green       => vga_green,
            blue        => vga_blue
        );

end Behavioral;
