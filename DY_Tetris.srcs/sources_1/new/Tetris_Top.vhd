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
        
        -- 12 bits per pixel
        red     : out std_logic_vector(3 downto 0); 
        green   : out std_logic_vector(3 downto 0);
        blue    : out std_logic_vector(3 downto 0)
    );
        
end Tetris_Top;

architecture Behavioral of Tetris_Top is
    -- Signals for clocking wizard
    signal clk_40mhz   : std_logic;
    signal clk_locked  : std_logic;

    -- Component declarations
    component clk_wiz_0
        Port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic;
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
        
    

end Behavioral;
