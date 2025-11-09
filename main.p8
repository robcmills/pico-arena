-- pico8 colors
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

-- pico8 input bit masks
input={
  p1_left=1,
  p1_right=2,
  p1_up=4,
  p1_down=8,
  p1_x=16,
  p1_o=32,
  p2_left=256,
  p2_right=512,
  p2_up=1024,
  p2_down=2048,
  p2_x=4096,
  p2_o=8192,
}

frame_duration_30=1/30
frame_duration_60=1/60

-- global state
s={}

-- global game state
g={}

-- maps
arenas={
  arena1={
    celx=0,
    cely=0,
    celh=10,
    celw=10,
  },
  arena2={
    celx=10,
    cely=0,
    celh=12,
    celw=16,
  },
  arena3={
    celx=26,
    cely=0,
    celh=12,
    celw=12,
  },
  menu={
    celx=0,
    cely=50,
    celh=14,
    celw=14,
  },
  test1={
    celx=119,
    cely=55,
    celh=9,
    celw=9,
  }
}

-- global test state
test={
  enabled=false,
  index=1,
  run_all=false,
  start_time=0,
}

tests={{
  init=function()
    logt("explode polish")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("duel", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      g.p2.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable immediate input
      g.p1.last_spawn_time=-g.settings.player_spawn_duration
      g.p2.last_spawn_time=-g.settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-g.settings.energy_loss_delay
      g.p2.last_energy_loss_time=-g.settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
      -- set player hp
      g.p1.hp=1
    end
  end,
  input=function()
    if g.frame==2 then
      logt("p2 shoots p1")
      test.fire_time=g.now
      return input.p2_x
    end
  end,
  update_post=function()
    if test.fire_time~=0 and g.now>test.fire_time+g.settings.player_explode_duration+frame_duration_60 then
      return true -- test finished
    end
  end,
}}

function init_tests()
  extcmd("rec_frames")
  logt("") -- separate tests with a blank line
  s.state="game"
  test.enabled=true
  test.start_time=time()
  tests[test.index].init()
end
function get_test_input()
  return tests[test.index].input()
end
function update_tests_pre()
  if not test.enabled then return end
  tests[test.index].update_pre()
end
function update_tests_post()
  if not test.enabled then return end
  if tests[test.index].update_post() then
    test.index+=1
    if not test.run_all or tests[test.index]==nil then
      extcmd("video")
      extcmd("shutdown")
    else
      init_tests()
    end
  end
end
-- end tests

-- get sprite number of arena tile
function aget(x,y)
  return mget(g.arena.celx+x,g.arena.cely+y)
end

function init_energy_pickups()
  for x=1,g.arena.celw do
    for y=1,g.arena.celh do
      if aget(x,y)==g.sprites.energy_spr then
        local key=x..","..y
        g.entities[key]={
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
function init_entities()
  init_energy_pickups()
end

function center_arena(a)
  -- add offset to center
  a.sx=flr((g.screen_size-g.tile_size*a.celw)/2)
  a.sy=flr((g.screen_size-g.tile_size*a.celh)/2)
end

function init_arena()
  center_arena(g.arena)
  init_entities()
end

function is_active(p)
  return p.hp>0 and not is_falling_into_void(p) and not is_spawning(p)
end

function is_bursting(p)
  return p.last_burst_time>0 and g.now<p.last_burst_time+g.settings.burst_grow_duration
end

function is_dashing(p)
  return p.velocity==g.settings.player_dash_velocity
end

function is_input_active(p)
  return is_active(p)
end

function is_falling_into_void(p)
  return p.void_fall_start~=nil and g.now-p.void_fall_start<=g.settings.player_fall_into_void_anim_time
end

function is_firing(p)
  return p.last_fire_time>0 and g.now-p.last_fire_time<g.settings.player_fire_anim_time
end

function is_spawning(p)
  return g.now-p.last_spawn_time<=g.settings.player_spawn_duration
end

function is_taking_damage(p)
  return p.last_dmg_time>0 and g.now-p.last_dmg_time<g.settings.player_damage_duration
end

function is_void(spr)
  return spr==g.sprites.void
end

function spawn_player(p)
  -- collect valid spawn points
  local spawns={}
  local other_p=p.id==1 and g.p2 or g.p1
  for x=0,g.arena.celw do
    for y=0,g.arena.celh do
      if aget(x,y)==g.sprites.spawn_spr and (other_p.tile_x~=x or other_p.tile_y~=y) then
        add(spawns,{x=x,y=y})
      end
    end
  end

  -- choose a random spawn point
  local s=rnd(spawns)
  p.tile_x=s.x
  p.tile_y=s.y
  p.pixel_x=tile_to_pixel(s.x,"x")
  p.pixel_y=tile_to_pixel(s.y,"y")

  -- set dir towards map center
  p.z=p.tile_x<g.arena.celw/2 and 0 or 180
  p.flip_x=p.z==180
  p.hp=g.settings.player_max_hp
  p.last_spawn_time=g.now

  -- spawn particles
  p.spawn_particles={}
  for i=1,8 do
    local target_x=tile_to_pixel(p.tile_x,"x")+1+rnd(4)
    local target_y=tile_to_pixel(p.tile_y,"y")+1+rnd(4)
    local start_x=target_x
    local start_y=target_y-rnd(24)
    local size=rnd(2)
    local duration=g.settings.player_spawn_duration
    local particle={
      c=rndw({{v=p.c,w=0.6},{v=white,w=0.1},{v=yellow,w=0.3}}),
      duration=duration,
      end_time=g.now+duration,
      size=size,
      start_time=g.now,
      start_y=start_y,
      target_y=target_y,
      x=start_x,
      y=start_y,
    }
    particle.update=function()
      local t=(g.now-particle.start_time)/particle.duration
      if t<0 then t=0 end
      if t>1 then t=1 end
      local eased=1-(1-t)^2 -- ease out slowdown
      particle.y=particle.start_y+(particle.target_y-particle.start_y)*eased
    end
    add(p.spawn_particles,particle)
  end
end

function init_game(game_type, arena)
  g={
    -- init global state
    arena=arena, -- active arena (map)
    entities={},
    debug="",
    frame=0,
    game_type=game_type,
    now=0,
    p1={
      burst_particles={},
      c=blue, -- color
      dash_particles={},
      energy=0,
      explode_particles={},
      score=0,
      hp=0,
      id=1,
      flip_x=false,
      last_burst_time=0,
      last_dmg_time=0,
      last_energy_loss_time=0,
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
      void_fall_start=nil, -- time when player started falling into void
      z=0, -- facing direction in degrees clockwise (0=East,90=South)
    },
    p2={
      burst_particles={},
      c=red,
      dash_particles={},
      energy=0,
      explode_particles={},
      score=0,
      hp=0,
      id=2,
      flip_x=true,
      last_burst_time=0,
      last_dmg_time=0,
      last_energy_loss_time=0,
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
      void_fall_start=nil,
      z=180,
    },
    lines={}, -- line weapon "tracers"
    screen_size=128,
    settings={
      burst_color=yellow,
      burst_delay=0.2,  -- seconds between burst fires
      burst_energy_loss=1,
      burst_grow_duration=0.2,  -- seconds burst radius grows
      burst_ring_color=dark_gray,
      burst_ring_duration=0.1,  -- seconds burst ring remains after growth
      burst_radius=12,
      dash_damage=1,
      enable_void_suicide=false,
      energy_loss_delay=0.32,  -- seconds until energy loss is applied (debounce) should be greater than burst_grow_duration else a single burst will drain multiple energy
      energy_pickup_amount=8,  -- amount of energy per energy pickup
      energy_respawn_time=15,  -- seconds until energy respawns
      line_delay=0.2,  -- seconds between weapon fires
      line_dmg=1,
      line_life=0.1,  -- seconds
      line_push=1,  -- number of tiles a line collision pushes the player
      player_damage_duration=0.32, -- seconds player damage animation lasts
      player_dash_particle_lifetime=0.2,  -- seconds a dash particle lasts
      player_dash_velocity=0.02,  -- seconds per tile of movement (lower is faster)
      player_explode_duration=1, -- seconds player explode animation lasts
      player_fall_into_void_anim_time=0.3, -- seconds player fall into void animation lasts
      player_fire_anim_time=0.3,  -- seconds player fire animation lasts
      player_max_energy=16,
      player_max_hp=8,
      player_radius=2,
      player_spawn_duration=0.64, -- seconds player spawn animation lasts
      player_velocity=0.15,  -- default velocity in seconds per tile (8 pixels)
    },
    sprites={
      flags={
        is_solid=0, -- block movement
      },
      energy_spr=33, -- sprite index for energy pickups
      spawn_spr=4,
      void=0,
    },
    start_time=time(),
    tile_size=8,
  }
  -- init game state that depends on settings
  g.p1.energy=g.settings.player_max_energy
  g.p2.energy=g.settings.player_max_energy
  g.p1.hp=g.settings.player_max_hp
  g.p2.hp=g.settings.player_max_hp
  -- init arena
  init_arena()
  -- spawn players
  spawn_player(g.p1)
  spawn_player(g.p2)
end

-- initialize global state
function init_state()
  s={
    menu={
      game_types={"duel","ctf"},
      input_delay=0.14,
      items={"game_type","time_limit","arena","start"},
      last_input_time=0,
      selected_arena_index=1,
      selected_game_type_index=1,
      selected_item_index=1,
      selected_time_limit_index=1,
      time_limits={2,4,8},
    },
    state="start",
  }
end

function _init()
  init_state()
  --s.state="game"
  --init_game("duel", arenas.arena2)
  init_tests()
end

-- move player in direction z until they collide with something
-- is_continue is true if we are continuing existing dash
function dash_player(player,z,is_continue)
  is_continue=is_continue==nil and false or is_continue
  if not is_continue then
    -- check if can dash
    if player.last_move_time~=nil then return end
    if player.energy<=0 then
      -- TODO: play empty energy sound
      -- TODO: flash player energy bar light_gray
      move_player(player,z)
      return
    end
  end
  local collider=raycast({x=player.tile_x,y=player.tile_y},z,true)
  local target={x=collider.x,y=collider.y}
  if collider.type~='void' or (collider.type=='void' and not g.settings.enable_void_suicide) then
    -- get adjacent tile
    if z==0 then target.x-=1
    elseif z==180 then target.x+=1
    elseif z==90 then target.y-=1
    elseif z==-90 then target.y+=1 end
  end
  -- cannot dash if already adjacent to collider
  if target.x==player.tile_x and target.y==player.tile_y then return end
  -- dash is happening
  -- update player flip state and z dir
  if z==0 then player.flip_x=false end
  if z==180 then player.flip_x=true end
  player.z=z
  if not is_continue then
    lose_energy(player,1)
  end
  -- move player
  player.last_move_time=g.now
  player.to_x=target.x
  player.to_y=target.y
  player.from_x=player.tile_x
  player.from_y=player.tile_y
  player.velocity=g.settings.player_dash_velocity
  -- TODO: play dash sound
end

function increase_score(p)
  p.score+=1
end

-- check for collisions mid-dash
-- necessary to enable continued dashing if collider moved out of the way
-- returns true if collision detected
-- returns false if path is clear to continue dashing
function player_dash_collision(player)
  local other_player=player.id==1 and g.p2 or g.p1
  local target={x=player.tile_x,y=player.tile_y}
  -- get adjacent tile
  if player.z==0 then target.x+=1
  elseif player.z==180 then target.x-=1
  elseif player.z==90 then target.y+=1
  elseif player.z==-90 then target.y-=1 end
  -- check if other player is occupying adjacent tile
  if target.x==other_player.tile_x and target.y==other_player.tile_y then
    -- if collision detected, cancel dash
    cancel_movement(player)
    -- check for dash vs dash collision
    if is_dashing(other_player) and other_player.z==get_opposite_direction(player.z) then
      dmg_player(player,g.settings.dash_damage)
      if player.hp>0 then
        push_player(player,other_player.z)
      elseif #player.explode_particles==0 then
        explode_player(player,other_player.z)
        increase_score(other_player)
      end
    end
    -- damage collider
    dmg_player(other_player,g.settings.dash_damage)
    if other_player.hp>0 then
      collider_pushed=push_player(other_player,player.z)
    elseif #other_player.explode_particles==0 then
      explode_player(other_player,player.z)
      increase_score(player)
    end
    return true
  end
  -- check entity collisions
  local collider=raycast({x=player.tile_x,y=player.tile_y},player.z,true)
  if collider.x==target.x and collider.y==target.y then
    cancel_movement(player)
    return true
  end
  return false
end

-- move player in direction z one tile
function move_player(player,z,is_push)
  is_push=is_push==nil and false or is_push
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
  local to_spr=aget(to_x,to_y) -- target arena sprite
  -- solid tiles
  if fget(to_spr,g.sprites.is_solid) then
    -- TODO: play solid bump sound
    return false
  end
  -- void
  if not is_push and not g.settings.enable_void_suicide and is_void(to_spr) then
    -- TODO: play void bump sound
    return false
  end
  -- other player collisions
  local other_player=player.id==1 and g.p2 or g.p1
  if other_player.tile_x==to_x and other_player.tile_y==to_y and other_player.hp>0 then
    -- TODO: play player bump sound
    return false
  end
  -- move player
  player.last_move_time=g.now
  player.to_x=to_x
  player.to_y=to_y
  player.from_x=player.tile_x
  player.from_y=player.tile_y
  player.velocity=g.settings.player_velocity
  return true
end

function set_player_pos(player,x,y,z)
  player.tile_x=x
  player.tile_y=y
  player.pixel_x=tile_to_pixel(x,"x")
  player.pixel_y=tile_to_pixel(y,"y")
  player.z=z
  player.flip_x=z==180
end

function dmg_player(p, dmg)
  p.hp-=dmg
  p.last_dmg_time=g.now
end

function push_player(p,dir)
  -- prevent changing player direction
  local prev_flip_x=p.flip_x
  local prev_z=p.z
  move_player(p,dir,true)
  p.flip_x=prev_flip_x
  p.z=prev_z
  -- return true if moved
  return p.last_move_time~=nil
end

function tile_to_pixel(tile,xy)
  return tile*g.tile_size+(xy=="x" and g.arena.sx or g.arena.sy)
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
      end_time=g.now+g.settings.player_explode_duration,
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
    local to_spr=aget(target.x,target.y)
    if to_spr==0 and intersect_void then
      return {type='void',x=target.x,y=target.y}
    end
    if fget(to_spr,g.sprites.is_solid) then
      return {type='tile',x=target.x,y=target.y}
    end
    -- check for player
    for p in all({g.p1,g.p2}) do
      if p.tile_x==target.x and p.tile_y==target.y and is_active(p) then
        return {type='player',p=p,x=target.x,y=target.y}
      end
    end
  end
  return {type='offscreen',x=target.x,y=target.y}
end

-- player "collider" is hit by player "shooter" with line weapon in given direction "z"
function player_line_collision(collider,shooter,z)
  dmg_player(collider,g.settings.line_dmg)
  if collider.hp>0 then
    if is_dashing(collider) then
      collider.dash_particles={}
    end
    collider_pushed=push_player(collider,z)
  elseif #collider.explode_particles==0 then
    explode_player(collider,z)
    increase_score(shooter)
  end
end

function fire_line(p)
  p.last_fire_time=g.now
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
    -- if collider player is shielding or bursting then shooter is damaged
    if collider.p.shield or is_bursting(collider.p) then
      player_line_collision(p,collider.p,get_opposite_direction(p.z))
      lose_energy(collider.p,g.settings.line_dmg)
    elseif not is_taking_damage(collider.p) then
      player_line_collision(collider.p,p,p.z)
    end
  end

  -- convert tile pos to pixel pos + map offset
  s.x=tile_to_pixel(s.x,"x")
  s.y=tile_to_pixel(s.y,"y")
  t.x=tile_to_pixel(t.x,"x")
  t.y=tile_to_pixel(t.y,"y")
  -- account for player direction and reticle offset (start pos)
  if p.z==0 then s.x+=9 end
  if p.z==180 then s.x-=3 end
  if p.z==0 or p.z==180 then
    s.y+=3
    t.y+=3
  end
  if p.z==-90 then s.y-=3 end
  if p.z==90 then s.y+=9 end
  if p.z==-90 or p.z==90 then
    s.x+=3
    t.x+=3
  end
  -- account for solid tile and player body offset (target pos)
  if collider.type=='tile' then
    if p.z==0 then t.x-=1
    elseif p.z==180 then t.x+=7
    elseif p.z==90 then t.y-=1
    elseif p.z==-90 then t.y+=7 end
  elseif collider.type=='player' then
    if p.z==0 then t.x-=1
    elseif p.z==180 then t.x+=7
    elseif p.z==90 then t.y-=1
    elseif p.z==-90 then t.y+=6 end
  end
  add(g.lines,{
    collider=collider,
    p=p.id,
    start_pos=s,
    start_time=g.now,
    target_pos=t,
    z=p.z,
  })
  lose_energy(p,g.settings.line_dmg)
end

function fire_weapon(p)
  if p.w==1 then fire_line(p) end
end

function get_player_center(p)
  return {x=p.pixel_x+3,y=p.pixel_y+3}
end

function get_distance(x1,y1,x2,y2)
  local dx=x2-x1
  local dy=y2-y1
  return sqrt(dx*dx+dy*dy)
end

function get_burst_push_z(x1,y1,x2,y2,z)
  local dx=x2-x1
  local dy=y2-y1
  -- cardinal directions
  if abs(dx)>0 and dy==0 then
    return dx>0 and 0 or 180
  elseif dx==0 and abs(dy)>0 then
    return dy>0 and 90 or -90
  end
  -- diagonals
  if dx~=0 and dy~=0 then
    z=((z+180)%360)-180 -- normalize to [-180,180)
    local horizontal_bias=(abs(z)<=45 or abs(z)>=135)
    if horizontal_bias then
      return dx>0 and 0 or 180
    else
      return dy>0 and 90 or -90
    end
  end
  return 0 -- points are the same
end

function lose_energy(p,amount)
  p.energy-=amount
  p.last_energy_loss_time=g.now
end

function can_lose_energy(p)
  return p.energy>0 and g.now-p.last_energy_loss_time>g.settings.energy_loss_delay
end

function cancel_burst(player,particle)
  del(player.burst_particles,particle)
end

function update_burst_collisions(player,particle)
  -- player collision
  local other_player=player.id==1 and g.p2 or g.p1
  local c=get_player_center(other_player)
  local dist=get_distance(particle.x,particle.y,c.x,c.y)-g.settings.player_radius-1
  if dist<=particle.radius then
    local push_z=get_burst_push_z(particle.x,particle.y,c.x,c.y,other_player.z)
    -- if other player is shielding or bursting then they take no damage
    if other_player.shield or is_bursting(other_player) then
      if can_lose_energy(other_player) then
        lose_energy(other_player,g.settings.burst_energy_loss)
      end
    elseif is_dashing(other_player) then
      -- dash beats burst
      cancel_burst(player,particle)
    elseif not is_taking_damage(other_player) then
      player_line_collision(other_player,player,push_z)
    end
  end
end

function get_burst_particle(p)
  local center=get_player_center(p)
  local particle = {
    c=g.settings.burst_color,
    end_time=g.now+g.settings.burst_grow_duration+g.settings.burst_ring_duration,
    radius=3,
    start_time=g.now,
    x=center.x,
    y=center.y,
  }
  particle.update=function()
    -- interpolate radius based on time
    local t=(g.now-particle.start_time)/g.settings.burst_grow_duration
    if t<0 then t=0 end
    if t>1 then t=1 end
    local ease=1-(1-t)^3 -- ease out slowdown
    particle.radius=3+ease*(g.settings.burst_radius-3)
    update_burst_collisions(p,particle)
  end
  return particle
end

function fire_burst(p)
  if p.energy<=0 then
    -- TODO: play empty energy sound
    -- TODO: flash player energy bar light_gray
    return
  end
  p.last_fire_time=g.now
  p.last_burst_time=g.now
  lose_energy(p,g.settings.burst_energy_loss)
  -- spawn burst particles
  add(p.burst_particles,get_burst_particle(p))
end

function update_player_burst_particles(player)
  if #player.burst_particles>0 then
    for particle in all(player.burst_particles) do
      if particle.end_time<g.now then
        del(player.burst_particles,particle)
      else
        particle.update()
      end
    end
  end
end

function update_player_spawn_particles(player)
  if #player.spawn_particles>0 then
    for particle in all(player.spawn_particles) do
      if particle.end_time<g.now then
        del(player.spawn_particles,particle)
      else
        particle.update()
      end
    end
  end
end

function update_player_explode_particles(player)
  if #player.explode_particles>0 then
    for particle in all(player.explode_particles) do
      if particle.end_time<g.now then
        del(player.explode_particles,particle)
        if #player.explode_particles==0 and g.game_type=="duel" then
          spawn_player(player)
        end
      else
        particle.update()
      end
    end
  end
end

function update_player_dash_particles(player)
  -- kill old dash particles
  for key,particle in pairs(player.dash_particles) do
    if particle.end_time<g.now then
      player.dash_particles[key]=nil
    end
  end
  if not is_dashing(player) then return end
  -- spawn new dash particles.
  -- if dash particle does not exist on that tile then spawn
  local key=player.tile_x..","..player.tile_y
  if not player.dash_particles[key] then
    local dash_particle={
      c=white,
      end_time=g.now+g.settings.player_dash_particle_lifetime,
      size=2,
      tile_x=player.tile_x,
      tile_y=player.tile_y,
      x=tile_to_pixel(player.tile_x,'x')+3,
      y=tile_to_pixel(player.tile_y,'y')+3,
    }
    player.dash_particles[key]=dash_particle
  end
end

function update_player_particles(player)
  update_player_spawn_particles(player)
  update_player_explode_particles(player)
  update_player_dash_particles(player)
  update_player_burst_particles(player)
end

function update_player_entity_collisions(p)
  local entity=g.entities[p.tile_x..","..p.tile_y]
  -- energy pickup
  if entity and entity.type=="energy" and entity.last_collected_time==nil and p.energy<g.settings.player_max_energy then
    p.energy+=g.settings.energy_pickup_amount
    if p.energy>g.settings.player_max_energy then p.energy=g.settings.player_max_energy end
    entity.last_collected_time=g.now
    -- TODO: play energy pickup sound
    -- TODO: flash player energy bar white
  end
end

function update_entities()
  for _,e in pairs(g.entities) do
    if e.type=="energy" and e.last_collected_time~=nil then
      if g.now-e.last_collected_time>g.settings.energy_respawn_time then
        e.last_collected_time=nil
      end
    end
  end
  update_player_entity_collisions(g.p1)
  update_player_entity_collisions(g.p2)
end

function cancel_movement(p)
  p.last_move_time=nil
  p.pixel_x=tile_to_pixel(p.tile_x,"x")
  p.pixel_y=tile_to_pixel(p.tile_y,"y")
  p.from_x=nil
  p.from_y=nil
  p.to_x=nil
  p.to_y=nil
  p.velocity=0
end

function update_player_movement(p)
  if p.last_move_time==nil then return end

  local dir=p.from_x<p.to_x and 0 or p.from_x>p.to_x and 180 or p.from_y<p.to_y and 90 or -90
  local dtime=g.now-p.last_move_time
  local dtiles=(dir==0 or dir==180) and p.to_x-p.from_x or p.to_y-p.from_y
  local total_time=abs(dtiles)*p.velocity
  local interpolation=min(dtime/total_time,1)
  local dpixels=dtiles*g.tile_size*interpolation

  if dir==0 or dir==180 then
    p.pixel_x=tile_to_pixel(p.from_x,"x")+dpixels
    -- if existing perpendicular partially interpolated movement then
    -- cancel it by "snapping" to new movement direction
    p.pixel_y=tile_to_pixel(p.to_y,"y")
  elseif dir==90 or dir==-90 then
    p.pixel_y=tile_to_pixel(p.from_y,"y")+dpixels
    p.pixel_x=tile_to_pixel(p.to_x,"x")
  end

  -- update current tile position based on pixel position
  p.tile_x=flr((p.pixel_x+g.tile_size/2-g.arena.sx)/g.tile_size)
  p.tile_y=flr((p.pixel_y+g.tile_size/2-g.arena.sy)/g.tile_size)

  -- if we are dashing, do collision check
  if p.velocity==g.settings.player_dash_velocity then
    if interpolation==1 and not player_dash_collision(p) then
      -- if no collision then continue dashing
      dash_player(p,p.z,true)
    end
    return
  end

  -- are we done moving?
  if interpolation==1 then
    p.last_move_time=nil
    p.pixel_x=tile_to_pixel(p.to_x,"x")
    p.pixel_y=tile_to_pixel(p.to_y,"y")
    p.from_x=nil
    p.from_y=nil
    p.to_x=nil
    p.to_y=nil
    p.velocity=0
  end
end

function update_player_xo(p)
  if g.now-p.last_fire_time>g.settings.burst_delay then
    fire_burst(p)
  end
end

function update_player_x(p,x_pressed)
  if x_pressed and g.now-p.last_fire_time>g.settings.line_delay and not is_spawning(p) then
    fire_weapon(p)
    p.last_fire_time=g.now
  end
end

function update_player_o(p,o_pressed)
  p.shield=o_pressed and p.energy>0 and not is_spawning(p) and not is_dashing(p) and not is_taking_damage(p)
end

function get_input()
  local b=get_input_bitfield()
  return {
    {
      left=b&1~=0,
      right=b&2~=0,
      up=b&4~=0,
      down=b&8~=0,
      x=b&16~=0,
      o=b&32~=0,
    },
    {
      left=b&256~=0,
      right=b&512~=0,
      up=b&1024~=0,
      down=b&2048~=0,
      x=b&4096~=0,
      o=b&8192~=0,
    },
  }
end

function update_player_input(p,i)
  if i.x and i.o then
    update_player_xo(p)
  else
    update_player_x(p,i.x)
    update_player_o(p,i.o)
  end
  if p.last_move_time~=nil then return end
  if i.left and i.o then dash_player(p,180)
  elseif i.left then move_player(p,180)
  elseif i.right and i.o then dash_player(p,0)
  elseif i.right then move_player(p,0)
  elseif i.up and i.o then dash_player(p,-90)
  elseif i.up then move_player(p,-90)
  elseif i.down and i.o then dash_player(p,90)
  elseif i.down then move_player(p,90)
  end
end

function get_input_bitfield()
  return test.enabled and get_test_input() or btn()
end

function get_other_player(p)
  return p.id==1 and g.p2 or g.p1
end

function update_void_fall(p)
  -- start
  if p.void_fall_start==nil and is_active(p) and p.velocity==0 and aget(p.tile_x,p.tile_y)==g.sprites.void then
    -- TODO: play fall into void sound
    p.void_fall_start=g.now
    p.hp=0
  end
  -- end
  if p.void_fall_start~=nil and (g.now-p.void_fall_start)>=g.settings.player_fall_into_void_anim_time then
    -- respawn
    p.void_fall_start=nil
    increase_score(get_other_player(p))
    -- TODO: play score minus sound
    spawn_player(p)
  end
end

function update_player_collisions(p)
  update_void_fall(p)
end

function update_player(p,input)
  if is_input_active(p) then
    update_player_input(p,input[p.id])
  end
  update_player_movement(p)
  update_player_particles(p)
  update_player_collisions(p)
end

function update_players()
  local input=get_input()
  update_player(g.p1,input)
  update_player(g.p2,input)
end

function update_lines()
  for i,l in pairs(g.lines) do
    if g.now-l.start_time>g.settings.line_life then
      deli(g.lines,i)
    end
    -- if collider is a player, update line end point to track their movement
    -- as they are pushed back (else line disconnects from player)
    if l.collider.type=="player" then
      -- offset depends on whether collider player is facing towards line
      -- because drawing line through reticle is ugly
      if l.z==0 then
        local is_facing=l.collider.p.z==180
        l.target_pos.x=l.collider.p.pixel_x-(is_facing and 1 or 0)
      elseif l.z==180 then
        local is_facing=l.collider.p.z==0
        l.target_pos.x=l.collider.p.pixel_x+(is_facing and 7 or 6)
      elseif l.z==90 then
        local is_facing=l.collider.p.z==-90
        l.target_pos.y=l.collider.p.pixel_y-(is_facing and 1 or 0)
      elseif l.z==-90 then
        local is_facing=l.collider.p.z==90
        l.target_pos.y=l.collider.p.pixel_y+(is_facing and 7 or 6)
      end
    end
  end
end

function update_game()
  g.frame+=1
  g.now=get_time()
  update_tests_pre()
  update_players()
  update_entities()
  update_lines()
end

function update_menu()
  local now=time()
  if now-s.menu.last_input_time<s.menu.input_delay then return end
  s.menu.last_input_time=now
  local i=get_input()
  -- up/down
  local down=i[1].down or i[2].down
  local up=i[1].up or i[2].up
  if down then
    s.menu.selected_item_index+=1
    if s.menu.selected_item_index>#s.menu.items then
      s.menu.selected_item_index=1
    end
  elseif up then
    s.menu.selected_item_index-=1
    if s.menu.selected_item_index<1 then
      s.menu.selected_item_index=#s.menu.items
    end
  end
  -- left/right
  local left=i[1].left or i[2].left
  local right=i[1].right or i[2].right
  if left or right then
    local dx=left and -1 or 1
    if s.menu.selected_item_index==1 then
      -- game type
      s.menu.selected_game_type_index+=dx
      if s.menu.selected_game_type_index<1 then
        s.menu.selected_game_type_index=#s.menu.game_types
      elseif s.menu.selected_game_type_index>#s.menu.game_types then
        s.menu.selected_game_type_index=1
      end
    elseif s.menu.selected_item_index==2 then
      -- time limit
      s.menu.selected_time_limit_index+=dx
      if s.menu.selected_time_limit_index<1 then
        s.menu.selected_time_limit_index=#s.menu.time_limits
      elseif s.menu.selected_time_limit_index>#s.menu.time_limits then
        s.menu.selected_time_limit_index=1
      end
    elseif s.menu.selected_item_index==3 then
      -- arena
      s.menu.selected_arena_index+=dx
      if s.menu.selected_arena_index<1 then
        s.menu.selected_arena_index=#keys(arenas)
      elseif s.menu.selected_arena_index>#keys(arenas) then
        s.menu.selected_arena_index=1
      end
    end
  end
  -- x to start
  local x=i[1].x or i[2].x
  local o=i[1].o or i[2].o
  if s.menu.items[s.menu.selected_item_index]=="start" and (x or o) then
    s.state="game"
    local game_type=s.menu.game_types[s.menu.selected_game_type_index]
    local arena_key=keys(arenas)[s.menu.selected_arena_index]
    local arena=arenas[arena_key]
    init_game(game_type, arena)
  end
end

function _update60()
  if s.state=="start" then
    update_menu()
  elseif s.state=="game" then
    update_game()
  end
end

function draw_arena(a)
  map(a.celx,a.cely,a.sx,a.sy,a.celw,a.celh)
end

function draw_energy_sprite(e,x,y)
  spr(g.sprites.energy_spr,x,y)
  pal(yellow,dark_gray)
  clip(x,y,g.tile_size,g.tile_size-2-flr((g.now-e.last_collected_time)/3))
  spr(g.sprites.energy_spr,x,y)
  clip()
  pal()
end

function draw_energy_entity(e)
  if e.last_collected_time==nil then return end
  -- if a player is "on top" of the energy pickup it will be obscured,
  -- so draw it in hud instead (so player can see respawn timing)
  if g.p1.tile_x==e.x and g.p1.tile_y==e.y then
    draw_energy_sprite(e,128/2-16,8)
  elseif g.p2.tile_x==e.x and g.p2.tile_y==e.y then
    draw_energy_sprite(e,128/2+8,8)
  else
    local x=e.x*g.tile_size+g.arena.sx
    local y=e.y*g.tile_size+g.arena.sy
    draw_energy_sprite(e,x,y)
  end
end

function draw_entities()
  for _,e in pairs(g.entities) do
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
  if p.velocity==g.settings.player_dash_velocity then
    sprn=x_offset==0 and 25 or 24
  end
  spr(sprn,x,y,1,1,x_offset<0,y_offset<0)
end

function get_dash_particle_color(p)
  local age=g.now-(p.end_time-g.settings.player_dash_particle_lifetime)
  local t=age/g.settings.player_dash_particle_lifetime  -- 0 = just spawned, 1 = about to end
  return t<0.33 and white or t<0.66 and light_gray or dark_gray
end

function draw_player_dash_particles(p)
  for _,par in pairs(p.dash_particles) do
    -- skip if player occupies same tile to avoid particles "ahead" of player
    if par.tile_x~=p.tile_x or par.tile_y~=p.tile_y then
      circfill(par.x,par.y,par.size,get_dash_particle_color(par))
    end
  end
end

function draw_player_burst_particles(player)
  if #player.burst_particles==0 then return end
  for p in all(player.burst_particles) do
    if g.now<p.start_time+g.settings.burst_grow_duration then
      circfill(p.x,p.y,p.radius,p.c)
    end
    if g.now<p.start_time+g.settings.burst_grow_duration+g.settings.burst_ring_duration then
      local ring_color=g.now<p.start_time+g.settings.burst_grow_duration and p.c or g.settings.burst_ring_color
      circ(p.x,p.y,p.radius,ring_color)
    end
  end
end

function draw_player_particles()
  draw_player_dash_particles(g.p1)
  draw_player_dash_particles(g.p2)
  draw_player_burst_particles(g.p1)
  draw_player_burst_particles(g.p2)
end

function get_void_fall_yoffset(p)
  local yoffset=0
  if p.void_fall_start~=nil then
    local t=(g.now-p.void_fall_start)/g.settings.player_fall_into_void_anim_time
    if t<0 then t=0 end
    if t>1 then t=1 end
    -- short pause and ease-in for cartoonish gravity
    local pause_frac=0.2
    local ease_t
    if t<pause_frac then
      ease_t=0
    else
      local nt=(t-pause_frac)/(1-pause_frac)
      ease_t=nt*nt
    end
    yoffset=ease_t*g.tile_size
  end
  return yoffset
end

function draw_player(p)
  if p.id==2 then
    pal(g.p1.c,g.p2.c) -- swap p1 -> p2 color (reuse same sprite)
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

  if is_spawning(p) then
    pal()
    return
  end

  local sprn=17 -- left/right
  if p.z==-90 then sprn=18 end -- up
  if p.z==90 then sprn=19 end -- down

  local xoffset=p.flip_x and -1 or 0 -- account for off-center sprites

  -- player fire animation
  if is_firing(p) then
    if sprn==17 then sprn=22 end -- use "squinting" sprites
    if sprn==19 then sprn=23 end
  end

  if is_taking_damage(p) then
    if sprn==17 then sprn=22 end -- use "squinting" sprites
    if sprn==19 then sprn=23 end
    pal(g.p1.c,10) -- swap player color -> yellow
  end

  local yoffset=0
  if is_falling_into_void(p) then
    pal(g.p1.c,light_gray) -- swap player colors -> light gray
    yoffset=get_void_fall_yoffset(p)
    clip(p.pixel_x,p.pixel_y,g.tile_size,g.tile_size-1)
  end

  -- draw player sprite
  spr(sprn,p.pixel_x+xoffset,p.pixel_y+yoffset,1,1,p.flip_x)
  clip()

  -- shield or aim reticle
  if not is_bursting(p) and not is_falling_into_void(p) then
    if p.shield then
      circ(p.pixel_x+3,p.pixel_y+3,3,yellow)
    else
      draw_player_dir(p)
    end
  end
  pal()
end

function draw_hp_hud(p)
  local seg_w=5 -- segment width
  local gap=1
  local total_w=g.settings.player_max_hp*(seg_w+gap)-gap*2
  local x=p.id==1 and 1 or 128-total_w-3
  -- background
  for i=0,g.settings.player_max_hp-1 do
    local sx=x+i*(seg_w+gap)
    rect(sx,9,sx+seg_w-1,10,dark_blue)
  end
  -- player hp
  for i=0,p.hp-1 do
    local sx=x+i*(seg_w+gap)
    rect(sx,9,sx+seg_w-1,10,p.c)
  end
end

function draw_energy_hud(p)
  local seg_h=1 -- segment height
  local seg_w=2 -- segment width
  local gap=1
  local total_w=g.settings.player_max_energy*(seg_w+gap)-gap*2
  local x=p.id==1 and 1 or 128-total_w-3
  local y=12
  -- background
  for i=0,g.settings.player_max_energy-1 do
    local sx=x+i*(seg_w+gap)
    rect(sx,y,sx+seg_w-1,y+seg_h,dark_gray)
  end
  -- player energy
  for i=0,p.energy-1 do
    local sx=x+i*(seg_w+gap)
    rect(sx,y,sx+seg_w-1,y+seg_h,yellow)
  end
  --rect(x,12,x+g.settings.player_max_energy*3,13,dark_gray) -- background
  --if p.energy>0 then rect(x,12,x+p.energy*3,13,yellow) end -- energy
end

function draw_lines()
  for l in all(g.lines) do
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

function draw_score_hud(p)
  local score_pad=tostr((p.score>=0 and p.score<10) and "0" or "")..tostr(p.score)
  local score_hud="\#"..int_to_p8hex(p.c).."\f7"..score_pad
  local xoffset=p.id==1 and -24 or 16
  if p.id==1 and p.score<-9 then xoffset-=4 end
  print(score_hud,g.screen_size/2+xoffset,2)
end

function draw_scores_hud()
  draw_score_hud(g.p1)
  draw_score_hud(g.p2)
end

function draw_game_clock()
  local limit_min=s.menu.time_limits[s.menu.selected_time_limit_index]
  local limit_sec=limit_min*60
  local remaining=limit_sec-g.now
  if remaining<0 then remaining=0 end
  local color=remaining<11 and red or remaining<31 and orange or white
  print(format_time(remaining),g.screen_size/2-10,2,color)
end

function draw_hud()
  -- names
  print("player 1",1,2,g.p1.c)
  local p2hud_w=print("player 2",0,-16)
  print("player 2",g.screen_size-p2hud_w-1,2,g.p2.c)
  draw_hp_hud(g.p1)
  draw_hp_hud(g.p2)
  draw_energy_hud(g.p1)
  draw_energy_hud(g.p2)
  draw_scores_hud()
  draw_game_clock()
end

function draw_debug()
  if test.enabled then
    debug_print("f:"..g.frame.." t:"..g.now)
  else
    debug_print(g.debug)
  end
end

function draw_game()
  draw_arena(g.arena)
  draw_entities()
  draw_player_particles()
  draw_player(g.p1)
  draw_player(g.p2)
  draw_lines()
  draw_hud()
  draw_debug()
  update_tests_post()
end

function draw_menu_background()
  g.screen_size=128
  g.tile_size=8
  center_arena(arenas.menu)
  draw_arena(arenas.menu)
end

function draw_title()
  print("pic",43,33,blue)
  spr(17,54,32,1,1)
  spr(20,61,32,1,1)
  print("arena",64,33,red)
end

function keys(table)
  local keys={}
  for k,v in pairs(table) do
    keys[#keys+1]=k
  end
  return keys
end

-- print centered
function printc(text,y)
  local retx=print(text,0,-128)
  print(text,g.screen_size/2-retx/2,y)
end

function draw_menu_items(items)
  for i,item in ipairs(items) do
    local is_selected=item[3]
    local key_color=is_selected and white or dark_gray
    local value_color=is_selected and yellow or dark_gray
    local y=(6+i)*g.tile_size+1
    local text="\f"..int_to_p8hex(key_color)..item[1]..":".."\f"..int_to_p8hex(value_color).."⬅️ "..item[2].." ➡️"
    printc(text,y)
  end
end

function draw_menu()
  local selected_game_type=s.menu.game_types[s.menu.selected_game_type_index]
  local selected_arena=keys(arenas)[s.menu.selected_arena_index]
  local selected_item=s.menu.items[s.menu.selected_item_index]
  local time_limit=s.menu.time_limits[s.menu.selected_time_limit_index].." min"
  draw_menu_items({
    {"game_type",selected_game_type,selected_item=="game_type"},
    {"time_limit",time_limit,selected_item=="time_limit"},
    {"arena",selected_arena,selected_item=="arena"},
  })
  print("start",54,97,selected_item=="start" and yellow or dark_gray)
end

function draw_start()
  draw_menu_background()
  draw_title()
  draw_menu()
end

function _draw()
  cls()
  if s.state=="start" then
    draw_start()
  elseif s.state=="game" then
    draw_game()
  end
end

-- utils

function assertTrue(condition,msg)
  logt("  "..(condition and "o" or "x").." "..msg)
end

function debug_print(str)
  print(str,2,120,6)
end

function get_adjacent_tile(x,y,dir)
  local dx=dir==0 and 1 or dir==180 and -1 or 0
  local dy=dir==90 and 1 or dir==-90 and -1 or 0
  return {x=x+dx,y=y+dy}
end

function get_opposite_direction(dir)
  if dir==0 then return 180
  elseif dir==180 then return 0
  elseif dir==90 then return -90
  elseif dir==-90 then return 90
  end
end

function get_time()
  return test.enabled and time()-test.start_time or time()-g.start_time
end

function log(str)
  printh(str,"arena.log")
end

function logt(str)
  printh(str,"arena_test.log")
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

function stringify(tbl)
  if type(tbl)~="table" then return tostring(tbl) end
  local s="{"
  for k,v in pairs(tbl) do
    local key=tostring(k)
    local val=stringify(v)
    s=s..key.."="..val..","
  end
  return s.."}"
end

function to_bin(n)
  return n==0 and "0" or to_bin(flr(n/2))..(n%2)
end
