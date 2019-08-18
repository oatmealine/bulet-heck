testent = {}
testent2 = {}

function testent:new(o)
	o = o or {x=0, y=0}
	setmetatable(o, self)
	self.__index = self

	o._time = math.random(0, 31415)/10000
	o._darkflash = 1
	o._seed = math.random(0, 10000)/10000
	o.wid = 32
	o.hig = 32

	o.type = 'entity'

	o.hp = 20

	return o
end

function testent:draw(o)
	love.graphics.setColor(o._darkflash, o._darkflash, o._darkflash)
	love.graphics.draw(sprites["square"], o.x-16, o.y-16)
end

function testent:update(o)
	local dt = love.timer.getDelta()
	o._time = o._time + dt*5

	o.x = o.x - 2
	o.y = o.y + math.sin(o._time)*(1+o._seed)

	if o._time > math.pi*2 then
		local tilt = math.random(-3, 3)/5

		table.insert(scene, bullet:new{x = o.x, y = o.y, vx = tilt, vy = -1})
		table.insert(scene, bullet:new{x = o.x, y = o.y, vx = -tilt, vy = 1})

		o._time = o._time - math.pi*2
	end

	if o._darkflash < 1 then
		o._darkflash = o._darkflash + 0.1
	end
end

function testent:hurt(o)
	o._darkflash = 0.2
end


function testent2:new(o)
	o = o or {x=0, y=0}
	setmetatable(o, self)
	self.__index = self

	o._time = math.random(0, 31415)/10000
	o._darkflash = 1
	o._seed = math.random(0,1)*2-1
	o.wid = 32
	o.hig = 32

	o.type = 'entity'

	o.hp = 20

	return o
end

function testent2:draw(o)
	love.graphics.setColor(o._darkflash, o._darkflash, o._darkflash)
	love.graphics.draw(sprites["triangle"], o.x-16, o.y-16)
end

function testent2:update(o)
	local dt = love.timer.getDelta()
	o._time = o._time + dt*5

	o.x = o.x - 5 + o._time/2
	o.y = o.y - o._seed*2

	if (o._time > 4) and (o._time < 6) then
		table.insert(scene, bullet:new{x = o.x, y = o.y, vx = -3, vy = math.random(-5,5)/100})
	end

	if o._darkflash < 1 then
		o._darkflash = o._darkflash + 0.1
	end
end

function testent2:hurt(o)
	o._darkflash = 0.2
end

