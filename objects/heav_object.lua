local heav_object = {hitbox = 4}
local obj = require "obj"

function heav_object:draw()
    set_color(0.8,0.7,0.95)
	line(0, 4, -4, 0, 0, -4, 4, 0, 0, 4)
end

function heav_object:init()
    self.time = 0
end

function heav_object:tick()
    local x, y = self.data.pos[1], self.data.pos[2]
    self.time = self.time+1
    local the = math.sin(self.time/5) / 30
    for obj in obj.in_box(x-50, y-50, x+50, y+50) do
        if obj ~= self then
            obj.data.avel = obj.data.avel + the
        end
    end
end

return {heav_object = heav_object}