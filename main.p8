function _init()
 debug={}
 p1 = {
  flip_x=false,
  x=3,
  y=3,
  z=0, -- direction in degrees clockwise (0=East,90=South)
 }
 p2 = {
  flip_x=false,
  x=6,
  y=6,
  z=0, -- direction in degrees clockwise (0=East,90=South)
 }
end

function move_player_left(p)
 p.flip_x=true
 p.x-=1
 p.z=180
end

function move_player_right(p)
 p.flip_x=false
 p.x+=1
 p.z=0
end

function move_player_up(p)
 p.y-=1
 p.z=-90
end

function move_player_down(p)
 p.y+=1
 p.z=90
end

function update_players()
 local bits=btn()
 if bits&1~=0 then move_player_left(p1) end
 if bits&2~=0 then move_player_right(p1) end
 if bits&4~=0 then move_player_up(p1) end
 if bits&8~=0 then move_player_down(p1) end
 if bits&256~=0 then move_player_left(p2) end
 if bits&512~=0 then move_player_right(p2) end
 if bits&1024~=0 then move_player_up(p2) end
 if bits&2048~=0 then move_player_down(p2) end
end

function _update()
 update_players()
end

function draw_player_dir(p) -- draw direction reticle
 local x_offset=p.z==0 and 1 or p.z==180 and -1 or 0 -- offset to adjacent tile
 local x_tile_offset=p.z==0 and -1 or 0 -- account for off-center sprites
 local x=p.x*8+x_offset*8+x_tile_offset
 local y_offset=p.z==-90 and -1 or p.z==90 and 1 or 0
 local y_tile_offset=p.z==90 and -1 or 0
 local y=p.y*8+y_offset*8+y_tile_offset
 local sprn=x_offset==0 and 21 or 20
 spr(sprn,x,y,1,1,x_offset<0,y_offset<0)
end

function draw_player(pnum)
 local p = pnum==1 and p1 or p2

 local sprn=17 -- left/right
 if p.z==-90 then sprn=18 end -- up
 if p.z==90 then sprn=19 end -- down

 if pnum==2 then
  pal(12,8) -- swap blue for red
 end
 local xoffset=p.flip_x and -1 or 0
 spr(sprn,p.x*8+xoffset,p.y*8,1,1,p.flip_x) -- draw player sprite
 draw_player_dir(p)
 pal()
end

-- debug
function to_bin(n)
  return n==0 and "0" or to_bin(flr(n/2))..(n%2)
end

function _draw()
 cls()
 map()
 draw_player(1)
 draw_player(2)
 -- print(debug)
end
