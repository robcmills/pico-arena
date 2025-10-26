-- utils

function log(str)
  printh(str, "p8log.txt")
end

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
dash_damage=1
dmg_anim_time=0.16-- seconds player damage animation lasts
energy_pickup_amount=8 -- amount of energy per energy pickup
energy_respawn_time=15 -- seconds until energy respawns
line_delay=0.2 -- seconds between weapon fires
line_dmg=1
line_life=0.1 -- seconds
line_push=1 -- number of tiles a line collision pushes the player
player_dash_particle_lifetime=0.2 -- seconds a dash particle lasts
player_dash_velocity=0.02 -- seconds per tile of movement (lower is faster)
player_velocity=0.1 -- default velocity in seconds per tile (8 pixels)
player_max_energy=16
player_max_hp=16
player_fire_anim_time=0.3 -- seconds player fire animation lasts

-- colors
black=0
dark_blue=1
dark_purple=2
dark_green=3
brown=4
dark_gray=5
light_gray=6
white=7
red=8
orange=9
yellow=10
green=11
blue=12
indigo=13
pink=14
peach=15

-- sprites
is_solid_flag=0 -- flag for map sprites that are solid (can not be walked through)
energy_spr=33 -- sprite index for energy pickups
spawn_spr=4

arenas={
  arena1={
    celx=0,
    cely=0,
    celh=10,
    celw=10,
  }
}

function init_energy_pickups(a)
  for x=1,arena.celw do
    for y=1,arena.celh do
      if mget(x,y)==energy_spr then
        local key=x..","..y
        entities[key]={
          last_collected_time=nil,
          type="energy",
          x=x,
          y=y,
        }
      end
    end
  end
end

-- build stateful entities table from arena map
-- pico8 map editor is limited to only boolean flags on map tile sprites
-- we need moar
function init_entities(a)
  entities={}
  init_energy_pickups(a)
end

function init_arena(a)
  arena=a
  -- calculate offset to center map
  arena.sx=flr((screen_size-tile_size*arena.celw)/2)
  arena.sy=flr((screen_size-tile_size*arena.celh)/2)
  init_entities(arena)
end

function spawn_player(p)
  -- collect valid spawn points
  local spawns={}
  local other_p=p.id==1 and p2 or p1
  for x=1,arena.celw do
    for y=1,arena.celh do
      if mget(x,y)==spawn_spr and other_p.tile_x~=x and other_p.tile_y~=y then
        add(spawns,{x=x,y=y})
      end
    end
  end

  -- choose a random spawn point
  local s=rnd(spawns)
  p.tile_x=s.x
  p.tile_y=s.y
  p.pixel_x=s.x*tile_size+arena.sx
  p.pixel_y=s.y*tile_size+arena.sy
  p.z=rnd({0,180})
  p.flip_x=p.z==180
  p.hp=player_max_hp
  p.last_spawn_time=now

  -- spawn particles
  p.spawn_particles={}
  for i=1,8 do
    local target_x=tile_to_pixel(p.tile_x,"x")+1+rnd(4)
    local target_y=tile_to_pixel(p.tile_y,"y")+1+rnd(4)
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
  arena=nil -- active arena (map)
  entities={}
  debug=""
  game_type="versus"
  now=0
  p1 = {
    c=blue, -- color
    dash_particles={},
    energy=player_max_energy,
    explode_particles={},
    score=0,
    hp=player_max_hp,
    id=1,
    flip_x=false,
    last_dmg_time=0,
    last_fire_time=0,
    last_move_bits=0,
    last_move_time=nil,
    last_spawn_time=0,
    spawn_particles={},
    w=1, -- selected weapon (1=line)
    -- position state (of top-left corner of 8x8 sprite)
    pixel_x=0, -- current x position in pixels, relative to arena origin (top left)
    pixel_y=0, -- current y position in pixels, relative to arena origin (top left)
    tile_x=0, -- current x position in tile coordinates, relative to arena origin (top left)
    tile_y=0, -- current y position in tiles coordinates, relative to arena origin (top left)
    from_x=nil, -- movement starting x position in tile coordinates
    from_y=nil, -- movement starting y position in tile coordinates
    to_x=nil, -- movement target x position in tile coordinates
    to_y=nil, -- movement target y position in tile coordinates
    velocity=0, -- movement velocity in seconds per tile (8 pixels)
    z=0, -- facing direction in degrees clockwise (0=East,90=South)
  }
  p2 = {
    c=red,
    dash_particles={},
    energy=player_max_energy,
    explode_particles={},
    score=0,
    hp=player_max_hp,
    id=2,
    flip_x=true,
    last_dmg_time=0,
    last_fire_time=0,
    last_move_bits=0,
    last_move_time=nil,
    last_spawn_time=0,
    spawn_particles={},
    w=1,
    pixel_x=0,
    pixel_y=0,
    tile_x=0,
    tile_y=0,
    from_x=nil,
    from_y=nil,
    to_x=nil,
    to_y=nil,
    velocity=0,
    z=180,
  }
  lines={} -- line weapon "tracers"
  screen_size=128
  tile_size=8

  init_arena(arenas.arena1)
  spawn_player(p1)
  spawn_player(p2)
end

-- move player in direction z until they collide with something
-- deal damage if applicable
function dash_player(player,z)
  -- check if can dash
  if player.last_move_time~=nil then return end
  if player.energy<=0 then
    -- TODO: play empty energy sound
    -- TODO: flash player energy bar light_gray
    move_player(player,z)
    return
  end
  local collider=raycast({x=player.tile_x,y=player.tile_y},z,true)
  local target={x=collider.x,y=collider.y}
  -- get adjacent tile
  if z==0 then target.x-=1
  elseif z==180 then target.x+=1
  elseif z==90 then target.y-=1
  elseif z==-90 then target.y+=1 end
  -- cannot dash if already adjacent to collider
  if target.x==player.tile_x and target.y==player.tile_y then return end
  -- dash is happening
  -- update player flip state and z dir
  if z==0 then player.flip_x=false end
  if z==180 then player.flip_x=true end
  player.z=z
  -- move player
  player.last_move_time=now
  player.to_x=target.x
  player.to_y=target.y
  player.from_x=player.tile_x
  player.from_y=player.tile_y
  player.velocity=player_dash_velocity
  -- TODO: play dash sound
end

function player_dash_collision(player)
  local other_player=player.id==1 and p2 or p1
  local target={x=player.to_x,y=player.to_y}
  -- get adjacent tile
  if player.z==0 then target.x+=1
  elseif player.z==180 then target.x-=1
  elseif player.z==90 then target.y+=1
  elseif player.z==-90 then target.y-=1 end
  -- check if other player is occupying adjacent tile
  if target.x==other_player.tile_x and target.y==other_player.tile_y then
    -- damage collider
    dmg_player(other_player,dash_damage)
    if other_player.hp>0 then
      collider_pushed=push_player(other_player,player.z)
    elseif #other_player.explode_particles==0 then
      explode_player(other_player,player.z)
      player.score+=1
    end
  end
end

-- move player in direction z one tile
function move_player(player,z)
  if player.last_move_time~=nil then return end
  -- Update player flip state and z dir
  if z==0 then player.flip_x=false end
  if z==180 then player.flip_x=true end
  player.z=z
  -- destination
  local dx=z==0 and 1 or z==180 and -1 or 0
  local dy=z==90 and 1 or z==-90 and -1 or 0
  local to_x=player.tile_x+dx
  local to_y=player.tile_y+dy
  -- check for collisions that would prevent movement
  -- solid tiles
  local to_spr=mget(to_x,to_y) -- target map sprite
  if fget(to_spr,is_solid_flag) then
    -- TODO: play solid bump sound
    return
  end
  -- other player collisions
  local other_player=player.id==1 and p2 or p1
  if other_player.tile_x==to_x and other_player.tile_y==to_y and other_player.hp>0 then
    -- TODO: play player bump sound
    return
  end
  -- move player
  player.last_move_time=now
  player.to_x=to_x
  player.to_y=to_y
  player.from_x=player.tile_x
  player.from_y=player.tile_y
  player.velocity=player_velocity
end

function shield_player(player)
  if player.energy<=0 then return end
  player.shield=true
end

function dmg_player(p, dmg)
  p.hp-=dmg
  p.last_dmg_time=now
end

function push_player(p, dir)
  -- TODO: enable pushing to interrupt existing movement
  local prev_flip_x=p.flip_x
  local prev_z=p.z
  move_player(p,dir)
  -- prevent changing player direction
  p.flip_x=prev_flip_x
  p.z=prev_z
  -- return true if moved
  return p.last_move_time~=nil
end

function tile_to_pixel(tile,xy)
  return tile*8+(xy=="x" and arena.sx or arena.sy)
end

function explode_player(player,dir)
  -- get center of sprite
  local cx=player.pixel_x+4
  local cy=player.pixel_y+4
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
    -- particle
    local particle={
      c=rnd({player.c,yellow,white}),
      end_time=now+0.5+rnd(0.5),
      size=size,
      x=cx+cos(spawn_angle)*spawn_radius,
      y=cy+sin(spawn_angle)*spawn_radius,
      vx=cos(angle)*speed,
      vy=-sin(angle)*speed
    }
    particle.update=function()
      particle.x+=particle.vx
      particle.y+=particle.vy
    end
    add(player.explode_particles,particle)
  end
end

function raycast(from_tile,dir,intersect_void)
  intersect_void=intersect_void==nil and false or intersect_void
  local target={x=from_tile.x,y=from_tile.y}
  -- walk in dir until hitting a solid tile, player or go offscreen
  local c=0
  while c<16 do
    c+=1
    if dir==0 then target.x+=1 end
    if dir==180 then target.x-=1 end
    if dir==90 then target.y+=1 end
    if dir==-90 then target.y-=1 end
    -- check for solid tile
    local to_spr=mget(target.x,target.y)
    if to_spr==0 and intersect_void then
      return {type='void',x=target.x,y=target.y}
    end
    if fget(to_spr,is_solid_flag) then
      return {type='tile',x=target.x,y=target.y}
    end
    -- check for player
    for p in all({p1,p2}) do
      if p.tile_x==target.x and p.tile_y==target.y and p.hp>0 then
        return {type='player',p=p,x=target.x,y=target.y}
      end
    end
  end
  return {type='offscreen',x=target.x,y=target.y}
end

function fire_line(p)
  if p.energy<=0 then
    -- TODO: play empty energy sound
    -- TODO: flash player energy bar light_gray
    return
  end

  local s={x=p.tile_x,y=p.tile_y} -- start tile
  local collider=raycast(s,p.z)
  local collider_pushed=false -- entity colliding with line was pushed
  local t=collider -- target tile

  if collider.type=='player' then
    dmg_player(collider.p,line_dmg)
    if collider.p.hp>0 then
      collider_pushed=push_player(collider.p,p.z)
    elseif #collider.p.explode_particles==0 then
      explode_player(collider.p,p.z)
      p.score+=1
    end
  end

  -- convert tile pos to pixel pos + map offset
  s.x=tile_to_pixel(s.x,"x")
  s.y=tile_to_pixel(s.y,"y")
  t.x=tile_to_pixel(t.x,"x")
  t.y=tile_to_pixel(t.y,"y")
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
  if collider.type=='tile' then
    if p.z==0 then t.x-=1 end
    if p.z==180 then t.x+=7 end
    if p.z==90 then t.y-=1 end
    if p.z==-90 then t.y+=7 end
  elseif collider.type=='player' then
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

  -- spawn dash particles
  if player.velocity==player_dash_velocity then
    local last_dash_particle=#player.dash_particles>0 and player.dash_particles[#player.dash_particles] or nil
    local particle_x=tile_to_pixel(player.tile_x,'x')+3
    local particle_y=tile_to_pixel(player.tile_y,'y')+3
    if last_dash_particle==nil or (last_dash_particle~=nil and (last_dash_particle.x~=particle_x or last_dash_particle.y~=particle_y)) then
      local dash_particle={
        c=yellow,
        end_time=now+player_dash_particle_lifetime,
        size=2,
        x=particle_x,
        y=particle_y,
      }
      add(player.dash_particles,dash_particle)
    end
  end

  -- update dash particles
  if #player.dash_particles>0 then
    for particle in all(player.dash_particles) do
      if particle.end_time<now then
        del(player.dash_particles,particle)
      end
    end
  end
end

function update_player_entity_collisions(p)
  local entity=entities[p.tile_x..","..p.tile_y]
  -- energy pickup
  if entity and entity.type=="energy" and entity.last_collected_time==nil and p.energy<player_max_energy then
    p.energy+=energy_pickup_amount
    if p.energy>player_max_energy then p.energy=player_max_energy end
    entity.last_collected_time=now
    -- TODO: play energy pickup sound
    -- TODO: flash player energy bar white
  end
end

function update_entities()
  for _,e in pairs(entities) do
    if e.type=="energy" and e.last_collected_time~=nil then
      if now-e.last_collected_time>energy_respawn_time then
	e.last_collected_time=nil
      end
    end
  end
  update_player_entity_collisions(p1)
  update_player_entity_collisions(p2)
end

function update_player_movement(p)
  if p.last_move_time==nil then return end

  local dir=p.from_x<p.to_x and 0 or p.from_x>p.to_x and 180 or p.from_y<p.to_y and 90 or -90
  local dtime=now-p.last_move_time
  local dtiles=(dir==0 or dir==180) and p.to_x-p.from_x or p.to_y-p.from_y
  local total_time=abs(dtiles)*p.velocity
  local interpolation=min(dtime/total_time,1)
  local dpixels=dtiles*tile_size*interpolation

  if dir==0 or dir==180 then
    p.pixel_x=p.from_x*tile_size+dpixels+arena.sx
  elseif dir==90 or dir==-90 then
    p.pixel_y=p.from_y*tile_size+dpixels+arena.sy
  end

  -- update current tile position based on pixel position
  p.tile_x=flr((p.pixel_x+tile_size/2-arena.sx)/tile_size)
  p.tile_y=flr((p.pixel_y+tile_size/2-arena.sy)/tile_size)

  -- are we done moving?
  if interpolation==1 then
    -- if we are ending a dash, do collision check
    if p.velocity==player_dash_velocity then
      player_dash_collision(p)
    end
    p.last_move_time=nil
    p.pixel_x=p.to_x*tile_size+arena.sx
    p.pixel_y=p.to_y*tile_size+arena.sy
    p.from_x=nil
    p.from_y=nil
    p.to_x=nil
    p.to_y=nil
    p.velocity=0
  end
end

function update_player_x(p, x_pressed)
  if x_pressed and now-p.last_fire_time>line_delay then
    fire_weapon(p)
    p.last_fire_time=now
  end
end

function update_player_o(p, o_pressed)
  p.shield=o_pressed and p.velocity==0 and p.energy>0
end

-- btn() returns a bitfield of all 12 button states for players 1 & 2
-- p1: bits 0..5  p2: bits 8..13
function update_player_input(p)
  local bits=btn()
  local shift=(p.id-1)*8
  local b=bits>>shift
  local p_left=b&1~=0
  local p_right=b&2~=0
  local p_up=b&4~=0
  local p_down=b&8~=0
  local p_x=b&16~=0
  local p_o=b&32~=0
  if p_left and p_o then dash_player(p,180)
  elseif p_left then move_player(p,180)
  elseif p_right and p_o then dash_player(p,0)
  elseif p_right then move_player(p,0)
  elseif p_up and p_o then dash_player(p,-90)
  elseif p_up then move_player(p,-90)
  elseif p_down and p_o then dash_player(p,90)
  elseif p_down then move_player(p,90)
  end
  update_player_x(p, p_x)
  update_player_o(p, p_o)
end

function update_player(p)
  update_player_movement(p)
  update_player_input(p)
  update_player_particles(p)
end

function update_players()
  update_player(p1)
  update_player(p2)
end

function update_lines()
  for i,l in pairs(lines) do
    if now-l.start_time>line_life then
      deli(lines,i)
    end
  end
end

function _update60()
  now=time()
  update_entities()
  update_players()
  update_lines()
end

function draw_arena()
  map(arena.celx,arena.cely,arena.sx,arena.sy,arena.celw,arena.celh)
end

function draw_energy_sprite(e,x,y)
  spr(energy_spr,x,y)
  pal(yellow,dark_gray)
  clip(x,y,tile_size,tile_size-2-flr((now-e.last_collected_time)/3))
  spr(energy_spr,x,y)
  clip()
  pal()
end

function draw_energy_entity(e)
  if e.last_collected_time==nil then return end
  -- if a player is "on top" of the energy pickup it will be obscured,
  -- so draw it in hud instead (so player can see respawn timing)
  if p1.tile_x==e.x and p1.tile_y==e.y then
    draw_energy_sprite(e,1,14)
  elseif p2.tile_x==e.x and p2.tile_y==e.y then
    draw_energy_sprite(e,128-8,14)
  else
    local x=e.x*tile_size+arena.sx
    local y=e.y*tile_size+arena.sy
    draw_energy_sprite(e,x,y)
  end
end

function draw_entities()
  for _,e in pairs(entities) do
    if e.type=="energy" then
      draw_energy_entity(e)
    end
  end
end

-- draw direction reticle
function draw_player_dir(p)
  local x_offset=p.z==0 and 1 or p.z==180 and -1 or 0 -- offset to adjacent tile
  local x_tile_offset=p.z==0 and -1 or 0 -- account for off-center sprites
  local x=p.pixel_x+x_offset*8+x_tile_offset
  local y_offset=p.z==-90 and -1 or p.z==90 and 1 or 0
  local y_tile_offset=p.z==90 and -1 or 0
  local y=p.pixel_y+y_offset*8+y_tile_offset
  local sprn=x_offset==0 and 21 or 20
  if p.velocity==player_dash_velocity then
    sprn=x_offset==0 and 25 or 24
  end
  spr(sprn,x,y,1,1,x_offset<0,y_offset<0)
end

function draw_player(p)
  if p.id==2 then
    pal(p1.c,p2.c) -- swap p1 -> p2 color (reuse same sprite)
  end

  if #p.spawn_particles>0 then
    -- draw spawn particles
    for par in all(p.spawn_particles) do
      rectfill(par.x,par.y,par.x+par.size,par.y+par.size,par.c)
    end
    pal()
    return
  end

  if #p.explode_particles>0 then
    -- draw explosion
    for par in all(p.explode_particles) do
      rectfill(par.x,par.y,par.x+par.size,par.y+par.size,par.c)
    end
    pal()
    return
  end

  if #p.dash_particles>0 then
    -- draw dash particles
    for par in all(p.dash_particles) do
      circfill(par.x,par.y,par.size,par.c)
    end
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

  -- yellow while taking damage or dashing
  if (p.last_dmg_time>0 and now-p.last_dmg_time<dmg_anim_time) or p.velocity==player_dash_velocity then
    if sprn==17 then sprn=22 end -- use "squinting" sprites
    if sprn==19 then sprn=23 end
    pal(p1.c,10) -- swap p1 color -> yellow
  end

  -- draw player sprite
  spr(sprn,p.pixel_x+xoffset,p.pixel_y,1,1,p.flip_x)

  -- shield or aim reticle
  if p.shield then
    circ(p.pixel_x+3,p.pixel_y+3,3,yellow)
  else
    draw_player_dir(p)
  end
  pal()
end

function draw_hp(p)
  local x=p.id==1 and 1 or 128/2+13
  rect(x,9,x+player_max_hp*3,10,1) -- background
  if p.hp>0 then rect(x,9,x+p.hp*3,10,p.c) end -- hp
end

function draw_energy_hud(p)
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
      yellow)
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
  draw_energy_hud(p1)
  draw_energy_hud(p2)
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
  draw_arena()
  draw_entities()
  draw_player(p1)
  draw_player(p2)
  draw_lines()
  draw_hud()
  debug_print(debug)
end
