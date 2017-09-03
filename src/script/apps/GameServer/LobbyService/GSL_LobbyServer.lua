--[[
Title: Lobby server
Author(s): LiXizhi
Date: 2011/3/6
Desc: Security note: this must be inside the firewall, since it will accept any incoming connection. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyServer.lua");
local server = Map3DSystem.GSL.Lobby.GSL_LobbyServer:new();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyData.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyMatchMaker.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbySharedLoot.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/AriesPowerAPI/AriesServerPowerAPI.lua");

local SharedLoot = commonlib.gettable("Map3DSystem.GSL.Lobby.SharedLoot");
local MatchMaker = commonlib.gettable("Map3DSystem.GSL.Lobby.MatchMaker");
local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
local player_info = commonlib.gettable("Map3DSystem.GSL.Lobby.player_info");
local tostring = tostring;
local format = format;
local GSL_LobbyServer = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.Lobby.GSL_LobbyServer"))
local BroadcastService = commonlib.gettable("Map3DSystem.GSL.Lobby.BroadcastService");
local ranking_info = commonlib.gettable("Map3DSystem.GSL.Lobby.ranking_info");

local proxy_addr_templ = "(rest)%s:script/apps/GameServer/LobbyService/GSL_LobbyServerProxy.lua";
-- whether to output log by default. 
local enable_debug_log = false;
-- the global instance, because there is only one instance of this object
local g_singleton;
local LobbyServer_nid = "lobbyserver";
-- if we did not receive any heart beat message from a game owner, we will remove the owner
local user_timeout_interval = 20000;
-- mapping from user nid to the game_info id. 
local users_to_games_map = {};
-- mapping from game_key to a table of game_id, game_info map.
-- only active games are in this table. 
local game_key_map = {};
-- precalculated search results, that will be transmitted over the network. usually updated every 1 or 2 seconds. 
local game_key_map_data = {};
-- mapping from game key name to game template. only games in this table are allowed to be created. 
local game_templates = {};

------------------------
--  GSL_LobbyServer class
------------------------
function GSL_LobbyServer:ctor()
	-- enable debugging here
	self.debug_stream = self.debug_stream or enable_debug_log;

	NPL.load("(gl)script/apps/GameServer/GSL_uac.lua");
	self.uac = Map3DSystem.GSL.GSL_uac:new();

	-- a mapping from game id to game_info struct. 
	self.games = {};
	self.last_game_id = 0;
	self.known_proxy = {};
end

-- get the global singleton.
function GSL_LobbyServer.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_LobbyServer:new();
	end
	return g_singleton;
end

-- do some one time init here
-- @param msg: {my_nid=string, lobbyserver_nid = string, proxy_thread_name=string, persistent_games=string, debug_stream="true"}
function GSL_LobbyServer:init(msg)
	self.my_nid = msg.my_nid;
	LobbyServer_nid = msg.lobbyserver_nid or LobbyServer_nid;
	-- pre-create worlds
	self.persistent_games_filename = msg.persistent_games;
	self.game_start_timeout_interval = msg.game_start_timeout_interval or 120000;
	self.timer_interval = msg.timer_interval or 3000;

	commonlib.gettable("Map3DSystem.options");
	System = Map3DSystem;
	System.options.version = System.options.version or msg.version;
	System.options.locale = System.options.locale or msg.locale;

	if(msg.debug_stream == "true") then
		self.debug_stream = true;
	end

	if(self.persistent_games_filename) then
		local xmlRoot = ParaXML.LuaXML_ParseFile(self.persistent_games_filename);
		if(not xmlRoot) then
			LOG.std(nil, "error", "lobbyserver", "failed loading persistent world config file %s", self.persistent_games_filename);
		else
			LOG.std(nil, "system", "lobbyserver", "loaded persistent world config file %s", self.persistent_games_filename or "");
			-- load all game template. 
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "//game") do
				local game_tmpl = {
					name = node.attr.name,
					keyname = node.attr.keyname,
					worldname=node.attr.worldname,
					is_persistent = true,
					min_level = tonumber(node.attr.min_level),
					max_level = tonumber(node.attr.max_level),
					game_type = node.attr.game_type,
					max_players = tonumber(node.attr.max_players),
					match_method = node.attr.match_method, -- "multi_pass", "simple"
					pre_world_id = tonumber(node.attr.pre_world_id),
				}
				game_tmpl.keyname = game_tmpl.keyname or game_tmpl.worldname;
				if(not game_templates[game_tmpl.keyname]) then
					game_templates[game_tmpl.keyname] = game_tmpl;
					local game_info_node;
					for game_info_node in commonlib.XPath.eachNode(node, "//game_instance") do
						-- precreate worlds
						local game_info = self:CreateNewGame({
							name = game_info_node.attr.name or game_tmpl.name,
							keyname = game_info_node.attr.keyname or game_tmpl.keyname,
							worldname = game_info_node.attr.worldname or game_tmpl.worldname,
							game_type = game_info_node.attr.game_type or game_tmpl.game_type,
							min_level = tonumber(game_info_node.attr.min_level) or game_tmpl.min_level,
							max_level = tonumber(game_info_node.attr.max_level) or game_tmpl.max_level,
							max_players = tonumber(game_info_node.attr.max_players) or game_tmpl.max_players,
							leader_text = game_info_node.attr.leader_text,
							requirement_tag = game_info_node.attr.requirement_tag,
							is_persistent = true,
						});
						--commonlib.echo(game_info);
					end
				else
					LOG.std(nil, "warn", "lobbyserver", "game template %s is already added before.", game_tmpl.keyname);
				end
			end
		end	
	end
	
	proxy_addr_templ = proxy_addr_templ:gsub("%(.-%)", "("..(msg.proxy_thread_name or "rest")..")");

	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer(timer);
	end})
	self.timer:Change(self.timer_interval, self.timer_interval)

	LOG.std(nil, "system","lobbyserver", "started: lobby server: %s, my_nid:%s, debug_stream=%s", LobbyServer_nid, self.my_nid or "", tostring(self.debug_stream));
end

-- @return the game_info of the id, it may return nil if not found.
function GSL_LobbyServer:GetGameByID(game_id)
	if(game_id) then
		return self.games[game_id]
	end
end

function GSL_LobbyServer:OnTimer(timer)
	-- check all games and close timed out games. 
	local game_start_timeout_interval = self.game_start_timeout_interval;
	SharedLoot.FrameMove();

	local cur_time = ParaGlobal.timeGetTime();
	local cleared_room;
	local game_id, game_info;
	for game_id, game_info in pairs(self.games) do
		if(game_info.start_time)then
			game_info.wait_ack_start_time = game_info.wait_ack_start_time or 0;
			game_info.wait_ack_start_time = game_info.wait_ack_start_time + self.timer_interval;
		end
		if(game_info.game_type == "PvP")then
			--game_start_timeout_interval = 30000;
		end
		if( (game_info.start_time and (cur_time-game_info.start_time) > game_start_timeout_interval) ) then
			--清空房间
			self:BroadcastGameInfoUpdate(game_info, "game_clear", game_info);
			if(not game_info.is_persistent) then
				-- remove the game 
				game_info:clear();
			
				-- non-persistent game room will be removed completely. 
				cleared_room = cleared_room or {};
				cleared_room[game_id] = true;

				-- remove from search key. 
				local games = game_key_map[game_info:get_keyname()];
				if(games) then	
					games[game_id] = nil;
				end
			else
				-- clear all users in this room.  and reuse this room. 
				game_info:clear();
			end
		elseif( (cur_time-game_info.last_user_tick) > user_timeout_interval ) then
			-- sign out the owner, if there has been no heart-beat message in the last user_timeout_interval period. 
			if(game_info.worldname ~= "HaqiTown_LafeierCastle_PVP_Matcher") then
				game_info.last_user_tick = cur_time;
				self:Handle_UserLeaveGame(game_info.owner_nid, game_id);	
			end
			
		end
	end

	-- clear rooms in the second pass
	if(cleared_room) then
		local _;
		for game_id, _ in pairs(cleared_room) do
			self.games[game_id] = nil;
		end
	end

	-- regenerate game_key_map_data, this will cache results every 3-5 seconds. 
	local keyname, games
	for keyname, games in pairs(game_key_map) do
		local paged_data = game_key_map_data[keyname];
		local game_tmpl = game_templates[keyname];
		if(game_tmpl) then
			if(not paged_data) then
				paged_data = {};
				game_key_map_data[keyname] = paged_data;
			end
		
			-- only output used data, and ignore other data. 
			local view_data = {};
			local game_id, game_info 
			for game_id, game_info in pairs(games) do
				local data = {};
				view_data[game_id] = game_info:get_view_data(data, game_tmpl);
			end
			paged_data.fulldata = commonlib.serialize_compact(view_data);
		end
	end

	-- do match making, and send the "match_start" message. 
	local matches = MatchMaker.FrameMove(self);
	if(matches) then
		local _, match;
		for _, match in ipairs(matches) do
			local team1 = match.teams[1];
			local team2 = match.teams[2];
			if(not team2 and team1) then
				-- human vs. AI. the grid_node_key is "local" or "a:.*"
				local grid_node_key;
				if(team1.player_count >= 2) then
					-- for multi-users, we will use the home server. for single user, we will use the local game server instead. 
					self.next_key = (self.next_key or 0) + 1;
					grid_node_key = "a:"..tostring(self.next_key);
				else
					grid_node_key = "local";
				end
				team1.status = "started";
				team1.start_time = ParaGlobal.timeGetTime();
				team1.wait_ack_start_time = 0;
				team1.grid_node_key = grid_node_key;
				team1.match_info = commonlib.deepcopy(match);

				self:BroadcastGameInfoUpdate(team1, "start_game", team1);

			elseif(team1 and team2 and team1.player_count == team2.player_count) then
				-- human vs. human the grid_node_key is "m:.*"
				self.next_key = (self.next_key or 0) + 1;
				local grid_node_key = "m:"..tostring(self.next_key);

				-- only the owner can start the game. 
				team1.status = "started";
				team1.start_time = ParaGlobal.timeGetTime();
				team1.wait_ack_start_time = 0;
				team1.grid_node_key = grid_node_key;
				-- only the owner can start the game. 
				team2.status = "started";
				team2.start_time = ParaGlobal.timeGetTime();
				team2.wait_ack_start_time = 0;
				team2.grid_node_key = grid_node_key;

				--self:BroadcastGameInfoUpdate(team1, "match_start", match);
				--self:BroadcastGameInfoUpdate(team2, "match_start", match);
				team1.match_info = commonlib.deepcopy(match);
				team2.match_info = commonlib.deepcopy(match);
				self:BroadcastGameInfoUpdate(team1, "start_game", team1);
				self:BroadcastGameInfoUpdate(team2, "start_game", team2);
			else
				LOG.std(nil, "debug", "lobbyserver", "invalid match found. "..commonlib.serialize_compact(match));
			end
		end
	end
end

-- set the message to lobby proxy to be forwarded back to client
-- @return true if successfully send. 
function GSL_LobbyServer:SendMessage(proxy_nid, user_nid, msg_type, msg_data, seq)
	-- game server address
	local proxy_address;
	if(self.my_nid ~= proxy_nid) then
		proxy_address = format(proxy_addr_templ, proxy_nid or "");
	else
		proxy_address = format(proxy_addr_templ, "");
	end

	if(self.debug_stream) then
		LOG.std(nil, "debug", "lobbyserver", "send type %s: proxy_address: %s data:%s", tostring(msg_type), proxy_address, commonlib.serialize_compact(msg_data));
	end	

	if( NPL.activate(proxy_address, {type = msg_type, user_nid = user_nid, msg = msg_data, seq=seq}) ~=0 ) then
		-- connection to server may be lost
		LOG.std(nil, "warn", "lobbyserver", "unable to send request to "..proxy_address);
	else
		return true;
	end
end

-- the room owner kicks a user out of the game
function GSL_LobbyServer:Handle_UserKickGame(proxy_nid,owner_nid, game_id, kick_nid, seq)
	if(not game_id or not owner_nid or not kick_nid)then return end
	local game_info = self:GetGameByID(game_id);
	if(game_info and game_info:has_player(owner_nid) and game_info:has_player(kick_nid) and game_info.owner_nid == owner_nid) then
		local remain_count = game_info:remove_player(kick_nid);
		local game_str = game_info:tostring();
		self:BroadcastGameInfoUpdate(game_info, "update_game", game_info, owner_nid, seq);

		self:SendMessage(proxy_nid, kick_nid, "kick_game", game_info);
	end
end
-- a user has just left the game, we will remove it and inform all other users in the same game. 
-- if the room is empty we will also remove the game from the game list. 
-- @param game_id: the game id, if nil, it will search its current game if any. 
function GSL_LobbyServer:Handle_UserLeaveGame(user_nid, game_id)
	if(not game_id) then
		game_id = users_to_games_map[user_nid];
		if(not game_id) then
			return;
		end
	end
	local game_info = self:GetGameByID(game_id);
	if(game_info and game_info:has_player(user_nid)) then
		local remain_count = game_info:remove_player(user_nid);
		if(remain_count > 0) then
			-- inform the rest of the user
			local game_str = game_info:tostring();
			self:BroadcastGameInfoUpdate(game_info, "leave_game", game_info);
		else
			-- in case the room is empty, we will reset it. 
			game_info:clear();
			if(not game_info.is_persistent) then
				-- remove from search key. 
				local games = game_key_map[game_info:get_keyname()];
				if(games) then	
					games[game_id] = nil;
				end
				self.games[game_id] = nil;
			end
		end
	end
end

-- create a new game based on the game setting
-- we will do dead game recover whenever a new game is created. 
-- @param game_settings; a table of {}. It may return nil, if the game key is not in the list of allowed ones. 
function GSL_LobbyServer:CreateNewGame(game_settings)
	local keyname = game_settings.keyname or game_settings.worldname;
	local game_info = self:CreateNewTemporaryGame(game_settings);
	if(not game_info) then
		return;
	end

	self.games[game_info.id] = game_info;
	
	-- add to game_key_map for fast search
	if(not game_key_map[keyname]) then	
		game_key_map[keyname] = {};
	end
	game_key_map[keyname][game_info.id] = game_info;

	return game_info;
end

-- create a new temporary game based on the game setting, only be used to pvp3v3 in lobbyMaker now. it doesn't add to "self.games" and "game_key_map"
-- we will do dead game recover whenever a new game is created. 
-- @param game_settings; a table of {}. It may return nil, if the game key is not in the list of allowed ones. 
function GSL_LobbyServer:CreateNewTemporaryGame(game_settings)
	local keyname = game_settings.keyname or game_settings.worldname
	if(not keyname or not game_templates[keyname]) then
		-- if key is not allowed, return nil.
		return
	end
	self.last_game_id = self.last_game_id + 1;
	local game_info = game_info:new({id = self.last_game_id});
	
	if(game_settings) then
		local game_tmpl = game_templates[keyname];
		local mode = game_settings.mode or 1;
		local game_type = game_settings.game_type;
		local max_players = game_settings.max_players or 4;
		--if(game_type and game_type == "PvE")then
			--max_players = self:GetMaxPlayerByMode(mode);
		--end
		game_info.password = game_settings.password;
		game_info.name = game_settings.name or game_tmpl.name;
		game_info.keyname = game_settings.keyname;
		game_info.worldname = game_settings.worldname or game_tmpl.worldname;
		game_info.key_name = game_settings.key_name;
		game_info.game_type = game_settings.game_type;
		game_info.min_level = game_settings.min_level or 0;
		game_info.max_level = game_settings.max_level or 50;
		game_info.max_players = max_players;
		game_info.leader_text = game_settings.leader_text;
		game_info.requirement_tag = game_settings.requirement_tag;
		game_info.is_persistent = game_settings.is_persistent;
		game_info.start_mode = game_settings.start_mode;
		game_info.friends_join_only = game_settings.friends_join_only;
		game_info.magic_star_level = game_settings.magic_star_level;
		game_info.attack = game_settings.attack;
		game_info.hit = game_settings.hit;
		game_info.hp = game_settings.hp;
		game_info.cure = game_settings.cure;
		game_info.guard_map = game_settings.guard_map;
		game_info.mode = mode;
	end
	return game_info;
end

-- private: leave a previous game. this function is called automatically whenever a user create or join a new world. 
function GSL_LobbyServer:LeavePreviousGame(user_nid)
	local game_id = users_to_games_map[user_nid];
	if(game_id) then
		self:Handle_UserLeaveGame(user_nid, game_id)
		return true;
	end
end

-- private: broadcast a message to all members in the game info
-- @param 
function GSL_LobbyServer:BroadcastGameInfoUpdate(game_info, msg_type, msg_data, caller_user_nid, caller_seq)
	if(game_info) then
		local user_nid, player_info
		for user_nid, player_info in game_info:eachPlayer() do
			if(caller_user_nid == user_nid) then
				self:SendMessage(player_info.proxy_nid, user_nid, msg_type, msg_data, caller_seq);
			else
				self:SendMessage(player_info.proxy_nid, user_nid, msg_type, msg_data);
			end
		end
	end
end

--更改副本难度
function GSL_LobbyServer:Handle_UserResetGameMode(proxy_nid, user_nid, game_settings, seq)
	local game_id = game_settings.id;
	local game_info = self:GetGameByID(game_id);

	if(game_info) then
		game_info["mode"] = game_settings.mode or 1;
		if(game_settings.max_players)then
			game_info["max_players"] = game_settings.max_players;
		end
		--self:SendMessage(proxy_nid, user_nid, "reset_game_mode", game_info, seq)
		self:BroadcastGameInfoUpdate(game_info, "reset_game_mode", game_info, owner_nid, seq);
	end
end
--重置房间属性
function GSL_LobbyServer:Handle_UserResetGame(proxy_nid, user_nid, game_settings, seq)
	local game_id = game_settings.id;
	local game_info = self:GetGameByID(game_id);

	if(game_info) then
		game_info["name"] = game_settings.name;
		game_info["leader_text"] = game_settings.leader_text;
		game_info["min_level"] = game_settings.min_level or game_info["min_level"];
		game_info["max_level"] = game_settings.max_level or game_info["max_level"];
		game_info["max_players"] = game_settings.max_players or game_info["max_players"];
		game_info["password"] = game_settings.password;
		game_info["requirement_tag"] = game_settings.requirement_tag;
		game_info["magic_star_level"] = game_settings.magic_star_level;
		game_info["hp"] = game_settings.hp;
		game_info["attack"] = game_settings.attack;
		game_info["hit"] = game_settings.hit;
		game_info["cure"] = game_settings.cure;
		game_info["guard_map"] = game_settings.guard_map;

		--self:SendMessage(proxy_nid, user_nid, "reset_game", game_info, seq)
		self:BroadcastGameInfoUpdate(game_info, "reset_game", game_info, owner_nid, seq);
	end
end
-- handle create_game message
-- remove the user from is previous game
-- and then create a new room for this user. maybe reuse existing games. 
function GSL_LobbyServer:Handle_UserCreateGame(proxy_nid, user_nid, game_settings, seq)
	self:LeavePreviousGame(user_nid);
	
	local game_info = self:CreateNewGame(game_settings);

	if(game_info) then
		-- add the first user
		local user_info = player_info:new({nid = user_nid, score=game_settings.score, school=game_settings.school, level = game_settings.level, fid = game_settings.family_id, bf = game_settings.best_friends, proxy_nid=proxy_nid, serverid = game_settings.serverid, gear_score = game_settings.gear_score, pvp_3v3_win_rate = game_settings.pvp_3v3_win_rate})
		if(game_info:add_user(user_nid, user_info)) then
			game_info:tick();
			-- remember the last id. 
			users_to_games_map[user_nid] = game_info.id;
			-- send confirm message back with complete game_info struct
			self:SendMessage(proxy_nid, user_nid, "create_game", game_info, seq)
		else
			LOG.std(nil, "error", "lobbyserver", "failed to create game for user %s", user_nid);
		end
	else
		LOG.std(nil, "error", "lobbyserver", "failed to create game for user %s,persistent_games_filename:%s", user_nid,self.persistent_games_filename);
	end
end

-- handle join_game message
function GSL_LobbyServer:Handle_UserJoinGame(proxy_nid, user_nid, msg, seq)
	self:LeavePreviousGame(user_nid);
	local game_info = self:GetGameByID(msg.game_id);
	--echo("33333333333333");
	--echo(game_info.players);
	--echo(game_info.player_count)
	if(game_info) then
		local bCanJoin, error_code = game_info:can_join(msg.password, msg.level, msg.school, msg.magic_star_level, msg.attack, msg.hit, msg.hp, msg.cure, msg.guard_map, msg.family_id,msg.gear_score);
		if(bCanJoin) then
			-- add the next user
			local user_info = player_info:new({nid=user_nid, score = msg.score, level=msg.level, school=msg.school, fid = msg.family_id, bf = msg.best_friends, proxy_nid=proxy_nid, display_name=display_name, serverid = msg.serverid, gear_score = msg.gear_score, pvp_3v3_win_rate = msg.pvp_3v3_win_rate})
			if(game_info:add_user(user_nid, user_info)) then
				-- remember the last id. 
				users_to_games_map[user_nid] = game_info.id;
				-- send message back with complete game_info struct to all users in the game
				self:BroadcastGameInfoUpdate(game_info, "join_game", game_info, user_nid, seq);
				game_info:tick();
				-- automatically start the game
				if(game_info.player_count == game_info.max_players and game_info.start_mode == "auto") then
					-- TODO: auto start the game. 
				end
			end
		else
			self:SendMessage(proxy_nid, user_nid, "join_game", {errorcode=error_code }, seq);
		end
	else
		self:SendMessage(proxy_nid, user_nid, "join_game", {errorcode="room_is_nil" }, seq);
	end
end

function GSL_LobbyServer:Handle_UserStartGame(proxy_nid, user_nid, game_id)
	--self:LeavePreviousGame(user_nid);
	local game_info = self:GetGameByID(game_id);
	if(game_info) then
		if(game_info.owner_nid == user_nid) then
			self.next_key = (self.next_key or 0) + 1;
			local grid_node_key = tostring(user_nid)..":"..tostring(self.next_key);

			-- only the owner can start the game. 
			game_info.status = "started";
			game_info.start_time = ParaGlobal.timeGetTime();
			game_info.wait_ack_start_time = 0;
			game_info.grid_node_key = grid_node_key;
			self:BroadcastGameInfoUpdate(game_info, "start_game", game_info);
			-- TODO: shall we reset the game once it is started, so that the game_info can be reused. 
		else
			self:SendMessage(proxy_nid, user_nid, "start_game", {errorcode="you are not owner" });
		end
	end
end

-- this function is called when the team is full and request the system to find an opponent team to match.
function GSL_LobbyServer:Handle_MatchMaking(proxy_nid, user_nid, game_id)
	--self:LeavePreviousGame(user_nid);
	local game_info = self:GetGameByID(game_id);
	if(game_info) then
		if(game_info.owner_nid == user_nid) then
			-- only the owner can start the game. 
			if(game_info.game_type == "PvP") then
				MatchMaker.AddGame(game_info, game_templates[game_info.keyname]);
				self:BroadcastGameInfoUpdate(game_info, "match_making", game_info);
			else
				self:SendMessage(proxy_nid, user_nid, "match_making", {errorcode="you are not in a pvp game. " });
			end
		else
			self:SendMessage(proxy_nid, user_nid, "match_making", {errorcode="you are not owner" });
		end
	end
end

function GSL_LobbyServer:Handle_s_chat(proxy_nid, user_nid, gameserver_id,chat_data)
	if(type(chat_data) == "string") then
		chat_data = chat_data:gsub("\n", "");
		local invalid_proxy;
		local proxy_nid, value;
		for proxy_nid, value in pairs(self.known_proxy) do
			if(not self:SendMessage(proxy_nid, 0, "s_chat", chat_data)) then
				invalid_proxy = invalid_proxy or {};
				invalid_proxy[proxy_nid] = true;
			end
		end
		-- also send to local proxy. 
		self:SendMessage(nil, 0, "s_chat", chat_data)

		-- remove proxy that is not reachable. the proxy usually ping the lobby server every few second to keep it alive. 
		if(invalid_proxy) then
			for proxy_nid, value in pairs(invalid_proxy) do
				self.known_proxy[proxy_nid] = nil;
			end
		end
	end
end

-- handle shared loot
function GSL_LobbyServer:Handle_s_shared_loot(proxy_nid, user_nid, loot_name, threadname)
	local loot = SharedLoot.TryGetLoot(user_nid, loot_name);
	if(loot) then
		if(loot.adds) then
			self:SendMessage(proxy_nid, 0, "s_shared_loot", {user_nid = user_nid,loot_name = loot_name,threadname=threadname});
		else
			local text = format("/shared_loot %s %s %d %s", tostring(user_nid), loot_name, 1, tostring(user_nid) or "");
			if(loot.is_bbs_to_all) then
				-- send to all users
				self:Handle_s_chat(proxy_nid, user_nid, nil, text);
			else
				-- only send to the given user
				text = text:gsub("\n", "");
				self:SendMessage(proxy_nid, user_nid, "s_chat", text);
			end
		end
	end
end

function GSL_LobbyServer:Handle_Chat(proxy_nid, user_nid, game_id,chat_data)
	local game_info = self:GetGameByID(game_id);
	if(game_info) then
		local msg = {
			sender_nid = user_nid,
			chat_data = chat_data,
		};
		self:BroadcastGameInfoUpdate(game_info, "chat_update", msg);
	end
end

function GSL_LobbyServer:Handle_GotoAddress(proxy_nid, user_nid, address_info, seq)
	if(not address_info.game_id) then return end
	local game_info = self:GetGameByID(address_info.game_id);
	if(address_info and game_info)then
		local nid = address_info.nid;
		if(nid)then
			local address = address_info.address;
			self:SendMessage(proxy_nid, user_nid, "goto_address", {}, seq);
			local player_nid, player_info
			for player_nid, player_info in game_info:eachPlayer() do
				if(nid == player_nid) then
					if(user_nid ~= nid) then
						self:SendMessage(player_info.proxy_nid, nid, "goto_address", {
							caller = user_nid,
							address = address,
						});
					end
					break;
				end
			end
		end
	end
end
-- handle: get room details including all its players and team info. 
function GSL_LobbyServer:Handle_UserGetGame(proxy_nid, user_nid, game_id, seq)
	local game_info = self:GetGameByID(game_id);
	if(game_info) then
		self:SendMessage(proxy_nid, user_nid, "get_game", game_info, seq);
	else
		self:SendMessage(proxy_nid, user_nid, "get_game", {errorcode="not found" }, seq);
	end
end

-- user heart beat to keep its current game alive. 
function GSL_LobbyServer:Handle_UserHeartBeat(proxy_nid, user_nid, game_id, seq)
	if(game_id == users_to_games_map[user_nid]) then
		local game_info = self:GetGameByID(game_id);
		if(game_info and game_info:has_player(user_nid)) then
			game_info:tick();
		end
	end
end


-- this is the most important function to search all available games based on some game keys 
-- @param game_keys: an array of game keys to search for 
function GSL_LobbyServer:Handle_UserFindGame(proxy_nid, user_nid, game_keys, seq)
	if(type(game_keys) == "table") then
		local games = {};
		
		local _, keyname
		for _, keyname in ipairs(game_keys) do
			games[keyname] = game_key_map_data[keyname];
		end
		self:SendMessage(proxy_nid, user_nid, "find_game", games, seq);
	end
end

-- all handlers
local handlers = {};

function handlers.heart_beat(self, proxy_nid, user_nid, data, msg)
	-- heart beat message. 
	if(data) then
		self:Handle_UserHeartBeat(proxy_nd, user_nid, data.game_id, msg.seq)
	end
end

function handlers.get_game(self, proxy_nid, user_nid, data, msg)
	-- get detailed information about a given game_info by game_id
	if(data) then
		self:Handle_UserGetGame(proxy_nid, user_nid, data.game_id, msg.seq)
	end
end

function handlers.find_game(self, proxy_nid, user_nid, data, msg)
	-- find all games that matches a given lists of names. 
	self:Handle_UserFindGame(proxy_nid, user_nid, data, msg.seq);
end

function handlers.user_connection_lost(self, proxy_nid, user_nid, data, msg)
	-- this message is sent by the proxy when it failed to deliver a message to the client. 
	self:Handle_UserLeaveGame(user_nid, nil)
end
function handlers.reset_game(self, proxy_nid, user_nid, data, msg)
	if(data) then
		-- data: {level=number, school=string, password="", serverid=int}
		self:Handle_UserResetGame(proxy_nid, user_nid, data, msg.seq)
	end
end
function handlers.reset_game_mode(self, proxy_nid, user_nid, data, msg)
	--更改副本难度模式
	if(data) then
		-- data: {mode=number, serverid=int}
		self:Handle_UserResetGameMode(proxy_nid, user_nid, data, msg.seq)
	end
end

function handlers.create_game(self, proxy_nid, user_nid, data, msg)
	if(data) then
		-- data: {level=number, school=string, password="", serverid=int}
		self:Handle_UserCreateGame(proxy_nid, user_nid, data, msg.seq)
	end
end

function handlers.leave_game(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_UserLeaveGame(user_nid, data.game_id)
	end
end
function handlers.join_game(self, proxy_nid, user_nid, data, msg)
	-- data: {game_id="", level=number, school=string, password="", serverid=int}
	if(data) then
		self:Handle_UserJoinGame(proxy_nid, user_nid, data, msg.seq)
	end
end
function handlers.match_making(self, proxy_nid, user_nid, data, msg)
	if(data) then
		-- this can only be called by the owner to enroll a match, the system will put this game into the enrollment list, 
		-- and wait until a proper opponent team is found, and send "match_start" message to both teams. During match making, the already enrolled team may be broken, so the client needs to handle that properly
		self:Handle_MatchMaking(proxy_nid, user_nid, data.game_id)
	end
end
function handlers.start_game(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_UserStartGame(proxy_nid, user_nid, data.game_id)
	end
end
function handlers.kick_game(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_UserKickGame(proxy_nid, user_nid, data.game_id, data.kick_nid, msg.seq)
	end
end
function handlers.chat(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_Chat(proxy_nid, user_nid, data.game_id,data.chat_data);
	end
end
function handlers.s_chat(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_s_chat(proxy_nid, user_nid, data.game_id,data.chat_data);
	end
end

function handlers.s_shared_loot(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_s_shared_loot(proxy_nid, data.user_nid or user_nid, data.loot_name, data.threadname);
	end
end

function handlers.ping(self, proxy_nid, user_nid, data, msg)
	if(not self.known_proxy[proxy_nid]) then
		--  known proxies
		self.known_proxy[proxy_nid] = true;
	end
end
function handlers.goto_address(self, proxy_nid, user_nid, data, msg)
	if(data) then
		self:Handle_GotoAddress(proxy_nid, user_nid, data.address_info, msg.seq);
	end
end

function handlers.pvp_arena_ranking_info(self, proxy_nid, user_nid, data, msg)
	if(data and data.RankingInfo_str) then
		local position, nid, ranking;
		for position, nid, ranking in data.RankingInfo_str:gmatch("%((%d+),(%d+),(%d+)%)") do
			ranking = tonumber(ranking);
			ranking_info.SetRankingInfo(nid, "ranking", ranking);
		end
	end
end

function handlers.pvp_arena_ranking_point_change(self, proxy_nid, user_nid, data, msg)
	if(data and data.nid) then
		local reason = data.reason;
		local count = data.count;
		local nid = tostring(data.nid);
		if(reason == "lose" or reason == "loss") then
			ranking_info.SetRankingInfo(nid, "last", "lose");
		elseif(reason == "win") then	
			ranking_info.SetRankingInfo(nid, "last", "win");
		elseif(reason == "flee") then
			ranking_info.SetRankingInfo(nid, "last", "lose");
		elseif(reason == "timedout") then
			ranking_info.SetRankingInfo(nid, "last", "lose");
		elseif(reason == "draw_game") then
			ranking_info.SetRankingInfo(nid, "last", "lose");
		end
	end
end


-- we received a message from the lobby server. 
function GSL_LobbyServer:OnReceiveMessage(msg)
	if(not msg) then return end
	if(self.debug_stream) then
		LOG.std(nil, "debug", "lobbyserver", "received msg:"..commonlib.serialize_compact(msg));
		LOG.std(nil, "debug", "lobbyserver", "persistent_games_filename:%s",self.persistent_games_filename or "");
	end	
	local proxy_nid = msg.nid;
	
	-- we will only support nid with 5 digits (not a user, should be a game server nid)
	if(not proxy_nid or (#proxy_nid > 5)) then 
		if(msg.tid) then
			if(self.uac:check_nid(proxy_nid or msg.tid) and msg.proxy_nid) then
				LOG.std(nil, "system", "lobbyserver", "connection %s is accepted as %s", proxy_nid or msg.tid, msg.proxy_nid);
				NPL.accept(proxy_nid or msg.tid, msg.proxy_nid);
				proxy_nid = msg.proxy_nid;
				self.known_proxy[proxy_nid] = true;
			end
		else
			-- local messages
			if(msg.type == "init") then
				self:init(msg)
				return;
			elseif(not proxy_nid) then
				proxy_nid = msg.proxy_nid;
			end
		end
	end
	local user_nid = msg.user_nid;
	if(not user_nid) then return end

	local msg_type = msg.type;
	local data = msg.msg;
	local func = handlers[msg_type];
	if(func) then
		func(self, proxy_nid, user_nid, data, msg);
	end
end

function GSL_LobbyServer:GetGameTemplate(keyname)
	return game_templates[keyname];
end

local function activate()
	local self = GSL_LobbyServer.GetSingleton();
	self:OnReceiveMessage(msg)
end
NPL.this(activate);