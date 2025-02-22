local phase = 0
local zoom = 0
local speed = 15
local pmousex, pmousey = 0, 0
local positions = {} --The first value is f(0), followed by f(1)... to f(t-1).
local vectors = 40 -- Number of clockwise rotating vectors
local xcoeffs, ycoeffs = {}, {}
local k = 0 -- Time simulated
local firsttransform = love.math.newTransform()
local secondtransform = love.math.newTransform()
function love.load()
  love.window.setFullscreen(true)
end
function love.draw()
  --Transforms
  local circlesize = 3
  if zoom == 0 then
    love.graphics.setLineWidth(1)
  elseif zoom == 1 then
    love.graphics.setLineWidth(0.5)
    love.graphics.applyTransform(firsttransform)
    circlesize = 2
  else
    love.graphics.setLineWidth(0.025)
    love.graphics.applyTransform(secondtransform)
    circlesize = 0.15
  end
  love.graphics.clear()
  local t = table.getn(positions)/2
  if t >= 3 then
    love.graphics.setColor(1, 1, 0)
    love.graphics.line(positions)
  end
  --Unfortunately most of this math does have to be done right before drawing things
  if phase >= 2 then
    local x = 0
    local y = 0
    local base_angle = 2 * math.pi * k / t
    for n = 0, 2 * vectors do -- n=-vectors, vectors does things in the wrong order
      local real_n = 0 -- the actual vector frequency
      if math.floor(n/2) == n/2 then
        real_n = - n / 2
      else
        real_n = (n + 1) / 2
      end
      local angle = base_angle * real_n
      local px, py = x, y
      x = x + xcoeffs[real_n] * math.cos(angle) - ycoeffs[real_n] * math.sin(angle)
      y = y + xcoeffs[real_n] * math.sin(angle) + ycoeffs[real_n] * math.cos(angle)
      love.graphics.setColor(1, 1, 1)
      if n >= 1 then
        love.graphics.line(px, py, x, y)
      end
    end
    love.graphics.setColor(0, 1, 1)
    love.graphics.circle("fill", x, y, circlesize)
    --Transforms
    local width, height = love.window.getMode()
    firsttransform:setTransformation(width / 2 - x * 2, height / 2 - y * 2, 0, 2, 2)
    secondtransform:setTransformation(width / 2 - x * 40, height / 2 - y * 40, 0, 40, 40)
  end
end
function love.update(dt)--TODO: use dt or only measure when the mouse has moved far away enough.
  if phase == 1 then
    local x, y = love.mouse.getPosition()
    pmousex, pmousey = x, y
    table.insert(positions, x)
    table.insert(positions, y)
  elseif phase >= 2 then
    k = k + (dt * speed / (zoom + 1))
  end
end
function love.mousepressed(x, y, button)
  if button == 1 then -- button = 1 means that the primary mouse button was pressed
    phase = phase + 1
    if phase == 1 then
      if not (x == pmousex and y == pmousey) then
        table.insert(positions, x)
        table.insert(positions, y)
        pmousex, pmousey = x, y
      end
    elseif phase == 2 then
      if table.getn(positions) >= (5 * vectors / 2) then
        xcoeffs, ycoeffs = calculate()
      else
        phase = 1
      end
    end
  elseif button == 2 and phase == 2 then
    zoom = zoom + 1
    if zoom == 3 then zoom = 0 end
  end
end
function love.keypressed(button)
  if button == "escape" then
    love.event.quit()
  end
end
function calculate()
  local t = table.getn(positions)/2
  local x = {} -- for the real mathematical value of n, subtract vectors+1
  local y = {}
  for n = -vectors, vectors do
    x[n] = 0
    y[n] = 0
    for k=0, t-1 do
      local angle = -2 * math.pi * k * n / t
      x[n] = x[n] + positions[2*k+1] * math.cos(angle) - positions[2*k+2] * math.sin(angle)
      y[n] = y[n] + positions[2*k+2] * math.cos(angle) + positions[2*k+1] * math.sin(angle)
    end
    x[n] = x[n]/t
    y[n] = y[n]/t
  end
  return x, y
end