library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Controller is
    generic (   -- standard values
        -- VGA 640x480 @60Hz timing
        h_visible   : integer := 640;   -- visible pixels
        h_fp        : integer := 16;    -- front porch
        h_pulse     : integer := 96;    -- sync pulse
        h_bp        : integer := 48;    -- back porch
        hsync_pol   : std_logic := '0'; -- negative polarity
    
        v_visible   : integer := 480;   -- visible lines
        v_fp        : integer := 10;    -- front porch
        v_pulse     : integer := 2;     -- sync pulse
        v_bp        : integer := 33;    -- back porch
        vsync_pol   : std_logic := '0'  -- negative polarity
    );
    Port (
        pixel_clk   : in  std_logic;  -- 25 MHz clock 
        reset       : in std_logic;      
        hsync       : out std_logic;
        vsync       : out std_logic;
        pixel_x     : out std_logic_vector (9 downto 0);      --horizontal pixel coordinates (max 1024 but only 640 needed)
        pixel_y     : out std_logic_vector (8 downto 0);      --vertical pixel coordinate (max 512 but only 480 needed)
        disp_ena    : out std_logic
        );
end VGA_Controller;

architecture Behavioral of VGA_Controller is
    -- constants 
    constant h_total    : integer := h_visible + h_fp + h_pulse + h_bp; --total no. of pixel clocks in row
    constant v_total    : integer := v_visible + v_fp + v_pulse + v_bp; -- total no. of rows in column
    
    signal h_count : integer range 0 to h_total - 1 := 0;
    signal v_count : integer range 0 to v_total - 1 := 0;

    
begin
    process(pixel_clk, reset)
    
    begin
        if(reset = '1') then  --active-high reset
            h_count <= 0;
            v_count <= 0;
            hsync <= not Hsync_pol;
            vsync <= not Vsync_pol;
            disp_ena <= '0';
            pixel_x <= (others =>'0');
            pixel_y <= (others =>'0');
        elsif(rising_edge(pixel_clk)) then
            -- running counter
            if( h_count < h_total -1) then
                h_count <= h_count + 1;
            else
                h_count <= 0;
                -- add a vertical count once one horizontal row is done
                if(v_count < v_total-1) then
                    v_count <= v_count +1;
                else
                    v_count <=0;
                end if;
            end if;
            
            -- generating synchronization signal pulses (refer to BASYS3 timing diagram)
            if(h_count >= h_visible + h_fp and h_count < h_visible + h_fp + h_pulse) then
                hsync <= hsync_pol;
            else
                hsync <= not hsync_pol;
            end if;
            if(v_count >= v_visible + v_fp and v_count < v_visible + v_fp + v_pulse) then
                vsync <= vsync_pol;
            else
                vsync <= not vsync_pol;
            end if;
            
            -- pixel position
            if(h_count < h_visible) then
                pixel_x <= std_logic_vector(to_unsigned(h_count, pixel_x'length));
            else 
                pixel_x <= (others =>'0');
            end if;
            if(v_count < v_visible)then
                pixel_y <= std_logic_vector(to_unsigned(v_count, pixel_y'length));
            else
                pixel_y <= (others =>'0');
            end if;
            
            --  only process pixel_x and pixel_y if in the visible area
            if(h_count < h_visible and v_count < v_visible) then
                disp_ena <= '1';
            else 
                disp_ena<= '0';
            end if;
            
            
        end if;
    end process;
        
end Behavioral;
