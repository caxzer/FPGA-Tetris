library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity Video_Renderer is
Port (
    field : in std_logic_vector(200 downto 1);  -- game field
    pixel_x : in std_logic_vector(9 downto 0);  -- screen pixel coordinates
    pixel_y : in std_logic_vector(8 downto 0);  -- 
    disp_ena  : in std_logic;
    
    -- tetrimino piece for color variation
    --thisPiece : in std_logic_vector(2 downto 0);
    
    -- output for color
    red  : out std_logic_vector(3 downto 0);
    green: out std_logic_vector(3 downto 0);
    blue : out std_logic_vector(3 downto 0)
 );


end Video_Renderer;

architecture Behavioral of Video_Renderer is
--playing field declaration
constant SCREEN_WIDTH   : integer := 640;
constant SCREEN_HEIGHT  : integer := 480;
constant GAME_WIDTH     : integer := 240;  -- 10 columns × 20 px + 40px including border
constant GAME_HEIGHT    : integer := 440;  -- 20 rows × 20 px + 40px including border
constant game_origin_x  : integer := (SCREEN_WIDTH  - GAME_WIDTH) / 2;
constant game_origin_y  : integer := (SCREEN_HEIGHT - GAME_HEIGHT) / 2;
constant cell_size      : integer := 20;


begin
    -- finding grid location
    -- combinatory(not synchrounous!)
    
    -- taking grid location and painting field
    process(pixel_x, pixel_y, field, disp_ena)
        -- 2D Array declaration 
        -- ACHTUNG : "GRID" ENTSPRICHT NICHT "FIELD"
        -- "GRID" ENTHÄLT AUCH GRENZE BLÖCKE
        -- "FIELDx/y"1-10
        variable grid_x : integer range 0 to 11;
        variable grid_y : integer range 0 to 21;
        -- grid_x and grid_y at 0 is grey 
        -- pxcell and pixel_x/y are starting from 0
        -- grid and field starts from 1
        variable pxcell_x : integer;
        variable pxcell_y : integer;
        variable is_border : boolean;
        variable field_idx : integer;
        variable inside_game_area : boolean;
    begin
        -- finding grid location
        inside_game_area := false;
        if disp_ena = '1' then
            if (to_integer(unsigned(pixel_x)) >= game_origin_x and to_integer(unsigned(pixel_x)) < game_origin_x + GAME_WIDTH) and 
               (to_integer(unsigned(pixel_y)) >= game_origin_y and to_integer(unsigned(pixel_y)) < game_origin_y + GAME_HEIGHT) then
                inside_game_area := true;
                grid_x := (to_integer(unsigned(pixel_x)) - game_origin_x) / cell_size;
                grid_y := (to_integer(unsigned(pixel_y)) - game_origin_y) / cell_size;
            end if;
        end if;
    
        if disp_ena = '0' or inside_game_area = false then
            red <= "0000";
            green <= "0000";
            blue <= "0000";

        elsif grid_x = 0 or grid_x = 11 or grid_y = 0 or grid_y = 21 then   -- border
            red <= "1000";  -- light grey border
            green <= "1000";
            blue <= "1000";
        
        else    -- inside borders
            field_idx := (grid_y - 1) * 10 + grid_x;
            if field_idx >= 1 and field_idx <= 200 and field(field_idx) = '1' then  -- if output field coordinate block is 1
                pxcell_x := (to_integer(unsigned(pixel_x)) - game_origin_x) mod cell_size;
                pxcell_y := (to_integer(unsigned(pixel_y)) - game_origin_y) mod cell_size;

                is_border := (pxcell_x = 0) or (pxcell_y = 0) or (pxcell_x = cell_size - 1) or (pxcell_y = cell_size - 1);

                if is_border then
                    red <= "0000";
                    green <= "0000";
                    blue <= "0000";
                else  -- block color here
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;
            else
                red <= "0000";
                green <= "0000";
                blue <= "0000";
            end if;
        end if;
    end process;
     
end Behavioral;
