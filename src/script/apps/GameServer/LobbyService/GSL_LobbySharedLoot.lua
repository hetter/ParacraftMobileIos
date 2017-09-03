--[[
Title: shared loot
Author(s): LiXizhi
Date: 2013/6/19
Desc: 
This file reads "config/Aries/Others/SharedLoot.kids.xml"
When a battle is finished, one can query the lobby for shared loot. 
The shared loot keeps a limited number of gobal resources in memory. When all resources are used, no loot is returned any more. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbySharedLoot.lua");
local SharedLoot = commonlib.gettable("Map3DSystem.GSL.Lobby.SharedLoot");
echo(SharedLoot.CheckLoot("test1"))

SharedLoot.FrameMove();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
local SharedLoot = commonlib.gettable("Map3DSystem.GSL.Lobby.SharedLoot");

local loots;

function SharedLoot.Init()
	if(SharedLoot.is_inited) then
		return loots;
	end
	if(not System or not System.options or not System.options.version) then
		return;
	end

	SharedLoot.is_inited = true;

	local filename;
	if(System.options.version == "kids") then
		filename = "config/Aries/Others/SharedLoot.kids.xml";
	else
		filename = "config/Aries/Others/SharedLoot.teen.xml";
	end

	loots = loots or {};

	if(filename) then
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			local loot;
			for loot in commonlib.XPath.eachNode(xmlRoot, "/loots/loot") do
				if(loot.attr and loot.attr.name and loot.attr.time_range and loot[1]) then
					loot.time_range = commonlib.timehelp.datetime_range:new(loot.attr.time_range);
					loot.total_count = tonumber(loot.attr.total_count);
					loot.remaining_count = loot.total_count;
					loot.is_bbs_to_all = loot.attr.is_bbs_to_all == "true"
					loots[loot.attr.name] = loot;

					local loot_text = loot[1];
					local gsid, count;
					local adds;
					for gsid, count in loot_text:gmatch("(%d+),(%d+)|?") do
						gsid = tonumber(gsid);
						count = tonumber(count);
						if(not adds) then
							adds = "";
							loot.reward_gsid = gsid;
							loot.reward_count = count;
						end
						adds = format("%s%d~%d~NULL~NULL|", adds, gsid, count);
					end
					loot.adds = adds;
				end
			end
		end
	end
	return loots;
end

function SharedLoot.GetLoot(loot_name)
	if(not SharedLoot.Init()) then
		return
	end
	return loots[loot_name or ""];
end

-- check if loot is available now. This function can be called on game, client or lobby. 
-- this is a data-only function. 
function SharedLoot.CheckLoot(loot_name)
	if(not SharedLoot.Init()) then
		return
	end

	local loot = loots[loot_name or ""];

	if( loot and (not loot.total_count or loot.remaining_count>0) ) then
		
		-- TODO: shall we cache this in TimerManager?
		local date_str, time_str = commonlib.log.GetLogTimeString();
		local hour,min = time_str:match("^(%d%d)%D*(%d%d)");
		hour = tonumber(hour);
		min = tonumber(min);
		local year, month, day = date_str:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)$");
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);

		if(loot.time_range:is_matched(min, hour, day, month, year)) then
			return loot;
		end
	end
end

-- try get loot
-- @return the loot object if succeed. 
function SharedLoot.TryGetLoot(nid, loot_name)
	if(not SharedLoot.Init()) then
		LOG.std(nil, "info", "SharedLoot", "TryGetLoot service not ready at the moment")
		return
	end
	local loot = SharedLoot.CheckLoot(loot_name);
	if(loot) then
		if(loot.remaining_count) then
			loot.remaining_count = loot.remaining_count -1;
		end
		LOG.std(nil, "info", "SharedLoot", "loot nid %d with %s", nid, loot_name)
		return loot;
	end
end


local tick_count = 1;
-- this function is called every few seconds to update resources according to settings
function SharedLoot.FrameMove()
	if(not SharedLoot.Init()) then
		return
	end
	
	tick_count = tick_count + 1;
	if(tick_count<=3) then
		-- making this function called less often.
		return;
	else
		tick_count = 1;
	end

	local date_str, time_str = commonlib.log.GetLogTimeString();
	local hour,min = time_str:match("^(%d%d)%D*(%d%d)");
	hour = tonumber(hour);
	min = tonumber(min);
	local year, month, day = date_str:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);

	local name, loot
	for name, loot in pairs(loots) do
		if(loot.time_range:is_matched(min, hour, day, month, year)) then
			-- do nothing. 
		else
			-- replenish it when not matched. 
			loot.remaining_count = loot.total_count;
		end
	end
end

