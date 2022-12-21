local world = {}

world.chunk_size = 1024
world.chunks = {}
setmetatable(world.chunks, {
	__index = function(_, bee)
		if rawget(world.chunks, bee) == nil then
			world.chunks[bee] = {}
		end
		return world.chunks[bee]
	end,
})
world.objects = {}
world.last_id = 0

function world.chunk_pos(x, y)
	return math.floor(x / world.chunk_size), math.floor(y / world.chunk_size)
end

function world.world_pos(x, y)
	return x * world.chunk_size, y * world.chunk_size
end

function world.chunk(x, y)
	local cx, cy = world.chunk_pos(x, y)
	if not world.chunks[cx][cy] then
		-- load chunk from disk if the
		world.chunks[cx][cy] = setmetatable(
			{pos = {cx, cy}, objects = {}}, chunk_mt)
	end
	return world.chunks[cx][cy]
end

function world.object(id)
	return world.objects[id]
end

function world.all()
	return coroutine.wrap(function()
		for _, o in pairs(world.objects) do
			coroutine.yield(o)
		end
	end)
end

function world.in_box(x1, y1, x2, y2)
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

return world
