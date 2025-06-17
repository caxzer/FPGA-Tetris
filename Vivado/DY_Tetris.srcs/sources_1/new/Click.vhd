library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
entity Click is
Port ( 
    clk : in std_logic;
    reset : in std_logic;
    control : in std_logic_vector(2 downto 0);
    cleared : in std_logic;
    endgame : in std_logic;
    buzzer : out std_logic
);
end Click;

architecture Behavioral of Click is
    constant clk_freq   : integer := 25170070;
    constant move_freq  : integer := 523;  -- C5
    constant drop_freq  : integer := 440;  -- A4
    constant clear_freq : integer := 784;  -- G5
    constant over_freq  : integer := 392;  -- G4
    constant move_dur   : integer := clk_freq / 1000 * 60;  -- 60ms
    constant drop_dur   : integer := clk_freq / 1000 * 100; -- 100ms
    constant clear_dur  : integer := clk_freq / 1000 * 120; -- 120ms
    constant over_dur   : integer := clk_freq / 1000 * 400; -- 400ms
    
    type sound_state_type is (IDLE, MOVE, DROP, CLEAR, OVER);
    signal state, next_state : sound_state_type := IDLE;

    signal duration_counter : integer := 0;
    signal tone_counter : integer := 0;
    signal tone_period : integer := 0;
    signal tone : std_logic := '0';
    
    signal cleared_pending , endgame_pending : std_logic := '0';
begin
    -- Latch events while busy
    process(clk, reset)
    begin
        if reset = '1' then
            cleared_pending  <= '0';
            endgame_pending  <= '0';
        elsif rising_edge(clk) then
            if (state /= IDLE) then
                if cleared = '1' then 
                    cleared_pending <= '1'; 
                end if;
                if endgame = '1' then
                    endgame_pending <= '1'; 
                end if;
            else
                cleared_pending  <= '0';
                endgame_pending  <= '0';
            end if;
        end if;
    end process;
    
    -- state prio machine
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            duration_counter <= 0;
        elsif rising_edge(clk) then
            if next_state = IDLE then
                duration_counter <= 0;
            elsif state /= next_state then
                duration_counter <= 0; -- just switched sounds, reset duration
            else
                duration_counter <= duration_counter + 1;
            end if;
            state <= next_state;
        end if;
    end process;
    
    -- next state logic
    process(state, control, cleared, endgame, duration_counter)
    begin
        next_state <= state;
        case state is
            when IDLE =>
                if endgame = '1' or endgame_pending = '1' then
                    next_state <= OVER;
                elsif cleared = '1'or cleared_pending = '1'  then
                    next_state <= CLEAR;
                elsif control = "011" then -- hard drop
                    next_state <= DROP; 
                elsif control = "001" or control = "010" or control = "101" or control = "100" then 
                    next_state <= MOVE;
                end if;
            when MOVE =>    -- left, right , rotate and soft drop
                if duration_counter >= move_dur then
                    next_state <= IDLE;
                end if;
            when DROP =>    -- hard drop
                if duration_counter >= drop_dur then
                    next_state <= IDLE;
                end if;
            when CLEAR =>   -- line clear
                if duration_counter >= clear_dur then
                    next_state <= IDLE;
                end if;
            when OVER =>    -- game over
                if duration_counter >= over_dur then
                    next_state <= IDLE;
                end if;
            when others =>
                next_state <= IDLE;
        end case;
    end process;
    
    -- set tone period
    process(state)
    begin
        case state is   -- with half periods
            when MOVE => tone_period <= clk_freq / (2 * move_freq);
            when DROP => tone_period <= clk_freq / (2 * drop_freq);
            when CLEAR => tone_period <= clk_freq / (2 * clear_freq);
            when OVER  => tone_period <= clk_freq / (2 * over_freq);
            when others => tone_period <= 0;
        end case;
    end process;
    
    -- tone generator
    process(clk, reset)
    begin
        if reset = '1' then
            tone <= '0';
            tone_counter <= 0;
        elsif rising_edge(clk) then
            if tone_period = 0 then -- IDLE
                tone <= '0';
                tone_counter <= 0;
            else
                if tone_counter >= tone_period then -- state dependent
                    tone <= not tone;   -- square wave gen
                    tone_counter <= 0;
                else
                    tone_counter <= tone_counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- output
    buzzer <= tone;
    
end Behavioral;
