local g = love.graphics

Chest = {}
Chest.width = 32
Chest.height = 16 
Chest.x = 0
Chest.y = 0

function Chest:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Chest:draw()
  g.setColor(192, 192, 192)
  g.rectangle("fill", self.x, self.y, self.width, self.height)
  g.setColor(255, 255, 0)
  g.rectangle("fill", self.x, self.y - 5, self.width, self.height / 2)
  g.setColor(0, 0, 0)
  g.rectangle("line", self.x + self.width / 3, self.y , self.width / 3, self.height / 2)
  g.rectangle("line", self.x, self.y + 3, self.width, 1)
end