function assert_true() end
function init_game() end
function log() end
function set_player_pos() end
function update_player_input() end
arenas={}
frame_duration_30=1/30
frame_duration_60=1/60
input={}
g={}
test={}
settings={}

tests={{
  init=function()
    log("player dash collisions with other player (long distance)")
    test.mark_time=0
    init_game(arenas.test2)
    music(-1)
    sfx(-1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,1,4,0)
      set_player_pos(g.p2,10,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("  both players move to same tile (one dashes)")
      test.mark_time=g.now
      return input.p1_right|input.p2_left|input.p2_o
    end
  end,
  update_post=function()
    if g.now>test.mark_time+settings.player_dash_velocity*10+frame_duration_60 then
      assert_true(g.p1.tile_x==1,"p1 pushed back to starting position")
      assert_true(g.p2.tile_x==3,"p2 dash canceled")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("player dash collisions with other player (short distance)")
    test.mark_time=0
    init_game(arenas.test1)
    music(-1)
    sfx(-1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("  both players move to same tile (one dashes)")
      test.mark_time=g.now
      return input.p1_right|input.p2_left|input.p2_o
    end
  end,
  update_post=function()
    if g.now>test.mark_time+settings.player_velocity+frame_duration_60 then
      assert_true(g.p1.tile_x~=g.p2.tile_x,"both players do not occupy same tile")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("player movement collisions with other player")
    test.mark_time=0
    init_game(arenas.test1)
    music(-1)
    sfx(-1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,4,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("  both players move to same tile")
      test.mark_time=g.now
      return input.p1_right|input.p2_left
    end
  end,
  update_post=function()
    if g.now>test.mark_time+settings.player_velocity+frame_duration_60 then
      assert_true(g.p1.tile_x~=g.p2.tile_x,"both players do not occupy same tile")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("cube explosion push_z")
    test.mark_time=0
    init_game(arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      music(-1)
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,6,4,180)
      set_player_pos(g.p2,2,4,0)
      -- set weapon
      g.p1.w=sprites.cube_spr
    end
  end,
  input=function()
    if g.frame==2 then
      log("p1 shoots cube")
      test.mark_time=g.now
      return input.p1_x
    end
  end,
  update_post=function()
    if g.now>test.mark_time+g.dt*25 then
      assert_true(g.p2.hp<settings.player_max_hp,"p2 damaged")
      assert_true(g.p2.tile_x==1,"p2 pushed horizontally by cube explosion")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("cube explosion push_z")
    test.mark_time=0
    init_game(arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      music(-1)
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,4,3,180)
      -- set weapon
      g.p1.w=sprites.cube_spr
    end
  end,
  input=function()
    if g.frame==2 then
      log("p1 shoots cube")
      return input.p1_x
    elseif g.frame==9 then
      log("p1 explodes cube")
      test.mark_time=g.now
      g.p1.last_fire_time=-settings.line_delay
      return input.p1_x
    end
  end,
  update_post=function()
    if g.now>test.mark_time+g.dt*25 then
      assert_true(g.p1.hp<settings.player_max_hp,"p1 damaged")
      assert_true(g.p2.hp<settings.player_max_hp,"p2 damaged")
      assert_true(g.p1.tile_x==1,"p1 pushed horizontally by cube explosion")
      assert_true(g.p2.tile_y==2,"p2 pushed vertically by cube explosion")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("cube explosion intersects")
    test.mark_time=0
    init_game(arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      music(-1)
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,2,180)
      -- set weapon
      g.p1.w=sprites.cube_spr
    end
  end,
  input=function()
    if g.frame==2 then
      log("p1 shoots cube")
      return input.p1_x
    elseif g.frame==9 then
      log("p1 explodes cube")
      test.mark_time=g.now
      g.p1.last_fire_time=-settings.line_delay
      return input.p1_x
    end
  end,
  update_post=function()
    if g.now>test.mark_time+g.dt*25 then
      assert_true(g.p1.hp<settings.player_max_hp,"p1 damaged")
      assert_true(g.p2.hp<settings.player_max_hp,"p2 damaged")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line beats cube")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game(arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
      -- set weapon
      g.p1.w=sprites.cube_spr
    end
  end,
  input=function()
    if g.frame==2 then
      log("p1 shoots p2 with cube")
      return input.p1_x
    elseif g.frame==5 then
      log("p2 shoots cube with line")
      test.fire_time=g.now
      return input.p2_x
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.dt*25 then
      assert_true(g.p1.hp<settings.player_max_hp,"p1 damaged")
      assert_true(g.p2.hp==settings.player_max_hp,"p2 not damaged")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("cube")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game(arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-settings.line_delay
      g.p2.last_fire_time=-settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable immediate input
      g.p1.last_spawn_time=-settings.player_spawn_duration
      g.p2.last_spawn_time=-settings.player_spawn_duration
      -- enable immediate energy loss
      g.p1.last_energy_loss_time=-settings.energy_loss_delay
      g.p2.last_energy_loss_time=-settings.energy_loss_delay
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
      -- set weapon
      g.p1.w=sprites.cube_spr
    end
  end,
  input=function()
    if g.frame==2 then
      log("p1 shoots p2 with cube")
      test.fire_time=g.now
      return input.p1_x
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.dt*50 then
      return true -- test finished
    end
  end,
},{
  init=function()
    log("burst vs burst")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      set_player_pos(g.p1,3,4,0)
      set_player_pos(g.p2,4,5,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("player 1 and 2 burst")
      test.fire_time=g.now
      return input.p1_x|input.p1_o|input.p2_o|input.p2_x
    else
      return input.p1_o|input.p2_o
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.burst_grow_duration+g.settings.burst_ring_duration+frame_duration_60 then
      assert_true(g.p1.tile_x==3,"p1 not pushed horizontally by burst")
      assert_true(g.p1.hp==g.settings.player_max_hp,"p1 did not lose hp")
      assert_true(g.p2.tile_x==4,"p2 not pushed horizontally by burst")
      assert_true(g.p2.hp==g.settings.player_max_hp,"p2 did not lose hp")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("burst vs shield")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      -- set player positions
      set_player_pos(g.p1,3,4,0)
      set_player_pos(g.p2,4,5,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("player 1 bursts and player 2 shields")
      test.fire_time=g.now
      return input.p1_x|input.p1_o|input.p2_o
    else
      return input.p2_o
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.burst_grow_duration+g.settings.burst_ring_duration+frame_duration_60 then
      assert_true(g.p2.tile_x==4,"p2 not pushed horizontally by burst")
      assert_true(g.p2.hp==g.settings.player_max_hp,"p2 did not lose hp")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("shield burst attack (pushback)")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      -- set player positions
      set_player_pos(g.p1,3,4,0)
      set_player_pos(g.p2,3,5,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("player 1 bursts")
      test.fire_time=g.now
      return input.p1_x|input.p1_o
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.burst_grow_duration+g.settings.burst_ring_duration+frame_duration_60 then
      assert_true(g.p2.tile_y==6,"p2 pushed vertically by burst")
      assert_true(g.p2.hp==g.settings.player_max_hp-1,"p2 lost one hp")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("shield burst attack (pushback)")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      -- set player positions
      set_player_pos(g.p1,4,4,0)
      set_player_pos(g.p2,5,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("player 1 bursts")
      test.fire_time=g.now
      return input.p1_x|input.p1_o
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.burst_grow_duration+g.settings.burst_ring_duration+frame_duration_60 then
      assert_true(g.p2.tile_x==6,"p2 pushed horizontally by burst")
      assert_true(g.p2.hp==g.settings.player_max_hp-1,"p2 lost one hp")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("shield burst attack")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("player 1 bursts")
      test.fire_time=g.now
      return input.p1_x|input.p1_o
    elseif g.frame>2 then
      -- p1 fires every frame after burst
      return input.p1_x
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.burst_grow_duration+g.settings.burst_ring_duration+frame_duration_60 then
      assert_true(g.p1.energy==g.settings.player_max_energy-2,"p1 spent two energy, one for burst and only one line after burst ended")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("settings.enable_void_suicide=true")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
    g.settings.enable_void_suicide=true
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
      -- set player positions
      set_player_pos(g.p1,2,4,180)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      test.move_time=g.now
      log("player 1 dashes into void")
      return input.p1_left|input.p1_o
    end
  end,
  update_post=function()
    if g.now>test.move_time+g.settings.player_dash_velocity+g.settings.player_fall_into_void_anim_time then
      assert_true(g.p1.hp==0,"player 1 dashed into void")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("settings.enable_void_suicide=false")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
    g.settings.enable_void_suicide=false
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
      -- set player positions
      set_player_pos(g.p1,2,4,180)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    -- p1 tries to moves into void
    if g.frame==2 then
      test.move_time=g.now
      log("player 1 tries to dash into void")
      return input.p1_left|input.p1_o
    end
  end,
  update_post=function()
    if g.now>test.move_time+g.settings.player_velocity then
      assert_true(g.p1.tile_x==1,"player 1 did not move into void")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("settings.enable_void_suicide=false")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
    g.settings.enable_void_suicide=false
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
      -- set player positions
      set_player_pos(g.p1,1,4,180)
      set_player_pos(g.p2,5,4,180)
    end
  end,
  input=function()
    -- p1 tries to moves into void
    if g.frame==2 then
      test.fire_time=g.now
      log("player 2 shoots p1 into void")
      return input.p2_x
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.player_velocity then
      assert_true(g.p1.hp==0,"player 1 hp is zero (falling into void)")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("settings.enable_void_suicide=false")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
    g.settings.enable_void_suicide=false
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
      -- set player positions
      set_player_pos(g.p1,1,4,180)
      set_player_pos(g.p2,5,4,180)
    end
  end,
  input=function()
    -- p1 tries to moves into void
    if g.frame==1 then
      test.move_time=g.now
      log("player 1 tried to move into void")
      return input.p1_left
    end
  end,
  update_post=function()
    if g.now>test.move_time+g.settings.player_velocity then
      assert_true(g.p1.tile_x==1,"player 1 did not move into void")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line does no damage if collider is already taking damage")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,5,4,180)
    end
  end,
  input=function()
    -- p1 presses x every frame
    if g.frame>1 then
      if test.fire_time==0 then
        test.fire_time=g.now
      end
      -- after taking damage once p2 holds o to shield
      if g.frame>2 then
        return input.p2_o|input.p1_x
      end
      return input.p1_x
    end
  end,
  update_post=function()
    if test.fire_time>0 and g.now>test.fire_time+g.settings.player_velocity*3 then
      assert_true(g.p1.hp==g.settings.player_max_hp-g.settings.line_dmg,"player 1 took one line damage")
      assert_true(g.p2.hp==g.settings.player_max_hp-g.settings.line_dmg,"player 2 took one line damage")
      assert_true(g.p2.tile_x==6,"player 2 pushed horizontally only one tile")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("mid-movement line and shield")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    test.shield_frame=0
    init_game("versus", arenas.test1)
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
      -- set player positions
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame==2 then
      log("  p2 moves left")
      test.move_time=g.now
      return input.p2_left
    elseif g.now>test.move_time+g.settings.player_velocity/2 then
      -- p2 shields mid-movement
      if test.shield_frame==0 then
        test.shield_frame=g.frame
      elseif g.frame==test.shield_frame+1 then
        log("  p1 fires while p2 is still mid-movement but shielded")
        test.fire_time=g.now
        return input.p1_x|input.p2_o
      end
      return input.p2_o
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.player_velocity then
      assert_true(g.p1.hp<g.settings.player_max_hp,"player 1 hp not full")
      assert_true(g.p2.hp==g.settings.player_max_hp,"player 2 hp full")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("falling and spawning player input is ignored")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p2.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- enable immediate input
      g.p1.last_spawn_time=-g.settings.player_spawn_duration
      g.p2.last_spawn_time=-g.settings.player_spawn_duration
      -- set player positions
      set_player_pos(g.p1,1,4,180)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame>2 then
      --log("  p1 moves into void and continues pressing left")
      if test.move_time==0 then
        test.move_time=g.now
      end
      return input.p1_left
    end
  end,
  update_post=function()
    if g.now>test.move_time+g.settings.player_velocity+g.settings.player_fall_into_void_anim_time+g.settings.player_spawn_duration+frame_duration_60 then
      return true -- test finished
    end
  end,
},{
  init=function()
    log("falling player input is ignored")
    test.fall_time=0
    test.fire_time=0
    test.move_time=0
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p2.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,1,4,180)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame==2 and test.move_time==0 then
      log("  p1 moves into void")
      test.move_time=g.now
      return input.p1_left
    elseif g.now>test.move_time+g.settings.player_velocity+frame_duration_60 and test.fire_time==0 then
      log("  p1 fires")
      test.fire_time=g.now
      return input.p1_x
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.player_velocity+frame_duration_60*2 then
      assert_true(g.p1.energy==g.settings.player_max_energy,"player 1 input ignored")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("shoot player just before fall into void")
    test.fire_time=0
    test.move_time=0
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p2.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,1,4,180)
      set_player_pos(g.p2,6,4,180)
    end
  end,
  input=function()
    if g.frame==2 and test.move_time==0 then
      log("  p1 moves into void")
      test.move_time=g.now
      return input.p1_left
    elseif g.now>test.move_time+g.settings.player_velocity/2 and test.fire_time==0 then
      log("  p2 fires")
      test.fire_time=g.now
      return input.p2_x
    end
  end,
  update_post=function()
    if g.now>test.fire_time+g.settings.player_velocity+g.settings.player_fall_into_void_anim_time+g.settings.player_spawn_duration+frame_duration_60 then
      assert_true(g.p1.score==-1,"player 1 score is -1")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line beats dash")
    test.p1_fire_time=0
    test.p2_dash_time=0
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,4,4,0)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_right|input.p2_o)
      test.p2_dash_time=g.now
      log("  player 2 dashes right")
    elseif g.now>=test.p2_dash_time+g.settings.player_dash_velocity and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires")
    end
  end,
  update_post=function()
    if g.now>test.p2_dash_time+g.settings.player_dash_velocity+g.settings.player_velocity+frame_duration_60 then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assert_true(g.p2.tile_x==6,"player 2 pushed horizontally only one tile")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line beats dash")
    test.p1_fire_time=0
    test.p2_dash_time=0
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,1,180)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_down|input.p2_o)
      test.p2_dash_time=g.now
      log("  player 2 dashes down")
    elseif g.now>=test.p2_dash_time+g.settings.player_dash_velocity*3 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires")
    end
  end,
  update_post=function()
    if g.now>test.p2_dash_time+g.settings.player_dash_velocity*3+g.settings.player_velocity+frame_duration_60 then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assert_true(g.p2.tile_y==4,"player 2 vertical movement cancelled")
      assert_true(g.p2.tile_x==7,"player 2 pushed horizontally")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("player dash polish")
    test.p1_dash_time=0
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_right|input.p1_o)
      update_player_input(g.p2,input.p2_down)
      test.p1_dash_time=g.now
      log("  player 1 dashes right and player 2 moves down")
    end
  end,
  update_post=function()
    if g.now>test.p1_dash_time+g.settings.player_dash_velocity*3+g.settings.player_velocity+frame_duration_60 then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line cancels player horizontal movement")
    test.p1_fire_time=0
    test.p2_move_time=0
    test.p2_start_x=6
    test.p2_start_y=4
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,test.p2_start_x,test.p2_start_y,180)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_left)
      test.p2_move_time=g.now
      log("  player 2 moves left")
    elseif g.p2.tile_x==test.p2_start_x-1 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires just after player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assert_true(g.p2.tile_x==test.p2_start_x,"player 2 pushed horizontally")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line cancels player horizontal movement")
    test.p1_fire_time=0
    test.p2_move_time=0
    test.p2_start_x=6
    test.p2_start_y=4
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,test.p2_start_x,test.p2_start_y,180)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_left)
      test.p2_move_time=g.now
      log("  player 2 moves left")
    elseif g.now>=test.p2_move_time+g.settings.player_velocity/2 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires just before player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assert_true(g.p2.tile_x==test.p2_start_x+1,"player 2 pushed horizontally")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line cancels player perpendicular movement")
    test.p1_fire_time=0
    test.p2_move_time=0
    test.p2_start_x=6
    test.p2_start_y=4
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,test.p2_start_x,test.p2_start_y,90)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_up)
      test.p2_move_time=g.now
      log("  player 2 moves up")
    elseif g.now>=test.p2_move_time+g.settings.player_velocity/2 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires just before player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assert_true(g.p2.tile_x==test.p2_start_x+1,"player 2 pushed horizontally")
      assert_true(g.p2.tile_y==test.p2_start_y,"player 2 vertical movement cancelled")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line miss does not cancel player movement")
    test.p1_fire_time=0
    test.p2_move_time=0
    test.p2_start_x=6
    test.p2_start_y=4
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,test.p2_start_x,test.p2_start_y,90)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_down)
      test.p2_move_time=g.now
      log("  player 2 moves down")
    elseif g.p2.tile_y==test.p2_start_y+1 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires just after player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p2_move_time+g.settings.player_velocity+frame_duration_60) then
      assert_true(g.p2.hp==g.settings.player_max_hp,"player 2 hp full")
      assert_true(g.p2.tile_x==test.p2_start_x,"player 2 not pushed horizontally")
      assert_true(g.p2.tile_y==test.p2_start_y+1,"player 2 vertical movement completed")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line cancels player perpendicular movement")
    test.p1_fire_time=0
    test.p2_move_time=0
    test.p2_start_x=6
    test.p2_start_y=4
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,test.p2_start_x,test.p2_start_y,90)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_down)
      test.p2_move_time=g.now
      log("  player 2 moves down")
    elseif g.now>=test.p2_move_time+g.settings.player_velocity/2 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires just before player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assert_true(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assert_true(g.p2.tile_x==test.p2_start_x+1,"player 2 pushed horizontally")
      assert_true(g.p2.tile_y==test.p2_start_y,"player 2 vertical movement cancelled")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line cancels player movement at start")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      g.p2.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,90)
    elseif g.frame==2 then
      update_player_input(g.p2,input.p2_down)
      log("  player 2 moves down")
    elseif g.frame==3 then
      update_player_input(g.p1,input.p1_x)
      log("  player 1 fires")
    end
  end,
  update_post=function()
    if g.now>(g.settings.player_velocity+frame_duration_30*2) then
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,90)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing right, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p2,2,4,90)
      set_player_pos(g.p1,6,4,180)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing left, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- manually set player positions
      set_player_pos(g.p1,4,3,90)
      set_player_pos(g.p2,4,5,0)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing down, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- manually set player positions
      set_player_pos(g.p1,4,5,-90)
      set_player_pos(g.p2,4,3,0)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing up, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      -- manually set player positions
      set_player_pos(g.p1,4,3,90)
      set_player_pos(g.p2,4,5,-90)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing down")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p2,2,4,0)
      set_player_pos(g.p1,6,4,180)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing left")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("line weapon")
    test.after_spawn_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      -- enable firing immediately
      g.p1.last_fire_time=-g.settings.line_delay
      -- disable spawn animation
      g.p1.spawn_particles={}
      g.p2.spawn_particles={}
      set_player_pos(g.p1,2,4,0)
      set_player_pos(g.p2,6,4,180)
    elseif g.frame==2 then
      update_player_input(g.p1,input.p1_x)
      log("  press x facing right")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("player x input ignored while spawning")
    test.after_spawn_frame=nil
    test.before_spawn_frame=nil
    test.line_delay_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      update_player_input(g.p1,input.p1_x)
      log("  press x on frame 1")
    elseif g.now>g.settings.line_delay and test.line_delay_frame==nil then
      test.line_delay_frame=g.frame
      update_player_input(g.p1,input.p1_x)
      log("  press x after line delay")
    elseif g.now>g.settings.player_spawn_duration-frame_duration_30 and test.before_spawn_frame==nil then
      test.before_spawn_frame=g.frame
      update_player_input(g.p1,input.p1_x)
      log("  press x before spawn")
    elseif g.now>g.settings.player_spawn_duration+frame_duration_30 and test.after_spawn_frame==nil then
      test.after_spawn_frame=g.frame
      update_player_input(g.p1,input.p1_x)
      log("  press x after spawn")
    end
  end,
  update_post=function()
    if g.frame==1 then
      -- line unused
      assert_true(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full after 1 frame")
      assert_true(g.p2.hp==g.settings.player_max_hp, "player 2 hp still full after 1 frame")
    elseif test.line_delay_frame~=nil and g.frame==test.line_delay_frame+1 then
      assert_true(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full after line_delay")
      assert_true(g.p2.hp==g.settings.player_max_hp, "player 2 hp still full after line_delay")
    elseif test.before_spawn_frame~=nil and g.frame==test.before_spawn_frame then
      assert_true(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full before spawn")
      assert_true(g.p2.hp==g.settings.player_max_hp, "player 2 hp still full before spawn")
    elseif test.after_spawn_frame~=nil and g.frame>test.after_spawn_frame then
      assert_true(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      assert_true(g.p2.hp<g.settings.player_max_hp, "player 2 hp not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    log("player o input ignored while spawning")
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      log("  press o while player is still spawning")
      update_player_input(g.p1,input.p1_o)
    end
  end,
  update_post=function()
    if g.frame>=1 then
      -- shield unused
      assert_true(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full")
      return true
    end
  end,
},{
  init=function()
    log("player directional input ignored while spawning")
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    test.p1_tile_x=g.p1.tile_x -- save previous spawn position
    if g.frame==1 then
      log("  press right while player is still spawning")
      update_player_input(g.p1,input.p1_right)
    end
  end,
  update_post=function()
    if g.frame==1 then
      -- player not moved
      assert_true(g.p1.tile_x==test.p1_tile_x, "player 1 position unchanged")
      return true
    end
  end,
}}
