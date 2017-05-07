require "ball"

local g = love.graphics

Generator = {}

Generator.x = 0
Generator.y = 0
Generator.width  = 32
Generator.height = 16

function Generator:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Generator:draw()
  g.setColor(138, 43, 226)
  g.rectangle("fill", self.x, self.y, self.width, self.height)
  g.setColor(147, 112, 219)
  g.rectangle("fill", self.x + 7, self.y + 5, 4, 4)
  g.rectangle("fill", self.x + 15, self.y + 5, 4, 4)
  g.rectangle("fill", self.x + 23, self.y + 5, 4, 4)
end
