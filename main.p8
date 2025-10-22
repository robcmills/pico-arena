-- utils

-- random weighted choice
function rndw(choices)
  local total=0
  for c in all(choices) do total+=c.w end
  local r=rnd(total)
  local run=0
  for c in all(choices) do
    run+=c.w
    if r<run then return c.v end
  end
end

-- constants
dmg_anim_time=0.1-- seconds player damage animation lasts
energy_pickup_amount=8 -- amount of energy per energy pickup
energy_spr=33 -- sprite index for energy pickups
is_solid_flag=0 -- flag for map sprites that are solid (can not be walked through)
line_delay=0.2 -- seconds between weapon fires
line_dmg=1
line_color=10
line_life=0.1 -- seconds
line_push=1 -- number of tiles a line collision pushes the player
move_delay=0.1 -- seconds between moves (only when btn held)
player_max_energy=16
player_max_hp=16
player_fire_anim_time=0.3 -- seconds player fire animation lasts
spawn_spr=4

-- colors
dark_gray=5
white=7
yellow=10

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
  -- collect valid spawn points
  local spawns={}
  local other_p=p.id==1 and p2 or p1
  for x=1,m.celw do
    for y=1,m.celh do
      if mget(x,y)==spawn_spr and other_p.x~=x and other_p.y~=y then
        add(spawns,{x=x,y=y})
      end
    end
  end

  -- choose a random spawn point
  local s=rnd(spawns)
  p.x=s.x
  p.y=s.y
  p.z=rnd({0,180})
  p.flip_x=p.z==180
  p.hp=player_max_hp
  p.last_spawn_time=now

  -- spawn particles
  p.spawn_particles={}
  for i=1,8 do
    local target_x=tile_to_pixel(p.x,"x")+1+rnd(4)
    local target_y=tile_to_pixel(p.y,"y")+1+rnd(4)
    local start_x=target_x
    local start_y=target_y-rnd(24)
    local size=rnd(2)
    local duration=0.32+rnd(0.32)
    local particle={
      c=rndw({{v=p.c,w=0.6},{v=white,w=0.1},{v=yellow,w=0.3}}),
      duration=duration,
      end_time=now+duration,
      size=size,
      start_time=now,
      start_y=start_y,
      target_y=target_y,
      x=start_x,
      y=start_y,
    }
    particle.update=function()
      local t=(now-particle.start_time)/particle.duration
      if t<0 then t=0 end
      if t>1 then t=1 end
      local eased=1-(1-t)^2 -- ease out slowdown
      particle.y=particle.start_y+(particle.target_y-particle.start_y)*eased
    end
    add(p.spawn_particles,particle)
  end
end

function _init()
  debug=0
  game_type="versus"
  now=0
  p1 = {
    c=12, -- color
    energy=player_max_energy,
    explode_particles={},
    score=0,
    hp=player_max_hp,
    id=1,
    flip_x=false,
    last_dmg_time=0,
    last_fire_bits=0,
    last_fire_time=0,
    last_move_bits=0,
    last_move_time=0,
    last_spawn_time=0,
    spawn_particles={},
    w=1, -- selected weapon (1=line)
    x=0, -- x position in tiles, relative to map origin (top left)
    y=0, -- y position in tiles, relative to map origin (top left)
    z=0, -- facing direction in degrees clockwise (0=East,90=South)
  }
  p2 = {
    c=8,
    energy=player_max_energy,
    explode_particles={},
    score=0,
    hp=player_max_hp,
    id=2,
    flip_x=true,
    last_dmg_time=0,
    last_fire_bits=0,
    last_fire_time=0,
    last_move_bits=0,
    last_move_time=0,
    last_spawn_time=0,
    spawn_particles={},
    w=1,
    x=0,
    y=0,
    z=180,
  }
  lines={} -- line weapon "tracers"
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
  -- target destination
  local to_x=p.x+dx
  local to_y=p.y+dy
  -- map collisions
  local to_spr=mget(to_x,to_y) -- target map sprite
  if fget(to_spr,is_solid_flag) then
    -- TODO: play solid bump sound
    return
  end
  -- player collisions
  local other_p=p.id==1 and p2 or p1
  if other_p.x==to_x and other_p.y==to_y and other_p.hp>0 then
    -- TODO: play player bump sound
    return
  end
  -- energy pickup
  if to_spr==energy_spr then
    p.energy+=energy_pickup_amount
    if p.energy>player_max_energy then p.energy=player_max_energy end
    -- TODO: play energy pickup sound
  end
  -- move player
  p.x=to_x
  p.y=to_y
end

function dmg_player(p, dmg)
  p.hp-=dmg
  p.last_dmg_time=now
end

function push_player(p, dir)
  -- get tile coordinates of push destination
  local to={x=p.x,y=p.y}
  if dir==0 then to.x+=line_push end
  if dir==180 then to.x-=line_push end
  if dir==90 then to.y+=line_push end
  if dir==-90 then to.y-=line_push end
  -- check if solid tile
  local to_spr=mget(to.x,to.y)
  if fget(to_spr,0) then return false end
  -- check if other player
  local other_p=p.id==1 and p2 or p1
  if other_p.x==to.x and other_p.y==to.y then return false end
  -- push player
  p.x=to.x
  p.y=to.y
  return true
end

function tile_to_pixel(tile,xy)
  return tile*8+(xy=="x" and m.sx or m.sy)
end

function explode_player(player, dir)
  local cx=tile_to_pixel(player.x,"x")+4
  local cy=tile_to_pixel(player.y,"y")+4
  local base_angle=0
  if dir==90 then base_angle=0.25
  elseif dir==180 then base_angle=0.5
  elseif dir==-90 then base_angle=-0.25
  end
  local spread=0.16
  local max_radius=4
  for i=1,16 do
    local size=flr(rnd(3))
    local spawn_angle=rnd()
    local spawn_radius=sqrt(rnd())*max_radius
    local angle=base_angle+(rnd()-0.5)*spread
    local speed=0.6+(2-size)*0.4+rnd(0.2) -- large=slow, small=fast
    local p={
      c=rnd({player.c,yellow,white}),
      end_time=now+0.5+rnd(0.5),
      size=size,
      x=cx+cos(spawn_angle)*spawn_radius,
      y=cy+sin(spawn_angle)*spawn_radius,
      vx=cos(angle)*speed,
      vy=-sin(angle)*speed
    }
    p.update=function()
      p.x+=p.vx
      p.y+=p.vy
    end
    add(player.explode_particles,p)
  end
end

function fire_line(p)
  if p.energy<=0 then
    -- TODO: play empty energy sound
    -- TODO: flash player energy bar light_gray
    return
  end

  local collider=nil -- entity colliding with line (if any)
  local collider_pushed=false -- entity colliding with line was pushed
  local s={x=p.x,y=p.y} -- start tile
  local t={x=p.x,y=p.y} -- target tile
  -- walk in dir until hitting a solid tile, player or screen edge
  local c=0
  while c<128 do
    c+=1
    if p.z==0 then t.x+=1 end
    if p.z==180 then t.x-=1 end
    if p.z==90 then t.y+=1 end
    if p.z==-90 then t.y-=1 end
    -- check for solid tile
    local to_spr=mget(t.x,t.y)
    if fget(to_spr,0) then
      collider='tile'
      break
    end
    -- check for player
    local other_p=p.id==1 and p2 or p1
    if other_p.x==t.x and other_p.y==t.y and other_p.hp>0 then
      collider='player'
      dmg_player(other_p, line_dmg)
      if other_p.hp>0 then
        collider_pushed=push_player(other_p, p.z)
      elseif #other_p.explode_particles==0 then
        explode_player(other_p, p.z)
        p.score+=1
      end
      break
    end
  end

  -- convert tile pos to pixel pos + map offset
  s.x=s.x*8+m.sx
  s.y=s.y*8+m.sy
  t.x=t.x*8+m.sx
  t.y=t.y*8+m.sy
  -- account for player direction and reticle offset (start pos)
  if p.z==0 then s.x+=10 end
  if p.z==180 then s.x-=4 end
  if p.z==0 or p.z==180 then
    s.y+=3
    t.y+=3
  end
  if p.z==-90 then s.y-=4 end
  if p.z==90 then s.y+=10 end
  if p.z==-90 or p.z==90 then
    s.x+=3
    t.x+=3
  end
  -- account for solid tile and player body offset (target pos)
  if collider=='tile' then
    if p.z==0 then t.x-=1 end
    if p.z==180 then t.x+=7 end
    if p.z==90 then t.y-=1 end
    if p.z==-90 then t.y+=7 end
  elseif collider=='player' then
    if p.z==180 then t.x+=6 end
    if p.z==-90 then t.y+=6 end
  end

  -- extend line if collider was pushed
  if collider_pushed then
    if p.z==0 then t.x+=line_push*tile_size end
    if p.z==180 then t.x-=line_push*tile_size end
    if p.z==90 then t.y+=line_push*tile_size end
    if p.z==-90 then t.y-=line_push*tile_size end
  end

  add(lines,{start_pos=s,target_pos=t,start_time=now,p=p.id})

  if p.energy>0 then p.energy-=1 end
  p.last_fire_time=now -- player fire animation
end

function fire_weapon(p)
  if p.w==1 then fire_line(p) end
end

function update_player_particles(player)
  -- spawn particles
  if #player.spawn_particles>0 then
    for particle in all(player.spawn_particles) do
      if particle.end_time<now then
        del(player.spawn_particles,particle)
      else
        particle.update()
      end
    end
  end

  -- explosion particles
  if #player.explode_particles>0 then
    for particle in all(player.explode_particles) do
      if particle.end_time<now then
        del(player.explode_particles,particle)
        if #player.explode_particles==0 and game_type=="versus" then
          spawn_player(player)
        end
      else
        particle.update()
      end
    end
  end
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
p1_fire_mask=16
p2_move_mask=3840
p2_fire_mask=4096

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

  -- weapon fire
  local p1_fire_bits=bits&p1_fire_mask
  if p1_fire_bits~=0 and (p1_fire_bits~=p1.last_fire_bits or now-p1.last_fire_time>line_delay) then
    fire_weapon(p1)
    p1.last_fire_bits=p1_fire_bits
    p1.last_fire_time=now
  end

  local p2_fire_bits=bits&p2_fire_mask
  if p2_fire_bits~=0 and (p2_fire_bits~=p2.last_fire_bits or now-p2.last_fire_time>line_delay) then
    fire_weapon(p2)
    p2.last_fire_bits=p2_fire_bits
    p2.last_fire_time=now
  end

  update_player_particles(p1)
  update_player_particles(p2)
end

function update_lines()
  for i,l in pairs(lines) do
    if now-l.start_time>line_life then
      deli(lines,i)
    end
  end
end

function _update()
  now=time()
  update_players()
  update_lines()
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

  if pnum==2 then
    pal(p1.c,p2.c) -- swap p1 -> p2 color (reuse same sprite)
  end

  if #p.spawn_particles>0 then
    -- draw spawn particles
    for p in all(p.spawn_particles) do
      rectfill(p.x,p.y,p.x+p.size,p.y+p.size,p.c)
    end
    pal()
    return
  end

  if #p.explode_particles>0 then
    -- draw explosion
    for p in all(p.explode_particles) do
      rectfill(p.x,p.y,p.x+p.size,p.y+p.size,p.c)
    end
    pal()
    return
  end

  if p.hp<=0 then
    pal()
    return
  end

  local sprn=17 -- left/right
  if p.z==-90 then sprn=18 end -- up
  if p.z==90 then sprn=19 end -- down

  local xoffset=p.flip_x and -1 or 0 -- account for off-center sprites

  -- player fire animation
  if p.last_fire_time>0 and now-p.last_fire_time<player_fire_anim_time then
    if sprn==17 then sprn=22 end -- use "squinting" sprites
    if sprn==19 then sprn=23 end
  end

  -- taking damage
  if p.last_dmg_time>0 and now-p.last_dmg_time<dmg_anim_time then
    if sprn==17 then sprn=22 end -- use "squinting" sprites
    if sprn==19 then sprn=23 end
    pal(p1.c,10) -- swap p1 color -> yellow
  end

  -- draw player sprite
  spr(sprn,p.x*8+xoffset+m.sx,p.y*8+m.sy,1,1,p.flip_x)
  draw_player_dir(p)
  pal()
end

function draw_hp(p)
  local x=p.id==1 and 1 or 128/2+13
  rect(x,9,x+player_max_hp*3,10,1) -- background
  if p.hp>0 then rect(x,9,x+p.hp*3,10,p.c) end -- hp
end

function draw_energy(p)
  local x=p.id==1 and 1 or 128/2+13
  rect(x,12,x+player_max_energy*3,13,dark_gray) -- background
  if p.energy>0 then rect(x,12,x+p.energy*3,13,yellow) end -- energy
end

function draw_lines()
  for l in all(lines) do
    line(
      l.start_pos.x,
      l.start_pos.y,
      l.target_pos.x,
      l.target_pos.y,
      line_color)
  end
end

-- pico8 palette color (int) to P8SCII Control Codes parameter (hex superset)
function int_to_p8hex(n)
  local set={1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f","g"}
  return set[n]
end

-- MM:SS with leading zeros
function format_time(t)
  local m=flr(t/60)
  local s=flr(t%60)
  return tostr(m<10 and "0" or "")..tostr(m)..":"..tostr(s<10 and "0" or "")..tostr(s)
end

function draw_hud()
  -- names
  print("player 1",1,2,p1.c)
  local p2hud_w=print("player 2",0,-16)
  print("player 2",screen_size-p2hud_w-1,2,p2.c)
  -- hp
  draw_hp(p1)
  draw_hp(p2)
  -- energy
  draw_energy(p1)
  draw_energy(p2)
  -- scores
  local p1_score_pad=tostr(p1.score<10 and "0" or "")..tostr(p1.score)
  local p1_score_hud="\#"..int_to_p8hex(p1.c).."\f7"..p1_score_pad
  print(p1_score_hud,screen_size/2-22,2)
  local p2_score_pad=tostr(p2.score<10 and "0" or "")..tostr(p2.score)
  local p2_score_hud="\#"..int_to_p8hex(p2.c).."\f7"..p2_score_pad
  print(p2_score_hud,screen_size/2+14,2)
  -- game clock
  print(format_time(now),screen_size/2-10,2)
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
  draw_lines()
  draw_hud()
end
