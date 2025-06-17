library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Video_Renderer is
Port (
    field : in std_logic_vector(200 downto 1);  -- game field
    pixel_x : in std_logic_vector(9 downto 0);  -- screen pixel coordinates
    pixel_y : in std_logic_vector(8 downto 0);  -- 
    disp_ena  : in std_logic;
    
    -- output for color
    red  : out std_logic_vector(3 downto 0);
    green: out std_logic_vector(3 downto 0);
    blue : out std_logic_vector(3 downto 0);
    
    -- score 
    score : in std_logic_vector(7 downto 0)
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
    constant SCORE_ORIGIN_X    : integer := 20;
    constant SCORE_ORIGIN_Y    : integer := 20;
    
    type font_array is array (0 to 9, 0 to 7) of std_logic_vector(7 downto 0);
    constant digit_font: font_array := (
      0 => ( "00111100", "01000010", "10000101", "10001001", "10010001", "10100001", "01000010", "00111100" ), -- 0
      1 => ( "00011000", "00111000", "00011000", "00011000", "00011000", "00011000", "00011000", "00111100" ), -- 1
      2 => ( "00111100", "01000010", "00000010", "00000100", "00001000", "00010000", "00100000", "01111110" ), -- 2
      3 => ( "00111100", "01000010", "00000010", "00011100", "00000010", "00000010", "01000010", "00111100" ), -- 3
      4 => ( "00000100", "00001100", "00010100", "00100100", "01000100", "01111110", "00000100", "00000100" ), -- 4
      5 => ( "01111110", "01000000", "01000000", "01111100", "00000010", "00000010", "01000010", "00111100" ), -- 5
      6 => ( "00111100", "01000010", "01000000", "01111100", "01000010", "01000010", "01000010", "00111100" ), -- 6
      7 => ( "01111110", "00000010", "00000100", "00001000", "00010000", "00010000", "00010000", "00010000" ), -- 7
      8 => ( "00111100", "01000010", "01000010", "00111100", "01000010", "01000010", "01000010", "00111100" ), -- 8
      9 => ( "00111100", "01000010", "01000010", "00111110", "00000010", "00000010", "01000010", "00111100" )  -- 9
    );
begin
    -- finding grid location
    -- combinatory(not synchrounous!)
    process(pixel_x, pixel_y, field, disp_ena)
        -- 2D Array declaration 
        -- ACHTUNG : "GRID" ENTSPRICHT NICHT "FIELD"
        -- "GRID" ENTHÄLT AUCH GRENZE-BLÖCKE
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
        
        -- score var
        variable score_int : integer;
        type integer_vector is array (0 to 2) of integer ;
        variable digits : integer_vector; -- For 3 digits
        variable which_digit : integer;
        variable digit_x, digit_y : integer;
        variable digit_val : integer;
        
        -- color var to avoid infering latches
        variable r,g,b : std_logic_vector(3 downto 0) := "0000";
    begin
        -- default color
        r := "0000";
        g := "0000";
        b := "0000";
        
        -- score to integer and split into digits
        score_int := to_integer(unsigned(score));
        digits(2) := score_int / 100;
        digits(1) := (score_int / 10) mod 10;
        digits(0) := score_int mod 10;
        
        -- handle score first
        if (to_integer(unsigned(pixel_x)) >= SCORE_ORIGIN_X) and 
           (to_integer(unsigned(pixel_x)) < SCORE_ORIGIN_X + 3*8) and
           (to_integer(unsigned(pixel_y)) >= SCORE_ORIGIN_Y) and
           (to_integer(unsigned(pixel_y)) < SCORE_ORIGIN_Y + 10) then
    
            -- 0 most significant, 2 least significant
            which_digit := (to_integer(unsigned(pixel_x)) - SCORE_ORIGIN_X) / 8;
            digit_x := (to_integer(unsigned(pixel_x)) - SCORE_ORIGIN_X) mod 8;
            digit_y := to_integer(unsigned(pixel_y)) - SCORE_ORIGIN_Y;
            digit_val := digits(2 - which_digit); -- digits are left to right

            if digit_font(digit_val, digit_y)(7 - digit_x) = '1' then
                r := "1111";
                g := "1111";
                b := "1111";
            else
                r:= "0000";
                g := "0000";
                b := "0000";
            end if;
         -- then handle color
        elsif disp_ena = '1' then
            inside_game_area := false;
            
            if (to_integer(unsigned(pixel_x)) >= game_origin_x and to_integer(unsigned(pixel_x)) < game_origin_x + GAME_WIDTH) and 
               (to_integer(unsigned(pixel_y)) >= game_origin_y and to_integer(unsigned(pixel_y)) < game_origin_y + GAME_HEIGHT) then
                inside_game_area := true;
                grid_x := (to_integer(unsigned(pixel_x)) - game_origin_x) / cell_size;
                grid_y := (to_integer(unsigned(pixel_y)) - game_origin_y) / cell_size;
            end if;
            
        
            if inside_game_area then
                if grid_x = 0 or grid_x = 11 or grid_y = 0 or grid_y = 21 then   -- border
                    r := "1000";  -- light grey border
                    g := "1000";
                    b := "1000";
                else    -- inside borders
                    field_idx := (grid_y - 1) * 10 + grid_x;
                    if field_idx >= 1 and field_idx <= 200 and field(field_idx) = '1' then  -- if output field coordinate block is 1
                        pxcell_x := (to_integer(unsigned(pixel_x)) - game_origin_x) mod cell_size;
                        pxcell_y := (to_integer(unsigned(pixel_y)) - game_origin_y) mod cell_size;
        
                        is_border := (pxcell_x = 0) or (pxcell_y = 0) or (pxcell_x = cell_size - 1) or (pxcell_y = cell_size - 1);
        
                        if is_border then   -- border of individual block color (super light grey)
                            r := "0011";
                            g := "0011";
                            b := "0011";
                        else  -- block color here : WHITE
                            r := "1111";
                            g := "1111";
                            b := "1111";
                        end if;
                    else
                        r := "0000";
                        g := "0000";
                        b := "0000";
                    end if;
                end if;
            end if;
        end if;
        
        -- fiannly assign to RGB 
        red   <= r;
        green <= g;
        blue  <= b;
    end process;
     
end Behavioral;
