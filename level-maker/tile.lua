local g = love.graphics

Tile = {}
Tile.x = 0
Tile.y = 0
Tile.width = 64
Tile.height = 64
Tile.color = { 0, 0, 0 }
Tile.type = "transparent"
Tile.name = "empty"
Tile.flag = "e"

function Tile:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end


