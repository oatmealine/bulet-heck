bullet = {}

function bullet:new(o)
	o = o or {x=0, y=0, vx=1, vy=1}
	setmetatable(o, self)
	self.__index = self

	o.wid = 6
	o.hig = 6

	o.type = 'bullet'

	o._seed = math.random(0, 10000)/10000

	return o
end

function bullet:draw(o)
	love.graphics.setColor(hslToRgb(o._seed, 0.5, 0.5))
	love.graphics.circle('line', o.x, o.y, 3)
	love.graphics.circle('line', o.x, o.y, 3.8)
	love.graphics.setColor(1,1,1)
	love.graphics.circle('fill', o.x, o.y, 3)
end

function bullet:update(o)
	local dt = love.timer.getDelta()
	o.x = o.x + o.vx * dt*65
	o.y = o.y + o.vy * dt*65
end