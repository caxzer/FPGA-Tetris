----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 01:30:27 PM
-- Design Name: 
-- Module Name: Game_Engine - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity Game_Engine is
--  Port ( );
    Port(
        clk : in std_logic;
        
        -- clock 2 for game speed
        tick: in std_logic; -- updates/refreshes screen every second
        
        -- player input
        move_left: in std_logic;
        move_right: in std_logic;
        pull_drop: in std_logic;
        reset: in std_logic;
        
        next_step: out bit_vector(3 downto 0)
        
        
        
    );
end Game_Engine;

architecture Behavioral of Game_Engine is
    type game_state is (IDLE, SPAWN, MOVE, DROP, COLLISION, LOCK, CLEAR, GAME_OVER);    --state type
    signal state, next_state: game_state;       -- process communication  
    
      
begin     
process(clk, reset, tick, move_left, move_right, pull_drop)
begin
-- if state = SPAWN
-- choose block from pseudorandom number generator input here
    
end process;
end Behavioral;
