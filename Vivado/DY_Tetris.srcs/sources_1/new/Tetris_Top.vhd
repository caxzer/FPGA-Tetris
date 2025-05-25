----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 12:53:18 PM
-- Design Name: 
-- Module Name: Tetris_Top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tetris_Top is
--  Port ( );
    Port (
        clk     : in std_logic;     --100Mhz Input from BASYS
        reset   : in std_logic;     
        vgaRed  : out std_logic_vector (3 downto 0);
        vgaBlue : out std_logic_vector (3 downto 0);
        vgaGreen: out std_logic_vector (3 downto 0);
        hsync   : out std_logic;
        vsync   : out std_logic
    );
        
end Tetris_Top;

architecture Behavioral of Tetris_Top is
    -- Signals for 40Mhz clocking wizard
    signal clk_25mhz   : std_logic;
    signal clk_locked  : std_logic; -- only run game is clk_locked is high
    
    -- Signals for Game speed ticks
    signal clk_gametick : std_logic;
    
    -- Signals for VGA 
    signal pixel_x: std_logic_vector(9 downto 0);
    signal pixel_y: std_logic_vector(8 downto 0);
    signal disp_ena: std_logic;
    --signal red, green, blue: std_logic_vector(3 downto 0);
    --signal h_sync,v_sync: std_logic;
    
    --Signals for controls
    signal move_left, move_right, pull_drop: std_logic ;
    signal next_step : bit_vector (3 downto 0);
    
    signal field: std_logic_vector(200 downto 1);  -- game field
    signal tetrimino_piece : std_logic_vector(2 downto 0);
    
    -- Component declarations
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
--            clk   : in std_logic;
--            reset : in std_logic;
            field : in std_logic_vector(200 downto 1);  -- game field
            pixel_x : in std_logic_vector(9 downto 0);  -- screen pixel coordinates
            pixel_y : in std_logic_vector(8 downto 0);  -- 
            disp_ena  : in std_logic;
            red  : out std_logic_vector(3 downto 0);
            green: out std_logic_vector(3 downto 0);
            blue : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component Game_Engine
        Port(
            clk : in std_logic;
            tick: in std_logic;
            move_left: in std_logic;
            move_right: in std_logic;
            pull_drop: in std_logic;
            reset: in std_logic;
            next_step: out bit_vector(3 downto 0)
        );
    end component;
    
    component Field_RAM
        Port(
            clk         : in std_logic;
            reset       : in std_logic;
            clk_gametick: in std_logic;
            next_step       : in bit_vector (3 downto 0);
            tetrimino_piece : in std_logic_vector (2 downto 0);
            field_out: out std_logic_vector(200 downto 1) ;
            field_in : in std_logic_vector(200 downto 1)  
        );
    end component;
    
    component PRNG
        Port(
            clk : in std_logic;
            reset : in std_logic;
            tetrimino_piece : out std_logic_vector(2 downto 0)
        );
    end component;
    
begin
    -- Instantiate clocking wizard
    clk_gen_inst : clk_wiz_0
        port map (
            clk_in1  => clk,
            reset    => reset,
            clk_out1 => clk_25mhz,
            locked   => clk_locked
        );
        
    -- need module to control gametick of 0,5 secs
    
    vga: VGA_Controller
        port map(
            pixel_clk => clk_25mhz,
            reset => reset,
            hsync => hsync,
            vsync => vsync,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            disp_ena => disp_ena
        );
     
    renderer: Video_Renderer
        port map(
--            clk => clk_25mhz,
--            reset => reset,
            field => field,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            red => vgaRed,
            green => vgaGreen,
            blue => vgaBlue,
            disp_ena => disp_ena
        );
    game_logic : Game_Engine
        port map(
            clk => clk_25mhz,
            reset => reset,
            tick => clk_gametick,
            move_left => move_left,
            move_right => move_right,
            pull_drop => pull_drop,
            --field => field,
            next_step => next_step
        );
        
    ram : Field_RAM
        port map(
            clk=> clk_25mhz,
            reset => reset,
            clk_gametick => clk_gametick,
            next_step => next_step,
            tetrimino_piece => tetrimino_piece,
            field_in => field,
            field_out => field
        );
        
    Pseudorandom : PRNG
        port map(
        clk => clk,
        reset => reset,
        tetrimino_piece => tetrimino_piece
        );
        
    

end Behavioral;
