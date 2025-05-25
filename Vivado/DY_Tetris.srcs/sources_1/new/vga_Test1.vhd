library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Top is
    Port (
        clk        : in  std_logic;          -- 100 MHz onboard clock (Basys3)
        reset  : in  std_logic;          -- active-high button
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
    --signal clk_div      : std_logic_vector(1 downto 0) := (others => '0');

    -- VGA signals
    signal pixel_x      : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y      : std_logic_vector(8 downto 0) := (others => '0');
    signal disp_ena     : std_logic;
    --signal reset_n      : std_logic;
    
    signal field : std_logic_vector(200 downto 1) := (others => '1');    
    
    component clk_wiz_0
        Port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic;   -- 40 Mhz
            locked   : out std_logic
        );
    end component;
    
    component VGA_Controller
        Port(
            pixel_clk   : in  std_logic;  -- 40 MHz clock (not bit because of rising edge)
            reset     : in std_logic;      -- manual reset, logic in top
            hsync       : out std_logic;
            vsync       : out std_logic;
            pixel_x     : out std_logic_vector (9 downto 0);      --horizontal pixel coordinates (1024 but only 640 needed)
            pixel_y     : out std_logic_vector (8 downto 0);      --vertical pixel coordinate (512 but only 480 needed)
            disp_ena    : out std_logic
        );
    end component;
    
    component Video_Renderer
        Port(
            clk   : in std_logic;
            reset : in std_logic;
            field : in std_logic_vector(200 downto 1);  -- game field
            pixel_x : in std_logic_vector(9 downto 0);  -- screen pixel coordinates
            pixel_y : in std_logic_vector(8 downto 0);  -- 
            disp_ena  : in std_logic;
            red  : out std_logic_vector(3 downto 0);
            green: out std_logic_vector(3 downto 0);
            blue : out std_logic_vector(3 downto 0)
        );
    end component;
    
begin

    -- Generate 25MHz pixel clock from 100MHz input
    clk_inst : clk_wiz_0
        port map (
            clk_in1  => clk,
            reset    => reset,
           clk_out1 => clk25
--            locked   => clk_locked
        );

    --reset_n <= not reset_btn;  -- active-low reset

    -- Instantiate VGA Controller
    vga_inst : entity work.VGA_Controller
        port map (
            pixel_clk => clk25,
            reset   => reset,
            hsync     => hsync,
            vsync     => vsync,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            disp_ena  => disp_ena
        );
        
    v_renderer_inst : entity work.Video_Renderer
        port map(
            clk         => clk25,
            reset       => reset,
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
