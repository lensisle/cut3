local tileset = require("tileset")
local levels = require("levels")
local objects = require("objects")
local g = love.graphics

require "ladder"
require "generator"
require "remover"
require "jewel"
require "bomb"
require "ball"
require "chest"

Map = {}
Map.currentLevel = 1
Map.currentGrid = nil
Map.tileWidth = 64
Map.tileHeight = 64

Map.gridWidth = 0
Map.gridHeight = 0

Map.currentObjects = nil
Map.ladders = {}
Map.generators = {}
Map.removers = {}
Map.jewels = {}
Map.bombs = {}
Map.balls = {}
Map.chests = {}
Map.currentTimeGenerate = 0

Map.levelFinished = false

local GENERATE_BALL_TIME = 2
local MAX_BALLS = 10
local currentFont = g.newFont(25)

function Map:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Map:load()
  self.currentGrid = levels[self.currentLevel]
  self.gridWidth = self.tileWidth * #self.currentGrid
  self.gridHeight = self.tileHeight * #self.currentGrid[1]

  self.currentObjects = objects[self.currentLevel]

  g.setFont(currentFont)

  for _, object in ipairs(self.currentObjects) do
    if object[3] == "ladder" then
      table.insert(self.ladders, Ladder:new{ x = object[1], y = object[2] })
    elseif object[3] == "generator" then
      local currentObject = Generator:new{ x = object[1], y = object[2] }
      table.insert(self.generators, currentObject)
    elseif object[3] == "remover" then
      table.insert(self.removers, Remover:new{ x = object[1], y = object[2] }) 
    elseif object[3] == "jewel" then
      table.insert(self.jewels, Jewel:new{ x = object[1], y = object[2] })
    elseif object[3] == "bomb" then
      table.insert(self.bombs, Bomb:new{ x = object[1], y = object[2] })
    elseif object[3] == "chest" then
      table.insert(self.chests, Chest:new{ x = object[1], y = object[2] })
    end
  end
  self:loadJewels()
end

function Map:draw()

  for i, row in ipairs(self.currentGrid) do
    for j, column in ipairs(row) do
      local currentCell = tileset[column]
      g.setColor(currentCell.color[1], currentCell.color[2], currentCell.color[3])
      local drawType = "line"
      if currentCell.type == "solid" or currentCell.type == "hidden-night" then drawType = "fill" end
      g.rectangle(drawType, (j - 1) * self.tileWidth, (i - 1) * self.tileHeight, self.tileWidth, self.tileHeight)
    end
  end

  for i, chest in ipairs(self.chests) do
    chest:draw()
  end

  for i, ladder in ipairs(self.ladders) do
    ladder:draw()
  end

  for i, generator in ipairs(self.generators) do
    generator:draw()
  end

  for i, ball in ipairs(self.balls) do
    ball:draw()
  end

  for i, removers in ipairs(self.removers) do
    removers:draw()
  end

  for i, jewel in ipairs(self.jewels) do
    jewel:draw()
  end

  for i, bomb in ipairs(self.bombs) do
    bomb:draw()
  end

  if self.currentLevel == 1 then
    g.setColor(0, 255, 0)
    g.print("welcome traveler", 200, 200)
  end

  if self.currentLevel == 2 then 
    g.setColor(0, 255, 0)
    g.print("beware of the dangerous materials", 130, 80)
  end

  if self.currentLevel == 5 then 
    g.setColor(0, 255, 0)
    g.print("one way city", 50, 80)
  end

end

function Map:update(dt)

  self.currentTimeGenerate = self.currentTimeGenerate + ( love.math.random(0.5, 1.0) * dt )
  if self.currentTimeGenerate > GENERATE_BALL_TIME then
    if MAX_BALLS > #self.balls and #self.generators > 0 then
      if #self.generators > 6 then
        self:generateBall()
        self:generateBall()
        self:generateBall()
      elseif #self.generators > 3 and #self.generators < 6 then
        self:generateBall()
        self:generateBall()
      else
        self:generateBall()
      end
    end
    self.currentTimeGenerate = 0
  end

  for i, ball in ipairs(self.balls) do
    ball:update(dt, self)
  end

  for i, remover in ipairs(self.removers) do
    remover:update(self)
  end
end

function Map:preSolve(obj, x, y)
  local cellType = tileset[ self.currentGrid[y][x] ].type
  local objGrid = obj.actualGrid

  if cellType == "solid" or cellType == "visible-solid" or cellType == "invisible-solid" then return true end

  if cellType == "invisible-left" and not (obj.facing == 1 or obj.facing == 2) then 
    if objGrid.x1 > x then
      return true
    end
  end
  if cellType == "invisible-right" and not (obj.facing == 1 or obj.facing == 2) then
    if objGrid.x1 < x then
      return true
    end
  end
end

function Map:getRange(x, y, w, h)
  local gw, gh = self.tileWidth, self.tileHeight
  local gx, gy = math.floor( x / gw ) + 1,
                 math.floor( y / gh ) + 1
  local gx2, gy2 = math.ceil( (x + w) / gw ),
                   math.ceil( (y + h) / gh )
  return gx, gy, gx2, gy2
end

function Map:resolveMovementX(obj, x, y, w, h)
  local gx, gy, gx2, gy2 = self:getRange(x, y, w, h)

  local reflect = false

  if self:preSolve(obj, gx2, gy) then
    x = ((gx2-1) * self.tileWidth) - w
    reflect = true
  elseif self:preSolve(obj, gx2, gy2) then
    x = ((gx2-1) * self.tileWidth) - w
    reflect = true
  end

  if self:preSolve(obj, gx, gy) then
    x = gx * self.tileWidth
    reflect = true
  elseif self:preSolve(obj, gx, gy2) then
    x = gx * self.tileWidth
    reflect = true
  end

  return x, reflect
end

function Map:resolveMovementY(obj, x, y, w, h)
  local gx, gy, gx2, gy2 = self:getRange(x, y, w, h)

  local onFloor = false

  if self:preSolve(obj, gx, gy2) then
    y = ((gy2-1) * self.tileHeight) - h
    onFloor = true
  elseif self:preSolve(obj, gx2, gy2) then
    y = ((gy2-1) * self.tileHeight) - h
    onFloor = true
  end

  if self:preSolve(obj, gx, gy) then
    y = gy * self.tileHeight
  elseif self:preSolve(obj, gx2, gy) then
    y = gy * self.tileHeight
  end

  return y, onFloor
end

function Map:loadJewels()
  for _, jewel in ipairs(self.jewels) do
    jewel:load()
  end
end

function Map:getStageBounds()
  return self.gridWidth, self.gridHeight
end

function Map:getLadders()
  return self.ladders
end

function Map:getGenerators()
  return self.generators
end

function Map:getJewels()
  return self.jewels
end

function Map:getBombs()
  return self.bombs
end

function Map:getBalls()
  return self.balls
end

function Map:getChests()
  return self.chests
end

function Map:getCurrentLevel()
  return self.currentLevel
end

function Map:setCurrentLevel(level)
  self.currentLevel = level
end

function Map:removeJewel(index)
  table.remove(self.jewels, index)
end

function Map:cleanWorld()
  for i in ipairs(self.ladders) do
    self.ladders[i] = nil
  end
  for i in ipairs(self.generators) do
    self.generators[i] = nil
  end
  for i in ipairs(self.balls) do
    self.balls[i] = nil
  end
  for i in ipairs(self.jewels) do
    self.jewels[i] = nil
  end
  for i in ipairs(self.bombs) do
    self.bombs[i] = nil
  end
  for i in ipairs(self.chests) do
    self.chests[i] = nil
  end
  for i in ipairs(self.removers) do
    self.removers[i] = nil
  end
end

function Map:generateBall()
  local parent = self.generators[love.math.random(1, #self.generators)]
  local currentBall = Ball:new{ x = parent.x + parent.width / 2, y = parent.y + parent.height / 2 }
  table.insert(self.balls, currentBall)
end

function Map:removeBall(id)
  table.remove(self.balls, id)
end


