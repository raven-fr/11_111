local font = require "font"
local utf8 = require "utf8"

local text = {}

local function draw_char(c, center)
	love.graphics.push()
	local c = font[c] or font["□"]
	if not center then
		love.graphics.translate(c.width / 2, 0)
	end
	for _, l in ipairs(c) do
		line(unpack(l))
	end
	love.graphics.pop()
	return c.width
end

function text.draw(str, x, y, opt)
	opt = opt or {}
	opt.scale = opt.scale or 1
	opt.spacing = opt.spacing or 3

	local lw = love.graphics.getLineWidth(lw)
	love.graphics.push()
	love.graphics.translate(x or 0, y or 0)
	love.graphics.scale(opt.scale)
	love.graphics.setLineWidth(lw / opt.scale)
	for _, c in utf8.codes(str) do
		love.graphics.translate(draw_char(utf8.char(c)), 0)
		love.graphics.translate(opt.spacing, 0)
	end
	love.graphics.pop()
	love.graphics.setLineWidth(lw)
end

return text
