---@diagnostic disable: lowercase-global
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
local g_cols = g.device.cols
local g_rows = g.device.rows

-- define global vars
-- ===================
local root_num = 24
local scale = "Major"
local gen_scale = mu.generate_scale_of_length(root_num, scale, g_cols) or {}
tab.print(gen_scale)
local g_scale_map = {}
local MODE = "direct"
local MODE_LIST = { "direct", "play", "record" }
local REC_NOTE_SEQ = {}
local seq_clock
-- init scale map
-- ===============
function init_scale_map()
  for y = 1, g_rows do
    g_scale_map[y] = {}
    for x = 1, g_cols do
      local note_offset = gen_scale[(17 - y)]
      g_scale_map[y][x] = {
        x = x,
        y = y,
        note = gen_scale[x] + note_offset

      }
    end
  end
end

-- init params options:
-- ====================
function init_params()
  scale_names = {}
  for i = 1, #mu.SCALES do
    table.insert(scale_names, mu.SCALES[i].name)
  end

  params:add {
    type = "number",
    id = "root_note",
    name = "root note",
    min = 0,
    max = 127,
    default = root_num,
    formatter = function(param)
      return mu.note_num_to_name(param:get() * 2, true)
    end,
    action = function(x)
      root_num = x
      update_scale_map()
    end
  }
  params:add {
    type = "option",
    id = "scale",
    name = "scale",
    options = scale_names,
    default = 1,
    action = function(x)
      scale = scale_names[x]
      update_scale_map()
    end
  }

  params:add {
    type = "option",
    id = "mode",
    name = "Mode",
    options = MODE_LIST,
    default = 1,
    action = function(x)
      MODE = MODE_LIST[x]
    end
  }
end

function update_scale_map()
  gen_scale = mu.generate_scale_of_length(root_num, scale, g_cols) or {}
  init_scale_map()
end

function init()
  init_params()
  init_scale_map()

  tab.print(g_scale_map[16][1])
end

function g.key(x, y, z)
  -- determine pressed note:
  local pressed_note
  if z == 1 then
    pressed_note = g_scale_map[y][x]
  end
  -- =======================



  -- play mode:
  if MODE == 'play' and z == 1 then
    seq_clock = clock.run(function() 
      play_seq(pressed_note) 
      draw_grid_note(pressed_note.x, pressed_note.y, 15)
      end)
    return
  elseif MODE == 'play' and z == 0 then
    clock.cancel(seq_clock)
  end

  -- =============
  -- Record Mode:
  if MODE == 'record' and z == 1 then
    table.insert(REC_NOTE_SEQ, pressed_note)
    tab.print(REC_NOTE_SEQ)
  end
  -- ==============

  if z == 1 and g_scale_map[y][x].note < 127 then
    engine.hz(mu.note_num_to_freq(pressed_note.note))
  end
  draw_grid_note(x, y, z)
end

function draw_grid_note(x, y, z)
  g:led(g_scale_map[y][x].x, g_scale_map[y][x].y, z * 15)
  g:refresh()
end

function key(n, z)
  if n == 3 and z == 1 then params:set('mode', 3) end
  if n == 3 and z == 0 then params:set('mode', 2) end
end

function test()
  while true do
    clock.sync(1 / 4)
    engine.hz(220)
  end
end

function play_seq(played_note)
  local i = 1
  while true do
    clock.sync(1 / 4)
    print("note played: ", played_note.note)
    if i > #REC_NOTE_SEQ then i = 1 end
    print("i: ", i)

    -- REC_NOTE_SEQ[i].note - REC_NOTE_SEQ[1].note is so we can get the relative note intervals starting with 0 at the first note
    local resulting_note = played_note.note + (REC_NOTE_SEQ[i].note - REC_NOTE_SEQ[1].note)
    print("resulting_note: ", resulting_note)
    engine.hz(mu.note_num_to_freq(resulting_note))
    if i > 1 then g:led(REC_NOTE_SEQ[i - 1].x, REC_NOTE_SEQ[i - 1].y, 0 ) end
    g:led(REC_NOTE_SEQ[i].x, REC_NOTE_SEQ[i].y, 15 )
    g:refresh()
    i = i + 1
  end
end

