local g = love.graphics

Jewel = {}

Jewel.x = 0
Jewel.y = 0

Jewel.width  = 16
Jewel.height = 16
Jewel.type = 1

function Jewel:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Jewel:load()
  self.type = love.math.random(1, 4)
end

function Jewel:draw()
  if self.type == 1 then
    g.setColor(255, 255, 0)
    g.rectangle("fill", self.x, self.y, self.width, self.height)
    g.setColor(255, 0, 0)
    g.rectangle("fill", self.x + 2, self.y + 2, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 10, self.y + 10, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 10, self.y + 2, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 2, self.y + 10, self.width / 4, self.height / 4)
    g.setColor(64, 244, 208)
    g.rectangle("fill", self.x + 6, self.y + 6, self.width / 4, self.height / 4)
  elseif self.type == 2 then
    
    g.setColor(127, 255, 0)
    g.rectangle("fill", self.x, self.y, self.width, self.height)
    g.setColor(0, 0, 255)
    g.rectangle("fill", self.x + 1, self.y + 6, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 6, self.y + 6, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 11, self.y + 6, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 6, self.y + 1, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 6, self.y + 11, self.width / 4, self.height / 4)

  elseif self.type == 3 then
    
    g.setColor(255, 0, 0)
    g.rectangle("fill", self.x, self.y, self.width, self.height)
    g.setColor(255, 255, 0)
    g.rectangle("fill", self.x + 1, self.y + 6, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 11, self.y + 6, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 6, self.y + 1, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 6, self.y + 11, self.width / 4, self.height / 4)
    g.setColor(0, 191, 255)
    g.rectangle("fill", self.x + 6, self.y + 6, self.width / 4, self.height / 4)

  elseif self.type == 4 then
    g.setColor(255, 255, 0)
    g.rectangle("fill", self.x, self.y, self.width, self.height)
    g.rectangle("fill", self.x + 1, self.y - 4, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 6, self.y - 4, self.width / 4, self.height / 4)
    g.rectangle("fill", self.x + 11, self.y - 4, self.width / 4, self.height / 4)
    g.setColor(255, 0, 0)
    g.rectangle("fill", self.x + 4, self.y + 4, self.width / 2, self.height / 2)
    g.setColor(255, 255, 0)
    g.rectangle("fill", self.x + 6, self.y + 6, self.width / 4, self.height / 4)
  end
end