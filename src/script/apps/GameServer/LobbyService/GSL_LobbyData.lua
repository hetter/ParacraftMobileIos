--[[
Title: Data structures used in Lobby service
Author(s): LiXizhi
Date: 2011/3/6
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyData.lua");
local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
local player_info = commonlib.gettable("Map3DSystem.GSL.Lobby.player_info");
	
local game1 = game_info:new({max_players = 4});
game1.worldname = "worlds/abc";
game1.owner_nid = "owner nid";
game1:add_user("user001", player_info:new({nid = "user001"}))
game1:add_user("user002", player_info:new({nid = "user002"}))
game1:remove_player("user001")
game1:make_owner("user002")
commonlib.echo(game1:tostring());
-----------------------------------------------
]]
local tostring = tostring;
local math_max = math.max;

NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");


-----------------------
-- ranking_info class
------------------------
local ranking_info = commonlib.gettable("Map3DSystem.GSL.Lobby.ranking_info");

-- mapping from nid to current nid ranking info. 
local nid_rankings = {};

-- we shall persistent all ranking info until the server restart.
function ranking_info.GetRankingInfo(nid, name)
	local ranking = nid_rankings[nid];
	if(ranking) then
		return ranking[name];
	end
end

-- we shall persistent all ranking info until the server restart.
function ranking_info.SetRankingInfo(nid, name, value)
	local ranking = nid_rankings[nid];
	if(not ranking) then
		ranking = {};
		nid_rankings[nid] = ranking;
	end
	ranking[name] = value;
end

-----------------------
-- player_info class
------------------------
local player_info = commonlib.createtable("Map3DSystem.GSL.Lobby.player_info", {
	nid,
	-- players in a game can be devided in to teams. Each team can has at most 4 players. Such as in a pvp game, one side has team_index 1, the other is 2. 
	team_index = 1,
	-- the rank_index within a team
	rank_index = 1,
	display_name = "unnamed",
	school = "unknown",
	level = 0,
	-- family id: we shall prevent game owner of the same family to match in a PvP duel.
	fid = nil,
	-- best friends id map.  nil or a table of {nid, ...}
	bf = nil,
	-- the game server nid with which this player is currently connected with. 
	proxy_nid,
	-- the integer server id, so that we know the displayname of the server. 
	serverid,
	-- a string of join, ready and started
	status_flag = "join",
});

function player_info:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

------------------------
-- game_info class
------------------------
local game_info = commonlib.createtable("Map3DSystem.GSL.Lobby.game_info", {
	id,
	-- the player nid who can change game settings, kick user and issue the start of the game. 
	owner_nid,
	-- the server id for display (it is always the owner's serverid). 
	serverid=nil,
	password,
	max_players = 4,
	name = "unnamed",
	-- the name of the game world, this is the key to start a game world instance(GSL_gridnode) on game server.
	worldname,
	-- this is used for fast indexing the game_info in lobby, the client can query games by keyname. if not provided, it is the same as the worldname.
	-- multiple game_info may share the same key name. 
	keyname, 
	-- a string that may be PvE, PvP, PvP_rank
	game_type = "PvE", 
	-- the current game status: open, waiting_ack, started, match_making
	status = "open",
	-- the start time, we will close the game it is started for some time.
	start_time = nil,
	-- min level
	min_level = nil,
	-- max level
	max_level = nil,
	-- the user school requirement tag. usually a string or nil. 
	requirement_tag = nil,
	-- some random text that the leader enters when it creates the game
	leader_text = nil,
	-- we shall prevent game of the same family to match in a PvP duel.
	family_id = nil, 
	-- nil or best friends array table. {nid, ...}
	best_friends = nil,
	-- last time that the user received a message. 
	last_user_tick = 0,
	-- mapping from player nid to player_info,
	players,
	-- if true, the game_info will be persistent and will not be removed from the list. If a game is started for 2 mins, it will be closed for reuse. 
	-- persistent game are usually those frequently visited PvE, PvP game that is precreated from xml file on the server side. 
	is_persistent = nil,
	-- the current player count
	player_count = nil,
	-- the tick count in milliseconds that we first started waiting for acknowledgement
	wait_ack_start_time = nil,
	-- it can be "manual", "auto". if "auto", the game will start automatically when max_players is reached. 
	start_mode = "auto",
	-- the number of frames that the team has been unable to find a game to match. This is only used by LobbyMatchMaker
	match_tick = 0,
	-- if true, only friends of the owner can join the game. 
	friends_join_only,
	grid_node_key = nil,
	--pvp 匹配信息
	match_info = nil,
	--魔法星等级
	magic_star_level = nil,
	--攻击力
	attack = nil,
	--命中
	hit = nil,
	--血量
	hp = nil,
	--治疗
	cure = nil,
	--每个系的防御力 guard_map = {storm = 0, fire = 0, life = 0, death = 0, ice = 0, }
	guard_map = nil,
	--副本难度
	mode = 1,-- 1 easy 2 normal 3 hard
});

function game_info:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	if(not o.player_count) then
		o.players = {};
		o.player_count = 0;
	elseif(o.players) then
		local user_nid, player;
		for user_nid, player in pairs(o.players) do
			player = player_info:new(player);
		end
	end
	return o
end

-- whether a given player is in this game
function game_info:has_player(user_nid)
	if(self.players[user_nid]) then
		return true
	end
end

-- whether there is 0 player
function game_info:is_empty()
	return self.player_count == 0;
end

-- whether it is full. Only full game can join a PvP game
function game_info:is_full()
	return self.max_players == self.player_count;
end

-- used for indexing this game. so that we can find one quickly. 
function game_info:get_keyname()
	return self.keyname or self.worldname or "";
end

-- get family id
function game_info:get_family_id()
	return self.family_id;
end

-- get school of the owner of the game
function game_info:get_school()
	if(self.owner_nid) then
		local player = self.players[self.owner_nid];
		if(player) then
			return player.school;
		end
	end
end

-- get the rank score to be used by PvP match making to find the best opponent.
-- currently, we use the average player level as the rank score. 
function game_info:get_rank_score()
	if(self.score) then
		return self.score;
	elseif(self.player_count>0) then
		local score = 0;

		local strict_pvp_score = if_else(System.options.version == "teen", 1800, 1800);

		-- recompute score using the average player level.
		local nid, player
		for nid, player in self:eachPlayer() do
			-- Note currently only one team is supported. 
			local player_score = math_max(player.level, player.score or player.level);
			
			local last = ranking_info.GetRankingInfo(nid, "last");
			if(last == "win") then
				if(player_score > strict_pvp_score) then
					player_score = math.floor(player_score/100)*100 + 99;
				else
					player_score = math.floor(player_score/100)*100 + 99;
				end
			elseif(last == "lose") then
				if(player_score > strict_pvp_score) then
					player_score = math.floor(player_score/100)*100;
				else
					player_score = math.floor(player_score/100)*100;
				end
			end

			-- tricky: alter the score secretly according to last win or lose
			--[[local ranking_score = ranking_info.GetRankingInfo(nid, "ranking");
			if(ranking_score) then
				local last = ranking_info.GetRankingInfo(nid, "last");
				if(last == "win") then
					-- add 260 if we have just won a game
					if(ranking_score > 1800) then
						ranking_score = ranking_score + 260;
					end
					player_score = math.max(ranking_score, player_score);
					
				elseif(last == "lose") then
					-- minus 260 if we have just lost a game
					if(ranking_score > 1260) then
						-- only substract score if user score is high enough. This protect weak users.
						ranking_score = ranking_score - 260;
					end
					player_score = ranking_score;
				end
			end]]
			score = score + player_score;
		end
		score = score / self.player_count;
		self.score = score;
	end
	return self.score or 0;
end

-- tick 
function game_info:tick(curTime)
	self.last_user_tick = curTime or commonlib.TimerManager.GetCurrentTime();
end

-- clear the room
function game_info:clear()
	self.players = {};
	self.player_count = 0;
	self.owner_nid = nil;
	self.owner_snid = nil;
	self.region_id = nil;
	self.status = nil;
	self.start_time = nil;
	self.serverid = nil;
	self.last_user_tick = nil;
	self.wait_ack_start_time = nil;
	self.grid_node_key = nil;
	self.match_tick = nil;
	self.match_info = nil;
	self.score = nil;
	self.family_id = nil;
	self.best_friends = nil;
	self.magic_star_level = nil;
	self.attack = nil;
	self.hit = nil;
	self.hp = nil;
	self.cure = nil;
	self.guard_map = nil;
	self.mode = 1;
end

-- make a given user owner of the game. the user must be already in the game, otherwise it will return nil.
-- @param user_nid: if nil, it will change the owner to the first one in the slot.  
-- @return true if added. 
function game_info:make_owner(user_nid)
	if(not user_nid) then
		local team_rank = self:get_team_rank();
		-- if no nid specified, make the next one in the rank owner of the game.
		user_nid = team_rank[1] or team_rank[2] or team_rank[3] or team_rank[4]
	end
	local owner = self.players[user_nid];
	if(owner) then
		self.owner_nid = user_nid;
		self.region_id = ExternalUserModule:GetRegionIDFromNid(user_nid);
		self.serverid = owner.serverid;
		self.family_id = owner.fid; -- for fast access in match maker
		self.best_friends = owner.bf; -- for fast access in match maker
		return true;
	end
end

-- whether a game is hosted in the same region as another one
-- @param game_info2: another region. the region id is set using the higher bits of the game owner's nid.
function game_info:is_in_same_region(game_info2)
	-- very tricky code just for 2144 region 4 user
	--if(self.region_id ~= game_info2.region_id) then
		--if(self.region_id == 4 or game_info2.region_id ==4) then
			--return false;
		--end 
	--end
	-- Note: we temporarily allow all users from different region to play together.
	return true;
end

-- this will check both family id and best friends id.
-- it will only return true if none of them match. 
function game_info:can_make_match_with(game_info2)

	-- teen version not check any conditions
	if(System.options.version == "teen") then
		return true
	end
	-- we will forbid family members to match in a PvP duel. 
	-- and we will forbid two game owners to be best friend with one another. 
	--return true;

	--if(self.player_count == 1 and self:get_school()== "life" and game_info2:get_school()== "life") then
		---- we will forbidden two life players to meet in 1v1. 
		--return false;
	--end

	-- this ensures that all if score is larger than 2200, it will avoid family id avoidence. 
	if (self:get_rank_score() > 5000 ) then
		return true;
	end

	-- only forbid family id
	local family_id2 = game_info2:get_family_id();
	return (not family_id2 or (family_id2 ~= self:get_family_id()));

	--local family_id2 = game_info2:get_family_id();
	--return (not family_id2 or (family_id2 ~= self:get_family_id())) and
		   --(not self:are_team_leaders_best_friend(game_info2)) ;
end

-- whether the team leaders of the two teams are best friends. 
function game_info:are_team_leaders_best_friend(game_info2)
	if(self.best_friends) then
		local best_friends = self.best_friends;
		local i;
		for i=1, 5 do
			local fnid = best_friends[i];
			if(fnid) then
				if(fnid == game_info2.owner_nid) then 
					return true;
				end
			else
				break;
			end
		end
	end
	if(game_info2.best_friends) then
		local best_friends = game_info2.best_friends;
		local i;
		for i=1, 5 do
			local fnid = best_friends[i];
			if(fnid) then 
				if(fnid == self.owner_nid) then
					return true;
				end
			else
				break;
			end
		end
	end
end

-- whether a given game has a best friend with another game
-- @param game_info2: 
-- @return true if there is a best friend in the opposite team. 
function game_info:has_best_friends(game_info2)
	if(self.best_friends) then
		local best_friends = self.best_friends;
		local i;
		for i=1, 5 do
			if(best_friends[i]) then 
				if(game_info2:has_player(best_friends[i])) then
					return true;
				end
			else
				break;
			end
		end
	end
	if(game_info2.best_friends) then
		local best_friends = game_info2.best_friends;
		local i;
		for i=1, 5 do
			if(best_friends[i]) then 
				if(self:has_player(best_friends[i])) then
					return true;
				end
			else
				break;
			end
		end
	end
end


local temp_rank = {};
-- get the team rank table
-- it is a table array of nid or nil. such as {nil, user_nid1, usernid2, nil}
-- @param team_index: the team index, if nil, it is the default team. 
-- @param output: if nil, it will use a global singleton table to store the output result. 
function game_info:get_team_rank(team_index, output)
	output = output or temp_rank;
	output[1] = nil;output[2] = nil;output[3] = nil;output[4] = nil;
	local nid, player
	for nid, player in self:eachPlayer() do
		-- Note currently only one team is supported. 
		output[player.rank_index] = nid;
	end
	return output;
end

-- remove a given player
-- @return the number of players left
function game_info:remove_player(user_nid)
	if(self.players[user_nid]) then
		self.players[user_nid] = nil;
		self.player_count = self.player_count - 1;
		-- if status is "started", we will reset it to open, since some player left the game. the logics may be different for different games. 
		-- self.status = nil;
		
		if(self.owner_nid == user_nid) then
			-- this will make the next one.
			self:make_owner(nil);
		end
		self.score = nil;
	end
	return self.player_count;
end

-- whether a given user is the owner of this game. 
function game_info:is_owner(user_nid)
	if(self.owner_nid == user_nid and self.owner_nid) then
		return true;
	end
end
-- @param map1:map1 = {storm = 0, fire = 0, life = 0, death = 0, ice = 0, }
-- @param map2:map2 = {storm = 0, fire = 0, life = 0, death = 0, ice = 0, }
--大于等于 都返回true
function game_info:FirstMorethanSecond(map1,map2)
	map1 = map1 or {};
	map2 = map2 or {};
	local storm_1 = map1.storm or 0;
	local fire_1 = map1.fire or 0;
	local life_1 = map1.life or 0;
	local death_1 = map1.death or 0;
	local ice_1 = map1.ice or 0;

	local storm_2 = map2.storm or 0;
	local fire_2 = map2.fire or 0;
	local life_2 = map2.life or 0;
	local death_2 = map2.death or 0;
	local ice_2 = map2.ice or 0;
	if(storm_1 >= storm_2 and fire_1 >= fire_2 and life_1 >= life_2 and death_1 >= death_2 and ice_1 >= ice_2)then
		return true;
	end
end
-- whether a given user can join the game world. 
-- TODO: verify school,level,etc
-- @param guard_map: guard_map = {storm = 0, fire = 0, life = 0, death = 0, ice = 0, }
-- @return bCanJoin, error_code:  true if can join, otherwise the second return value is the error message. 
function game_info:can_join(password, level, school, magic_star_level, attack, hit, hp, cure, guard_map, family_id, gear_score)
	if(self.requirement_tag)then
		if(not school)then
			return false, "wrong_school";
		end
		local s;
		local bFind;
		for s in string.gfind(self.requirement_tag, "[^|]+") do
			if(s == school)then
				bFind = true;
				break;
			end
		end
		if(not bFind)then
			return false, "wrong_school";
		end
	end
	if( self.password and self.password ~= password) then
		return false, "wrong_password";
	--PvE只判断最低等级
	elseif(level and self.min_level and  self.min_level > level) then 
		return false, "wrong_level";
	elseif(level and self.max_level and self.game_type == "PvP" and level > self.max_level) then 
		return false, "wrong_level";
	elseif(self.player_count >= self.max_players)then
		return false, "max_user";
	elseif(self.status ~= "open")then
		return false,"unopen"
	end
	--魔法星是从0级开始
	if(self.magic_star_level)then
		magic_star_level = magic_star_level or -1;
		if(magic_star_level < self.magic_star_level)then
			return false,"wrong_magic_star_level";
		end
	end
	if(self.hp)then
		hp = hp or 0;
		if(hp < self.hp)then
			return false,"wrong_hp";
		end
	end
	if(self.attack)then
		attack = attack or 0;
		if(attack < self.attack)then
			return false,"wrong_attack";
		end
	end
	if(self.hit)then
		hit = hit or 0;
		if(hit < self.hit)then
			return false,"wrong_hit";
		end
	end
	
	if(self.cure)then
		cure = cure or 0;
		if(cure < self.cure)then
			return false,"wrong_cure";
		end
	end
	if(self.guard_map)then
		if(not self:FirstMorethanSecond(guard_map,self.guard_map))then
			return false, "wrong_guard";
		end
	end

	local worldname = self.worldname;
	if(System.options.version == "kids" and worldname and worldname == "HaqiTown_LafeierCastle_PVP_ThreeTeam") then
		if(family_id ~= self.family_id) then
			return false, "wrong_family_id";
		end
		if(self.player_count >= 2) then
			local beHasSameSchool = true;
			local nid, player;
			for nid, player in self:eachPlayer() do
				if(player.school ~= school) then
					beHasSameSchool = false;
					break;
				end
			end
			if(beHasSameSchool) then
				return false, "wrong_team_school";
			end
		end
	end
	if(System.options.version == "kids" and worldname and (worldname == "HaqiTown_LafeierCastle_PVP_ThreeTeam" or worldname == "HaqiTown_LafeierCastle_PVP_TwoTeam")) then
		local owner = self.players[self.owner_nid];
		if(math.abs(gear_score - owner.gear_score) >= 400) then
			return false, "wrong_gear_score";
		end
	end
	if(System.options.version == "kids" and worldname and (worldname == "HaqiTown_RedMushroomArena_2v2_1999" or worldname == "HaqiTown_RedMushroomArena_2v2_5000")) then
		local owner = self.players[self.owner_nid];
		if(school == owner.school) then
			return false, "wrong_team_school_2v2";
		end
		if((not family_id) or (family_id and family_id ~= owner.fid)) then
			return false, "wrong_family_id_2v2";
		end
		if((owner.gear_score < 1800 and gear_score >= 1800) or (owner.gear_score >= 1800 and gear_score < 1800)) then
			return false, "wrong_gear_score_2v2";
		end
	end
	--if(self.) then
--
	--end
	return true;
end
--在房间开启后 有2分钟等待时间，这个时间内可以反复进入副本
function game_info:can_login_world(user_nid)
	if(self.status == "started" and self:has_player(user_nid))then
		if(self.wait_ack_start_time and self.wait_ack_start_time <= 120000)then
			return true;
		end 
	end
end
-- add a new user. if it is the first user, it automatically become the owner of the room. 
-- @return true if success or if already exist. return false if max user reached. 
function game_info:add_user(user_nid, player)
	if(self:has_player(user_nid)) then
		return true;
	end
	if(self.player_count >= self.max_players)then
		return false;
	end
	
	-- find the first free rank index to assign the user to. to improve efficiency, we will code using if instead of for. 
	local team_rank = self:get_team_rank();
	if(not team_rank[1]) then
		player.rank_index = 1
	elseif(not team_rank[2]) then
		player.rank_index = 2
	elseif(not team_rank[3]) then
		player.rank_index = 3
	else
		player.rank_index = 4
	end

	self.players[user_nid] = player;
	self.player_count = self.player_count + 1;
	if(self.player_count == 1)then
		self:make_owner(user_nid);
	end 
	self.score = nil;
	return true;
end

-- return an iterator of selected nodes in the XML document.
-- see function XPath.selectNodes(xmlLuaTable, xpath) for parameter specification
function game_info:eachPlayer()
	return pairs(self.players);
end

-- convert to string for network update etc. 
function game_info:tostring()
	return commonlib.serialize_compact(self);
end

-- get only necessary data to display the game info in a list on the client. 
-- @param game_tmpl: if not nil, we will compare and outout minlevel and max level. 
function game_info:get_view_data(o, game_tmpl)
	o = o or {};
	o.n = self.name;
	o.c = self.player_count;
	o.onid = self.owner_nid;
	o.sid = self.serverid;
	if(self.password)then
		o.np = true; -- need a password
	end
	o.maxp = self.max_players;
	o.worldname = self.worldname;
	o.game_type = self.game_type;
	o.keyname = self.keyname;
	o.s = self.status;
	o.mode = self.mode;
	if(game_tmpl) then
		if(self.min_level~=game_tmpl.min_level) then
			o.minl = self.min_level;
		else
			o.minl = game_tmpl.min_level;
		end
		if(self.max_level~=game_tmpl.max_level) then
			o.maxl = self.max_level;
		else
			o.maxl = game_tmpl.max_level;
		end
		o.rtag = self.requirement_tag;
		o.m_level = self.magic_star_level;
		o.attack = self.attack;
	end
	return o;
end


-- this function only call when is pvp3v3 oneplayer team or pvp3v3 twoplayer team
function game_info:get_pvp_3v3_win_rate()
	if(self.pvp_3v3_win_rate) then
		return self.pvp_3v3_win_rate;
	elseif(self.player_count>0) then
		local pvp_3v3_win_rate = 0;

		local nid, player
		for nid, player in self:eachPlayer() do
			pvp_3v3_win_rate = pvp_3v3_win_rate + player.pvp_3v3_win_rate;
		end
		pvp_3v3_win_rate = pvp_3v3_win_rate/self.player_count;
	
		self.pvp_3v3_win_rate = pvp_3v3_win_rate;
	end
	return self.pvp_3v3_win_rate or 0;
end

-- set the pvp_3v3_win_rate;
function game_info:set_pvp_3v3_win_rate(value)
	self.pvp_3v3_win_rate = value;
end

function game_info:isPVP3v3()
	local worldname = self.worldname;
	if(System.options.version == "kids" and worldname and (worldname == "HaqiTown_LafeierCastle_PVP_OneTeam" or worldname == "HaqiTown_LafeierCastle_PVP_TwoTeam" or worldname == "HaqiTown_LafeierCastle_PVP_ThreeTeam" or worldname == "HaqiTown_LafeierCastle_PVP_Matcher")) then
		return true;
	else
		return false;
	end
end

-- get the players gear_score
function game_info:get_gear_score()
	-- changed 2016.7.27 by Xizhi: we no longer protect users with low gear score, instead all users will be having the same score. 
	local force_3v3_gear_score = 1500; 
	local gs;
	if(self.gear_score) then
		if(self:isPVP3v3()) then
			gs = force_3v3_gear_score;
		else
			gs = self.gear_score;
		end
		if(self.player_count == 3 and self:isPVP3v3()) then
			local rate = self:get_pvp_3v3_win_rate();
			rate = rate * 100;
			if (rate >= 60) then 
			   gs = gs + 100;
			elseif (rate > 55) then 
			   gs = gs + 50;
			elseif (rate > 50) then 
			   gs = gs + 30; 
			elseif (rate > 45) then 
			   gs = gs - 30;
			elseif (rate >= 40) then 
			   gs = gs - 50; 
			else
				gs = gs - 100; 
			end
		end
		return gs;
		--return self.gear_score;
	elseif(self.player_count>0) then
		local gear_score = 0;

		for nid, player in self:eachPlayer() do
			if(System.options.version == "kids" and self:isPVP3v3()) then
				gs = force_3v3_gear_score;
			else
				gs = player.gear_score;
			end
			--gear_score = gear_score + player.gear_score;
			gear_score = gear_score + gs;
		end
		gear_score = math.floor(gear_score/self.player_count);
		
		self.gear_score = gear_score;
		if(self.player_count == 3 and self:isPVP3v3()) then
			local rate = self:get_pvp_3v3_win_rate();
			rate = rate * 100;
			if (rate >= 60) then 
			   gear_score = gear_score + 100;
			elseif (rate > 55) then 
			   gear_score = gear_score + 50;
			elseif (rate > 50) then 
			   gear_score = gear_score + 30; 
			elseif (rate > 45) then 
			   gear_score = gear_score - 30;
			elseif (rate >= 40) then 
			   gear_score = gear_score - 50; 
			else
				gear_score = gear_score - 100; 
			end

		end
		return gear_score or 0;
	end
	return self.gear_score or 0;
end

-- set the players gear_score
function game_info:set_gear_score(value)
	self.gear_score = value;
end

------------------------
-- PvP match_info class
------------------------
local match_info = commonlib.createtable("Map3DSystem.GSL.Lobby.match_info", {
	-- usually teams[1] and teams[2] are game_info table
	teams = nil,
	start_time = nil,
	max_match_time = nil,
	-- a string of join, ready and started
	status_flag = "join",

	win_count = nil,
});

function match_info:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

------------------------
-- PvP match maker
------------------------
