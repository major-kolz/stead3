stead = {
	space_delim = ' ',
	scene_delim = '^^',
	delim = '|',
	call_top = 0,
	call_ctx = { txt = nil, self = nil },
	objects = {};
	next_dynamic = -1;
	max_dynamic = 32767;
	tables = {};
	functions = {};
	includes = {};
	tostr = tostring;
	tonum = tonumber;
	type = type;
	err = error;
	setmt = setmetatable;
	getmt = getmetatable;
	table = table;
	pairs = pairs;
	ipairs = ipairs;
	rawset = rawset;
	rawget = rawget;
	rawequal = rawequal;
	io = io;
	os = os;
	string = string;
	next = next;
	loadfile = loadfile;
	dofile = dofile;
	getinfo = debug.getinfo;
	__mod_hooks = {};
	files = {};
	busy = function() end;
}

local std = stead

function stead:abort()
	self.abort_cmd = true
end

local table = std.table
local pairs = std.pairs
local ipairs = std.ipairs
local string = std.string
local rawset = std.rawset
local rawget = std.rawget
local type = std.type
local io = std.io;

if _VERSION == "Lua 5.1" then
	std.eval = loadstring
	std.unpack = unpack
else
	std.eval = load
	std.unpack = table.unpack
	table.maxn = table_get_maxn
	string.gfind = string.gmatch
	math.mod = math.fmod
	math.log10 = function(a)
		return std.math.log(a, 10)
	end
end

local function __mod_callback_reg(f, hook, ...)
	if type(f) ~= 'function' then
		std.err ("Wrong parameter to mod_"..hook..".", 2);
	end
	if not std.__mod_hooks[hook] then
		std.__mod_hooks[hook] = {}
	end
	table.insert(std.__mod_hooks[hook], f);
--	f();
end

function std.mod_call(hook, ...)
	if not std.__mod_hooks[hook] then
		return
	end
	for k, v in ipairs(std.__mod_hooks[hook]) do
		local a, b = v(...)
		if a ~= nil or b ~= nil then
			return a, b
		end
	end
end

function std.mod_call_rev(hook, ...)
	if not std.__mod_hooks[hook] then
		return
	end
	for i = #std.__mod_hooks[hook], 1, -1 do
		local v = std.__mod_hooks[hook][i]
		local a, b = v(...)
		if a ~= nil or b ~= nil then
			return a, b
		end
	end
end

function std.mod_init(f, ...)
	__mod_callback_reg(f, 'init', ...)
	if std.initialized then -- require from game
		f(...)
	end
end

function std.mod_done(f, ...)
	__mod_callback_reg(f, 'done', ...)
end

function std.mod_start(f, ...)
	__mod_callback_reg(f, 'start', ...)
end

function std.mod_cmd(f, ...)
	__mod_callback_reg(f, 'cmd', ...)
end

function std.mod_step(f, ...)
	__mod_callback_reg(f, 'step', ...)
end

function std.mod_save(f, ...)
	__mod_callback_reg(f, 'save', ...)
end

function std.hook(o, f)
	local ff
	if type(o) ~= 'function' then
		ff = function()
			return o
		end
	else
		ff = o
	end
	return function(...)
		return f(ff, ...)
	end
end

std.fmt = function(str, state)
	str = stead.obj.xref('<empty>', str)
	return str
end

local lua_keywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["goto"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

std.setmt(stead, {
	__call = function(s, k)
		return std.ref(k)
	end;
})

function std.is_obj(v, t)
	if type(v) ~= 'table' then
		return false
	end
	return v['__'..(t or 'obj')..'_type']
end

function std.class(s, inh)
--	s.__parent = function(s)
--		return inh
	--	end;
	s.type = function(s, t)
		return std.is_obj(s, t)
	end;
	s.__call = function(s, ...)
		local a = { ... }
		if #a == 1 and type(a[1]) == 'string' then
			return std.ref(a[1])
		end
		return s:new(...)
	end;
	s.__tostring = function(self)
		if not std.is_obj(self) then
			local os = s.__tostring
			s.__tostring = nil
			local t = std.tostr(self)
			s.__tostring = os
			return t
		end
		return std.dispof(self)
	end;
	s.__div = function(s, b)
		if type(b) == 'string' or type(b) == 'number' then
			if std.is_tag(b) then
				return std.rawequal(s.tag, b)
			else
				return std.rawequal(s.nam, b)
			end
		end
		return std.rawequal(s, b)
	end;
	s.__dirty = function(s, v)
		local o = rawget(s, '__dirty_flag')
		if v ~= nil then
			if std.game then
				rawset(s, '__dirty_flag', v)
			end
			return s
		end
		return o
	end;
	s.__index = function(t, k)
		local ro = rawget(t, '__ro')
		local v
		if ro then
			v = rawget(ro, k)
		end
		if v == nil then
			return s[k]
		end
		if std.game and type(v) == 'table' then
			-- make rw if simple table
			if type(v.__dirty) ~= 'function' then
				t.__var[k] = true
				rawset(t, k, v)
				ro[k] = nil
			end
		end
		return v
	end;
	s.__newindex = function(t, k, v)
		local ro
		if std.is_obj(t) and type(k) == 'string' then
			ro = t.__ro
		end
		if not std.game and ro then
			rawset(ro, k, v)
			return
		end

		t:__dirty(true)
		if ro then
			if type(v) ~= 'function' or std.functions[v] then
				t.__var[k] = true
			else
				std.err("Wrong variable operation: "..std.tostr(k), 2)
			end
			ro[k] = nil
		end
		if std.is_obj(v, 'list') and std.is_obj(t) then
			v:attach(t)
		end
		rawset(t, k, v)
	end
	std.setmt(s, inh or { __call = s.__call })
	return s
end

function std.is_tag(n)
	return type(n) == 'string' and n:byte(1) == 0x23
end

std.list = std.class {
	__list_type = true;
	new = function(s, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.list:"..std.tostr(v), 2)
		end
		if std.is_obj(v, 'list') then -- already list
			return v
		end
		v.__list = {} -- where is attached
		std.setmt(v, s)
		return v
	end;
	ini = function(s, o)
		for i = 1, #s do
			local k = s[i]
			s[i] = std.ref(k)
			if not std.is_obj(s[i]) then
				std.err("Wrong item in list: "..std.tostr(k), 2)
			end
			s:__attach(s[i])
		end
		if o then
			s:attach(o)
		end
	end;
	sort = function(s)
		std.table.sort(s, function(a, b)
			local p1 = std.tonum(a.pri) or 0
			local p2 = std.tonum(b.pri) or 0
			return p1 < p2
		end)
	end;
	display = function(s)
		local r
		for i = 1, #s do
			if r then
				r = r .. std.space_delim
			end
			local o = s[i]
			if o:visible() then
				local d = o:xref(std.call(s[i], 'dsc'))
				if type(d) == 'string' then
					r = (r or '').. d
				end
				if not o:closed() then
					d = o.obj:display()
					if type(d) == 'string' then
						r = (r or '') .. d
					end
				end
			end
		end
		return r
	end;
	disable = function(s)
		for i = 1, #s do
			s[i]:disable()
		end
	end;
	enable = function(s)
		for i = 1, #s do
			s[i]:enable()
		end
	end;
	close = function(s)
		for i = 1, #s do
			s[i]:close()
		end
	end;
	open = function(s)
		for i = 1, #s do
			s[i]:open()
		end
	end;
	attach = function(s, o) -- attach to object
		s:detach(o)
		table.insert(s.__list, o)
	end;
	detach = function(s, o) -- detach from object
		for i = 1, #s.__list do
			if s.__list[i] == o then
				table.remove(s.__list, i)
				break
			end
		end
	end;
	__attach = function(s, o) -- attach object to list
		s:__detach(o)
		table.insert(o.__list, s)
	end;
	__detach = function(s, o) -- detach object from list
		for i = 1, #o.__list do
			if o.__list[i] == s then
				table.remove(o.__list, i)
				break
			end
		end
	end;
	add = function(s, n, pos)
		if s:lookup(n) then
			return -- already here
		end
		if not pos then
			local o = std.ref(n)
			s:__dirty(true)
			s:__attach(o)
			table.insert(s, o)
			s:sort()
			return o
		end
		if type(pos) ~= 'number' then
			std.err("Wrong parameter to list.add:"..std.tostr(pos), 2)
		end
		if pos > #s then
			pos = #s
		elseif pos < 0 then
			pos = #s + pos + 1
		end
		if pos <= 0 then
			pos = 1
		end
		local o = std.ref(n)
		s:__dirty(true)
		s:__attach(o)
		if pos then
			table.insert(s, pos, o)
		else
			table.insert(s, o)
		end
		s:sort()
		return o
	end;
	for_each = function(s, fn, ...)
		if type(fn) ~= 'function' then
			std.err("Wrong parameter to list:for_each: "..std.tostr(fn), 2)
		end
		for i = 1, #s do
			local r, v = fn(s[i], ...)
			if r ~= nil or v ~= nil then
				return r, v
			end
		end
	end;
	lookup = function(s, n)
		local o, tag
		if std.is_tag(n) then
			tag = n
		else
			o = std.ref(n)
		end
		for i = 1, #s do
			if s[i] == o or (tag and s[i].tag == tag) then
				return s[i], i
			end
		end
	end;
--	seen = function(s, n)
--		for i = 1, #s do
--			local o = std.ref(s[i])
--			if std.dispof(o) == n then
--				return o, i
--			end
--		end
--	end;
	empty = function(s)
		return (#s == 0)
	end;
	zap = function(s) -- delete all objects
		local l = {}
		for i = 1, #s do
			table.insert(l, s[i])
		end
		for i = 1, #l do
			s:del(l[i])
		end
	end;
	del = function(s, n)
		local o, i = s:lookup(n)
		if i then
			s:__dirty(true)
			s:__detach(o)
			table.remove(s, i)
			s:sort()
			return o
		end
	end;
	save = function(s, fp, n)
		if not s:__dirty() then
			return
		end
		fp:write(string.format("%s = std.list { ", n))
		for i = 1, #s do
			local vv = std.deref(s[i])
			if not vv then
				std.err ("Can not do deref on: "..std.tostr(s[i]), 2)
			end
			if i ~= 1 then
				fp:write(string.format(", "))
			end
			if type(vv) == 'number' then
				fp:write(string.format("%d", vv))
			else
				fp:write(string.format("%q", vv))
			end
		end
		fp:write(" }:__dirty(true)\n")

	end;
}
std.save_var = function(vv, fp, n)
	if type(vv) == 'boolean' or type(vv) == 'number' then
		fp:write(string.format("%s = ", n))
		fp:write(std.tostr(vv)..'\n')
	elseif type(vv) == 'string' then
		fp:write(string.format("%s = ", n))
		fp:write(string.format("%q\n", vv))
	elseif type(vv) == 'function' then
		if std.functions[vv] and std.functions[vv] ~= n then
			local k = std.functions[vv]
			fp:write(string.format("%s = %s\n", n, k))
		else
			std.err("Can not save variable (function): "..n, 2)
		end
	elseif type(vv) == 'table' then
		if std.tables[vv] and std.tables[vv] ~= n then
			local k = std.tables[vv]
			fp:write(string.format("%s = %s\n", n, k))
		elseif std.is_obj(vv) then
			local d = std.deref(vv)
			if not d then
				std.err("Can not deref object:"..std.tostr(vv), 2)
			end
			fp:write(string.format("%s = ", n))
			if type(d) == 'string' then
				fp:write(string.format("std %q\n", d))
			else
				fp:write(string.format("std(%d)\n", d))
			end
		elseif type(vv.save) == 'function' then
			vv:save(fp, n)
		else
			fp:write(string.format("%s = %s\n", n,  std.dump(vv)))
--			std.save_table(vv, fp, n)
		end
	end
end

std.save_members = function(vv, fp, n)
	local l
	for k, v in pairs(vv) do
		l = nil
		if type(k) == 'number' then
			l = string.format("%s%s", n, std.varname(k))
			std.save_var(v, fp, l)
		elseif type(k) == 'string' then
			l = string.format("%s%s", n, std.varname(k))
			std.save_var(v, fp, l)
		end
	end
end

std.save_table = function(vv, fp, n)
	fp:write(string.format("%s = {}\n", n))
	std.save_members(vv, fp, n)
end

function std:reset() -- reset state
	self:done()
	self:init()
	std.dofile('main3.lua')
end

function std:load(fname) -- load save
	self:reset()
	std.ref 'game':ini(true)

	local f, err = std.loadfile(fname) -- load all diffs
	if not f then
		std.err(err, 2)
	end
	f();
	std.ref 'game':ini()
	return self.game:lastdisp()
end

function std.gamefile(fn, reset) -- load game file
	if type(fn) ~= 'string' then
		std.err("Wrong paramter to stead:file: "..std.tostr(f), 2)
	end
	if reset then
		std:reset()
		if fn ~= 'main3.lua' then
			std.startfile = fn -- another start file
		end
		std.ref 'game':ini()
		std.game.player:need_scene(true)
		return
	end
	std.__in_gamefile = true
	std.dofile(fn)
	std.__in_gamefile = false
	std.ref 'game':ini()
	table.insert(std.files, fn) -- remember it
end

function std:save(fp)
	local close
	if type(fp) == 'string' then
		fp = io.open(fp, "wb");
		if not fp then
			return nil, false -- can create file
		end
		close = true
	end
	local n
	if std.type(std.savename) == 'function' then
		n = std.savename()
	end
	if std.type(n) == 'string' then
		fp:write("-- $Name: "..n:gsub("\n","\\n").."$\n");
	end
	fp:write("local std = stead\n");
	-- reset
	if std.startfile then
		fp:write(string.format("std:reset(%q)\n", std.startfile))
	end
	-- files
	for i = 1, #std.files do
		fp:write(string.format("std.gamefile(%q)\n", std.files[i]))
	end

	local oo = std.objects

	std.busy(true)
	std.for_each_obj(function(v)
		if v.__dynamic then
			std.busy(true)
			v:save(fp, string.format("std(%s)", std.deref_str(v)))
		end
	end)

	std.mod_call('save', fp)

	std.for_each_obj(function(v)
		if not v.__dynamic then
			std.busy(true)
			v:save(fp, string.format("std(%s)", std.deref_str(v)))
		end
	end)
	if close then
		fp:flush();
		fp:close();
	end
	std.busy(false)
end

function std.for_each_obj(fn, ...)
	local oo = std.objects
	for k, v in pairs(oo) do
		if std.is_obj(v) then
			local a, b = fn(v, ...)
			if a ~= nil and b ~= nil then
				return a, b
			end
		end
	end
end

function std:init()
	std.obj { nam = '@',
		  {
			  iface = {
			  };
		  };
		  act = function(s, x)
			  local cmd = std.cmd_parse(x)
			  if s.iface[cmd[1]] then
				  return std.call(s.iface, std.unpack(cmd))
			  end
			  std.err ('Undefined @ act: '..std.tostr(x), 2)
	end; }
	std.rawset(_G, 'iface', std.ref '@iface') -- force iface override
	std.world { nam = 'game', player = 'player', codepage = 'UTF-8' }
	std.room { nam = 'main' }
	std.player { nam = 'player', room = 'main' }
	std.xact = std.ref '@'.iface
	std.mod_call('init') -- init modules
	std.initialized = true
end

function std:done()
	std.mod_call_rev('done')
	local objects = {}
	std.for_each_obj(function(v)
		local k = std.deref(v)
		if type(k) == 'string' and k:byte(1) == 0x40 then
			objects[k] = v
		else
			print("Deleting "..k)
		end
	end)
	std.objects = objects
	std.next_dynamic = -1
	if std.ref 'game' then
		std.delete('game')
	end
	if std.ref 'main' then
		std.delete('main')
	end
	if std.ref 'player' then
		std.delete('player')
	end
	if std.ref '@' then
		std.delete('@')
	end
	std.files = {}
--	std.includes = {}
	std.initialized = false
	std.game = nil
	std.rawset(_G, 'init', nil)
	std.rawset(_G, 'start', nil)
end

function std.dirty(o)
	if type(o) ~= 'table' or type(o.__dirty) ~= 'function' then
		return false
	end
	return o:__dirty()
end

function std.deref_str(o)
	local k = std.deref(o)
	if type(k) == 'number' then
		return std.tostr(k)
	elseif type(k) == 'string' then
		return std.string.format("%q", k)
	end
	return
end

function std.varname(k)
	if type(k) == 'number' then
		return string.format("[%d]", k)
	elseif type(k) == 'string' then
		if not lua_keywords[k] then
			return string.format(".%s", k)
		else
			return string.format("[%q]", k)
		end
	end
end

local function next_dynamic(n)
	if n then
		std.next_dynamic = n
	end
	std.next_dynamic = std.next_dynamic - 1
	if std.next_dynamic < -std.max_dynamic then
		std.next_dynamic = - 1
	end
	return std.next_dynamic
end

local function dyn_name()
	local oo = std.objects
	if not oo[std.next_dynamic] then
		local n = std.next_dynamic
		next_dynamic()
		return n
	end

	local on = std.next_dynamic
	local n = next_dynamic()

	while oo[n] and n ~= on do
		n = n - 1
		if n < -std.max_dynamic then
			n = -1
		end
	end

	if oo[n] then
		std.err("No free ids for dynamic objects", 2)
	end

	next_dynamic(n)

	return n
end

std.obj = std.class {
	__obj_type = true;
	new = function(self, v)
		if std.game and not std.__in_new and not std.__in_gamefile then
			std.err ("Use std.new() to create dynamic objects:"..std.tostr(v), 2)
		end
		local oo = std.objects
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.obj:"..std.tostr(v), 2)
		end
		if std.is_tag(v.nam) then
			rawset(v, 'tag', v.nam)
			rawset(v, 'nam', nil)
		end

		if v.nam == nil then
			if std.__in_new then
				rawset(v, 'nam', dyn_name())
			else
				rawset(v, 'nam', #oo + 1)
			end
		elseif type(v.nam) ~= 'string' and type(v.nam) ~= 'number' then
			std.err ("Wrong .nam in object.", 2)
		end

		if oo[v.nam] then
			if v.nam ~= 'main' and v.nam ~= 'player' and v.nam ~= 'game' then
				std.err ("Duplicated object: "..v.nam, 2)
			end
		end
		local ro = {}
		local vars = {}
		local raw = {}
		for i = 1, #v do
			if type(v[i]) ~= 'table' then
				std.err("Wrong declaration: "..std.tostr(v[i]), 2)
			end
			for key, val in pairs(v[i]) do
				if type(key) ~= 'string' then
					std.err("Wrong var name: "..std.tostr(key), 2)
				end
				raw[key] = true
				rawset(v, key, val)
			end
		end
		for i = 1, #v do
			table.remove(v, 1)
		end
		if not v.obj then
			rawset(v, 'obj', {})
		end
		if type(v.obj) ~= 'table' then
			std.err ("Wrong .obj attr in object:" .. v.nam, 2)
		end
		v.obj = std.list(v.obj)
--		v.obj:attach(v)
		for key, val in pairs(v) do
			if not raw[key] then
				ro[key] = val
				rawset(v, key, nil)
			end
		end
		rawset(v, '__ro', ro)
		rawset(v, '__var', vars)
		rawset(v, '__list', {}) -- in what list(s)
		oo[ro.nam] = v
		std.setmt(v, self)
		return v
	end;
	actions = function(s, t)
		t = t or 'act'
		if type(t) ~= 'string' then
			std.err("Wrong argument to obj:actions(): "..std.tostr(t), 2)
		end
		return s['__nr_'..t] or 0
	end;
	renam = function(s, new)
		local oo = std.objects
		if new == s.nam then
			return
		end
		if oo[new] then
			std.err ("Duplicated obj name: "..std.tostr(new), 2)
		end
		oo[s.nam] = nil
		oo[new] = s
		rawset(s, 'nam', new)
		return s
	end;
	ini = function(s)
		for k, v in pairs(s) do
			if std.is_obj(v, 'list') then
				v:ini(s)
			end
		end

		for k, v in pairs(s.__ro) do
			if std.is_obj(v, 'list') then
				v:ini(s)
			end
		end
	end;
	inroom = function(s, r)
		local rooms = r or {}
		local ww = {}
		local o
		if type(rooms) ~= 'table' then
			std.err("Wrong argument to room: "..std.tostr(r), 2)
		end
		s:where(ww)
		while #ww > 0 do
			local nww = {}
			for k, v in ipairs(ww) do
				if std.is_obj(v, 'room') then
					if not o then
						o = v
					end
					table.insert(rooms, v)
				else
					v:where(nww)
				end
			end
			ww = nww
		end
		return o
	end;
	where = function(s, w)
		local list = s.__list
		local r = w or { }
		local o
		if type(r) ~= 'table' then
			std.err("Wrong argument to obj:where: "..std.tostr(w), 2)
		end
		for i = 1, #list do
			local l = list[i]
			local ll = l.__list
			o = ll[1]
			if not w then
				break
			end
			for k = 1, #ll do
				table.insert(r, ll[k])
			end
		end
		return o
	end;
	remove = function(s, w)
		local o = std.ref(s)
		if not s then
			std.err ("Wrong object in remove: "..std.tostr(s), 2)
		end
		if w then
			w = std.ref(w)
			if not w then
				std.err ("Wrong where in remove", 2)
			end
			w.obj:del(o)
			return o
		end
		local where = {}
		s:where(where)
		for i = 1, #where do
			where[i].obj:del(o)
		end
		return o, where
	end;
	close = function(s)
		s.__closed = true
		return s
	end;
	open = function(s)
		s.__closed = nil
		return s
	end;
	closed = function(s)
		return s.__closed or false
	end;
	disable = function(s)
		s.__disabled = true
		return s
	end;
	enable = function(s)
		s.__disabled = nil
		return s
	end;
	disabled = function(s)
		return s.__disabled or false
	end;
	empty = function(s)
		for i = 1, #s.obj do
			local o = s.obj[i]
			if not o:disabled() then
				return false
			end
		end
		return true
	end;
	save = function(s, fp, n)
		if s.__dynamic then -- create
			local n = std.functions[s.__dynamic.fn]
			if not n then
				std.err("Error while saving dynamic object: "..s, 2)
			end
			local arg = s.__dynamic.arg
			local l = ''
			for i = 1, #arg do
				l = ', '..string.format("%s%s", l, std.dump(arg[i]))
			end
			if type(s.nam) == 'number' then
				l = string.format("std.new(%s%s):renam(%d)\n", n, l, s.nam)
			else
				l = string.format("std.new(%s%s)\n", n, l, s.nam)
			end
			fp:write(l)
		end
		for k, v in pairs(s.__ro) do
			local o = s.__ro[k]
			if std.dirty(o) then
				local l = string.format("%s%s", n, std.varname(k))
				std.save_var(s[k], fp, l)
			end
		end
		for k, v in pairs(s.__var) do
			local l = string.format("%s%s", n, std.varname(k))
			std.save_var(s[k], fp, l)
		end
	end;
	xref = function(self, str)
		local function xrefrep(str)
			local oo = self
			local a
			local s = string.gsub(str,'[\001\002]','');
			s = s:gsub('\\?[\\'..std.delim..']', { [ std.delim ] = '\001', [ '\\'..std.delim ] = std.delim });
			local i = s:find('\001', 1, true)
			if i then -- xact
				oo = s:sub(1, i - 1)
				s = s:sub(i + 1)
				if oo:find("@", 1, true) == 1 then -- call '@' obj (aka xact)
					local o = '@'
					a = oo:sub(2)
					self = std.ref(o)
				else
					if std.is_tag(oo) then -- #tag?
						self = std.here():lookup(oo)
					else
						self = std.ref(oo)
					end
				end
			end
			if not std.is_obj(self) then
				std.err("Wrong object in xref: "..std.tostr(oo), 2)
			end
			return iface:xref(s, self, a);
		end
		if type(str) ~= 'string' then
			return
		end
		local s = string.gsub(str, '\\?[\\{}]',
			{ ['{'] = '\001', ['}'] = '\002', [ '\\{' ] = '{', [ '\\}' ] = '}' }):gsub('\001([^\002]+)\002', xrefrep):gsub('[\001\002]', { ['\001'] = '{', ['\002'] = '}' });
		if s == str then
			return iface:xref(s, self)
		end
		return s;
	end;
	visible = function(s)
		return not s:disabled()
	end;
	seen = function(s, w)
		local o
		if not s:visible() then
			return
		end
		if (not std.is_tag(w) and std.ref(w) == s) or (std.is_tag(w) and w == s.tag) then
			return s
		end

		if s:closed() then
			return
		end

		for i = 1, #s.obj do
			local v = s.obj[i]
			o = v:seen(w)
			if o then
				return o, v
			end
		end
	end;
	lookup = function(s, w)
		local o = s.obj:lookup(w)
		if o then
			return o, s
		end
		for i = 1, #s.obj do
			local v = s.obj[i]
			o = v:lookup(w)
			if o then
				return o, v
			end
		end
	end;
	for_each = function(s, fn, ...)
		local r, v = s.obj:for_each(fn, ...)
		if r ~= nil or v == false then
			return r, v
		end
		for i = 1, #s.obj do
			r, v = s.obj[i]:for_each(fn, ...)
			if r ~= nil then
				return r, v
			end
		end
	end;
	dump = function(s)
		local rc
		for i = 1, #s.obj do
			local v = s.obj[i]
			if std.is_obj(v) and not v:disabled() then
				local vv
				if rc then
					rc = rc .. std.delim
				else
					rc = ''
				end
				vv = iface:xref(std.dispof(v), v)
				vv = vv:gsub('\\?'..std.delim,
					     { [std.delim] = '\\'..std.delim });
				rc = rc .. vv
				if not v:closed() then
					vv = v:dump()
					if vv then
						rc = rc .. std.delim .. vv
					end
				end
			end
		end
		return rc
	end;
};

std.room = std.class({
	__room_type = true;
	from  = function(s)
		return s.__from or s
	end;
	new = function(self, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.room:"..std.tostr(v), 2)
		end
		if not v.way then
			rawset(v, 'way',  {})
		end
		if type(v.way) ~= 'table' then
			std.err ("Wrong .way attr in object:" .. v.nam, 2)
		end
		v.way = std.list(v.way)
--		v.way:attach(v)
		v = std.obj(v)
		std.setmt(v, self)
		return v
	end;
	visited = function(s)
		return s.__visits
	end;
	visits = function(s)
		return s.__visits or 0
	end;
	seen = function(self, w)
		local r, v = std.obj.seen(self, w)
		if std.is_obj(r) then
			return r, v
		end
		r, v = self.way:lookup(w)
		if not std.is_obj(r) or r:disabled() or r:closed() then
			return
		end
		return r, self.way
	end;
	lookup = function(self, w)
		local r, v = std.obj.lookup(self, w)
		if std.is_obj(r) then
			return r, v
		end
		r, v = self.way:lookup(w)
		if std.is_obj(r) then
			return r, self.way
		end
		return r, v
	end;
	scene = function(s)
		local title, dsc, objs
		title = iface:title(std.titleof(s))
		dsc = std.call(s, 'dsc')
		return std.par(std.scene_delim, title or false, dsc)
	end;
	display = function(s)
		return s.obj:display()
	end;
	dump_way = function(s)
		local rc
		for i = 1, #s.way do
			local v = s.way[i]
			if std.is_obj(v, 'room')
			and not v:disabled() and not v:closed() then
				local vv
				if rc then
					rc = rc .. std.delim
				else
					rc = ''
				end
				vv = iface:xref(std.dispof(v), v)
				vv = vv:gsub('\\?'..std.delim,
					     { [std.delim] = '\\'..std.delim });
				rc = rc .. vv
			end
		end
		return rc
	end
}, std.obj);

std.world = std.class({
	__game_type = true;
	new = function(self, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.pl:"..std.tostr(v), 2)
		end
		if not v.player then
			v.player = 'player'
		end
		v = std.obj(v)
		if v.lifes == nil then
			rawset(v, 'lifes', {})
		end
		v.lifes = std.list(v.lifes)
		std.setmt(v, self)
		return v
	end;
	time = function(s, t)
		local ov = s.__time or 0
		if t ~= nil then
			if type(t) ~= 'number' then
				std.err ("Wrong parameter to game:time: "..stead.tostr(t), 2)
			end
			s.__time = t
		end
		return ov
	end;
	ini = function(s, nostart)
--		std.mod_call('init') -- init modules

		s.player = std.ref(s.player) -- init game
		if not s.player then
			std.err ("Wrong player", 2)
		end
		std.obj.ini(s)

		std.for_each_obj(function(v) -- call ini of all objects
			rawset(v, '__list', {}) -- reset all links
		end)

		std.for_each_obj(function(v) -- call ini of all objects
			if v ~= s and type(v.ini) == 'function' then
				v:ini()
			end
		end)

		if not std.game then
			if type(std.rawget(_G, 'init')) == 'function' then
				init()
			end
			std.game = s
		end
		if not nostart then
			std.mod_call('start')
			if type(std.rawget(_G, 'start')) == 'function' then
				start() -- start before load
			--	std.rawset(_G, 'start', nil)
			end
		end
	end;
	lifeon = function(s, w, ...)
		return s.lifes:add(w, ...)
	end;
	lifeoff = function(s, w)
		return s.lifes:del(w)
	end;
	live = function(s, w)
		return s.lifes:lookup(w)
	end;
	set_pl = function(s, w)
		if not std.is_obj(w, 'player') then
			std.err("Wrong parameter to game:set_pl(): "..std.tostr(w), 2)
		end
		s.player = w
		w:need_scene(true)
	end;
	life = function(s)
		local av, vv
		s:events(false, false)
		local ll = {}

		for i = 1, #s.lifes do
			table.insert(ll, s.lifes[i])
		end

		for i = 1, #ll do
			local v, pre
			local o = ll[i]
			if not o:disabled() then
				v, pre = std.method(o, 'life');
				av, vv = s:events()
				if pre then -- hi-pri msg
					av = std.par(std.space_delim, av or false, v)
				else
					vv = std.par(std.space_delim, vv or false, v)
				end
				s:events(av or false, vv or false)
				if pre == false then -- break cycle
					break
				end
			end
		end
	end;
	step = function(s)
		s:life()
		s.__time = s:time() + 1
	end;
	lastdisp = function(s, str)
		local ov = s.__lastdisp
		if str ~= nil then
			s.__lastdisp = str
		end
		return ov
	end;
	disp = function(s, state)
		local r, l, av, pv
		local reaction = s:reaction() or nil
		r = std.here()
		if state then
			reaction = iface:em(reaction)
			av, pv = s:events()
			av = iface:em(av)
			pv = iface:em(pv)
			l = s.player:look() -- objects [and scene]
		end
		l = std.par(std.scene_delim, reaction or false,
			    av or false, l or false,
			    pv or false) or ''
		return l
	end;
	lastreact = function(s, t)
		local o = s.__lreaction
		if t == nil then
			return o
		end
		s.__lreaction = t or nil
		return o
	end;
	reaction = function(s, t)
		local o = s.__reaction
		if t == nil then
			return o
		end
		s.__reaction = t or nil
		return o
	end;
	events = function(s, av, pv)
		local oa = s.__aevents
		local op = s.__pevents
		if av ~= nil then
			s.__aevents = av or nil
		end
		if pv ~= nil then
			s.__pevents = pv or nil
		end
		return oa, op
	end;
	cmd = function(s, cmd)
		local r, v
		s.player:moved(false)
		s.player:need_scene(false)
		std.abort_cmd = false
		r, v = std.mod_call('cmd', cmd)
		if r ~= nil or v ~= nil then

		elseif cmd[1] == nil or cmd[1] == 'look' then
			if not s.started then
				s.started = true
				r, v = s.player:walk('main', true)
			else
				s.player:need_scene(true)
				v = true
			end
--			r, v = s.player:look()
		elseif cmd[1] == 'act' then
			if #cmd < 2 then
				return nil, false
			end
			local o = std.ref(cmd[2]) -- on what?
			if std.is_obj(o) and std.nameof(o) == '@' then
				local a = {}
				for i = 3, #cmd do
					table.insert(a, cmd[i])
				end
				r, v = std.call(o, 'act', std.unpack(a))
			else
				o = s.player:search(o)
				if not o then
					return nil, false -- wrong input
				end
				r, v = s.player:take(o)
				if not v then
					r, v = s.player:action(o)
				end
			end
			-- if s.player:search(o)
		elseif cmd[1] == 'use' then
			if #cmd < 2 then
				return nil, false
			end
			local o1 = std.ref(cmd[2])
			local o2 = std.ref(cmd[3])
			o1 = s.player:have(o1)
			if not o1 then
				return nil, false -- wrong input
			end
			if o1 == o2 or not o2 then -- inv?
				if not o1 then
					return nil, false -- wrong input
				end
				r, v = s.player:useit(o1)
			else
				r, v = s.player:useon(o1, o2)
			end
		elseif cmd[1] == 'go' then
			if #cmd < 2 then
				return nil, false
			end
			local o = std.ref(cmd[2])
			if not o then
				return nil, false -- wrong input
			end
			r, v = s.player:go(o)
		elseif cmd[1] == 'inv' then -- show inv
			r = s.player:dump() -- just info
			v = nil
		elseif cmd[1] == 'way' then -- show ways
			r = s.player:where():dump_way()
			v = nil
		elseif cmd[1] == 'save' then -- todo
			if #cmd < 2 then
				return nil, false
			end
			r = std:save(cmd[2])
			v = nil
		elseif cmd[1] == 'load' then -- todo
			if #cmd < 2 then
				return nil, false
			end
			r = std:load(cmd[2])
			v = false
		end

		if v == false or std.abort_cmd then
			return r, false -- wrong cmd?
		end

		s = std.game -- after reset game is recreated
		s:reaction(r or false)

		if v then -- game:step
			std.mod_call('step')
			s:step()
		end
		r = s:disp(v)
		if v then
			s:lastreact(s:reaction() or false)
			s:lastdisp(r)
		end
		return r, true
	end;
}, std.obj);

local function array_rw(t)
	local ro = rawget(t, '__ro')
	if not ro then
		return
	end
	for k, v in pairs(ro) do
		rawset(t, k, v)
	end
	for k, v in pairs(t) do
		if type(k) ~= 'string' or k:find("__", 1, true) ~= 1 then
			if type(v) == 'table' and std.rawget(v, '__array') then
				array_rw(v)
			end
		end
	end
end

std.player = std.class ({
	__player_type = true;
	new = function(self, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.pl:"..std.tostr(v), 2)
		end
		if not v.room then
			v.room = 'main'
		end
		v = std.obj(v)
		std.setmt(v, self)
		return v
	end;
	ini = function(s)
		s.room = std.ref(s.room)
		if not s.room then
			std.err ("Wrong player location: "..std.tostr(s), 2)
		end
		std.obj.ini(s)
	end;
	moved = function(s, v)
		local ov = s.__moved or false
		if v == nil then
			return ov
		end
		if type(v) ~= 'boolean' then
			std.err("Wrong parameter to player:moved: "..std.tostr(v), 2)
		end
		if v == false then v = nil end
		s.__moved = v
		return ov
	end;
	need_scene = function(s, v)
		local ov = s.__need_scene or false
		if v == nil then
			return ov
		end
		if type(v) ~= 'boolean' then
			std.err("Wrong parameter to player:need_scene: "..std.tostr(v), 2)
		end
		if v == false then v = nil end
		s.__need_scene = v
		return ov
	end;
	look = function(s)
		local scene
		local r = s:where()
		if s:need_scene() then
			scene = r:scene()
		end
		return std.par(std.scene_delim, scene or false, r:display())
	end;
	search = function(s, w)
		local r, v
		r, v = s:where():seen(w)
		if r ~= nil then
			return r, v
		end
		r, v = s:where().way:lookup(w)
		if r and not r:disabled() and not r:closed() then
			return r, s:where()
		end
		r, v = s:seen(w)
		if r ~= nil then
			return r, v
		end
		return
	end;
	have = function(s, w)
		local o, i = s:inventory():lookup(w)
		if not o then
			return o, i
		end
		if o:disabled() then
			return
		end
		return o, i
	end;
	useit = function(s, w, ...)
		return s:call('inv', w, ...)
	end;
	useon = function(s, w1, w2)
		local r, v, t
		w1 = std.ref(w1)
		w2 = std.ref(w2)

		if w2 and w1 ~= w2 then
			return s:call('use', w1, w2)
		end
		-- inv mode?
		return s:call('inv', w1, w2)
	end;
	call = function(s, m, w1, w2, ...)
		local w
		if type(m) ~= 'string' then
			std.err ("Wrong method in player.call: "..std.tostr(m), 2)
		end

		w = std.ref(w1)
		if not std.is_obj(w) then
			std.err ("Wrong parameter to player.call: "..std.tostr(w1), 2)
		end

		local r, v, t
		r, v = std.call(std.ref 'game', 'on'..m, w, w2, ...)
		t = std.par(std.scene_delim, t or false, r)
		if v == false then
			return t or r, true
		end
		if v ~= true then
			r, v = std.call(s, 'on'..m, w, w2, ...)
			t = std.par(std.scene_delim, t or false, r)
			if v == false then
				return t or r, true
			end
		end
		if v ~= true then
			r, v = std.call(s:where(), 'on'..m, w, w2, ...)
			t = std.par(std.scene_delim, t or false, r)
			if v == false then
				return t or r, true
			end
		end
		if m == 'use' and w2 then
			r, v = std.call(w2, 'used', w, ...)
			t = std.par(std.scene_delim, t or false, r)
			if r ~= nil or v ~= nil then
				w2['__nr_used'] = (w2['__nr_used'] or 0) + 1
				return t or r, true -- stop chain
			end
		end
		r, v = std.call(w, m, w2, ...)
		t = std.par(std.scene_delim, t or false, r)
		if v ~= nil or r ~= nil then
			w['__nr_'..m] = (w['__nr_'..m] or 0) + 1
			return t or r, v
		end
		r, v = std.call(std.ref 'game', m, w, w2, ...)
		t = std.par(std.scene_delim, t or false, r)
		return t or r, v
	end;
	action = function(s, w, ...)
		return s:call('act', w, ...)
	end;
	inventory = function(s)
		return s.obj
	end;
	take = function(s, w, ...)
		local r, v = s:call('tak', w, ...)
		if v == true then -- take it!
			w = std.ref(w)
			local o = w:remove()
			s:inventory():add(o)
			return r, v
		end
		if v == false then -- forbidden take
			return r, true
		end
		return r, v
	end;
	walkin = function(s, w)
		return s:walk(w, true, false)
	end;
	walkout = function(s, w)
		if w == nil then
			w = s:where():from()
		end
		return s:walk(w, false, true)
	end;
	walk = function(s, w, noexit, noenter)
		w = std.ref(w)
		if not w then
			std.err("Wrong parameter to walk: "..std.tostr(w))
		end

		local inwalk = w

		local r, v, t
		local f = s:where()
		r, v = std.call(std.ref 'game', 'onwalk', inwalk)

		t = std.par(std.scene_delim, t or false, r)

		if v == false or s:moved() then -- stop walk
			return t, true
		end

		if v ~= true then
			r, v = std.call(s, 'onwalk', inwalk)
			t = std.par(std.scene_delim, t or false, r)
			if v == false or s:moved() then
				return t, true
			end
		end

		if v ~= true then
			if not noexit and not s.__in_onexit then
				s.__in_onexit = true
				r, v = std.call(s:where(), 'onexit', inwalk)
				s.__in_onexit = false
				t = std.par(std.scene_delim, t or false, r)
				if v == false or s:moved() then
					return t, true
				end
			end
			if not noenter then
				r, v = std.call(inwalk, 'onenter', s:where())
				t = std.par(std.scene_delim, t or false, r)
				if v == false or s:moved() then
					return t, true
				end
			end
		end
		if not noexit and not s.__in_exit then
			s.__in_exit = true
			r, v = std.call(s:where(), 'exit', inwalk)
			s.__in_exit = false
			t = std.par(std.scene_delim, t or false, r)
			if s:moved() then
				return t, true
			end
		end
		if not noenter then
			s.room = inwalk
			s.room.__from = f
			r, v = std.call(inwalk, 'enter', f)
			t = std.par(std.scene_delim, t or false, r)
			if s:moved() then
				return t, true
			end
		end
		s.room = inwalk
		s.room.__visits = (s.room.__visits or 0) + 1
		s:need_scene(true)
		s:moved(true)
		return t, true
	end;
	go = function(s, w)
		local r, v
		r, v = s:where():seen(w)
		if not std.is_obj(r, 'room') then
			return nil, false
		end
		return s:walk(w)
	end;
	where = function(s, where)
		if type(where) == 'table' then
			table.insert(where, s.room)
		end
		return s.room
	end;
}, std.obj)

-- merge strings with "space" as separator
std.par = function(space, ...)
	local res
	local a = { ... };
	for i = 1, #a do
		if type(a[i]) == 'string' then
			if res == nil then
				res = ""
			else
				res = res .. space;
			end
			res = res .. a[i];
		end
	end
	return res;
end
-- add to not nill string any string
std.cat = function(v,...)
	if not v then
		return nil
	end
	if type(v) ~= 'string' then
		std.err("Wrong parameter to std.cat: "..std.tostr(v), 2);
	end
	local a = { ... }
	for i = 1, #a do
		if type(a[i]) == 'string' then
			v = v .. a[i];
		end
	end
	return v;
end

std.cctx = function()
	return std.call_ctx[std.call_top];
end

std.callpush = function(v, ...)
	std.call_top = std.call_top + 1;
	std.call_ctx[std.call_top] = { txt = nil, self = v };
end

std.callpop = function()
	std.call_ctx[std.call_top] = nil;
	std.call_top = std.call_top - 1;
	if std.call_top < 0 then
		std.err ("callpush/callpop mismatch")
	end
end

std.pclr = function()
	std.cctx().txt = nil
end

std.pget = function()
	return std.cctx().txt;
end

std.pr = function(...)
	local a = {...}
	if std.cctx() == nil then
		error ("Call from global context.", 2);
	end
	for i = 1, #a do
		std.cctx().txt = std.par('', std.cctx().txt or false, std.tostr(a[i]));
	end
--	std.cctx().txt = std.cat(std.cctx().txt, std.space_delim);
end

std.p = function(...)
	std.pr(...)
	std.cctx().txt = std.cat(std.cctx().txt, std.space_delim);
end

std.pn = function(...)
	std.pr(...)
	std.cctx().txt = std.cat(std.cctx().txt, '^');
end

std.pf = function(fmt, ...)
	if type(ftm) ~= 'string' then
		std.err("Wrong argument to std.pf: "..std.tostr(fmt))
	end
	std.pr(string.format(fmt, ...))
end

local function __dump(t, nested)
	local rc = '';
	if type(t) == 'string' then
		rc = string.format("%q", t):gsub("\\\n", "\\n")
	elseif type(t) == 'number' then
		rc = std.tostr(t)
	elseif type(t) == 'boolean' then
		rc = std.tostr(t)
	elseif type(t) == 'function' then
		if std.functions[t] and nested then
			local k = std.functions[t]
			return string.format("%s", k)
		end
	elseif type(t) == 'table' and not t.__visited then
		t.__visited = true
		if std.tables[t] and nested then
			local k = std.tables[t]
			return string.format("%s", k)
		elseif std.is_obj(t) then
			local d = std.deref(t)
			if type(d) == 'number' then
				rc = string.format("std(%d)", d)
			else
				rc = string.format("std %q", d)
			end
			return rc
		end
		local k,v
		local nkeys = {}
		local keys = {}
		for k,v in pairs(t) do
			if type(v) ~= 'function' and type(v) ~= 'userdata' then
				if type(k) == 'number' then
					table.insert(nkeys, { key = k, val = v })
				elseif k:find("__", 1, true) ~= 1 then
					table.insert(keys, { key = k, val = v })
				end
			end
		end
		table.sort(nkeys, function(a, b) return a.key < b.key end)
		rc = "{ "
		local n
		for k = 1, #nkeys do
			v = nkeys[k]
			if v.key == k then
				rc = rc .. __dump(v.val, true)..", "
			else
				n = k
				break
			end
		end
		if n then
			for k = n, #nkeys do
				v = nkeys[k]
				rc = rc .. "["..std.tostr(v.key).."] = "..__dump(v.val, true)..", "
			end
		end
		for k = 1, #keys do
			v = keys[k]
			if type(v.key) == 'string' then
				if v.key:find("^[a-zA-Z_]+[a-zA-Z0-9_]*$") and not lua_keywords[v.key] then
					rc = rc .. v.key .. " = "..__dump(v.val, true)..", "
				else
					rc = rc .. "[" .. string.format("%q", v.key) .. "] = "..__dump(v.val, true)..", "
				end
			else
				rc = rc .. std.tostr(v.key) .. " = "..__dump(v.val, true)..", "
			end
		end
		rc = rc:gsub(",[ \t]*$", "") .. " }"
	end
	return rc
end

local function cleardump(t)
	if type(t) ~= 'table' or not t.__visited then
		return
	end
	t.__visited = nil
	for k, v in pairs(t) do
		cleardump(v)
	end
end

function std.dump(t)
	local rc = __dump(t)
	cleardump(t)
	return rc
end

function std.new(fn, ...)
	if type(fn) ~= 'function' then
		std.err ("Wrong parameter to std.new", 2)
	end
	if not std.functions[fn] then
		std.err ("Function is not declared in 1-st argument of std.new", 2)
	end
	local arg = { ... }

	std.__in_new = true
	local o = fn(...)
	std.__in_new = false

	if type(o) ~= 'table' then
		std.err ("Constructor did not return object:"..std.functions[fn], 2)
	end
	rawset(o, '__dynamic', { fn = fn, arg = {...} })
	if std.game then
		o:ini() -- do initialization
	end
	return o
end

function std.delete(s)
	s = std.ref(s)
	if std.is_obj(s) then
		if type(s.nam) == 'number' and not s.__dynamic then -- static objects
			std.objects[s.nam] = false
		else
			std.objects[s.nam] = nil
		end
	else
		std.err("Delete non object table", 2)
	end
end

function std.nameof(o)
	o = std.ref(o)
	if not std.is_obj(o) then
		std.err("Wrong parameter to std.nameof: "..std.tostr(o), 2)
		return
	end
	return o.nam
end
function std.dispof(o)
	o = std.ref(o)
	if not std.is_obj(o) then
		std.err("Wrong parameter to std.dispof", 2)
		return
	end
	if o.disp ~= nil then
		return std.call(o, 'disp')
	end
	if type(o.nam) ~= 'string' then
		if std.is_tag(o.tag) then
			o = o.tag:sub(2)
			return o
		end
		if type(o.nam) == 'number' then
			return std.tostr(o.nam)
		end
		std.err("No nam nor disp are specified for obj: "..std.tostr(o.nam), 2)
	end
	return o.nam
end

function std.titleof(o)
	o = std.ref(o)
	if not std.is_obj(o) then
		std.err("Wrong parameter to std.titleof", 2)
		return
	end
	if o.title ~= nil then
		return std.call(o, 'title')
	end
	return std.dispof(o)
end

function std.ref(o)
	if type(o) == 'table' then
		return o
	end
	local oo = std.objects
	if oo[o] then
		return oo[o]
	end
end

function std.deref(o)
	if std.is_obj(o) then
		return o.nam
	elseif std.ref(o) then
		return o
	end
end

std.method = function(v, n, ...)
	if type(v) ~= 'table' then
		std.err ("Call on non table object:"..std.tostr(n), 2);
	end
	if v[n] == nil then
		return
	end
	if type(v[n]) == 'string' then
		return v[n], true;
	end
	if type(v[n]) == 'function' then
		std.callpush(v, ...)
		local a, b = v[n](v, ...);
		if type(a) ~= 'string' and b == nil then
			a, b = std.pget(), a
			if b == nil then
				b = true -- the fact of call
			end
		end
		std.callpop()
		return a, b
	end
	if type(v[n]) == 'boolean' then
		return v[n], true
	end
	if type(v[n]) == 'table' then
		return v[n], true
	end
	std.err ("Method not string nor function:"..std.tostr(n), 2);
end

std.call = function(v, n, ...)
	if type(v) ~= 'table' then
		std.err("Call on non table object: "..std.tostr(n), 2)
	end
	local r, v = std.method(v, n, ...)
	if type(r) == 'string' then
		if v == nil then v = true end
		return r, v
	end
	return r or nil, v
end

local function get_token(inp)
	local q, k
	local rc = ''
	k = 1
	if inp:sub(1, 1) == '"' then
		q = true
		k = k + 1
	end
	while true do
		local c = inp:sub(k, k)
		if c == '' then
			if q then
				return nil -- error
			end
			break
--			return rc, k
		end
		if c == '"' and q then
			k = k + 1
			break
		end
		if not q and (c == ' ' or c == ',' or c == '\t') then
			break
		end
		if q and c == '\\' then
			k = k + 1
			c = inp:sub(k, k)
			rc = rc .. c
		else
			rc = rc .. c
		end
		k = k + 1
	end
	if not q then
		if std.tonum(rc) then
			rc = std.tonum(rc)
		elseif rc == 'true' then
			rc = true
		elseif rc == 'false' then
			rc = false
		end
	end
	return rc, k
end

local function cmd_parse(inp)
	local cmd = {}
	if type(inp) ~= 'string' then
		return false
	end
	if inp:find("^save[ \t]+") then
		cmd[1] = 'save'
		cmd[2] = inp:gsub("^save[ \t]+", "")
		return cmd
	elseif inp:find("^load[ \t]+") then
		cmd[1] = 'load'
		cmd[2] = inp:gsub("^load[ \t]+", "")
		return cmd
	end
	inp = inp:gsub("[ \t]*$", "")
	while true do
		inp = inp:gsub("^[ ,\t]*","")
		local v, i = get_token(inp)
		inp = inp:sub(i)
		if v == nil or v == '' then
			break
		end
		table.insert(cmd, v)
	end
	return cmd
end

std.cmd_parse = cmd_parse

function std.me()
	return std.ref 'game'.player
end

function std.here()
	return std.me().room
end

function std.cacheable(n, f)
	return function(...)
		local s = std.cache[n]
		if s ~= nil then
			if s == -1 then s = nil end
			return s
		end
		std.cache[n] = -1
		s = f(...)
		if s ~= nil then
			std.cache[n] = s
		end
		return s
	end
end

std.obj {
	nam = '@iface';
	cmd = function(self, inp)
		local cmd = cmd_parse(inp)
		print("input: ", inp)
		if not cmd then
			return "Error in cmd arguments", false
		end

		std.cmd = cmd
		std.cache = {}
		local r, v = std.ref 'game':cmd(cmd)
		print("r, v = ", r, v)
		if v == false then
			if r == true then -- true, false is now menu mode
				return nil, true -- hack for menu mode
			end
			return iface:fmt(r, cmd[1] == 'load'), false
		end
		if v == true then
			r = iface:fmt(r, true)
		end
		print(r, v)
		return r, v
	end;
	xref = function(self, str, obj)
		obj = std.ref(obj)
		if not obj then
			return str;
		end
		return std.cat(str, "("..std.deref(obj)..")");
	end;
	title = function(self, str)
		return "[ "..std.tostr(str).." ]"
	end;
	fmt = function(self, str, state)
		if type(str) ~= 'string' then
			return
		end
		local s = string.gsub(str,'[\t \n]+', std.space_delim);
		s = string.gsub(s, '\\?[\\^]', { ['^'] = '\n', ['\\^'] = '^', ['\\\\'] = '\\'} );
		s = std.fmt(s, state)
		return std.cat(s, '\n')
	end;
	input = function(self)
	end;
	em = function(self, str)
		return str
	end;
};

function std.include(f)
	if std.game then
		std.err("Use include() only in global context", 2)
	end
	if type(f) ~= 'string' then
		std.err("Wrong argument to include(): "..std.tostr(f), 2)
	end
	if not f:find("%.lua$") then
		f = f .. '.lua'
	end
	if not std.includes[f] then
		std.includes[f] = true
		std.dofile(f)
	end
end

function std.abort()
	std.abort_cmd = true
end

function std.nop()
	std.abort()
	if std.cctx() then
		std.pr(std.game:lastdisp())
	end
	return std.game:lastdisp(), false
end

-- require "ext/gui"
require "strict"
require "dlg"
require "aliases"
