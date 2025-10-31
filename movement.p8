
  -- vector from "start" tile to "destination" tile
  local dx=p.to_x-p.from_x
  local dy=p.to_y-p.from_y
  -- distance (in tiles) between start and destination
  local dtiles=sqrt(dx*dx+dy*dy)
  -- total move time in seconds
  local total_time=dtiles*p.velocity
  -- how much time has passed since movement began
  local dtime=g.now-p.last_move_time
  -- interpolation factor (0.0 → 1.0)
  local interpolation=min(dtime/total_time,1)
  -- interpolated offset (tiles)
  local moved_tiles=interpolation*dtiles
  -- normalize direction vector (unit direction)
  local ndx=dx/dtiles
  local ndy=dy/dtiles
  -- offset in pixels
  local dpx=ndx*moved_tiles*g.tile_size
  local dpy=ndy*moved_tiles*g.tile_size
  -- update pixel positions relative to arena origin
  p.pixel_x=tile_to_pixel(p.from_x,"x")+dpx
  p.pixel_y=tile_to_pixel(p.from_y,"y")+dpy
