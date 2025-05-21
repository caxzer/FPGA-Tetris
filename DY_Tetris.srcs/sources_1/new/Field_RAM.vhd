----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2025 07:18:46 PM
-- Design Name: Game field RAM
-- Module Name: Field_RAM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Provide information for collision check, and saving if lock state is provied
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- rename to draw_block!!
entity Field_RAM is
Port (
    clk         : in std_logic;
    reset       : in std_logic;
    clk_gametick: in std_logic;
    next_step       : in bit_vector (3 downto 0);
    tetrimino_piece : in std_logic_vector (2 downto 0);
    -- gamegrid_pkg is defined from 1-10 and 1-20
    --field       : out field_grid
--    get_field_x : in bit;
--    get_field_y : in bit;
--    set_field_x : out bit;
--    set_field_y: out bit;
    
    field_out: out std_logic_vector(200 downto 1) ;
    field_in : in std_logic_vector(200 downto 1)  
 );
end Field_RAM;

architecture Behavioral of Field_RAM is
-- initialize a interminent grid and set all bits to zero


begin
process(clk,reset,get_field_x,get_field_y)
begin
end process;


end Behavioral;
