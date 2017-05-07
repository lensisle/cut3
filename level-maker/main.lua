require "tile"
require "../ladder"
require "../jewel"
require "../bomb"
require "../remover"
require "../generator"
require "../chest"
local gamera = require "gamera"

local g = love.graphics
local level = {}
local objects = {}

local tiles = {}

local textInput = ""
local textStatus = ""

local currentTile = nil

local currentClickX = 0 
local currentClickY = 0

local yPadding = 100

local c = gamera.new(0, 0, g.getWidth(), g.getHeight())

local cameraSpeed = 250

local currentX, currentY = c:getPosition()

local stageWidth, stageHeight = 0, 0

local currentObj = nil
local currentObjID = ""

function love.load()
  platform = Tile:new()
  platform.color = { 70, 130, 180 }
  platform.type = "solid"
  platform.name = "platform"
  platform.flag = "p"
  platform.x = 0

  empty = Tile:new()
  empty.color = { 255, 0, 255 }
  empty.type = "transparent"
  empty.name = "empty"
  empty.flag = "e"
  empty.x = 64

  invisible = Tile:new()
  invisible.color = { 0, 0, 0 }
  invisible.type = "invisible-solid"
  invisible.name = "invisible"
  invisible.flag = "i"
  invisible.x = 128

  visibleSolid = Tile:new()
  visibleSolid.color = { 255, 0, 255 }
  visibleSolid.type = "visible-solid"
  visibleSolid.name = "visible solid"
  visibleSolid.flag = "k"
  visibleSolid.x = 192

  invisibleLeft = Tile:new()
  invisibleLeft.color = { 0, 255, 0 }
  invisibleLeft.type = "invisible-left"
  invisibleLeft.name = "invisible left"
  invisibleLeft.flag = "l"
  invisibleLeft.x = 256

  invisibleRight = Tile:new()
  invisibleRight.color = { 255, 255, 0 }
  invisibleRight.type = "invisible-right"
  invisibleRight.name = "invisible right"
  invisibleRight.flag = "r"
  invisibleRight.x = 320

  hiddenNight = Tile:new()
  hiddenNight.color = { 0, 0, 0 }
  hiddenNight.type = "hidden-night"
  hiddenNight.name = "hidden night"
  hiddenNight.flag = "h"
  hiddenNight.x = 384

  table.insert(tiles, invisibleLeft)
  table.insert(tiles, invisibleRight)
  table.insert(tiles, hiddenNight)
  table.insert(tiles, visibleSolid)
  table.insert(tiles, invisible)
  table.insert(tiles, platform)
  table.insert(tiles, empty)

  setCameraBounds()
end

function love.update(dt)

  if dt > 1/60 then dt = 1/60 end

  -- TODO: fix out of bounds movement

  if love.keyboard.isDown("left") then
    currentX = currentX - cameraSpeed * dt
    c:setPosition(currentX, currentY)
  elseif love.keyboard.isDown("right") then
    currentX = currentX + cameraSpeed * dt
    c:setPosition(currentX, currentY)
  elseif love.keyboard.isDown("up") then
    currentY = currentY - cameraSpeed * dt
    c:setPosition(currentX, currentY)
  elseif love.keyboard.isDown("down") then
    currentY = currentY + cameraSpeed * dt
    c:setPosition(currentX, currentY)
  end

  if love.keyboard.isDown("backspace") then
    if string.len(textInput) > 0 then
      textInput = textInput:sub(1, #textInput - 1)
    end
  end

  if love.keyboard.isDown("return") then
    if string.match(textInput, "map") then
      local mapWidth, mapHeight = 0, 0
      local cleanInput = textInput:sub(4, #textInput)
      local cleanTable = split(cleanInput, "x")
      if #cleanTable > 1 then
        mapWidth, mapHeight = tonumber(cleanTable[1]), tonumber(cleanTable[2])
      end
      loadLevel(mapWidth, mapHeight)
      textInput = ""
      textStatus = "Status: <Map generated> " .. mapWidth .. "x" .. mapHeight

      setCameraBounds()
    end

    if string.match(textInput, "clear") then
      currentTile = nil
      currentObj = nil
      textInput = ""
    end

    if string.match(textInput, "save") then
      save(level)
      textInput = ""
    end

    if string.match(textInput, "obj") then
      local obj = textInput:sub(4, #textInput)
      loadObject(obj)
      textInput = ""
    end

    if string.match(textInput, "clean") then
      objects = {}
      textInput = ""
    end

    if string.match(textInput, "last") then    
      objects[#objects] = nil
      textInput = ""
    end

    if string.match(textInput, "id") then    
      local id = textInput:sub(3, #textInput)     
      for i, obj in pairs(objects) do
        if i == tonumber(id) then
          if objects[i] then
            objects[i] = nil
          end
        end
      end
      textInput = ""
    end

  end

  -- selecting a tile
  for i, tile in ipairs(tiles) do
    if currentClickX > tile.x and
       currentClickX < tile.x + tile.width and
       currentClickY > tile.y and
       currentClickY < tile.y + tile.height then

      currentObj = nil
      currentTile = tile
    end
  end

end

function split(inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          t[i] = str
          i = i + 1
  end
  return t
end

function love.textinput(t)
  textInput = textInput .. t
end

function love.mousereleased(x, y, button)
  if button == 'l' then
    currentClickX, currentClickY = c:toWorld(love.mouse.getPosition())
    if currentTile then
      checkAdd(level)
    elseif currentObj then
      checkAddObj(currentObj)
    end
  end
end

function love.draw()

  c:draw(function(l,t,w,h)

    g.setBackgroundColor(51, 51, 51)
    
    for i, v in ipairs(tiles) do
      i = i - 1
      g.setColor(v.color[1], v.color[2], v.color[3])
      if v.type == "visible-solid" or v.type == "invisible-left" or v.type == "invisible-right" or v.type == "transparent" then
        g.rectangle("line", v.x, v.y, v.width, v.height)
      else
        g.rectangle("fill", v.x, v.y, v.width, v.height)
      end
      
      g.setColor(0, 255, 0, 255)
      g.printf(v.name, v.x, v.y + v.height / 2 - 4, 64, "center")
    end

    g.print("Console: ", 0, 80)
    g.print(textInput, 80, 80)
    g.print(textStatus, 80, 95)

    if #level > 0 then
      drawLevel(level)
    end

    if currentTile then
      drawTile(currentTile)
    elseif currentObj then
      drawObject(currentObj)
    end

    if #objects > 0 then
      for i, obj in pairs(objects) do
        obj[1]:draw()
      end
    end

  end)

end

function drawObject(obj)
  local ox, oy = c:toWorld(love.mouse.getPosition())
  obj.x = ox
  obj.y = oy
  obj:draw()
end

function drawTile(tile)
  g.setColor(tile.color[1], tile.color[2], tile.color[3])
  local tx, ty = c:toWorld(love.mouse.getPosition())
  if tile.type == "visible-solid" or tile.type == "invisible-left" or tile.type == "invisible-right" or tile.type == "transparent" then
    g.rectangle("line", tx - tile.width / 2, ty - tile.height / 2, tile.width, tile.height)
  else
    g.rectangle("fill", tx - tile.width / 2, ty - tile.height / 2, tile.width, tile.height)
  end
  g.setColor(0, 255, 0, 255)
  g.printf(tile.name, tx - tile.width / 2, ty - 10, 64, "center")
end

function drawLevel(level)
  for i, row in ipairs(level) do
    for j, tile in ipairs(row) do
      g.setColor(tile.color[1], tile.color[2], tile.color[3])
      if tile.type == "visible-solid" or tile.type == "invisible-left" or tile.type == "invisible-right" or tile.type == "transparent" then
        g.rectangle("line", tile.x, tile.y, tile.width, tile.height)
      else
        g.rectangle("fill", tile.x, tile.y, tile.width, tile.height)
      end
      g.setColor(0, 255, 0, 255)
      g.printf(tile.name, tile.x, tile.y + 12, 64, "center")
    end
  end
end

function loadLevel(w, h)
  level = {}
  for i=1,h do
    level[i] = {}
    for j=1,w do
      local currentTile = Tile:new()
      currentTile.color = { 255, 0, 255 }
      currentTile.type = "transparent"
      currentTile.name = "empty"
      currentTile.flag = "e"
      currentTile.x = currentTile.width * j 
      currentTile.y = currentTile.height * i + yPadding
      level[i][j] = currentTile
    end
  end
end

function checkAdd(level)
  if currentClickY > 100 then

    for i, row in ipairs(level) do
      for j, tile in ipairs(row) do

        if currentClickX > tile.x and
          currentClickX < tile.x + tile.width and
          currentClickY > tile.y and
          currentClickY < tile.y + tile.height then

          local insertedTile = Tile:new()
          insertedTile.x = tile.x
          insertedTile.y = tile.y
          insertedTile.name = currentTile.name
          insertedTile.flag = currentTile.flag
          insertedTile.type = currentTile.type
          insertedTile.color = currentTile.color
          level[i][j] = insertedTile
        end

      end
    end

  end
end

function checkAddObj(obj)
  local newObj = obj
  newObj.x, newObj.y = currentClickX, currentClickY
  local objPair = { newObj, currentObjID }
  table.insert(objects, objPair)
  currentObj = nil
end

function setCameraBounds()
  stageWidth, stageHeight = g.getHeight(), g.getWidth()
  if #level > 0 and #level[1] > 0 then
      
      stageWidth = #level * 64 + 64 + 200
      stageHeight = #level[1] * 64 + 100 + 64 + 200

      if stageWidth < g.getHeight() then
        stageWidth = g.getHeight()
      end 

      if stageHeight < g.getWidth() then
        stageHeight = g.getWidth()
      end

  end
  c:setWorld(0, 0, stageHeight, stageWidth)
end

-- TODO: Fix this function to automatize the process of adding a new level in the game. 
-- EX: open the levels file and append the new level to the existing levels

function save(level)
  local levelstr = levelToString(level)
  fl = io.open("level-maker/level.lua", "w")
  io.output(fl)
  io.write(levelstr)
  io.close()
  if #objects > 0 then
    local objsstr = objectsToString(objects)
    ol = io.open("level-maker/objects.lua", "w")
    io.output(ol)
    io.write(objsstr)
    io.close()
  end
end

function levelToString(level)
  local levelstr = ""
  for i, row in pairs(level) do
    levelstr = levelstr .. "{"
    for j, tile in pairs(row) do
      if j < #row then
        levelstr = levelstr .. "'" .. tile.flag .. "',"
      else
        levelstr = levelstr .. "'" .. tile.flag .. "'"
      end
    end
    if i < #level then
      levelstr = levelstr .. "},\n"
    else
      levelstr = levelstr .. "}"
    end
  end
  return levelstr
end

function objectsToString(objects)
  local objsstr = ""
  for i, obj in pairs(objects) do
    c:setPosition(c:toWorld(0, 0))
    local lx, ly = c:toScreen(obj[1].x - 64, obj[1].y - 164) 
    if i == #objects then
      objsstr = objsstr .. "{" .. lx .. "," .. ly .. "," .. "'" .. obj[2] .. "'" .. "}"
    else
      objsstr = objsstr .. "{" .. lx .. "," .. ly .. "," .. "'" .. obj[2] .. "'" .. "}," .. "\n"
    end
  end
  return objsstr
end

function loadObject(obj)
  currentTile = nil
  currentObj = nil
  if obj == "ladder" then
    currentObj = Ladder:new()
    currentObjID = "ladder"
  elseif obj == "jewel" then
    currentObj = Jewel:new()
    currentObj:load()
    currentObjID = "jewel"
  elseif obj == "bomb" then
    currentObj = Bomb:new()
    currentObjID = "bomb"
  elseif obj == "remover" then
    currentObj = Remover:new()
    currentObjID = "remover"
  elseif obj == "generator" then
    currentObj = Generator:new()
    currentObjID = "generator"
  elseif obj == "chest" then
    currentObj = Chest:new()
    currentObjID = "chest"
  end
end










