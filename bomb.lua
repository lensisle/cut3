local g = love.graphics

Bomb = {}
Bomb.width  = 64
Bomb.height = 64
Bomb.x = 0
Bomb.y = 0

function Bomb:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Bomb:draw()
  g.setColor(255, 255, 0)
  g.rectangle("line", self.x, self.y, self.width, self.height)
  g.setColor(255, 0, 0)
  g.circle("fill", self.x + 32, self.y + 32, 25, 50)
  g.setColor(255, 255, 0)
end