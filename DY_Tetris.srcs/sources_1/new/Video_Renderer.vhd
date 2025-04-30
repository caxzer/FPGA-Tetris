----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 07:20:15 PM
-- Design Name: 
-- Module Name: Video_Renderer - Behavioral
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
use work.gamegrid_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity Video_Renderer is
Port (
    clk         : in std_logic;
    reset       : in std_logic;
    
    -- game field
    field : in field_grid;
    
    -- screen pixel coordinates
    pixel_x     : in integer;
    pixel_y     : in integer;
    disp_ena    : in std_logic;
    
    -- output for color
    red         : out std_logic_vector(3 downto 0);
    green       : out std_logic_vector(3 downto 0);
    blue        : out std_logic_vector(3 downto 0)
 );


end Video_Renderer;

architecture Behavioral of Video_Renderer is
--playing field declaration
constant SCREEN_WIDTH   : integer :=  600;
constant SCREEN_HEIGHT  : integer :=  800;
constant GAME_WIDTH     : integer :=  220;
constant GAME_HEIGHT    : integer :=  440;
constant game_origin_x  : integer :=  (SCREEN_WIDTH  - GAME_WIDTH) / 2;
constant game_origin_y  : integer :=  (SCREEN_HEIGHT - GAME_HEIGHT)/ 2;
constant cell_size      : integer :=  20;

-- 2D Array declaration 
-- ACHTUNG : "GRID" ENTSPRICHT NICHT "FIELD"
-- "GRID" ENTHÄLT AUCH GRENZE BLÖCKE
-- "FIELDx"1-10
-- "FIELDy"1-20
signal grid_x : integer range 0 to 11;
signal grid_y : integer range 0 to 21;
-- grid_x and grid_y at 0 is just black 
signal inside_game_area : bit := '0';
--signal is_border : bit;

begin
    -- finding grid location
    -- combinatory(not synchrounous!)
    process(pixel_x,pixel_y,disp_ena)
    begin
    if disp_ena = '1' then
        if (pixel_x >= game_origin_x and pixel_x < game_origin_x + GAME_WIDTH) and (pixel_y >= game_origin_y and pixel_y < game_origin_y + GAME_HEIGHT) then
            inside_game_area <= '1';
            grid_x <= (pixel_x - game_origin_x) / cell_size;
            grid_y <= (pixel_y - game_origin_y) / cell_size;
        else
            inside_game_area <= '0';
            grid_x <= 0;
            grid_y <= 0;
        end if;
    end if;
    end process;
    
    -- taking grid location and painting field
    process(grid_x, grid_y,pixel_x, pixel_y,reset)
    variable pxcell_x : integer:= 1 ;
    variable pxcell_y : integer:= 1 ;
    variable is_border : boolean ;
    begin
        -- paint edges grey, constantly showing
        if grid_y = 0 or grid_y = 21 or grid_x = 0 or grid_x = 11 then
            red <= "1000";
            green <= "1000";
            blue <= "1000";
        end if;
        if reset = '0' then
            -- paint everything else
            if field(grid_x)(grid_y) = '1' and disp_ena = '1' then
                -- pixel position inside the cell
                pxcell_x := (pixel_x - game_origin_x - cell_size) mod cell_size;
                pxcell_y := (pixel_y - game_origin_y - cell_size) mod cell_size;
                
                -- borer pixel check
                is_border := ((pxcell_x = 1) or (pxcell_y = 1) or (pxcell_x = cell_size ) or (pxcell_y = cell_size ));
                    
                if not is_border  then
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                else 
                    red <= "0000";
                    green <= "0000";
                    blue <= "0000";
                end if;
            else 
                red <= "0000";
                green <= "0000";
                blue <= "0000";
            end if;
        else -- reset condition
            red <= "0000";
            green <= "0000";
            blue <= "0000";
        end if;
    end process;
    
end Behavioral;
