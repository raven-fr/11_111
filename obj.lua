local world = require "world"
local pi = math.pi

local obj = {}

obj.max_size = 20
local types = {}

function obj.load_types()
	for _, f in ipairs(love.filesystem.getDirectoryItems "objects") do
		local ts = assert(love.filesystem.load("objects/"..f))()
		for t, v in pairs(ts) do
			types[t] = v
		end
	end
end
 
function obj.new(type, pos, data, ...)
	world.last_id = world.last_id + 1
	local o = setmetatable(
		{id = world.last_id, data = data or {}, type = type}, obj)
	o.data.pos = pos
	o:init(...)
	return o
end

function obj.load(id, data)
	local o = setmetatable({id = id, data = data, type = data.type}, obj)
	o:init()
	return o
end

function obj.is_obj(v)
	return getmetatable(v) == obj
end

function obj:__index(v)
	if obj[v] then
		return obj[v]
	else
		return types[rawget(self, "type")][v]
	end
end

function obj:overload(m, ...)
	if types[self.type][m] then
		return types[self.type][m](self, ...)
	end
end

function obj:tick(...)
	if self.data.vel then
		local vx, vy = unpack(self.data.vel)
		self.data.pos[1] = self.data.pos[1] + vx
		self.data.pos[2] = self.data.pos[2] + vy
	end
	if self.data.avel then
		self.data.angle = (self.data.angle or 0) + self.data.avel / pi
	end
	self:overload("tick", ...)
	local chunk = world.chunk(unpack(self.data.pos))
	if chunk ~= self.chunk then
		self.chunk.objects[self.id] = nil
		chunk.objects[self.id] = self
		self.chunk = chunk
	end
end

function obj:draw(...)
	love.graphics.push()
	love.graphics.translate(unpack(self.data.pos))
	if self.data.angle then
		love.graphics.rotate(self.data.angle)
	end
	self:overload("draw", ...)
	love.graphics.pop()
end

function obj:init(...)
	self.chunk = world.chunk(unpack(self.data.pos))
	self.chunk.objects[self.id] = self
	world.objects[self.id] = self
	return self:overload("init", ...)
end

function obj:remove()
	self.chunk.objects[self.id] = nil
	world.objects[self.id] = nil
	return self:overload "remove"
end

return obj
