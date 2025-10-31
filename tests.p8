function assertTrue() end
function init_game() end
function logt() end
function set_player_pos() end
function update_player_input() end
arenas={}
frame_duration_30=1/30
frame_duration_60=1/60
input={}
g={}
test={}

tests={{
  init=function()
    logt("line cancels player horizontal movement")
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
      logt("  player 2 moves left")
    elseif g.p2.tile_x==test.p2_start_x-1 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      logt("  player 1 fires just after player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assertTrue(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assertTrue(g.p2.tile_x==test.p2_start_x,"player 2 pushed horizontally")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line cancels player horizontal movement")
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
      logt("  player 2 moves left")
    elseif g.now>=test.p2_move_time+g.settings.player_velocity/2 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      logt("  player 1 fires just before player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assertTrue(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assertTrue(g.p2.tile_x==test.p2_start_x+1,"player 2 pushed horizontally")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line cancels player perpendicular movement")
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
      logt("  player 2 moves up")
    elseif g.now>=test.p2_move_time+g.settings.player_velocity/2 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      logt("  player 1 fires just before player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assertTrue(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assertTrue(g.p2.tile_x==test.p2_start_x+1,"player 2 pushed horizontally")
      assertTrue(g.p2.tile_y==test.p2_start_y,"player 2 vertical movement cancelled")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line miss does not cancel player movement")
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
      logt("  player 2 moves down")
    elseif g.p2.tile_y==test.p2_start_y+1 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      logt("  player 1 fires just after player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p2_move_time+g.settings.player_velocity+frame_duration_60) then
      assertTrue(g.p2.hp==g.settings.player_max_hp,"player 2 hp full")
      assertTrue(g.p2.tile_x==test.p2_start_x,"player 2 not pushed horizontally")
      assertTrue(g.p2.tile_y==test.p2_start_y+1,"player 2 vertical movement completed")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line cancels player perpendicular movement")
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
      logt("  player 2 moves down")
    elseif g.now>=test.p2_move_time+g.settings.player_velocity/2 and test.p1_fire_time==0 then
      test.p1_fire_time=g.now
      update_player_input(g.p1,input.p1_x)
      logt("  player 1 fires just before player 2 tile position changes")
    end
  end,
  update_post=function()
    if g.now>(test.p1_fire_time+g.settings.player_velocity+frame_duration_60) then
      assertTrue(g.p2.hp<g.settings.player_max_hp,"player 2 hp not full")
      assertTrue(g.p2.tile_x==test.p2_start_x+1,"player 2 pushed horizontally")
      assertTrue(g.p2.tile_y==test.p2_start_y,"player 2 vertical movement cancelled")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line cancels player movement at start")
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
      logt("  player 2 moves down")
    elseif g.frame==3 then
      update_player_input(g.p1,input.p1_x)
      logt("  player 1 fires")
    end
  end,
  update_post=function()
    if g.now>(g.settings.player_velocity+frame_duration_30*2) then
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing right, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing left, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing down, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing up, collider facing away")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing down")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing left")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("line weapon")
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
      logt("  press x facing right")
    end
  end,
  update_post=function()
    if g.now>g.settings.player_damage_duration then
      --assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("player x input ignored while spawning")
    test.after_spawn_frame=nil
    test.before_spawn_frame=nil
    test.line_delay_frame=nil
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      update_player_input(g.p1,input.p1_x)
      logt("  press x on frame 1")
    elseif g.now>g.settings.line_delay and test.line_delay_frame==nil then
      test.line_delay_frame=g.frame
      update_player_input(g.p1,input.p1_x)
      logt("  press x after line delay")
    elseif g.now>g.settings.player_spawn_duration-frame_duration_30 and test.before_spawn_frame==nil then
      test.before_spawn_frame=g.frame
      update_player_input(g.p1,input.p1_x)
      logt("  press x before spawn")
    elseif g.now>g.settings.player_spawn_duration+frame_duration_30 and test.after_spawn_frame==nil then
      test.after_spawn_frame=g.frame
      update_player_input(g.p1,input.p1_x)
      logt("  press x after spawn")
    end
  end,
  update_post=function()
    if g.frame==1 then
      -- line unused
      assertTrue(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full after 1 frame")
      assertTrue(g.p2.hp==g.settings.player_max_hp, "player 2 hp still full after 1 frame")
    elseif test.line_delay_frame~=nil and g.frame==test.line_delay_frame+1 then
      assertTrue(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full after line_delay")
      assertTrue(g.p2.hp==g.settings.player_max_hp, "player 2 hp still full after line_delay")
    elseif test.before_spawn_frame~=nil and g.frame==test.before_spawn_frame then
      assertTrue(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full before spawn")
      assertTrue(g.p2.hp==g.settings.player_max_hp, "player 2 hp still full before spawn")
    elseif test.after_spawn_frame~=nil and g.frame>test.after_spawn_frame then
      assertTrue(g.p1.energy<g.settings.player_max_energy,"player 1 energy not full after spawn")
      assertTrue(g.p2.hp<g.settings.player_max_hp, "player 2 hp not full after spawn")
      return true -- test finished
    end
  end,
},{
  init=function()
    logt("player o input ignored while spawning")
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    if g.frame==1 then
      logt("  press o while player is still spawning")
      update_player_input(g.p1,input.p1_o)
    end
  end,
  update_post=function()
    if g.frame>=1 then
      -- shield unused
      assertTrue(g.p1.energy==g.settings.player_max_energy,"player 1 energy still full")
      return true
    end
  end,
},{
  init=function()
    logt("player directional input ignored while spawning")
    init_game("versus", arenas.test1)
  end,
  update_pre=function()
    test.p1_tile_x=g.p1.tile_x -- save previous spawn position
    if g.frame==1 then
      logt("  press right while player is still spawning")
      update_player_input(g.p1,input.p1_right)
    end
  end,
  update_post=function()
    if g.frame==1 then
      -- player not moved
      assertTrue(g.p1.tile_x==test.p1_tile_x, "player 1 position unchanged")
      return true
    end
  end,
}}
