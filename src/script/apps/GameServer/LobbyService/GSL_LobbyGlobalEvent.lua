--[[
Title: The global event
Author(s): LiXizhi
Date: 2013/6/19
Desc: 
This file reads "config/Aries/Others/server_event.kids.xml", it be used on server or on client depending on your usage. 
broadcast event to all online users 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyGlobalEvent.lua");
local GlobalEvent = commonlib.gettable("Map3DSystem.GSL.Lobby.GlobalEvent");
GlobalEvent.Start(bIsClient)
-----------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/DateTime.lua");
local GlobalEvent = commonlib.gettable("Map3DSystem.GSL.Lobby.GlobalEvent");

-- run a check every 10 seconds. 
GlobalEvent.check_interval = 2000;
-- time between two successive event
GlobalEvent.min_event_interval = 10000;

local events;
function GlobalEvent.Init()
	if(GlobalEvent.is_inited) then
		return;
	end
	GlobalEvent.is_inited = true;

	local filename;
	if(System.options.version == "kids") then
		filename = "config/Aries/Others/server_event.kids.xml";
	else
		filename = "config/Aries/Others/server_event.teen.xml";
	end

	if(filename) then
		NPL.load("(gl)script/ide/LuaXML.lua");

		local min_interval = math.floor(GlobalEvent.min_event_interval/1000);

		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			local event;
			for event in commonlib.XPath.eachNode(xmlRoot, "/events/event") do
				if(event.attr and event.attr.time_range and event[1]) then
					event.enabled = event.attr.enabled ~= "false";
					if(event.enabled) then
						events = events or {};
						event.time_range = commonlib.timehelp.datetime_range:new(event.attr.time_range);
						event.min_interval = tonumber(event.attr.min_interval) or min_interval;
						event.from_level = tonumber(event.attr.from_level)
						event.to_level = tonumber(event.attr.to_level)
						event.display_mid_mes = event.attr.display_mid_mes
						events[#events+1] = event;
						if(type(event[1]) == "table") then
							event[1] = commonlib.Lua2XmlString(event[1])
						end
					end
				end
			end
		end
	end
end

function GlobalEvent.CheckEvent(min, hour, day, month, year)
	if(not events) then
		return;
	end
	local current_time = math.floor(commonlib.TimerManager.GetCurrentTime() / 1000);

	local active_event;
	local _, event
	for _, event in ipairs(events) do
		if( event.enabled and 
			((not event.last_active_time) or (current_time - event.last_active_time) > event.min_interval) and
			event.time_range:is_matched(min, hour, day, month, year) )then
			event.last_active_time = current_time;
			active_event = event;
			-- LOG.std(nil, "info", "GlobalEvent", event[1]);

			if(GlobalEvent.mytimer) then
				GlobalEvent.mytimer:Change(GlobalEvent.min_event_interval, GlobalEvent.check_interval);
			end
			break;
		end
	end
	return active_event;
end

-- @param bIsClient: if true, it is client. if false, it is server. 
function GlobalEvent.Start(bIsClient)
	GlobalEvent.Init();
	if(events) then
		GlobalEvent.mytimer = GlobalEvent.mytimer or commonlib.Timer:new({callbackFunc = if_else(bIsClient, GlobalEvent.FrameMoveClient, GlobalEvent.FrameMoveServer),})
		GlobalEvent.mytimer:Change(GlobalEvent.check_interval, GlobalEvent.check_interval);
	end
end


-- this function is called by the every few seconds to check to see if we need to broadcast any event
-- client should call this function
function GlobalEvent.FrameMoveClient()
	local seconds, min, hour, day, month, year = MyCompany.Aries.Scene.GetServerDateTime();
	local event = GlobalEvent.CheckEvent(min, hour, day, month, year);
	if(event) then
		local text = event[1];
		local level = MyCompany.Aries.Player.GetLevel();
		if((event.from_level or level)<=level and level <= (event.to_level or level)) then
			--echo("111");
			--echo(event);
			if(event.attr and event.attr.func) then
				--echo("222");
				local func = commonlib.getfield(event.attr.func);
				func();
			end

			if(event.attr.value or text) then
				if(event.display_mid_mes ~= "false") then
					CommonCtrl.BroadcastHelper.PushLabel({id="global_event", label = event.attr.value or text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				end
				
				MyCompany.Aries.ChatSystem.ChatChannel.AppendChat({ChannelIndex=MyCompany.Aries.ChatSystem.ChatChannel.EnumChannels.System, is_direct_mcml=true, words=text or event.attr.value, bHideSubject=true});
			end
		end
	end
end

-- this function is called by the every few seconds to check to see if we need to broadcast any event
-- server should call this function
function GlobalEvent.FrameMoveServer(lobby_server)
	local date_str, time_str = commonlib.log.GetLogTimeString();
	local hour,min = time_str:match("^(%d%d)%D*(%d%d)");
	hour = tonumber(hour);
	min = tonumber(min);
	local year, month, day = date_str:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);

	local event = GlobalEvent.CheckEvent(min, hour, day, month, year);
	if(event) then
		-- broadcast to all
		Map3DSystem.GSL.system:SendChat(nil, event[1], true);
	end
end

function GlobalEvent.GotoMobNearby(value, mcmlNode)
	local worldname = mcmlNode:GetAttribute("worldname");
	local displayname = mcmlNode:GetAttribute("displayname");
	local position = mcmlNode:GetAttribute("position");

	NPL.load("(gl)script/apps/Aries/Pet/MonsterHandBook/MonsterHandBook.lua");
	local MonsterHandBook = commonlib.gettable("MyCompany.Aries.Pet.MonsterHandBook");
	MonsterHandBook.GoToMonsterPosition(worldname,displayname,position);
end

function GlobalEvent.OpenAnanasCoinPage()
	NPL.load("(gl)script/apps/Aries/Gift/GiftingForRechargeInHoliday.lua");
	local GiftingForRechargeInHoliday = commonlib.gettable("MyCompany.Aries.Gift.GiftingForRechargeInHoliday");
	GiftingForRechargeInHoliday.ShowPage();
end

function GlobalEvent.OpenLittleGamePage()
	NPL.load("(gl)script/apps/Aries/Pet/LittleGame.lua");
	local LittleGame = commonlib.gettable("MyCompany.Aries.Pet.LittleGame");
	LittleGame.ShowPage();
end

function GlobalEvent.CreateHorseAndMushroom()
	NPL.load("(gl)script/apps/Aries/NPCs/FollowPets/30549_GoldenMushroom.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/FollowPets/30548_GoldenHorse.lua");
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;
	--echo(worldinfo)
	if(worldname == "61HaqiTown") then
		MyCompany.Aries.Quest.NPCs.GoldenHorse.CreateFunction();
		MyCompany.Aries.Quest.NPCs.GoldenMushroom.CreateFunction();
	end

end

function GlobalEvent.BroadCastMsgOnClick(keyname)
	if (keyname) then		
		local npcid = string.match(keyname,"npc_(%d+)");
		local pve_world = string.match(keyname,"openworld_(.*)")
		if (npcid) then
			NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	        local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
            WorldManager:GotoNPCAndDialog(npcid);	

		elseif (pve_world) then
            NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
            local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
			LobbyClientServicePage.MenuClick({Name="open_world", worldname= pve_world});	

		elseif (keyname=="pvp_1v1_join" or keyname=="pvp_2v2_join" or keyname=="crazy_tower") then
            NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
            local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
			LobbyClientServicePage.MenuClick({Name = keyname})		

		elseif(keyname == "battlefield")then
			NPL.load("(gl)script/apps/Aries/Instance/main.lua");
			MyCompany.Aries.Instance.EnterInstance_BattlefieldClient();
		
		end
	end
end

function GlobalEvent.BroadCastMsgBattleFieldIsStart()
	local Player = commonlib.gettable("MyCompany.Aries.Player");
	if(Player.IsInCombat()) then
		return;
	end

	local public_world_list = {
		["61HaqiTown"] = true,
		["FlamingPhoenixIsland"] = true,
		["FrostRoarIsland"] = true,
		["AncientEgyptIsland"] = true,
		["DarkForestIsland"] = true,
	};
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local world_info = WorldManager:GetCurrentWorld()
	if(not public_world_list[world_info.name]) then
		return;
	end

	local ItemManager = System.Item.ItemManager;
	local beHas,_,_,copies = ItemManager.IfOwnGSItem(50417);
	if(copies and copies >= 10) then
		return;
	end

	_guihelper.MessageBox("英雄谷开赛了，现在马上参加！",function(result)
		if(result == _guihelper.DialogResult.Yes) then
			NPL.load("(gl)script/apps/Aries/CombatRoom/BattleFieldTeam.lua");
			local BattleFieldTeam = commonlib.gettable("MyCompany.Aries.CombatRoom.BattleFieldTeam");
			if(BattleFieldTeam.CanJoin()) then
				BattleFieldTeam.DoJoin();
			end
		end
	end,_guihelper.MessageBoxButtons.YesNo);
	
end

function GlobalEvent.JoinBattleField()
	NPL.load("(gl)script/apps/Aries/CombatRoom/BattleFieldTeam.lua");
	local BattleFieldTeam = commonlib.gettable("MyCompany.Aries.CombatRoom.BattleFieldTeam");
	if(BattleFieldTeam.CanJoin()) then
		BattleFieldTeam.DoJoin();
	end
end

function GlobalEvent.JoinPVP1v1()
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	LobbyClientServicePage.MenuClick({Name = "pvp_1v1_join"});	
end

function GlobalEvent.JoinPVP3v3()
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	LobbyClientServicePage.MenuClick({Name = "pvp_3v3_join"});	
end

function GlobalEvent.OpenItemLuckyPage()
    NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemLuckyPage.lua");
    local ItemLuckyPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemLuckyPage");
    ItemLuckyPage.ShowPage();
end

function GlobalEvent.OpenHaqiShop()
	NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
	MyCompany.Aries.HaqiShop.ShowMainWnd("tuijian","1001");
end

