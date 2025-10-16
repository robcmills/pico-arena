function _init()
 p1 = {
  flip_x=false,
  x=4,
  y=4,
  z=0, -- direction in degrees clockwise (0=East,90=South)
 }
end

function updateP1()
 if btnp(0) then
  p1.flip_x=true
  p1.x-=1
  p1.z=180
 elseif btnp(1) then
  p1.flip_x=false
  p1.x+=1
  p1.z=0
 elseif btnp(2) then
  p1.y-=1
  p1.z=-90
 elseif btnp(3) then
  p1.y+=1
  p1.z=90
 end
end

function _update()
 updateP1()
end

function drawP1()
 local pspr=p1.z<-45 and 18 or 17
 spr(pspr,p1.x*8,p1.y*8,1,1,p1.flip_x)
end

function _draw()
 cls()
 map()
 drawP1()
end
