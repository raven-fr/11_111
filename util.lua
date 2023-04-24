
local M = {}

function M.copy(t)
	local c = {}
	for k,v in pairs(t) do
		c[k] = v
	end
	return c
end

function M.deepcopy(t)
	local copied = {}
	local function dc(t)
		if not copied[t] then
			local c = {}
			copied[t] = c
			for k,v in pairs(t) do
				if type(v) == 'table' then
					v = dc(v)
				end
				c[k] = v
			end
		end
		return copied[t]
	end
	return dc(t)
end

function M.rot(a, x, y)
	return x*math.cos(a) - y*math.sin(a), x*math.sin(a) + y*math.cos(a)
end

function M.magnitude(v)
	local s = 0
	for _, a in ipairs(v) do
		s = s + a*a
	end
	return math.sqrt(s)
end

return M
