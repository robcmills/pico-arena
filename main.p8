function _init()
 btn_bits=0
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

function update_player(pnum)
 local bits=btn()
 if bits~=0 then btn_bits=bits end -- for debugging

 if pnum==1 then
  if bits&1~=0 then move_player_left(p1) end
  if bits&2~=0 then move_player_right(p1) end
  if bits&4~=0 then move_player_up(p1) end
  if bits&8~=0 then move_player_down(p1) end
 elseif pnum==2 then
  if bits&256~=0 then move_player_left(p2)
  elseif bits&512~=0 then move_player_right(p2)
  elseif bits&1024~=0 then move_player_up(p2)
  elseif bits&2048~=0 then move_player_down(p2)
  end
 end
end

function _update()
 update_player(1)
 update_player(2)
end

function draw_player(pnum)
 local p = pnum==1 and p1 or p2
 local sprn=p.z<-45 and 18 or 17
 if pnum==2 then
  pal(12,8) -- swap blue for red
 end
 spr(sprn,p.x*8,p.y*8,1,1,p.flip_x)
 pal()
end

function to_bin(n)
  return n==0 and "0" or to_bin(flr(n/2))..(n%2)
end

function _draw()
 cls()
 map()
 draw_player(1)
 draw_player(2)
 print(to_bin(btn_bits))
end
