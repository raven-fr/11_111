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

return world
