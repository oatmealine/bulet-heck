local startload = love.timer.getTime()

require "audio"
require "utils"

scene = {}
projectiles = {}

ox = love.graphics.getWidth()/3
oy = love.graphics.getHeight()/2

points = 0
didpointsanim = false
pointsanimprog = 0

local upd = 0

function love.load()
  sprites = {}
  palettes = {}

  love.graphics.setDefaultFilter("nearest","nearest")

  local function addsprites(d)
    local dir = "assets/sprites"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if string.sub(file, -4) == ".png" then
        local spritename = string.sub(file, 1, -5)
        local sprite = love.graphics.newImage(dir .. "/" .. file)
        if d then
          spritename = d .. "/" .. spritename
        end
        sprites[spritename] = sprite
        --print(colr.cyan("ℹ️ added sprite "..spritename))
      elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        print("ℹ️ found sprite dir: " .. file)
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addsprites(file)
      end
    end
  end
  addsprites()

  local function addAudio(d)
    local dir = "assets/audio"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addAudio(file)
      else
        local audioname = file
        if file:ends(".wav") then audioname = file:sub(1, -5) end
        if file:ends(".mp3") then audioname = file:sub(1, -5) end
        if file:ends(".ogg") then audioname = file:sub(1, -5) end
        if file:ends(".flac") then audioname = file:sub(1, -5) end
        if file:ends(".xm") then audioname = file:sub(1, -4) end
        --[[if d then
          audioname = d .. "/" .. audioname
        end]]
        sound_exists[audioname] = true
        --print("ℹ️ audio "..audioname.." added")
      end
    end
  end
  addAudio()

  local function addEntities(d)
    local dir = "entities"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addEntities(file)
      else
        require(dir .. '/' .. file:sub(1, -5))
      end
    end
  end
  addEntities()

  print("boot complete!")

  print("load took ~"..(math.floor((love.timer.getTime()-startload)*1000)/1000).."ms")
end

function love.draw()
  local dt = love.timer.getDelta()
  love.graphics.setColor(1,1,1)
  
  local time = love.timer.getTime()
  local function renderparralax(sprite, speed, xoffset, sine)
    local scale = love.graphics.getHeight()/sprite:getHeight()
    local yoffset = (sine == true) and math.cos(time*3 + speed/10)*2 or 0

    love.graphics.draw(sprite, -sprite:getWidth()*scale + (time*speed) % (sprite:getWidth()*scale) + xoffset, yoffset, 0, scale, scale)

    love.graphics.draw(sprite, (time*speed) % (sprite:getWidth()*scale) + xoffset, yoffset, 0, scale, scale)

    love.graphics.draw(sprite, sprite:getWidth()*scale + (time*speed) % (sprite:getWidth()*scale) + xoffset, yoffset, 0, scale, scale)
  end

  renderparralax(sprites["bg/bg0"], 15, 0)
  renderparralax(sprites["bg/bg1"], 30, 0)

  renderparralax(sprites["bg/bgc0"], 40, 0, true)
  renderparralax(sprites["bg/bgc1"], 60, 0, true)
  renderparralax(sprites["bg/bgc2"], 50, 0, true)
  renderparralax(sprites["bg/bgc3"], 70, 0, true)
  renderparralax(sprites["bg/bgc4"], 65, 0, true)

  for _,o in ipairs(scene) do
    o:draw(o)
  end

  love.graphics.setColor(1,1,1)
  for _,p in ipairs(projectiles) do
    if p.type == 'bullet' then
      love.graphics.setColor(1,1,1)
      love.graphics.circle('fill', p.x-p.size, p.y-p.size, p.size)
    elseif p.type == 'point' then
      love.graphics.push()
      
      love.graphics.translate(p.x, p.y)
      love.graphics.rotate(love.timer.getTime()*(1+p.seed/2) + (p.seed * 4))
      
      love.graphics.setColor(hslToRgb(p.seed, 0.6, 0.5))
      love.graphics.rectangle('fill', -p.size/2, -p.size/2, p.size, p.size)
     
      love.graphics.pop()
    end
  end

  love.graphics.setColor(1,1,1)
  love.graphics.draw(sprites["o"], ox-16, oy-14+math.sin(love.timer.getTime())*2)
  love.graphics.rectangle('fill', ox, oy, 1, 1)
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle('line', ox-1, oy-1, 3, 3)

  for i=0, math.pi*8-1 do
    love.graphics.push()

    love.graphics.translate(ox, oy)
    love.graphics.rotate(i/4)

    local alpha = (points/1000 > i/(math.pi*8-1)) and 1 or 0.2

    love.graphics.setColor(1,1,1,alpha)
    love.graphics.circle('fill', 0, -23, 2)
    love.graphics.setColor(0.1,0.1,0.1,alpha)
    love.graphics.circle('line', 0, -23, 2)
    
    love.graphics.pop()
  end

  if not didpointsanim and points > 1000 then
    didpointsanim = true
    pointsanimprog = 1
  end

  if pointsanimprog ~= 0 then
    pointsanimprog = pointsanimprog + dt*200
    local alpha = (300-pointsanimprog)/300

    love.graphics.setColor(1,1,0,alpha)
    love.graphics.circle('line', ox, oy, pointsanimprog)
    love.graphics.setColor(1,1,0,0.75*alpha)
    love.graphics.circle('line', ox, oy, pointsanimprog-10)
    love.graphics.setColor(1,1,0,0.25*alpha)
    love.graphics.circle('line', ox, oy, pointsanimprog-20)

    if alpha < 0 then
      pointsanimprog = 0
    end
  end
end

function love.update(dt)
  upd = upd + 1
  if upd % 50 == 1 then
    if math.random(1,3) == 1 then
      table.insert(scene, testent2:new{x = love.graphics.getWidth(), y = math.random(0,love.graphics.getHeight())})
    else
      table.insert(scene, testent:new{x = love.graphics.getWidth(), y = math.random(0,love.graphics.getHeight())})
    end
  end

  if love.keyboard.isDown('down') then
    oy = oy + dt*230
  end
  if love.keyboard.isDown('up') then
    oy = oy - dt*230
  end
  if love.keyboard.isDown('right') then
    ox = ox + dt*230
  end
  if love.keyboard.isDown('left') then
    ox = ox - dt*230
  end
  if love.keyboard.isDown('z') then
    table.insert(projectiles, {size = 3, x = ox, y = 4+oy+math.sin(love.timer.getTime()*8)*10, type = 'bullet', vx = 5, vy = 0})
    table.insert(projectiles, {size = 3, x = ox, y = 4+oy+math.sin(-love.timer.getTime()*8)*10, type = 'bullet', vx = 5, vy = 0})
  end

  for _,o in ipairs(scene) do
    o:update(o)

    if ox > o.x-o.wid/2 and ox < o.x+o.wid/2 and oy > o.y-o.hig/2 and oy < o.y+o.hig/2 then
      odie()
    end

    if o.x-10 > love.graphics.getWidth() or o.x+10 < 0 or o.y-10 > love.graphics.getHeight() or o.y+10 < 0 then
      table.remove(scene, _)
    end
  end

  for _,p in ipairs(projectiles) do
    if p.type == 'bullet' then
      p.x = p.x + p.vx * dt*65
      p.y = p.y + p.vy * dt*65
      if p.x-10 > love.graphics.getWidth() or p.x+10 < 0 or p.y-10 > love.graphics.getHeight() or p.y+10 < 0 then
        table.remove(projectiles, _)
      end
      for i,o in ipairs(scene) do
        if p.x > o.x-o.wid/2 and p.x < o.x+o.wid/2 and p.y > o.y-o.hig/2 and p.y < o.y+o.hig/2 and o.type ~= 'bullet' then
          table.remove(projectiles, _)
          if not o.hp or o.hp < 0 then
            table.remove(scene, i)
            for i=0, math.random(2,6) do
              table.insert(projectiles, {size = math.random(4,7), x = o.x+math.random(-20,20), y = o.y+math.random(-20,20), type = 'point', seed = math.random(0, 10000)/10000})
            end
          else
            o.hp = o.hp - p.size/3
            if o.hurt then o:hurt(o) end
          end
        end
      end
    elseif p.type == 'point' then
      if not ((math.abs(ox - p.x) > 400) or (math.abs(oy - p.y) > 400)) then
        p.x = p.x + (ox - p.x) * ((400-math.abs(ox-p.x))/2300)
        p.y = p.y + (oy - p.y) * ((400-math.abs(oy-p.y))/2300)
      end

      if p.x > ox-16 and p.y > oy-16 and p.x < ox+16 and p.y < oy+16 then
        points = points + 10
        table.remove(projectiles, _)
      end
    end
  end
end

function love.keypressed(key)
  if key == 'r' then
    scene = {}
    projectiles = {}
    ox = love.graphics.getWidth()/3
    oy = love.graphics.getHeight()/2
    points = 0
    didpointsanim = false
    pointsanimprog = 0
  elseif key == 'x' then
    if points > 1000 then
      for i=0, 50 do
        table.insert(projectiles, {size = 10, x = ox, y = oy, type = 'bullet', vx = i/10, vy = 5-i/10})
        table.insert(projectiles, {size = 10, x = ox, y = oy, type = 'bullet', vx = 5-i/10, vy = i/10})
        table.insert(projectiles, {size = 10, x = ox, y = oy, type = 'bullet', vx = 5-i/10, vy = -i/10})
      end
      points = 0
      didpointsanim = false
    end
  end
end

function odie()
  ox = -9999
  oy = -9999
end