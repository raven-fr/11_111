line = love.graphics.line
function box(x, y, w, h) line(x, y, x + w, y, x + w, y + h, x, y + h, x, y) end
set_color = love.graphics.setColor

local coarsity = 4
local lines = {}
local placing

local function window_scale()
	local w, h = love.graphics.getDimensions()
	return 18 / math.min(w, h)
end

local function window_transform()
	local scale = window_scale()
	local w, h = love.graphics.getDimensions()
	local trans = love.math.newTransform(w/2, h/2, 0, 1/scale, 1/scale)
	return trans
end

local function nearest(x, y)
	local c = 16 / coarsity
	return math.floor(x / c + 0.5) * c,
		math.floor(y / c + 0.5) * c
end

function love.draw()
	love.graphics.applyTransform(window_transform())
	love.graphics.setLineWidth(0.04)
	set_color(0.2, 0.2, 0.2)
	local c = 16 / coarsity
	for x = -8, 8 - c, c do
		for y = -8, 8 - c, c do
			line(x, y, x + c, y)
			line(x, y, x, y + c)
		end
	end
	set_color(0.4, 0.4, 0.4)
	box(-8, -8, 16, 16)
	box(-4, -4, 8, 8)
	set_color(1, 1, 1)
	for _, l in ipairs(lines) do
		line(unpack(l))
	end
	if placing then
		for i = 1, #placing - 2, 2 do
			line(unpack(placing, i, i + 3))
		end
	end
end

function love.mousepressed(x, y, button)
	local x, y = window_transform():inverseTransformPoint(x, y)
	if button == 1 then
		local x, y = nearest(x, y)
		if not placing then
			placing = {x, y, x, y}
		else
			if placing[#placing - 3] == placing[#placing - 1]
					and placing[#placing - 2] == placing[#placing] then
				table.remove(placing)
				table.remove(placing)
				if #placing >= 4 then
					table.insert(lines, placing)
				end
				placing = nil
			else
				table.insert(placing, x)
				table.insert(placing, y)
			end
		end
	end
end

function love.mousemoved(x, y, _, _)
	local x, y = window_transform():inverseTransformPoint(x, y)
	if placing then
		local x, y = nearest(x, y)
		placing[#placing - 1], placing[#placing] = x, y
	end
end

function love.wheelmoved(_, y)
	if y > 0 and coarsity < 64 then
		coarsity = coarsity * 2
	elseif y < 0 and coarsity > 4 then
		coarsity = coarsity / 2
	end
end

function to_commands(lines)
	local t = {}
	for _, l in ipairs(lines) do
		table.insert(t, "\tline("..table.concat(l, ", ")..")\n")
	end
	return table.concat(t)
end

function to_array(lines)
	local t = {}
	for _, l in ipairs(lines) do
		table.insert(t, "\t{"..table.concat(l, ", ").."}")
	end
	return "{\n"..table.concat(t, ",\n").."\n}\n"
end

function love.keypressed(key)
	if love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
		if key == "c" then
			if love.keyboard.isDown "lalt" or love.keyboard.isDown "ralt" then
				lines = {}
			else
				love.system.setClipboardText(to_array(lines))
			end
		elseif key == "v" then
			local c, err = loadstring("return "..love.system.getClipboardText())
			if c then
				local ok, ls = pcall(c)
				if ok then lines = ls end
			end
		end
	end
end
