--[[
NPL.load("(gl)script/apps/DBServer/LocalCache.lua");
local LocalCache = commonlib.gettable("DBServer.LocalCache");
]]

NPL.load("(gl)script/ide/commonlib.lua");

local LocalCache = commonlib.gettable("DBServer.LocalCache");


function LocalCache.get(key)
	if(LocalCache[key]) then
		return LocalCache[key];
	end
	return nil;
end


function LocalCache.set(key, value)
	if(key and value) then
		LocalCache[key] = value;
	end
end


function LocalCache.remove(key)
	LocalCache[key] = nil;
end


function LocalCache.removeAll()
	LocalCache = {};
end