-- constants
p_hp=16
spawn_spr=4

maps={
 map1={
  celx=0,
  cely=0,
  celh=10,
  celw=10,
 }
}

function init_map(_m)
 m=_m
 m.sx=flr((screen_size-tile_size*m.celw)/2)
 m.sy=flr((screen_size-tile_size*m.celh)/2)
end

function spawn_player(p)
 p.alive=true
 p.hp=p_hp
 local spawns={}
 local other_p=p.id==1 and p2 or p1
 for x=1,m.celw do
  for y=1,m.celh do
   if mget(x,y)==spawn_spr and other_p.x~=x and other_p.y~=y then
    add(spawns,{x=x,y=y})
   end
  end
 end
 local s=rnd(spawns)
 p.x=s.x
 p.y=s.y
end

function _init()
 debug=0
 move_delay=0.15 -- seconds between moves (only when btn held)
 now=0
 p1 = {
  alive=false,
  hp=p_hp,
  id=1,
  flip_x=false,
  last_move_bits=0,
  last_move_time=0,
  w=1, -- selected weapon (1=line)
  x=0, -- x position in tiles, relative to map origin (top left)
  y=0, -- y position in tiles, relative to map origin (top left)
  z=0, -- facing direction in degrees clockwise (0=East,90=South)
 }
 p2 = {
  alive=false,
  hp=p_hp,
  id=2,
  flip_x=true,
  last_move_bits=0,
  last_move_time=0,
  w=1,
  x=0,
  y=0,
  z=180,
 }
 m=nil -- active map
 screen_size=128
 tile_size=8

 init_map(maps.map1)
 spawn_player(p1)
 spawn_player(p2)
end

function move_player(p,z)
 local dx=z==0 and 1 or z==180 and -1 or 0
 local dy=z==90 and 1 or z==-90 and -1 or 0
 if z==0 then p.flip_x=false end
 if z==180 then p.flip_x=true end
 p.z=z
 local to_x=p.x+dx -- target destination
 local to_y=p.y+dy
 -- map collisions
 local to_spr=mget(to_x,to_y) -- target map sprite
 if fget(to_spr,0) then return end -- is_solid flag
 -- player collisions
 local other_p=p.id==1 and p2 or p1
 if other_p.x==to_x and other_p.y==to_y then return end
 p.x=to_x
 p.y=to_y
end

-- btn() returns a bitfield of all 12 button states for players 1 & 2
-- p1: bits 0..5  p2: bits 8..13
-- p1_mask=111111 p2_mask=11111100000000
-- o,x,down,up,right,left
-- p1_move_mask=1111 p2_move_mask=111100000000
--                                |  |    8421
--                                |  |   16
--                                |  |  32
--                                |  | 64
--                                |  |128
--                                |  256
--                                | 512
--                                |1024
--                                2048
p1_move_mask=15
p2_move_mask=3840

function update_players()
 local bits=btn()

 -- p1 movement
 local p1_move_bits=bits&p1_move_mask
 if p1_move_bits~=p1.last_move_bits or now-p1.last_move_time>move_delay then
  if bits&1~=0 then move_player(p1,180)
  elseif bits&2~=0 then move_player(p1,0)
  elseif bits&4~=0 then move_player(p1,-90)
  elseif bits&8~=0 then move_player(p1,90) end
  p1.last_move_bits=p1_move_bits
  p1.last_move_time=now
 end

 -- p2 movement
 local p2_move_bits=bits&p2_move_mask
 if p2_move_bits~=p2.last_move_bits or now-p2.last_move_time>move_delay then
  if bits&256~=0 then move_player(p2,180)
  elseif bits&512~=0 then move_player(p2,0)
  elseif bits&1024~=0 then move_player(p2,-90)
  elseif bits&2048~=0 then move_player(p2,90) end
  p2.last_move_bits=p2_move_bits
  p2.last_move_time=now
 end
end

function _update()
 now=time()
 update_players()
end

function draw_map()
 map(m.celx,m.cely,m.sx,m.sy,m.celw,m.celh)
end

function draw_player_dir(p) -- draw direction reticle
 local x_offset=p.z==0 and 1 or p.z==180 and -1 or 0 -- offset to adjacent tile
 local x_tile_offset=p.z==0 and -1 or 0 -- account for off-center sprites
 local x=p.x*8+x_offset*8+x_tile_offset+m.sx
 local y_offset=p.z==-90 and -1 or p.z==90 and 1 or 0
 local y_tile_offset=p.z==90 and -1 or 0
 local y=p.y*8+y_offset*8+y_tile_offset+m.sy
 local sprn=x_offset==0 and 21 or 20
 spr(sprn,x,y,1,1,x_offset<0,y_offset<0)
end

function draw_player(pnum)
 local p=pnum==1 and p1 or p2

 local sprn=17 -- left/right
 if p.z==-90 then sprn=18 end -- up
 if p.z==90 then sprn=19 end -- down

 if pnum==2 then
  pal(12,8) -- swap blue for red
 end
 local xoffset=p.flip_x and -1 or 0 -- account for off-center sprites
 spr(sprn,p.x*8+xoffset+m.sx,p.y*8+m.sy,1,1,p.flip_x) -- draw player sprite
 draw_player_dir(p)
 pal()
end

function draw_hud()
 print("player 1",1,1,12)
 print(p1.hp,1,9,14)
 print("player 2",95,1,8)
 print(p2.hp,95,9,14)
end

function to_bin(n)
  return n==0 and "0" or to_bin(flr(n/2))..(n%2)
end

function debug_print(str)
 print(str,1,120,6)
end

function _draw()
 cls()
 draw_map()
 draw_player(1)
 draw_player(2)
 draw_hud()
end
