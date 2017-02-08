local std = stead
local input = std.ref '@input'
local type = std.type
local instead = std.ref '@instead'

function input:event(...)
	local a 
	for k, v in std.ipairs {...} do
		a = (a and ', ' or ' ') .. std.dump(v)
	end
	return '@user_event'.. a or ''
end

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@user_event' then
		return
	end
	return std.call(instead, 'event', cmd[2])
end)