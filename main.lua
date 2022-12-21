local world = require "world"
local obj = require "obj"

obj.load_types()
line = love.graphics.line
set_color = love.graphics.setColor

line_width = 0.4
local cam = {
	x = 0, y = 0,
	scale = 1.1,
	panning = false,
}

for i = 1, 100 do
	obj.new("test", {math.random() * 1000, math.random() * 1000}, {
		avel = math.random() * 0.5 - 0.25,
		vel = {math.random() * 0.5 - 0.25, math.random() * 0.5 - 0.25}
	})
end

obj.new("test", {0, 0})

local function window_scale()
	local w, h = love.graphics.getDimensions()
	return 256 / math.min(w, h)
end

local function view_scale()
	return window_scale() / cam.scale
end

local function view_dimensions()
	local w, h = love.graphics.getDimensions()
	local scale = view_scale()
	return w * scale, h * scale
end

local function window_transform()
	local scale = window_scale()
	local trans = love.math.newTransform(0, 0, 0, 1/scale, 1/scale)
	return trans
end

local function view_transform()
	local w, h = view_dimensions()
	local trans = window_transform()
	trans:scale(cam.scale, cam.scale)
	trans:translate(-cam.x + w/2, -cam.y + h/2)
	return trans
end

function love.draw()
	love.graphics.clear(0, 0, 0)
	local w, h = view_dimensions()
	local cx1, cy1 = cam.x - w/2, cam.y - h/2
	local cx2, cy2 = cam.x + w/2, cam.y + h/2

	love.graphics.applyTransform(view_transform())
	-- the line thickness will scale according to the zoom amount. counteract this.
	love.graphics.setLineWidth(line_width / cam.scale)
	-- draw a grid
	set_color(0.1, 0.1, 0.1)
	for x = cx1 - cx1%64, cx2, 64 do
		for y = cy1 - cy1%64, cy2, 64 do
			line(x, y, x + world.chunk_size, y)
			line(x, y, x, y + world.chunk_size)
		end
	end
	-- draw all possibly visible objects
	for o in world.iterate(cx1 - 20, cy1 - 20, cx2 + 20, cy2 + 20) do
		set_color(1, 1, 1)
		o:draw()
	end
	love.graphics.origin()

	love.graphics.applyTransform(window_transform())
	love.graphics.setLineWidth(line_width)
	set_color(1, 1, 1)
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
		cam.x = cam.x - dx
		cam.y = cam.y - dy
	end
end

function love.wheelmoved(_, y)
	cam.scale = math.min(math.max(cam.scale + (y * 0.1), 0.25), 4)
end
