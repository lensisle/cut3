require "player"
require "map"
require "camera"

local g = love.graphics

local p = Player:new()
local m = Map:new()
local c = Camera:new()

function love.load()
  m:load()
  p:reset(m)
  
  local stageWidth, stageHeight = m:getStageBounds()
  c:setBounds(0, 0, stageHeight, stageWidth)
end

function love.draw()
  c:set()

  m:draw()
  p:draw()
  
  c:unset()
end

function love.update(dt)

  if dt > 1/60 then dt = 1/60 end

  p:update(dt, m)
  c:setPosition(p.x - g.getWidth() / 2, p.y - g.getHeight() / 2)
  m:update(dt)

  if m.levelFinished then
    local stageWidth, stageHeight = m:getStageBounds()
    c:setBounds(0, 0, stageHeight, stageWidth)
    m.levelFinished = false
  end

  -- TODO: This block should be moved to another place

  local currentIndex = nil

  for i, ladder in ipairs(m:getLadders()) do
    if ladder:checkNearby(p) then
      currentIndex = i
      break
    end
  end

  if currentIndex and m:getLadders()[currentIndex]:checkNearby(p) then
    p.inLadder = true
  else
    p.inLadder = false
  end

  -- ^^^^^^^ --

end