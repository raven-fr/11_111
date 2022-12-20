local test = {radius = 4}

function test:draw()
	line(-4, 4, 0, -4, 4, 4, -4, 4)
	set_color(4, 0.6, 0.7)
	line(4, -4, 0, 4, -4, -4, 4, -4)
end

function test:init()
end

function test:tick()
end

return {test = test}
