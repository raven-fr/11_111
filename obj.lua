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

function obj.get(id)
	return world.objects[id]
end

function obj.is_obj(v)
	return getmetatable(v) == obj
end

function obj.in_box(x1, y1, x2, y2)
	return coroutine.wrap(function()
		for x = x1, x2 + world.chunk_size, world.chunk_size do
			for y = y1, y2 + world.chunk_size, world.chunk_size do
				for _, o in pairs(world.chunk(x, y).objects) do
					local x, y = unpack(o.data.pos)
					if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
						coroutine.yield(o)
					end
				end
			end
		end
	end)
end

function obj.at(x, y)
	return coroutine.wrap(function()
		for o in obj.in_box(
				x - obj.max_size, y - obj.max_size,
				x + obj.max_size, y + obj.max_size) do
			if o:in_hitbox(x, y) then
				coroutine.yield(o)
			end
		end
	end)
end

function obj.all()
	return coroutine.wrap(function()
		for _, o in pairs(world.objects) do
			coroutine.yield(o)
		end
	end)
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

function obj:init(...)
	self.chunk = world.chunk(unpack(self.data.pos))
	self.chunk.objects[self.id] = self
	world.objects[self.id] = self
	self.data.vel = self.data.vel or {0, 0}
	self.data.avel = self.data.avel or 0
	return self:overload("init", ...)
end

function obj:tick(...)
	local vx, vy = unpack(self.data.vel)
	self.data.pos[1] = self.data.pos[1] + vx
	self.data.pos[2] = self.data.pos[2] + vy

	self.data.angle = (self.data.angle or 0) + self.data.avel / pi

	if self.hitbox then
		local x, y = unpack(self.data.pos)
		for o in obj.in_box(
				x - obj.max_size, y - obj.max_size,
				x + obj.max_size, y + obj.max_size) do
			if o.hitbox and o ~= self then
				local dist = o.hitbox + self.hitbox
				local ox, oy = unpack(o.data.pos)
				local dx, dy = ox - x, oy - y
				if dx*dx + dy*dy < dist*dist then
					local angle = math.atan2(dy, dx)
					self:collision(o, angle)
					o:collision(self, pi - angle)
					-- reposition self outside of collided object
					self.data.pos[1] =
						self.data.pos[1] - math.cos(angle) * dist + dx
					self.data.pos[2] =
						self.data.pos[2] - math.sin(angle) * dist + dy
					self:collision_exit(o, angle)
					o:collision_exit(self, pi - angle)
				end
			end
		end
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

function obj:collision(collided, angle)
	self.force = {collided.data.vel[1] * math.cos(angle),
		collided.data.vel[2] * math.sin(angle)}
	self.torque = -collided.data.avel
	return self:overload("collision", collided, angle, self.force)
end

function obj:collision_exit(collided, angle)
	self.data.vel[1] = self.data.vel[1] + self.force[1]
	self.data.vel[2] = self.data.vel[2] + self.force[2]
	collided.data.vel[1] = collided.data.vel[1] - self.force[1]
	collided.data.vel[2] = collided.data.vel[2] - self.force[2]
	self.data.avel = self.data.avel + self.torque
	collided.data.avel = collided.data.avel + self.torque
	return self:overload("collision_exit", collided, angle, self.force)
end

function obj:in_hitbox(px, py)
	local x, y = unpack(self.data.pos)
	local dx, dy = x - px, y - py
	return dx*dx + dy*dy < self.hitbox*self.hitbox
end

function obj:remove()
	self.chunk.objects[self.id] = nil
	world.objects[self.id] = nil
	return self:overload "remove"
end

return obj
