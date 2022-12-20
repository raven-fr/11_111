local test = {}

function test:draw()
	line(-4, 4, 0, -4, 4, 4, -4, 4)
	set_color(1, 0.6, 0.7)
	line(4, -4, 0, 4, -4, -4, 4, -4)
end

function test:init()
	self.data.angle = math.random() * math.pi
end

function test:tick()
	self.data.angle = self.data.angle + 0.1
end

return {test = test}
