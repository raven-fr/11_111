
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

return M
