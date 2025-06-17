library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tetris_Top is
    Port (
        clk100     : in std_logic;                      --100Mhz Input from BASYS
        re_set   : in std_logic;                        -- active low reset
        
        --controls
        btnC : in std_logic;
        btnU : in std_logic;
        btnL : in std_logic;
        btnR : in std_logic;
        btnD : in std_logic;
        
        --video
        vga_Red  : out std_logic_vector (3 downto 0);
        vga_Blue : out std_logic_vector (3 downto 0);
        vga_Green: out std_logic_vector (3 downto 0);
        hsync   : out std_logic;
        vsync   : out std_logic;
        
        --7 segment
        seg : out std_logic_vector(6 downto 0);
        digit_on : out std_logic_vector(3 downto 0);
        
        --melody
        buzzer: out std_logic
    );
        
end Tetris_Top;

architecture Behavioral of Tetris_Top is
    -- Signals for ~25Mhz clocking wizard
    signal clk   : std_logic;
    signal clk_locked  : std_logic; -- only run game is clk_locked is high
    signal reset, c_reset : std_logic;
    
    -- Signals for Game speed ticks
    signal clk_gametick : std_logic;
    
    -- Signals for VGA 
    signal pixel_x: std_logic_vector(9 downto 0);
    signal pixel_y: std_logic_vector(8 downto 0);
    signal disp_ena: std_logic;
    
    --Signals for controls
    signal control : std_logic_vector (2 downto 0);
    
    -- Signals for tick/counter
    signal counter : std_logic_vector (7 downto 0);
    
    -- Signals for fields
    signal update_myblock: std_logic_vector(200 downto 1);  
    signal update_saved: std_logic_vector(200 downto 1); 
    signal update_output: std_logic_vector(200 downto 1); 
    signal savedfield: std_logic_vector(200 downto 1); 
    signal myblockfield: std_logic_vector(200 downto 1); 
    signal outputfield: std_logic_vector(200 downto 1); 
    
    signal update_myblock_en : std_logic ;
    signal update_saved_en : std_logic;
    signal update_output_en : std_logic;
    
    -- Signal for random block
    signal tetrimino_piece : std_logic_vector(2 downto 0);
    
    -- Signal for scoreboard
    signal score : std_logic_vector(7 downto 0);
    
    -- signal for tone 
    signal cleared : std_logic;
    signal endgame : std_logic;
    
    -- Component declarations
    component clk_wiz_0
        Port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic;   -- 25 Mhz
            locked   : out std_logic
        );
    end component;
    
--    component Clock
--        Port(
--            clk100 : in std_logic;
--            reset: in std_logic;
--            clk:out std_logic
--        );
--    end component;
    
    component VGA_Controller
        Port(
            pixel_clk   : in  std_logic;  -- 40 MHz clock (not bit because of rising edge)
            reset       : in std_logic;      -- manual reset, logic in top
            hsync       : out std_logic;
            vsync       : out std_logic;
            pixel_x     : out std_logic_vector (9 downto 0);      --horizontal pixel coordinates (1024 but only 640 needed)
            pixel_y     : out std_logic_vector (8 downto 0);      --vertical pixel coordinate (512 but only 480 needed)
            disp_ena    : out std_logic
        );
    end component;
   
    component Video_Renderer
        Port(
            -- combinatory
            field : in std_logic_vector(200 downto 1);  -- game field
            pixel_x : in std_logic_vector(9 downto 0);  -- screen pixel coordinates
            pixel_y : in std_logic_vector(8 downto 0);  -- 
            disp_ena  : in std_logic;
            score : in std_logic_vector(7 downto 0);
            red  : out std_logic_vector(3 downto 0);
            green: out std_logic_vector(3 downto 0);
            blue : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component Input_Controller
        Port(
            clk     : in std_logic;
            reset   : in std_logic; --Achtung Schalter!
            up      : in std_logic;
            down    : in std_logic;
            left    : in std_logic;
            right   : in std_logic;
            centre  : in std_logic;
            control : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component Game_Engine
        Port(
            clk : in std_logic;
            reset: in std_logic;
            counter: in std_logic_vector (7 downto 0);
            c_reset : out std_logic;
            control : in std_logic_vector(2 downto 0);
            tetrimino_piece: in std_logic_vector (2 downto 0);
            savedfield  : in std_logic_vector (200 downto 1);
            myblock     : in std_logic_vector(200 downto 1);
            set_update_myblock : out std_logic_vector(200 downto 1);
            set_update_saved : out std_logic_vector(200 downto 1);
            set_update_output : out std_logic_vector (200 downto 1);
            update_myblock_en: out std_logic;
            update_output_en : out std_logic;
            update_saved_en : out std_logic;
            score : out std_logic_vector(7 downto 0);
            cleared : out std_logic;
            endgame : out std_logic
        );
    end component;
    
    component Tick_Counter 
        Port(
            clk : in  std_logic;
            reset: in  std_logic;
            c_reset: in std_logic;
            counter_vector : out std_logic_vector (7 downto 0) --8-bit output
        );
    end component;
    
    component Field_RAM
        Port(
            clk         : in std_logic;
            reset       : in std_logic;
            update_saved: in std_logic_vector(200 downto 1);
            update_output: in std_logic_vector(200 downto 1);
            update_myblock: in std_logic_vector(200 downto 1);
            outputfield: out std_logic_vector(200 downto 1);
            savedfield: out std_logic_vector(200 downto 1);
            myblockfield: out std_logic_vector(200 downto 1);
            update_myblock_en: in std_logic;
            update_output_en : in std_logic;
            update_saved_en : in std_logic
        );
    end component;
    
    component PRNG
        Port(
            clk : in std_logic;
            reset : in std_logic;
            tetrimino_piece : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component Scoreboard
        Port(
            clk : in std_logic;
            reset: in std_logic;
            score: in std_logic_vector(7 downto 0); -- max 255
            seg: out std_logic_vector (6 downto 0);
            digit_on: out std_logic_vector (3 downto 0)
        );
    end component;
    
--    component Melody 
--        Port (
--        clk    : in  std_logic;  -- 25 MHz
--        reset  : in  std_logic;
--        buzzer : out std_logic
--        );
--    end component;
    
    component Click
        Port(
            clk : in std_logic;
            reset : in std_logic;
            control : in std_logic_vector(2 downto 0);
            cleared : in std_logic;
            endgame : in std_logic;
            buzzer : out std_logic
        );
    end component;
    
begin
    reset <= not re_set;    --active low reset

    -- Instantiate clocking wizard
    clk_gen_inst : clk_wiz_0
        port map (
            clk_in1  => clk100,     --in
            reset    => reset,      --in
            clk_out1 => clk,        --out
            locked   => clk_locked  --out
        );
--    clocking: Clock
--        port map(
--            clk100 => clk100,
--            reset => reset,
--            clk => clk
--        );

    
    vga: VGA_Controller
        port map(
            pixel_clk => clk,
            reset => reset,
            hsync => hsync,
            vsync => vsync,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            disp_ena => disp_ena
        );
     
    renderer: Video_Renderer
        port map(
            field => outputfield,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            red => vga_Red,
            green => vga_Green,
            blue => vga_Blue,
            score => score,
            disp_ena => disp_ena
        );
    input: Input_Controller
        port map(
            clk => clk,
            reset => reset,
            up => btnU,
            down => btnD,
            left => btnL,
            right => btnR,
            centre => btnC,
            control => control
        );
        
    game_logic : Game_Engine
        port map(
            clk => clk,
            reset => reset,
            counter => counter,
            c_reset => c_reset,
            control => control,
            tetrimino_piece => tetrimino_piece,
            savedfield => savedfield,
            myblock =>  myblockfield,
            set_update_myblock => update_myblock,
            set_update_saved => update_saved,
            set_update_output => update_output,
            update_myblock_en => update_myblock_en,
            update_output_en => update_output_en,
            update_saved_en => update_saved_en,
            score => score,
            cleared => cleared,
            endgame => endgame
        );
    tick : Tick_Counter
        port map(
            clk => clk,
            reset => reset,
            c_reset => c_reset,
            counter_vector => counter
        );
    ram : Field_RAM
        port map(
            clk   => clk,
            reset => reset,
            update_saved => update_saved,
            update_output => update_output,
            update_myblock => update_myblock,
            update_saved_en => update_saved_en,
            update_output_en => update_output_en,
            update_myblock_en => update_myblock_en,
            outputfield => outputfield,
            savedfield => savedfield,
            myblockfield => myblockfield
        );
        
    pseudorandom : PRNG
        port map(
            clk => clk,
            reset => reset,
            tetrimino_piece => tetrimino_piece
        );
        
    highscore : Scoreboard
        port map(
            clk => clk100,
            reset => reset,
            score => score,
            seg => seg,
            digit_on => digit_on
        );
        
    tone : Click
        port map(
            clk => clk,
            reset => reset,
            control => control,
            cleared => cleared,
            endgame => endgame,
            buzzer => buzzer
        );
--    music : Melody
--        port map(
--            clk => clk,
--            reset => reset,
--            buzzer => buzzer
--        );

end Behavioral;
