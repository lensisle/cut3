local g = love.graphics

Ladder = {}
Ladder.x = 0
Ladder.y = 0
Ladder.width  = 16
Ladder.height = 128


function Ladder:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Ladder:draw()
  g.setColor(0, 191, 255)
  g.line(self.x, self.y + 10, self.x + self.width, self.y + 10)
  for i=1, 10 do
    g.line(self.x, self.y + i + ((10 * i) + 10), self.x + self.width, self.y + i + ((10 * i) + 10))
  end
  g.rectangle("line", self.x, self.y, self.width, self.height)
end

function Ladder:checkNearby(player)
  local isNearby = false
  if player.x > self.x - self.width / 2 and player.x < self.x + self.width and player.y > self.y and player.y < self.y + self.height then
    isNearby = true
  end
  return isNearby
end