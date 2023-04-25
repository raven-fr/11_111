local obj = require "obj"
local util = require 'util'

local x_obj = {hitbox = 4}

function x_obj:draw()
	set_color(0.5, 1, 0.8)
	line(-1, 4, -3, 3, -4, 1, 0, 0, -1, 4)
	line(0, 0, 1, 4, 3, 3, 4, 1, 0, 0)
	line(0, 0, 4, -1, 3, -3, 1, -4, 0, 0)
	line(0, 0, -1, -4, -3, -3, -4, -1, 0, 0)
end

local range = 40
function x_obj:tick()
    local x, y = unpack(self.data.pos)
	for o in obj.in_circle(x, y, range) do
		if o ~= self then
			local px, py = self:observe_pos(o)
			local mag = util.magnitude{px, py}
			local dx, dy = px / mag, py / mag
			self:avel_to_accel(o, dx * mag/range/10, dy * mag/range/10)
		end
	end
end

return {x = x_obj}
