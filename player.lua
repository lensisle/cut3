local g = love.graphics

Player = {}
Player.x = 0
Player.y = 0
Player.xv = 0
Player.yv = 0
Player.speed = 150
Player.width = 16
Player.height = 16

Player.isJumping = false
Player.onFloor = true
Player.inLadder = false

Player.lifes = 6
Player.score = 0

Player.actualGrid = { x1 = 0, x2 = 0, y1 = 0, y2 = 0 }

local PLAYER_SPEED = 150
local MAX_SPEED = 600
local JUMP_POWER = 400
local LADDER_SPEED = 180
local GRAVITY = 1000

local jewelMSG = false

local jewelsLeft = 0
local currentJewels = 0

local currentFont = g.newFont(12)
local mapFont = g.newFont(25)

function Player:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Player:update(dt, map)

  for _, ball in ipairs(map:getBalls()) do
    if self:checkCollide(ball) then
      self:die(map)
    end
  end

  for i, jewel in ipairs(map:getJewels()) do
    if self:checkCollide(jewel) then
      self:addScore(jewel)
      map:removeJewel(i)
    end
  end

  for i, bomb in ipairs(map:getBombs()) do
    if self:checkCollide(bomb) then
      self:die(map)
    end
  end

  self:move()

  self.x = self.x + self.xv * dt
  self.x = map:resolveMovementX(self, self.x, self.y, self.width, self.height)
 
  self.yv = self.yv + GRAVITY * dt
  self.yv = math.min(self.yv, MAX_SPEED)
  self.y = self.y + self.yv * dt

  self.y, self.onFloor = map:resolveMovementY(self, self.x, self.y, self.width, self.height)

  self.actualGrid.x1,
  self.actualGrid.x2,
  self.actualGrid.y1,
  self.actualGrid.y2 = map:getRange(self.x, self.y, self.width, self.height)

  for i, chest in ipairs(map:getChests()) do
    if self:checkCollide(chest) then
      if #map:getJewels() == 0 then
        if map.currentLevel == 15 then
          self:gameReset(map)
          map.levelFinished = true
        else
          self:nextLevel(map)
          map.levelFinished = true
        end
      else
        jewelMSG = true
      end
    else
      jewelMSG = false
    end
  end

  jewelsLeft = #map:getJewels()

end

function Player:move()
  if love.keyboard.isDown("left") then
    self.xv = -PLAYER_SPEED
  elseif love.keyboard.isDown("right") then
    self.xv = PLAYER_SPEED
  else
    self.xv = 0
  end

  if love.keyboard.isDown("z") and not self.isJumping and not self.inLadder and self.onFloor then
    self.isJumping = true
    self.onFloor = false
    self.yv = -JUMP_POWER
  elseif not self.onFloor then
    self.isJumping = false
  end

  if self.isJumping then
    self.yv = -JUMP_POWER
  end

  if love.keyboard.isDown("up") and self.inLadder then
    self.yv = -LADDER_SPEED - 80
  elseif love.keyboard.isDown("down") and self.inLadder then
    self.yv = LADDER_SPEED
  elseif self.inLadder then
    self.yv = 0
  end

  if love.keyboard.isDown("d") then
    print(self.x, self.y)
  end

end

function Player:draw()
  g.setColor(0, 255, 0)
  g.rectangle("fill", self.x, self.y, self.width, self.height)

  if jewelMSG then
    g.setColor(255, 255, 255)
    g.setFont(currentFont)
    g.print("Get all the jewels \nbefore leave. " .. currentJewels .. "/" .. jewelsLeft + currentJewels, self.x - self.width / 2, self.y - self.height * 2)
    g.setFont(mapFont)
  end

end

function Player:checkCollide(obj)
  return self.x < obj.x + obj.width and
         obj.x < self.x + self.width and
         self.y < obj.y + obj.height and
         obj.y < self.y + self.height
end

function Player:reset(map)
  if map.currentLevel == 1 then
    self.x = 213
    self.y = 304
  elseif map.currentLevel == 2 then
    self.x = 89
    self.y = 368
  elseif map.currentLevel == 3 then
    self.x = 153
    self.y = 752
  elseif map.currentLevel == 4 then
    self.x = 151
    self.y = 432
  elseif map.currentLevel == 5 then
    self.x = 214
    self.y = 304
  elseif map.currentLevel == 6 then
    self.x = 151
    self.y = 112
  elseif map.currentLevel == 7 then
    self.x = 86
    self.y = 304
  elseif map.currentLevel == 8 then
    self.x = 150
    self.y = 112
  elseif map.currentLevel == 9 then
    self.x = 216
    self.y = 1264
  elseif map.currentLevel == 10 then
    self.x = 280
    self.y = 560
  elseif map.currentLevel == 11 then
    self.x = 151
    self.y = 1200
  elseif map.currentLevel == 12 then
    self.x = 152
    self.y = 112
  elseif map.currentLevel == 13 then
    self.x = 149
    self.y = 176
  elseif map.currentLevel == 14 then
    self.x = 88
    self.y = 560
  elseif map.currentLevel == 15 then
    self.x = 85 
    self.y = 1072
  end
end

function Player:die(map)
  currentJewels = 0
  jewelsLeft = 0
  self.lifes = self.lifes - 1
  self:reset(map)
  map:cleanWorld()
  map:load()
end

function Player:addScore(jewel)
  currentJewels = currentJewels + 1
end

function Player:nextLevel(map)
  currentJewels = 0
  jewelsLeft = 0
  map:cleanWorld()
  map:setCurrentLevel(map:getCurrentLevel() + 1)
  map:load()
  self:reset(map)
end

function Player:gameReset(map)
  currentJewels = 0
  jewelsLeft = 0
  map:cleanWorld()
  map:setCurrentLevel(1)
  map:load()
  self:reset(map)
end



