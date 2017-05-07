local g = love.graphics

Remover = {}

Remover.x = 0
Remover.y = 0
Remover.width = 28
Remover.height = 28

function Remover:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Remover:draw()
  g.setColor(255, 255, 255)
  g.rectangle("line", self.x, self.y, self.width, self.height)
  g.rectangle("line", self.x + self.width / 4, self.y + self.height / 4, self.width / 2, self.height / 2)
end

function Remover:update(map)

  for i, ball in ipairs(map:getBalls()) do
    if self:checkCollide(ball) then
      map:removeBall(i)
    end
  end

end

function Remover:checkCollide(obj)
  return self.x < obj.x + obj.width and
         obj.x < self.x + self.width and
         self.y < obj.y + obj.height and
         obj.y < self.y + self.height
end