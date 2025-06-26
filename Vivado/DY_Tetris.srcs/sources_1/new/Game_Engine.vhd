library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Game_Engine is
    Port(
        clk : in std_logic;
        reset: in std_logic;
        
        -- tick counter
        counter: in std_logic_vector (7 downto 0);
        c_reset : out std_logic;
        
        -- player input
        control : in std_logic_vector(2 downto 0);
        
        --tetrimino piece from PRNG
        tetrimino_piece: in std_logic_vector (2 downto 0);
        
        -- input fields
        savedfield  : in std_logic_vector (200 downto 1);
        myblock     : in std_logic_vector(200 downto 1);
        
        --output field vector
        set_update_myblock : out std_logic_vector(200 downto 1);
        set_update_saved : out std_logic_vector(200 downto 1);
        set_update_output : out std_logic_vector (200 downto 1);
        update_myblock_en : out std_logic;
        update_saved_en: out std_logic;
        update_output_en: out std_logic;
        
        --score
        score : out std_logic_vector(7 downto 0);
        
        --tone
        cleared: out std_logic;
        endgame: out std_logic
    );
end Game_Engine;

architecture Behavioral of Game_Engine is
    type game_state is (IDLE, SPAWN, MOVE, HARD_DROP, FALL, CHECK, LOCK, FLASH, CLEAR, GAME_OVER);    --state type
    signal state, next_state: game_state;       -- process communication  
    signal next_c_reset : std_logic := '0';
    
    --init pivot (center of rotation)
    signal pivot_x, next_pivot_x : integer:= 5;
    signal pivot_y, next_pivot_y : integer:= 2;
    
    --declaration for block coordinates of myblock
    type coord_array is array(0 to 3) of integer;
    signal block_x, block_y, next_block_x, next_block_y: coord_array; 
    
    -- temporary signal of field vector 
    signal update_myblock : std_logic_vector(200 downto 1) := (others => '0');
    signal update_saved : std_logic_vector(200 downto 1) := (others => '0');
    signal update_output : std_logic_vector(200 downto 1) := (others => '0');
    
    signal next_update_output_en : std_logic := '0';
    signal next_update_saved_en  : std_logic := '0';
    signal next_update_myblock_en : std_logic := '0';
    
    -- locking signals
    signal lock_row_check : integer range 0 to 20 := 20;
    signal next_row_check : integer range 0 to 20 := 20;
    
    -- flash!
    signal flash_on : boolean := false;
    
    -- score
    signal highscore, score_inc : integer range 0 to 255 := 0; 
    signal dynamic_tick : std_logic_vector (7 downto 0);
    
    -- next tone 
    signal next_cleared : std_logic;
    signal next_endgame : std_logic;
begin
    --dynamic tick adjustor, drop 50ms every level up
    process(highscore)
        variable temp : integer;
    begin
        temp := 40 - highscore;
        if highscore > 30 then  -- max out at 500ms per fall    
            temp := 10;
        end if;
        dynamic_tick <= std_logic_vector(to_unsigned(temp, 8));
    end process;

    -- state register process
    process(clk, reset)
    begin
        if reset = '1' then
            pivot_x <= 5;
            pivot_y <= 2;
            
            block_x <= (others => 0);
            block_y <= (others => 0);
            
            set_update_myblock <= (others => '0');
            set_update_saved <= (others => '0');
            set_update_output <= (others => '0');
            update_output_en <= '0';
            update_saved_en  <= '0';
            update_myblock_en <= '0';
            
            highscore <= 0;
            
            lock_row_check <= 20;
            
            cleared <= '0';
            endgame <= '0';
            
            c_reset <= '1';
            state <= IDLE;
            
        elsif rising_edge(clk) then
            pivot_x <= next_pivot_x;
            pivot_y <= next_pivot_y;
            
            block_x <= next_block_x;
            block_y <= next_block_y;
            
            set_update_myblock <= update_myblock;
            set_update_saved <= update_saved;
            set_update_output <= update_output;
            update_output_en <= next_update_output_en;
            update_saved_en  <= next_update_saved_en;
            update_myblock_en <= next_update_myblock_en;
            
            highscore <= highscore + score_inc;
            
            lock_row_check <= next_row_check;
            
            cleared <= next_cleared;
            endgame <= next_endgame;
            
            c_reset <= next_c_reset;
            state <= next_state;
            
        end if;
    end process;
    
    --next state logic
    process(state, counter, control)    --sensitive to counter, will enter every 50 miliseconds
        variable myblock_next,temp_saved : std_logic_vector(200 downto 1); -- next field
        variable index,i,r,row,full_counter : integer;       -- simple counter variables
        variable temp_pivot_x, temp_pivot_y, best_pivot_y : integer ;
        variable no_move, collision, can_fall : boolean := false;
        variable new_block_x, new_block_y :coord_array;      
    begin
        -- NEXT signal assignments
        next_state <= state;  -- default state
        next_c_reset <= '0'; -- only reset counter once per state change 
        next_update_output_en <= '0';
        next_update_saved_en <= '0';
        next_update_myblock_en <= '0';
        next_pivot_x <= pivot_x;
        next_pivot_y <= pivot_y;
        next_block_x <= block_x;
        next_block_y <= block_y;
        next_row_check <= lock_row_check;
        score_inc <= 0;
        next_cleared <= '0';
        next_endgame <= '0';
        
        -- initiate next vector to all zeros every process start
        myblock_next := (others => '0');
        collision := false;
        
        case state is
            when IDLE =>
            if reset = '0' then
                next_c_reset <= '1';
                update_myblock<= (others => '0');
                update_saved<= (others => '0');
                update_output<= (others => '0');
                next_state <= SPAWN;
            end if;
    
            when SPAWN =>
                if counter = "00010100" then    -- short 1 second delay between idle and spawn
                    temp_pivot_x := 5;
                    temp_pivot_y := 2;
                    -- block generation logic
                    case tetrimino_piece is
                        when "000" =>   -- square block
                            new_block_x := (0,0,1,1);
                            new_block_y := (0,1,0,1);
                         when "001" =>  -- line block
                            new_block_x := (-1,0,1,2);
                            new_block_y := (0,0,0,0);
                        when "010" =>  -- S block
                            new_block_x := (-1,0,0,1);
                            new_block_y := (0,0,1,1);
                        when "011" =>  --Z block
                            new_block_x := (-1,0,0,1);
                            new_block_y := (1,1,0,0);
                        when "100" =>  -- L block
                            new_block_x := (-1, 0, 1, 1);
                            new_block_y := (0, 0, 0, 1);
                        when "101" =>  -- J block
                            new_block_x := (-1,-1,0,1);
                            new_block_y := (1,0,0,0);
                        when "110" =>  -- T block
                            new_block_x := (-1,0,0,1);
                            new_block_y := (0,1,0,0);
                        when others =>  -- default to square
                            new_block_x := (0,0,1,1);
                            new_block_y := (0,1,0,1);
                    end case;
                    
                    -- place block in next field
                    for i in 0 to 3 loop
                        index := (temp_pivot_x+new_block_x(i)) + 10 * (temp_pivot_y - new_block_y(i) - 1);
                        if index >= 1 and index <= 200 then
                            myblock_next(index) := '1';
                        end if;
                    end loop;
                    
                    -- collision check!
                    if (myblock_next and savedfield) /=  (200 downto 1 => '0') then --collision detected!
                        next_c_reset <= '1';    -- reset counter
                        next_state <= GAME_OVER;
                    else
                        -- save pivot var to signal
                        next_pivot_x <= temp_pivot_x;
                        next_pivot_y <= temp_pivot_y;
                        -- save block var to signal
                        next_block_x <= new_block_x;
                        next_block_y <= new_block_y;
                       
                        -- update fields
                        -- loop based assignment to save LUTs resources
                        for i in 1 to 200 loop
                            update_output(i) <= myblock_next(i) or savedfield(i);
                        end loop;
                        next_update_output_en <= '1';
                         
                        update_myblock <= myblock_next;
                        next_update_myblock_en <= '1';
                        
                        next_c_reset <= '1';    -- reset counter
                        next_state <= MOVE;     -- exit state
                    end if;
                end if;
    
            when MOVE => 
                temp_pivot_x := 0;
                temp_pivot_y := 0;
                no_move := false;
                
                if control = "001" then         -- shift left
                    temp_pivot_x := pivot_x - 1;
                    temp_pivot_y := pivot_y;
                    
                    -- preemption for edge blocks: don't move!
                    for r in 0 to 19 loop 
                        if myblock((r*10) + 1) = '1' then   --only check left edge
                            no_move:=true;
                        end if;
                    end loop;
                    
                    -- allowed to move
                    if not no_move then
                        for i in 0 to 3 loop
                            index := (temp_pivot_x+block_x(i)) + 10 * (temp_pivot_y - block_y(i) - 1);
                            if index < 1 or index > 200 then
                                collision := true;
                            else
                                myblock_next(index) := '1';
                                if savedfield(index) = '1' then
                                    collision:= true;                        
                                end if;
                            end if;
                        end loop;
                        
                        --collision check
                        if not collision then 
                            update_myblock <= myblock_next;     --update myblock field
                            next_update_myblock_en <= '1';
                            
                            for i in 1 to 200 loop
                                update_output(i) <= myblock_next(i) or savedfield(i);
                            end loop;
                            next_update_output_en <= '1';
                            
                            next_pivot_x <= temp_pivot_x;   -- update pivot
                            next_pivot_y <= temp_pivot_y;    -- y stays the same
                        end if;
                    end if;
                elsif control = "010" then      -- shift right
                    temp_pivot_x := pivot_x + 1;
                    temp_pivot_y := pivot_y;
                    
                    -- preemption for edge blocks: don't move!
                    for r in 0 to 19 loop  
                        if myblock((r*10) + 10) = '1' then  --only check right edge
                            no_move:=true;
                        end if;
                    end loop;
                    
                    -- allowed to move
                    if not no_move then
                        for i in 0 to 3 loop
                            index := (temp_pivot_x+block_x(i)) + 10 * (temp_pivot_y - block_y(i) - 1);
                            if index < 1 or index > 200 then
                                collision:=true;
                            else
                                myblock_next(index) := '1';
                                if savedfield(index) = '1' then
                                    collision:= true; 
                                end if;
                            end if;
                        end loop;
                        
                        --collision check
                        if not collision then  --no collision
                            update_myblock <= myblock_next;
                            next_update_myblock_en <= '1';
                            
                            for i in 1 to 200 loop
                                update_output(i) <= myblock_next(i) or savedfield(i);
                            end loop;
                            
                            next_update_output_en <= '1';
                            next_pivot_x <= temp_pivot_x;
                            next_pivot_y <= temp_pivot_y;    -- y stays the same
                        end if;
                    end if;   
                elsif control = "101" then      -- rotate
                    temp_pivot_x := pivot_x;
                    temp_pivot_y := pivot_y;
                    -- preempt : check if pivot is touching any edges
                    for r in 0 to 19 loop  
                        --if myblock((r*10) + 10) = '1' or myblock((r*10) + 1) = '1' then
                        if (pivot_x = 1 or pivot_x = 10 or pivot_y = 1 or pivot_y = 20)then
                            no_move:=true;
                        end if;
                    end loop;
                    
                    -- allowed to move                
                    if not no_move then
                        --clockwise rotation of block (y'=-x) ; (x'=y) 
                        for i in 0 to 3 loop
                            new_block_x(i) := block_y(i);
                            new_block_y(i) := -block_x(i);
                        end loop;
                        
                        for i in 0 to 3 loop
                            index := (temp_pivot_x+new_block_x(i)) + 10 * (temp_pivot_y - new_block_y(i) - 1);
                            if index < 1 and index > 200 then
                                collision:= true;
                            else
                                myblock_next(index) := '1';
                                if savedfield(index) = '1' then
                                    collision:= true; 
                                end if;
                            end if;
                        end loop;
                        
                        -- collision check
                        if not collision then  --no collision
                            update_myblock <= myblock_next;
                            next_update_myblock_en <= '1';
                            
                            for i in 1 to 200 loop
                                update_output(i) <= myblock_next(i) or savedfield(i);
                            end loop;
                            next_update_output_en <= '1';
                            
                            --update my block config vector
                            next_block_x <= new_block_x;
                            next_block_y <= new_block_y;    
                            next_pivot_x <= temp_pivot_x;
                            next_pivot_y <= temp_pivot_y;
                        end if;
                    end if;
                
                elsif control = "100" then      -- soft-drop
                    temp_pivot_x := pivot_x;
                    temp_pivot_y := pivot_y +1;
                    --condition for drop
                    for i in 0 to 3 loop
                        index := (temp_pivot_x+block_x(i)) + 10 * (temp_pivot_y - block_y(i) - 1);
                        if index < 1 or index > 200 then
                            collision:=true;
                        else
                            myblock_next(index) := '1';
                            if savedfield(index) = '1' then
                                collision:= true; 
                            end if;
                        end if;
                    end loop;
                    --collision check
                    if not collision then  --no collision
                        update_myblock <= myblock_next;
                        next_update_myblock_en <= '1';
                        
                        for i in 1 to 200 loop
                            update_output(i) <= myblock_next(i) or savedfield(i);
                        end loop;                        
                        next_update_output_en <= '1';
                        
                        next_pivot_x <= temp_pivot_x;
                        next_pivot_y <= temp_pivot_y;    -- y stays the same
                    end if;
                    
                elsif control = "011" then      --hard-drop
                    next_c_reset <= '1';
                    next_state <= HARD_DROP;
                end if;
                
                -- Tick-synchron
                if counter = dynamic_tick then    -- every 2 seconds one tick!       
                --if counter = "00000010" then    --debug
                        next_c_reset <= '1';
                        next_state <= FALL;
                end if;
                
            
            when HARD_DROP => 
                can_fall := true;
                -- test next 
                for i in 0 to 3 loop
                    index := (pivot_x + block_x(i)) + 10 * ((pivot_y + 1) - block_y(i) - 1);
                    if index < 1 or index > 200 or savedfield(index) = '1' then
                        can_fall:= false;
                    end if;
                end loop;
                
                if can_fall then
                    -- Move down one row
                    next_pivot_y <= pivot_y + 1;
                    next_state <= HARD_DROP; -- Keep dropping
                else
                    -- Cannot drop further, lock piece
                    myblock_next := (others => '0');
                    for i in 0 to 3 loop
                        index := (pivot_x + block_x(i)) + 10 * (pivot_y - block_y(i) - 1);
                        if (index >= 1) and (index <= 200) then
                            myblock_next(index) := '1';
                        end if;
                    end loop;
                    
                    update_myblock <= myblock_next;
                    next_update_myblock_en <= '1';
                    
                    for i in 1 to 200 loop
                        update_output(i) <= myblock_next(i) or savedfield(i);
                        update_saved(i) <= myblock_next(i) or savedfield(i);
                    end loop;         
                    next_update_output_en <= '1';
                    next_update_saved_en <= '1';    
                    
                    next_c_reset <= '1';
                    next_state <= LOCK;
                end if;
                
                
                
            when FALL =>
                -- update temp relative pivot position
                temp_pivot_x := pivot_x;
                temp_pivot_y := pivot_y + 1;
                                
                -- compare with next block location
                for i in 0 to 3 loop
                    index := (temp_pivot_x+block_x(i)) + 10 * (temp_pivot_y - block_y(i) - 1);
                    if index < 1 or index > 200 then   -- out of bounds
                        collision := true;
                    else    
                        myblock_next(index) := '1';
                        if savedfield(index) = '1' then -- collision with other blocks
                            collision:= true;                        
                        end if;
                    end if;
                end loop;
                
                -- tetrimino collision check!
                if collision then
                    for i in 1 to 200 loop
                        update_saved(i) <= myblock(i) or savedfield(i); -- prev myblock!
                    end loop;
                    next_update_saved_en <= '1'; 
                    next_c_reset <= '1';
                    next_state <= LOCK;                    
                else 
                    -- valid fall
                    next_pivot_y <= temp_pivot_y;
                    next_pivot_x <= temp_pivot_x;
                    
                    --update fields
                    for i in 1 to 200 loop
                        update_output(i) <= myblock_next(i) or savedfield(i);
                    end loop;
                    next_update_output_en <= '1';
                    update_myblock <= myblock_next;
                    next_update_myblock_en <= '1';
                    
                    next_c_reset <= '1';    --reset tick
                    next_state <= MOVE;
                end if;
                
            when LOCK =>
                next_state <= CHECK;    --NEW dummy state for field update
    
            when CHECK =>
                -- Check row from bottom up, restart check after return to this state
                
                if lock_row_check > 0 then
                    full_counter := 0;
                    for i in 1 to 10 loop
                        if savedfield((lock_row_check-1)*10 + i) = '1' then
                            full_counter := full_counter + 1;
                        end if;
                    end loop;
                    
                    if full_counter = 10 then   -- ONLY ENTER FLASH + CLEAR WHEN ONE ROW IS FULL
                        next_row_check <= lock_row_check;   -- clear THIS row
                        next_c_reset <= '1';
                        next_state <= FLASH; 
                    else
                        next_row_check <= lock_row_check - 1;   -- Check next higher row in next loop cycle
                        next_state <= CHECK;     
                    end if;
                else
                    -- All rows checked, nothing left to clear
                    update_myblock <= (others => '0'); -- Clear myblock here
                    next_update_myblock_en <= '1';  
                    next_row_check <= 20;
                    next_c_reset <= '1';
                    next_state <= SPAWN;
                end if;
           
            when FLASH =>
                
                -- rows off
                for i in 1 to 200 loop
                    if ((i - 1) / 10) + 1 = lock_row_check and not flash_on then
                        update_output(i) <= '0';    -- flash OFF
                    else
                        update_output(i) <= savedfield(i);  -- show other rows
                    end if;
                end loop;
                next_update_output_en <= '1';
                
                --rows on
                if counter = "00000010" or counter = "00000100" then    --100ms
                    flash_on <= false;
                    next_cleared <= '1';
                else 
                    flash_on <= true;
                end if;
                
                if counter = "00001010" then -- stop flashing
                        next_c_reset <= '1';
                        next_state <= CLEAR;
                end if;
            
            when CLEAR =>
                temp_saved := savedfield;
                -- check row from bottom up
                for row in 20 downto 2 loop
                    if row <= lock_row_check then
                        for i in 1 to 10 loop   -- move row above down by 1
                            temp_saved((row-1)*10 + i) := savedfield((row-2)*10 + i);
                        end loop;
                    end if;
                end loop;
                
                -- Set top row to zero if it was cleared
                for i in 1 to 10 loop
                    temp_saved(i) := '0';
                end loop;

                -- save and output
                update_saved <= temp_saved;
                next_update_saved_en <= '1';
                update_output <= temp_saved;
                next_update_output_en <= '1';
                
                -- SCORE + 1
                score_inc <= 1;
                
                -- Prepare for next lock/clear cycle
                next_row_check <= 20;    -- Restart from bottom
                next_c_reset <= '1';
                next_state <= LOCK;     -- new FSM logic required, not going to spawn directly!
                
                
            when GAME_OVER =>
                if counter = "00001010" then        -- 500ms
                    update_output <= not savedfield;-- flash inverted saved field!
                    next_endgame <= '1';    -- game over tone
                    next_update_output_en <= '1';
                end if;
                
                if counter = "00010100" then        -- 1000ms
                    update_output <= savedfield;-- flash saved field!
                    next_update_output_en <= '1';
                    next_c_reset <= '1';            -- reset counter
                end if;
                -- stay in this state!!
                
            when others => next_state <= IDLE; --default to IDLE
        end case;
        
    end process;
    
    score <= std_logic_vector(to_unsigned(highscore,8));
    
end Behavioral;
