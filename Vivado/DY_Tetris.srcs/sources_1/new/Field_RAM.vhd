library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Field_RAM is
Port (
    clk         : in std_logic;
    reset       : in std_logic;
    
    --Eingänge
    --to saved fields
    update_saved: in std_logic_vector(200 downto 1);
    update_saved_en : in std_logic;
    --to output fields
    update_output: in std_logic_vector(200 downto 1);
    update_output_en : in std_logic;
    --to myblock fields
    update_myblock: in std_logic_vector(200 downto 1);
    update_myblock_en : in std_logic;
    
    --Ausgänge
    outputfield: out std_logic_vector(200 downto 1);
    savedfield: out std_logic_vector(200 downto 1);
    myblockfield: out std_logic_vector(200 downto 1)
     
 );
end Field_RAM;

architecture Behavioral of Field_RAM is
    -- initialize a interminent (temporary) grid and set all bits to zero 
    signal internal_outputfield : std_logic_vector(200 downto 1) := (others => '0');
    signal internal_savedfield  : std_logic_vector(200 downto 1) := (others => '0');
    signal internal_myblockfield: std_logic_vector(200 downto 1) := (others => '0');
begin
process(clk, reset)
    begin
        if reset = '1' then
            internal_outputfield   <= (others => '0');
            internal_savedfield    <= (others => '0');
            internal_myblockfield  <= (others => '0');

        elsif rising_edge(clk) then
                if update_myblock_en = '1' then
                    internal_myblockfield <= update_myblock;
                end if;
                
                if update_saved_en = '1' then
                    internal_savedfield <= update_saved;
                end if;
                
                if update_output_en = '1' then
                    internal_outputfield <= update_output;
                end if;
        end if;
end process;

-- Output assignments
outputfield   <= internal_outputfield;
savedfield    <= internal_savedfield;
myblockfield  <= internal_myblockfield;

end Behavioral;
