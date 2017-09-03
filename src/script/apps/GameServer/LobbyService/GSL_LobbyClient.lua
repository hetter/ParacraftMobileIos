--[[
Title: Lobby client
Author(s): LiXizhi
Date: 2011/3/6
Desc: "on_game_update" event is fired when user leaves a room.
the message format is {type="on_game_update", game_info=table, old_game_info=table}
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyClient.lua");
local lobbyclient = Map3DSystem.GSL.Lobby.GSL_LobbyClient.GetSingleton();
lobbyclient:AddEventListener("on_game_update", function(msg)
	if(msg.game_info) then
		-- this is the game info class instace, one can call its methods. 
	end
end);
-----------------------------------------------
]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyData.lua");
local game_info_class = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
local player_info = commonlib.gettable("Map3DSystem.GSL.Lobby.player_info");

local tostring = tostring;
local GSL_LobbyClient = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.Lobby.GSL_LobbyClient"))

local proxy_addr_templ = "(rest)%s:script/apps/GameServer/LobbyService/GSL_LobbyServerProxy.lua";
-- whether to output log by default. 
local enable_debug_log = true;
-- the global instance, because there is only one instance of this object
local g_singleton;
-- default timeout for request
local default_timeout = 5000;
local heartbeat_interval = 5000;
-- constructor
function GSL_LobbyClient:ctor()
	-- enable debugging here
	self.debug_stream = self.debug_stream or enable_debug_log;
	self.events = commonlib.EventDispatcher:new();
	self.callbacks = {};
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer(timer);
	end})
	self.timer:Change(heartbeat_interval, heartbeat_interval);

	-- each lobby client must be associated with a gsl client object, even if none is provided.
	self:SetClient();
end

function GSL_LobbyClient:OnTimer()
	-- send heart beat to the server at heartbeat_interval 
	if(self.game_info) then
		if(self.game_info.owner_nid == tostring(System.User.nid)) then
			-- currently only the owner send the heart beat. 
			local game_id = self.game_info.id;
			if(game_id) then
				self:SendMessage("heart_beat", {game_id = game_id}, nil, nil);
			end
		end
	end
end

-- return the owner nid of the current game that the user is in. it may return nil if null. 
function GSL_LobbyClient:GetOwnerNid()
	if(self.game_info) then
		return self.game_info.owner_nid
	end
end

-- get the global singleton.
function GSL_LobbyClient.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_LobbyClient:new();
	end
	return g_singleton;
end

-- set the gsl client object
-- @param client: if nil it is the global default client object. 
function GSL_LobbyClient:SetClient(client)
	self.client = client or commonlib.gettable("Map3DSystem.GSL_client");
end

function GSL_LobbyClient:GetClient()
	return self.client;
end

-- add a NPL call back script to a given even listener
-- there can only be one listener per type per instance. 
-- @param ListenerType: string 
-- @param callbackScript: the function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
-- @param self_this: the first parameter to be passed to the callback. if nil, it will be GSL_LobbyClient(self). 
function GSL_LobbyClient:AddEventListener(ListenerType, callbackScript, self_this)
	self.events:AddEventListener(ListenerType, callbackScript, self_this or self);
end

-- remove a NPL call back script from a given even listener
-- @param ListenerType: string 
-- @param callbackScript: if nil, all callback of the type is removed. the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
function GSL_LobbyClient:RemoveEventListener(ListenerType, callbackScript)
	self.events:RemoveEventListener(ListenerType);
end

-- clear all registered event listeners
function GSL_LobbyClient:ResetAllEventListeners()
	self.events:ClearAllEvents();
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_LobbyClient:FireEvent(event)
	self.events:DispatchEvent(event, self)
end

-- send a message to server
-- if there is a reply with the same msg_type, we will return via a callback function. 
-- @param func_callback: optional callback function
-- @param timeout: if timeout is specified in milliseconds, a timeout message will be sent via func_callback. only valid when callback is specified.  Default to 5000(3 seconds)
function GSL_LobbyClient:SendMessage(msg_type, msg_data, func_callback, timeout)
	if(not self.client) then
		LOG.std(nil, "error", "lobbyclient", "no gsl client is found");
		return
	end
	-- game server address
	self.proxy_address = string.format(proxy_addr_templ, tostring(self.client.gameserver_nid));

	if(self.debug_stream) then
		LOG.std(nil, "debug", "lobbyclient", "send type %s: data:%s", tostring(msg_type), commonlib.serialize_compact(msg_data));
	end	

	local seq;
	if(func_callback) then
		seq = self:GetNextSeqNumber();
		local cb = {
			func_callback = func_callback,
			timer = commonlib.Timer:new({callbackFunc = function(timer)
				func_callback(nil, "timeout");
				timer:Change();
			end})
		}
		cb.timer:Change(timeout or default_timeout, nil);
		self.callbacks[seq] = cb;
	end

	if( NPL.activate(self.proxy_address, {type = msg_type, msg = msg_data, seq=seq}) ==0 ) then
	else
		-- connection to server may be lost
		LOG.std("", "warning", "lobbyclient", "unable to send request to "..self.proxy_address);
	end
end

local seq = 0;

-- get the next sequence number
function GSL_LobbyClient:GetNextSeqNumber()
	seq = seq + 1;
	return seq;
end

-- find all games by keys
-- @param game_key_array: array of game keys such as {"FireCavern_1to10", "TreasureHouse_4"}
-- @param func_callback: the call back function of function(msg) end
-- msg is like {nid="1003",type="find_game",seq=1,msg={msg={TreasureHouse_1={fulldata="{[16]={c=0,n=\"宝箱世界哈奇小镇1\",},[17]={c=0,n=\"宝箱世界哈奇小镇2\",},}",},LightHouse_S1_10to20={fulldata="{[6]={c=0,n=\"试炼1-大家请进1\",},[7]={c=0,n=\"试炼1-大家请进2\",},}",},TheGreatTree_10to50={fulldata="{[4]={c=0,n=\"神木-高手请进\",},[5]={c=0,n=\"神木-高手练习赛\",},}",},TreasureHouse_2={fulldata="{[18]={c=0,n=\"宝箱世界火鸟岛1\",},[19]={c=0,n=\"宝箱世界火鸟岛2\",},}",},YYsDream_S1={fulldata="{[12]={c=0,n=\"梦幻火鸟岛1\",},[13]={c=0,n=\"梦幻火鸟岛2\",},}",},},type="find_game",seq=1,user_nid="208711216",},}
function GSL_LobbyClient:FindGame(game_key_array, func_callback, timeout)
	self:SendMessage("find_game", game_key_array, func_callback, timeout);
end

-- get detailed information of a game, such as all its player information, etc. 
-- @param game_id: game id of the game
-- @param func_callback: the call back function of function(msg) end
-- msg is like 
function GSL_LobbyClient:GetGameDetail(game_id, func_callback, timeout)
	self:SendMessage("get_game", {game_id = game_id}, func_callback, timeout);
end
--更改副本难度
--[[
@param game_setting = {
		id = game_info.id,
		mode = mode,
	};
]]
function GSL_LobbyClient:ResetGameMode(game_settings, func_callback, timeout)
	game_settings.serverid = game_settings.serverid or Map3DSystem.User.WorldServerSeqId;
	self:SendMessage("reset_game_mode", game_settings, func_callback, timeout);
end
--[[ reset a game
@param game_setting = {
		id = game_info.id,
        name = name,
        leader_text = leader_text,
        min_level = min_level,
        max_level = max_level,
        max_players = max_players,
        password = password,
        requirement_tag = requirement_tag,
        magic_star_level = magic_star_level,
        hp = hp,
        attack = attack,
        hit = hit,
        cure = cure,
        guard_map = guard_map,
	};
]]
function GSL_LobbyClient:ResetGame(game_settings, func_callback, timeout)
	game_settings.serverid = game_settings.serverid or Map3DSystem.User.WorldServerSeqId;
	self:SendMessage("reset_game", game_settings, func_callback, timeout);
end
--[[ create a new game 
@param game_setting = {
		keyname = "",
		min_level = nil,
		max_level = nil,
		name = "",
		start_mode = "auto",
		level = owner combat level,
		school = school,
		family_id = number or nil, 
		best_friends = nil or table array of nids,
	};
]]
function GSL_LobbyClient:CreateGame(game_settings, func_callback, timeout)
	game_settings.serverid = game_settings.serverid or Map3DSystem.User.WorldServerSeqId;
	self:SendMessage("create_game", game_settings, func_callback, timeout);
end

--[[ join an existing game 
@param game_setting = {
		game_id=int,
		school=string,
		level=int, 
		display_name=string,
		family_id = number or nil, 
		best_friends = nil or table array of nids,
	};
]]
function GSL_LobbyClient:JoinGame(game_settings, func_callback, timeout)
	game_settings.serverid = game_settings.serverid or Map3DSystem.User.WorldServerSeqId;
	self:SendMessage("join_game", game_settings, func_callback, timeout);
end

-- get the game_info that the user is current in. it may return nil if the user is not is any room. 
function GSL_LobbyClient:GetCurrentGame()
	return self.game_info;
end

-- update game info. It will fire an event of 
-- {type="on_game_update", game_info, old_game_info}
-- @param game_info: either a table string or the table object. if nil, it may mean that the user left the game room. 
function GSL_LobbyClient:UpdateMyGameInfo(game_info)
	LOG.std(nil, "debug", "lobbyclient", "update game info:"..commonlib.serialize_compact(game_info));
	if(type(game_info) == "string") then
		game_info = NPL.LoadTableFromString(game_info);
	elseif(type(game_info) == "table") then
	else
		game_info = nil;
	end
	local old_game_info = self.game_info;
	if(game_info) then
		self.game_info = game_info_class:new(game_info);
		if(not self.game_info:has_player(tostring(System.User.nid))) then
			LOG.std(nil, "warn", "lobbyclient", "game update does not have local user");
		end
	else
		self.game_info = nil;
	end
	self:FireEvent({type="on_game_update", game_info=self.game_info, old_game_info=old_game_info});
end

-- leave a given game. 
function GSL_LobbyClient:LeaveGame(game_id, func_callback, timeout)
	self:SendMessage("leave_game", {game_id = game_id}, func_callback, timeout);
	-- TODO: shall we inform the client?
	self.game_info = nil;
end

function GSL_LobbyClient:StartGame(game_id, func_callback, timeout)
	self:SendMessage("start_game", {game_id = game_id}, func_callback, timeout);
end
function GSL_LobbyClient:MatchMaking(game_id, func_callback, timeout)
	self:SendMessage("match_making", {game_id = game_id}, func_callback, timeout);
end
--[[
	local game_settings = {
		game_id = game_id,
		kick_nid = kick_nid,
	}
--]]
function GSL_LobbyClient:KickGame(game_settings, func_callback, timeout)
	self:SendMessage("kick_game", game_settings, func_callback, timeout);
end

function GSL_LobbyClient:SentChatMessage(chat_msg)
	self:SendMessage("chat", chat_msg);
end

function GSL_LobbyClient:SendServerChatMessage(chat_msg)
	self:SendMessage("s_chat", chat_msg);
end

--[[
	local address_info = {
		game_id = game_id,
		nid = nid,
		address = address,
	}
--]]
function GSL_LobbyClient:CallUserToWorldAddress(address_info, func_callback, timeout)
	self:SendMessage("goto_address", {address_info = address_info}, func_callback, timeout);
end
-- we received a message from the lobby server. 
function GSL_LobbyClient:OnReceiveMessage(msg)
	if(not msg) then return end

	if(self.debug_stream) then
		LOG.std(nil, "debug", "lobbyclient", "received msg:"..commonlib.serialize_compact(msg));
	end	

	local msg_type = msg.type;
	if(msg_type == "create_game" or msg_type == "join_game" or msg_type == "leave_game") then
		if(msg.msg) then
			local data_table = msg.msg.msg;
			if(type(data_table) == "table") then
				if(not data_table.error_code) then
					if(data_table.player_count) then
						self:UpdateMyGameInfo(data_table);
					end
				else
					LOG.std(nil, "debug", "lobbyclient", "msg_type: %s has an erroc code of %s", msg_type, data_table.error_code);
				end
			end
		end
	elseif(msg_type == "start_game") then
	elseif(msg_type == "find_game") then
		
	end
	self:FireEvent({type="on_handle_all_msg", msg});

	if(msg.seq) then
		-- invoke callbacks if any
		local callback_ = self.callbacks[msg.seq];
		if(callback_ and callback_.func_callback) then
			callback_.func_callback(msg);
			if(callback_.timer) then
				callback_.timer:Change();
			end
		end
	end

	-- fire event after message is processed
	if(msg_type) then
		self:FireEvent(msg);
	end
end

local function activate()
	local self = GSL_LobbyClient.GetSingleton();
	self:OnReceiveMessage(msg)
end
NPL.this(activate);