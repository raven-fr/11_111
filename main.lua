
local cam = {
	x = 0, y = 0,
	scale = 256,
	panning = false,
}

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
	love.graphics.setColor(1, 1, 1)
	love.graphics.ellipse("fill", 10, 10, 1, 1)
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
