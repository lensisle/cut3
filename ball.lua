local g = love.graphics

Ball = {}
Ball.xv = 0
Ball.yv = 0

Ball.facing = 1
Ball.speed = 140

Ball.width  = 16
Ball.height = 16

Ball.gravityFactor = 0

Ball.isColliding = false

function Ball:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  self.gravityFactor = love.math.random(200, 450)
  self.facing = love.math.random(1, 2)
  return obj
end

function Ball:draw()
  g.setColor(255, 255, 255)
  g.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Ball:update(dt, map)
 
  
  self.x = self.x + self.xv * dt
  
  self.x, self.isColliding = map:resolveMovementX(self, self.x, self.y, self.width, self.height)

  if self.isColliding then
    self:reflect()
  end

  self.y = self.y + (self.yv + self.gravityFactor) * dt

  self.y = map:resolveMovementY(self, self.x, self.y, self.width, self.height)

  self:move()
end

function Ball:move()
  if self.facing == 2 then
    self.xv = self.speed
  elseif self.facing == 1 then
    self.xv = -self.speed
  end
end

function Ball:reflect()
  if self.facing == 1 then
    self.facing = 2
    self.isColliding = false
  elseif self.facing == 2 then
    self.facing = 1
    self.isColliding = false
  end
end


