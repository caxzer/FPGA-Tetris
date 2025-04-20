----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 01:29:58 PM
-- Design Name: 
-- Module Name: VGA_Controller - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_Controller is
--  Port ( );
    generic (
        -- data sheet: 800x600 Display @ 60 Hz
        h_visible  : integer := 800;
        h_fp    : integer := 40;
        h_pulse     : integer := 128;
        h_bp     : integer := 88;
        hsync_pol  : std_logic :='1';
        v_visible  : integer := 600;
        v_fp    : integer := 1;
        v_pulse     : integer := 4;
        v_bp     : integer := 23;
        vsync_pol  : std_logic := '1'
    );
    Port (
        pixel_clk : in  STD_LOGIC;  -- 40 MHz clock
        reset_n: in std_logic;      -- manual reset, logic in top
        hsync   : out STD_LOGIC;
        vsync   : out STD_LOGIC;
        --red : out STD_LOGIC_VECTOR(3 downto 0);
        --green   : out STD_LOGIC_VECTOR(3 downto 0);
        --blue    : out STD_LOGIC_VECTOR(3 downto 0);
        pixel_x: out integer; --horizontal ixel coordinate
        pixel_y: out integer; --vertical pixel coordinate
        disp_ena : out STD_LOGIC
        );
end VGA_Controller;

architecture Behavioral of VGA_Controller is
    -- constants 
    constant h_total    : integer := h_visible + h_fp + h_pulse + h_bp; --total no. of pixel clocks in row
    constant v_total    : integer := v_visible + v_fp + v_pulse + v_bp; -- total no. of rows in column
    

    
begin
    process(pixel_clk, reset_n)
    variable h_count : integer range 0 to h_total - 1 := 0;
    variable v_count : integer range 0 to v_total - 1 := 0;
    begin
        if(reset_n = '0') then  
            h_count:= 0;
            v_count:= 0;
            hsync <= not Hsync_pol;
            vsync <= not Vsync_pol;
            disp_ena <= '0';
            pixel_x <= 0;
            pixel_y <= 0;
        elsif(rising_edge(pixel_clk)) then
            -- running counter
            if( h_count < h_total -1) then
                h_count := h_count + 1;
            else
                h_count := 0;
                -- add a vertical count once one horizontal row is done
                if(v_count < v_count-1) then
                    v_count := v_count +1;
                else
                    v_count :=0;
                end if;
            end if;
            
            --generating synchronization signal pulses (refer to BASYS3 timing diagram)
            if(h_count > h_visible + h_fp and h_count <= h_visible + h_fp + h_pulse) then
                hsync <= hsync_pol;
            else
                hsync <= not hsync_pol;
            end if;
            
            if(v_count > v_visible + v_fp and v_count <= v_visible + v_fp + v_pulse) then
                vsync <= vsync_pol;
            else
                vsync <= not vsync_pol;
            end if;
            
            -- pixel position
            if(h_count < h_visible) then
                pixel_x <= h_count;
            end if;
            if(v_count < v_visible)then
                pixel_y <= v_count;
            end if;
            
            -- display out enable if not blank
            if(h_count < h_visible and v_count < v_visible) then
                disp_ena <= '1';
            else 
                disp_ena<= '0';
            end if;
            
            
        end if;
    end process;
        
end Behavioral;
