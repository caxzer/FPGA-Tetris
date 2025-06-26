FPGA-Tetris

DY-Projekt
HAW HAMBURG



____NOTES___

Controls: 
- left_button : move left
- right_button : move right
- center_button : rotate
- up_button : start
- down_button : soft-drop

Features:
standard resolution : 640x480@60hz 25.175Mhz (25.17301Mhz instead because of PLL limitations!)
size of one block : 20x20 pixels
size of field : 100x200 pixels 
Block color: white
remove 1 pixel on the side of every block
centered field
block falls every 2 seconds
on clear: flash the line 3 times and clears it, then move the entire grid down by 1 cell

Terminology:
Tetrimino: tetris blocks
Block: one grid block of a Tetrimino cell 
Grid: game area with border (count starts from 0)
Field : game area excluding border (count from 1 onwards)
pixel: actual pixels of the resolution (count starts from 0)


Blocks (spawn position with respect with axis: x=5, y=2) and rotational axis (anti-clockwise):
line-piece: 
ooxo

L-piece:
  o
oxo

reverse L-piece:
o
oxo

T-piece:
 o
oxo

Z-piece:
oo
 xo

S-piece:
 oo
ox

square piece (no rotation!):
ox
oo

Module description:
VGA_Controller : generates vital H- and V-Sync for output, alongside pixel coordinates and display_enable signal 
Video_Renderer : takes grid and vga outputs for actual color generation and display on screen 
Game_Engine : !!NEEDS EXPANSION!! takes care of Tetermino generation, movement & rotation with collision, Line clearing, score
Field_RAM : supply game engine with current grid position updates grid on every tick with falling blocks , AND instant movement updates if control detected!
PRNG : generates a random number between 1 and 7 for the Tetriminos
Input_Controller : takes input and makes a bit vector for clean input signal
Scoreboard : 7-Segment-Display controller
Tick_counter : generates tick every 100ms (for control movements)(use 20 ticks for each fall)


Goals and timeline:
1. draw FSM and Block Diagramm
2. make display work

--- Zwischenbericht
3. draw blocks
4. blocks fall with each tick
5. blocks move 
6. clear/lose conditions
7. scoreboard
8. faster falling with each score

-- Finishing touches
9. Pseudorandom improvement

10. color? (optional)

-- 2 Days before presentation (no more code changes here, only improvements)
11. rework FSM and Block Diagram
12. Prep Presentation

--- Finalbericht

References (add here!): 
https://forum.digikey.com/t/vga-controller-vhdl/12794
https://github.com/sajadh76/VGA/blob/master/VGA%20(2).vhd
https://tomverbeure.github.io/video_timings_calculator
https://www.instructables.com/Video-Interfacing-With-FPGA-Using-VGA/

