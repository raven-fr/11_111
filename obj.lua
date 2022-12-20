local world = require "world"

local obj = {}

local types = {}
function obj.load_types()
	for _, f in ipairs(love.filesystem.getDirectoryItems "objects") do
		local ts = assert(love.filesystem.load("objects/"..f))()
		for t, v in pairs(ts) do
			types[t] = v
		end
	end
end
 
function obj.new(type, pos, ...)
	world.last_id = world.last_id + 1
	local o = setmetatable(
		{id = world.last_id, data = {pos = pos}, type = type}, obj)
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
	local chunk = world.chunk(unpack(self.data.pos))
	if chunk ~= self.chunk then
		self.chunk.objects[self.id] = nil
		chunk.objects[self.id] = self
		self.chunk = chunk
	end
	return self:overload("tick", ...)
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
	world.objects[self.id] = self
	return self:overload("init", ...)
end

function obj:unload()
	self.chunk.objects[self.id] = nil
	world.objects[self.id] = nil
	return self:overload "unload"
end

return obj
