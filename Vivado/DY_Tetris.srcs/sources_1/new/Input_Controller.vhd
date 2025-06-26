library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Input_Controller is
    Port (
        clk     : in std_logic;
        reset   : in std_logic; --Achtung Schalter!
        up      : in std_logic;
        down    : in std_logic;
        left    : in std_logic;
        right   : in std_logic;
        centre  : in std_logic;
        
        control : out std_logic_vector(2 downto 0)
    );
end Input_Controller;

architecture Behavioral of Input_Controller is
    constant DEBOUNCE : integer := 125850 ;    --5ms debounce time
    signal up_sync_0, up_sync : std_logic := '0';
    signal down_sync_0, down_sync : std_logic := '0';
    signal left_sync_0, left_sync : std_logic := '0';
    signal right_sync_0, right_sync : std_logic := '0';
    signal centre_sync_0, centre_sync : std_logic := '0';
    
    signal up_deb : std_logic := '0';
    signal down_deb : std_logic := '0';
    signal left_deb : std_logic := '0';
    signal right_deb : std_logic := '0';
    signal centre_deb: std_logic := '0';
    
    signal last_up_deb : std_logic := '0';
    signal last_down_deb : std_logic := '0';
    signal last_left_deb : std_logic := '0';
    signal last_right_deb : std_logic := '0';
    signal last_centre_deb: std_logic := '0';
    
    signal up_count, down_count, left_count, right_count, centre_count : integer range 0 to DEBOUNCE := 0;
begin
    -- synchronisation gegen Metastabilität
    process(clk)
    begin
        if rising_edge(clk) then
            up_sync_0       <= up;
            up_sync         <= up_sync_0;
            
            down_sync_0     <= down;
            down_sync       <= down_sync_0;
    
            left_sync_0     <= left;
            left_sync       <= left_sync_0;
    
            right_sync_0    <= right;
            right_sync      <= right_sync_0;
    
            centre_sync_0   <= centre;
            centre_sync     <= centre_sync_0;
        end if;
    end process;
    
    
    -- debounce & output
    process(clk, reset)
    begin
        if reset = '1' then
            up_deb    <= '0';
            down_deb  <= '0';
            left_deb  <= '0';
            right_deb <= '0';
            centre_deb<= '0';
            
            up_count    <= 0;
            down_count  <= 0;
            left_count  <= 0;
            right_count <= 0;
            centre_count<= 0;
            
            last_up_deb    <= '0';
            last_down_deb  <= '0';
            last_left_deb  <= '0';
            last_right_deb <= '0';
            last_centre_deb<= '0';
            
            control <= "000";
        elsif rising_edge(clk) then   
            -- up
            if up_sync= '1' then    --synchonized
                if up_count < DEBOUNCE then
                    up_count <= up_count + 1;
                    up_deb <= '0';
                else
                    up_deb <= '1';
                end if;
            else
                up_count <= 0;
                up_deb <= '0';
            end if;
              
            -- down
            if down_sync = '1' then
                if down_count < DEBOUNCE then
                    down_count <= down_count + 1;
                    down_deb <= '0';
                else
                    down_deb <= '1';
                end if;
            else
                down_count <= 0;
                down_deb <= '0';
            end if;

            -- left
            if left_sync = '1' then 
                if left_count < DEBOUNCE then
                    left_count <= left_count + 1;
                    left_deb <= '0';
                else
                    left_deb <= '1';
                end if;
            else
                left_count <= 0;
                left_deb <= '0';
            end if;

            -- right
            if right_sync= '1' then
                if right_count < DEBOUNCE then
                    right_count <= right_count + 1;
                    right_deb<= '0';
                else
                    right_deb <= '1';
                end if;
            else
                right_count <= 0;
                right_deb <= '0';
            end if;

            -- centre
            if centre_sync = '1' then
                if centre_count < DEBOUNCE then
                    centre_count <= centre_count + 1;
                    centre_deb <= '0';
                else
                    centre_deb <= '1';
                end if;
            else
                centre_count <= 0;
                centre_deb <= '0';
            end if;
            
            -- output in "Control"-vector
            if left_deb = '1' and (last_left_deb = '0')then
                control <= "001";
            elsif right_deb = '1' and (last_right_deb = '0')then
                control <= "010";
            elsif up_deb = '1' and (last_up_deb = '0')then
                control <= "101";
            elsif centre_deb = '1' and (last_centre_deb = '0')then
                control <= "011";
            elsif down_deb = '1' and (last_down_deb = '0')then
                control <= "100";
            else
                control <= "000"; -- idle/no input
            end if;
            
            -- update last signals
            last_up_deb <= up_deb;
            last_right_deb <= right_deb;
            last_left_deb <= left_deb;
            last_centre_deb <= centre_deb;
            last_down_deb <= down_deb;
        end if;
    end process;
end Behavioral;
