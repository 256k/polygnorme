-- polygnomre
-- a soft recreation of polygome from stretta
-- based on a small demo video on YT.
--
-- by 256k.
--

-- a op-1 endless style sequencer
-- when in record mode:
-- the grid will be divided in a musical scale way
-- based on root note & scale chosen from params
-- each row will be a series of notes in the scale
-- each col will be chord numbers ( based on scale) 
-- chord as in chord progression chord. i dont know how it's called
-- maybe based on circle of fifths? tbd.
-- pressing a button will enter it an array of notes to be played in sequence
-- at a rate determined from params
-- we can enter notes or rests

-- in play mode:
-- each key is the root note onto which that entire sequence is based on and it plays. 
-- you can play multiple keys an they will each create their own times sequence that will play

-- other ideas:
-- having the top row be a control row
-- having the option to have a hold button so you don't have to hold the button down to play
-- perhaps have a reverse and random mode of play
-- 


engine.name = "PolyPerc"
local g = grid.connect()
local mu = require "musicutil"
local g_cols = g.cols
local g_rows = g.rows

-- define global vars
-- ===================
local root_num = 24
local scale = "Major"
local gen_scale = mu.generate_scale_of_length(root_num, scale, 16)
local g_scale_map ={}
   
   
-- init scale map
-- ===============
function init_scale_map()
x_index = 1
for y = 1, g_rows do
  g_scale_map[y] = {}
  for x = 1, g_cols do
    g_scale_map[y][x] = (gen_scale[x] + gen_scale[(17 - y)] + 5)
    
  end
end
end


function init()
  init_scale_map()
end
  

function g.key(x,y,z)
  if z == 1 then
    print("note", g_scale_map[y][x])
  engine.hz(mu.note_num_to_freq(g_scale_map[y][x]))  
  end
end

