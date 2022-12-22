local test = {hitbox = 4}

function test:draw()
	set_color(0.95, 0.95, 0.95)
	line(-4, 4, 0, -4, 4, 4, -4, 4)
	set_color(1, 0.6, 0.7)
	line(4, -4, 0, 4, -4, -4, 4, -4)
end

function test:init()
end

function test:tick()
end

return {test = test}
