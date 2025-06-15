----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2025 12:56:34 PM
-- Design Name: 
-- Module Name: Melody - Behavioral
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

entity Melody is
    Port (
        clk    : in  std_logic;  -- 100 MHz
        reset  : in  std_logic;
        buzzer : out std_logic
    );
end Melody;

architecture Behavioral of Melody is
    -- Note Frequencies
    type freq_array is array(0 to 8) of integer;
    constant note_freqs : freq_array := (
        0,    -- 0: silence
        440,  -- 1: A4
        494,  -- 2: B4
        523,  -- 3: C5
        587,  -- 4: D5
        659,  -- 5: E5
        698,  -- 6: F5
        784,  -- 7: G5
        880   -- 8: A5
    );

    -- Melody
    type melody_array is array(0 to 65) of integer;
    constant melody_notes : melody_array := (
        5, 5, 2, 3,
        4, 4, 3, 2,
        1, 1,
        
        1, 3, 5, 5, 
        4, 3, 2, 2,
        
        2, 3, 4, 4,
        5, 5, 3, 3,
        1, 1, 1, 1,
        1, 1, 0, 0,
        
        0, 4, 4, 6,
        8, 8, 7, 6,
        0, 5, 5, 3,
        5, 5, 4, 3,
        
        2, 3, 4, 4,
        5, 5, 3, 3,
        1, 1, 1, 1,
        1, 1, 0, 0 
    );

    
    constant note_duration_ms : integer := 125; -- 1/8 
    constant clk_freq : integer := 25170070;
    constant duration_cycles : integer := clk_freq / 1000 * note_duration_ms;

    signal tone        : std_logic := '0';
    signal counter     : integer := 0;
    signal tone_counter: integer := 0;
    signal note_index  : integer range 0 to 65 := 0;
    signal tone_period : integer := clk_freq / (2 * 440); -- start with A4
begin
    -- square wave generator
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tone <= '0';
                tone_counter <= 0;
            elsif melody_notes(note_index) /= 0 then
                if tone_counter >= tone_period then
                    tone <= not tone;
                    tone_counter <= 0;
                else
                    tone_counter <= tone_counter + 1;
                end if;
            else
                tone <= '0';
                tone_counter <= 0;
            end if;
        end if;
    end process;
    
    buzzer <= tone;

    -- melody sequencer
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                note_index <= 0;
                counter <= 0;
                tone_period <= clk_freq / (2 * note_freqs(melody_notes(0)));
            elsif counter >= duration_cycles then
                if note_index = 65 then
                    note_index <= 0;
                else
                    note_index <= note_index + 1;
                end if;
                counter <= 0;
                tone_period <= clk_freq / (2 * note_freqs(melody_notes(note_index + 1)));
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    

end Behavioral;
