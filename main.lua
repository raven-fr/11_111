local obj = require "obj"

obj.load_types()
line = love.graphics.line
function box(x, y, w, h) line(x, y, x + w, y, x + w, y + h, x, y + h, x, y) end
set_color = love.graphics.setColor

local line_width = 0.4
local cam = {
	x = 0, y = 0,
	scale = 1.1,
	panning = false,
}
local dragging
local selecting
local selection

for i = 1, 100 do
	obj.new("test", {math.random() * 1000 - 500, math.random() * 1000 - 500}, {
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

local function draw_world()
	local w, h = view_dimensions()
	local cx1, cy1 = cam.x - w/2, cam.y - h/2
	local cx2, cy2 = cam.x + w/2, cam.y + h/2
	love.graphics.push()
	love.graphics.applyTransform(view_transform())
	-- the line thickness will scale according to the zoom amount. counteract this.
	love.graphics.setLineWidth(line_width / cam.scale)
	-- draw a grid
	set_color(0.1, 0.1, 0.1)
	for x = cx1 - cx1%64, cx2, 64 do
		for y = cy1 - cy1%64, cy2, 64 do
			line(x, y, x + 64, y)
			line(x, y, x, y + 64)
		end
	end
	-- draw all possibly visible objects
	for o in obj.in_box(
			cx1 - obj.max_size, cy1 - obj.max_size,
			cx2 + obj.max_size, cy2 + obj.max_size) do
		set_color(1, 1, 1)
		o:draw()
	end
	if selection then
		set_color(1, 1, 0.5)
		for o in pairs(selection) do
			local x, y = unpack(o.data.pos)
			box(x - o.hitbox, y - o.hitbox, o.hitbox*2, o.hitbox*2)
		end
	end
	love.graphics.pop()
end

local function draw_hud()
	love.graphics.push()
	love.graphics.applyTransform(window_transform())
	love.graphics.setLineWidth(line_width)
	-- things
	love.graphics.pop()
end

function love.draw()
	love.graphics.clear(0, 0, 0)
	draw_world()
	draw_hud()
end

function love.update()
	if not (selection or dragging) then
		for o in obj.all() do
			o:tick()
		end
	end
end

function love.mousepressed(x, y, button)
	local x, y = view_transform():inverseTransformPoint(x, y)
	if button == 1 then
	elseif button == 2 then
		cam.panning = true
	end
end

function love.mousereleased(x, y, button)
	local x, y = view_transform():inverseTransformPoint(x, y)
	if button == 1 then
		if not dragging then
			local clicked = obj.at(x, y)()
			if not love.keyboard.isDown "lshift" then
				if clicked and not (selection and selection[clicked]) then
					selection = {[clicked] = true}
				else
					selection = nil
				end
			elseif clicked then
				selection = selection or {}
				selection[clicked] = true
			end
		else
			selecting = nil
		end
		dragging = nil
	elseif button == 2 then
		cam.panning = false
	end
end

function love.mousemoved(x, y, dx, dy)
	local x, y = view_transform():inverseTransformPoint(x, y)
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
