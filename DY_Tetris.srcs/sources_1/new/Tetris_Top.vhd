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
use work.gamegrid_pkg.all;

entity Tetris_Top is
--  Port ( );
    Port (
        clk     : in std_logic;     --100Mhz Input from BASYS
        reset   : in std_logic;     
        vgaRed  : out std_logic_vector (3 downto 0);
        vgaBlue : out std_logic_vector (3 downto 0);
        vgaGreen: out std_logic_vector (3 downto 0);
        Hsync   : out std_logic;
        Vsync   : out std_logic
    );
        
end Tetris_Top;

architecture Behavioral of Tetris_Top is
    -- Signals for 40Mhz clocking wizard
    signal clk_40mhz   : std_logic;
    signal clk_locked  : std_logic; -- only run game is clk_locked is high
    
    -- Signals for Game speed ticks
    signal clk_gametick : std_logic;
    
    -- Signals for VGA 
    signal pixel_x,pixel_y: integer range 0 to 800;
    signal disp_ena: std_logic;
    signal red, green, blue: std_logic_vector(3 downto 0);
    signal h_sync,v_sync: std_logic;
    
    --Signals for controls
    signal move_left, move_right, pull_drop: std_logic ;
    signal next_step : bit_vector (3 downto 0);
    
    signal field: field_grid;
    signal tetrimino_piece : bit_vector(2 downto 0);
    
    -- Component declarations
    component clk_wiz_0
        Port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic;   -- 40 Mhz
            locked   : out std_logic
        );
    end component;
    
    
    
begin
    -- Instantiate clocking wizard
    clk_gen_inst : clk_wiz_0
        port map (
            clk_in1  => clk,
            reset    => reset,
            clk_out1 => clk_40mhz,
            locked   => clk_locked
        );
        
    -- need module to control gametick of 0,5 secs
    
    vga_controller: entity work.VGA_Controller
        port map(
            pixel_clk => clk_40mhz,
            reset_n => reset,
            hsync => h_sync,
            vsync => v_sync,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            disp_ena => disp_ena
        );
     
    renderer: entity work.Video_Renderer
        port map(
            clk => clk_40mhz,
            reset => reset,
            field => field,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            red => red,
            green => green,
            blue => blue,
            disp_ena => disp_ena
        );
    game_logic : entity work.Game_Engine
        port map(
            clk => clk_40mhz,
            reset => reset,
            tick => clk_gametick,
            move_left => move_left,
            move_right => move_right,
            pull_drop => pull_drop,
            --field => field,
            next_step => next_step
        );
        
    ram : entity work.Field_RAM
        port map(
            clk=> clk_40mhz,
            reset => reset,
            clk_gametick => clk_gametick,
            next_step => next_step,
            tetrimino_piece => tetrimino_piece
        );
        
    -- Assignment to VGA Port
    Hsync   <= h_sync;
    Vsync   <= v_sync;
    vgaRed  <= red;
    vgaBlue <= green;
    vgaGreen<= blue;
        
    

end Behavioral;
