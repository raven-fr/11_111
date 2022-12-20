local world = require "world"
local obj = require "obj"

obj.load_types()
line = love.graphics.line
set_color = love.graphics.setColor
love.graphics.setLineWidth(0.5)

local cam = {
	x = 0, y = 0,
	scale = 256,
	panning = false,
}

for i = 1, 100 do
	obj.new("test", {math.random() * 1000, math.random() * 1000}, {
		avel = math.random() * 0.5 - 0.25,
		vel = {math.random() * 0.5 - 0.25, math.random() * 0.5 - 0.25}
	})
end

local function view_scale()
	local w, h = love.graphics.getDimensions()
	return cam.scale / math.min(w, h)
end

local function view_transform()
	local scale = view_scale()
	local trans = love.math.newTransform(0, 0, 0, 1/scale, 1/scale)
	trans:translate(cam.x, cam.y)
	return trans
end

function love.draw()
	love.graphics.clear(0,0,0)
	love.graphics.applyTransform(view_transform())
	for _, o in pairs(world.objects) do
		love.graphics.setColor(1, 1, 1)
		o:draw()
	end
end

function love.update()
	for _, o in pairs(world.objects) do
		o:tick()
	end
end

function love.mousepressed(_, _, button)
	if button == 2 then
		cam.panning = true
	end
end

function love.mousereleased(_, _, button)
	if button == 2 then
		cam.panning = false
	end
end

function love.mousemoved(_, _, dx, dy)
	if cam.panning then
		local scale = view_scale()
		dx, dy = dx * scale, dy * scale
		cam.x = cam.x + dx
		cam.y = cam.y + dy
	end
end
