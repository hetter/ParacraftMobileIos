--[[
Title: The match maker
Author(s): LiXizhi
Date: 2011/4/22
Desc: Match formula: 
local score_diff = math_abs(score1 - score2);
local score_avg = math_max(math_min(score1, score2), max_score);
if(score_diff<pvp_best_match_diff_abs or (score_diff/score_avg) <= score_diff_p) then
end
Note1: score_diff_p is increaased by pvp_best_match_diff_percent every diff_percent_double_tick_count ticks until min_simple_match_tick_count is reached, 
afterwhich we will match any team. 
Note2: score1 is max(level, score), max_score is ususally 50
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyMatchMaker.lua");
local MatchMaker = commonlib.gettable("Map3DSystem.GSL.Lobby.MatchMaker");
MatchMaker.AddGame(game_info);
-----------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyData.lua");
local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
local match_info = commonlib.gettable("Map3DSystem.GSL.Lobby.match_info");
local player_info = commonlib.gettable("Map3DSystem.GSL.Lobby.player_info");

local tostring = tostring;
local math_abs = math.abs;
local math_ceil = math.ceil;
local math_floor = math.floor;
local math_max = math.max;
local math_min = math.min;


--[[ DEFINE this to use a different paramter set. 
"ladder": 
"happy_pvp": 
"good_old_pvp": only use percentage 
]]
local MAKER_MODE = "strict"; 

-- mapping from game_key to a table of game_candidates
local game_candidates = {};

-- for every 10 ticks(10 seconds), we will double the pvp_best_match_diff_percent or use pvp_best_match_diff_percent_map until min_simple_match_tick_count ticks are passed.
local diff_percent_double_tick_count = 10;
-- the max score. if this is nil, we will use the larger of the two team's scores
local max_score = 50;
-- the max percent of difference between two matching teams' ranking score:
--  fomula: (math_abs(score1 - score2)/(max_score)) < pvp_best_match_diff_percent
local pvp_best_match_diff_percent = 0.02;
-- we now use values in pvp_best_match_diff_percent_map as diff, the index is increased by 1 after each diff_percent_double_tick_count(10seconds)
local strict_old_pvp_diff = {0.02, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1, 1.5, 2, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5};
local free_pvp_diff = {1, 3, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100};

local pvp_best_match_diff_percent_map = strict_old_pvp_diff;
-- the minimum of ticks before we employ the simple match instead of best match algorithm. 
-- if nil, a best match must be found(team may wait for ever if no matching ones are found)
--  the period is min_simple_match_tick_count*GSL_LobbyServer.timer_interval. so 150 usually means 150 seconds. 
local min_simple_match_tick_count = 600;

-- if a long time has passed and there is no predefined diff in pvp_best_match_diff_percent_map, we will use this value. 
local pvp_max_match_diff_percent = 10;

-- if two teams' score only differs by this amount, we will make them a pair immediately, regardless of pvp_best_match_diff_percent. 
local pvp_best_match_diff_abs = 2;

-- if two teams' score difference is bigger than this value, then the two teams should never meet each other.(simple match disabled)  
-- if nil, it takes no effect. 
local max_allowed_pvp_score_diff = nil;

-- setting multi_pass to true: to use the formula: 
--	(math_abs(score1 - score2)/(max_score)) < pvp_best_match_diff_percent
local bEnable_multi_pass = true;

-- the max score that a user can meet AI opponents
local use_ai_bot_score;--  = 1200;
-- the number of ticks(seconds) that need to wait before an AI bot is selected as opponents. 
local use_ai_bot_ticks = 120;
local max_match_ticks_teen = 100;

-- allow gear_score offset in pvp_3v3 for kids version
local allowed_gear_score_offset = 150;

local game_info_ids_for_3v3;

if(MAKER_MODE == "good_old_pvp") then
	-- default values
elseif(MAKER_MODE == "happy_pvp") then
	min_simple_match_tick_count = 30;
	pvp_best_match_diff_percent_map = free_pvp_diff;
	pvp_max_match_diff_percent = 100;
elseif(MAKER_MODE == "ladder") then
	min_simple_match_tick_count = 30;
	pvp_best_match_diff_percent_map = {0.02, 0.06, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.5, 0.6, 0.8, 1, };
	pvp_best_match_diff_abs = 100;
	max_allowed_pvp_score_diff = 500;
	max_score = 1000;
	min_simple_match_tick_count = nil; -- disable simple match
	-- increase the allowed match diff between two team per tick(second)
	pvp_radius_grow_per_sec = 2;
	strict_pvp_score = 0;
elseif(MAKER_MODE == "strict") then
	min_simple_match_tick_count = 30;
	pvp_best_match_diff_percent_map = {0.02, 0.06, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.5, 0.6, 0.8, 1, };
	pvp_best_match_diff_abs = 100;
	-- max_allowed_pvp_score_diff = 149;
	max_allowed_pvp_score_diff = 400;
	max_score = 1000;
	min_simple_match_tick_count = nil; -- disable simple match
	-- increase the allowed match diff between two team per tick(second)
	pvp_radius_grow_per_sec = 1;
	-- we will use 100 strict score mapping when user score is below 1800. arena_server.lua also use this value. they must match. 
	strict_pvp_score = 1800;
	-- no ai shall be used when user reached this score range. 
	no_ai_bot_score = strict_pvp_score + 100;
end


-----------------------
-- the candidate class: 
--  containing all candidates from which we will find a match
--  the first added will be matched first. 
------------------------
local MatchCandidates = commonlib.gettable("Map3DSystem.GSL.Lobby.MatchCandidates");

function MatchCandidates:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	-- mapping from game id to game_info table
	o.id_map = {};
	-- pending for deletion
	o.delete_id_map = {};
	-- array of game_info in the order of starting. 
	o.game_array = commonlib.List:new();
	return o
end

-- whether the candidate is already in the list. 
function MatchCandidates:HasGame(game_id)
	if(game_id) then
		return (self.id_map[game_id] ~= nil);
	end
end

-- add game_info to the candidates. 
function MatchCandidates:AddGame(game_info)
	local game_id = game_info.id;
	if(game_id and (not self:HasGame(game_id))) then
		local new_item = {game_info=game_info}
		self.id_map[game_id] = {game_info=game_info};
		game_info.status = "match_making";

		local game_array = self.game_array;
		
		if(System.options.version == "teen") then
			game_array:addtail(new_item);
			--game_array:push_front(new_item);
		elseif(System.options.version == "kids") then
			local new_score = game_info:get_rank_score();
			-- insert to the proper position according to its rank_score
			local item = game_array:first();
			local before_item;
			while (item and item.game_info:get_rank_score() >=  new_score) do
				before_item = item;
				item = game_array:next(item);
			end
			if(before_item) then
				game_array:insert_after(new_item, before_item);
			else
				game_array:push_front(new_item);
			end
		end
		
	else
		game_info.status = "match_making";
	end
end

-- this function will not remove the game immediately,but mark the game as to be deleted and then delete in the next tick time. 
function MatchCandidates:RemoveGame(game_info)
	game_info.match_tick = nil;
	if(game_info.status == "match_making") then
		game_info.status = "open";
	end
	local item = self.id_map[game_info.id];
	if(item) then
		self.id_map[game_info.id] = nil;
		return self.game_array:remove(item);
	end
end

-- this funciton will delete the game from id_map and delete_id_map
-- only used internally when removing the game from game_array. use RemoveGame() for other purposes.
function MatchCandidates:DeleteGameItem(item)
	local game_info = item.game_info;

	if(self.match_method == "threePVPMatcher") then
		local delete_game_infos = game_info.need_delete_game_info_ids;
		local keyname,delete_game_info_ids;
		for keyname,delete_game_info_ids in pairs(delete_game_infos) do
			local candidates = game_candidates[keyname];
			if(candidates) then
				local game_array_for_candidates = candidates.game_array;


				if(game_array_for_candidates:size() >= 0) then
					local item = game_array_for_candidates:first();
					while (item) do
						--local game_info = item.game_info;
						local id = item.game_info.id;
						if(delete_game_info_ids[id]) then
							item = candidates:DeleteGameItem(item);
						else
							item = game_array_for_candidates:next(item);
						end
					end
				end
			end	
		end
	end

	if(game_info.status == "match_making") then
		game_info.status = "open";
	end
	game_info.match_tick = nil;
	self.id_map[game_info.id] = nil;
	return self.game_array:remove(item);
end

-- Call this function regularly to clean up internal state
-- @param lobby_server: the lobby server instance
-- @param matches: array of matches found during this frame move. 
-- @return matches;
function MatchCandidates:FrameMove(lobby_server, matches)
	local i;
	local game_array = self.game_array;
	local delete_id_map = self.delete_id_map;
	
	if(game_array:size() >= 0) then
		-- remove all games which is not full

		--LOG.std(nil, "debug", "GSL_LobbyMatchMaker", "count %d", game_array:size());

		local item = game_array:first();
		while (item) do
			local game_info = item.game_info;
			if(not game_info:is_full()) then
				item = self:DeleteGameItem(item);
			else
				item = game_array:next(item);
			end
		end

		local count;
		matches, count = self:PopMatches(matches);
	end
	return matches;
end

function MatchCandidates:FindMatch(item)
	
end

local score_increase_rate_teen = {
	[100] = 100,
	[80]  = 0.2,
	[60]  = 0.1,
	[40]  = 0.05,
};

-- pop all matches that make a pair
-- pop an array of match_info, if there is no match, we will return nil
-- @param matches: the in|out table where the poped matches are inserted. if nil, we may create one and return it. 
-- @return the matches are returned. the number of matches added is returned as the second params.
function MatchCandidates:PopMatches(matches)
	local game_array = self.game_array;
	local delete_id_map = self.delete_id_map;

	local count = 0;
	local teams;

	local match_method;
	if(self.match_method) then
		match_method = self.match_method
	else
		match_method = if_else(bEnable_multi_pass, "multi_pass", "simple");
	end

	if(System and System.options) then
		strict_pvp_score = if_else(System.options.version == "teen", 1800, 0) ;
		max_allowed_pvp_score_diff = if_else(System.options.version == "teen", 400, 300) ;
		--use_ai_bot_score = if_else(System.options.version == "teen", 1600, nil);
		use_ai_bot_score = if_else(System.options.version == "teen", 30000, nil);
		if(self.is_2v2) then
			-- disable all 2v2 
			use_ai_bot_score = nil;
			if(System.options.version == "kids") then
				max_allowed_pvp_score_diff = 1000;
			end
		end
		-- let the range from below strict_pvp_score to suffer
		-- strict_pvp_score = strict_pvp_score - 100;
	end

	-----------------------------
	-- match making algorithm: 
	-----------------------------
	if(match_method == "threePVPTeamer") then
		return matches,count;
	elseif(match_method == "threePVPMatcher") then	
		local item = game_array:first();
		while (item) do
			local game_info = item.game_info;
		
			game_info.match_tick = (game_info.match_tick or 0) + 1;
		
			local gear_score1 = game_info:get_gear_score();
			local hHasFoundMatch;
			
			-- checking for human opponents
			local candidate_item = game_array:next(item);
			
			while(candidate_item) do
				local game_info2 = candidate_item.game_info;
				local gear_score2 = game_info2:get_gear_score();
				local gear_score_offset = math.abs(gear_score1 - gear_score2);

				if(gear_score_offset <= allowed_gear_score_offset and game_info:can_make_match_with(game_info2)) then
					local match_info = match_info:new();
					match_info.teams = {game_info, game_info2};
					self:DeleteGameItem(candidate_item);
					item = self:DeleteGameItem(item);
						
					matches = matches or {};
					matches[#matches+1] = match_info;
					count = count + 1;
					hHasFoundMatch = true;
					LOG.std(nil, "system", "GSL_LobbyMatchMaker", "accurate match found with score %.2f %.2f: between owner %s %s", gear_score1, gear_score2, tostring(game_info.owner_nid), tostring(game_info2.owner_nid));
					break;
				end

				candidate_item = game_array:next(candidate_item);
			end	
			
			if(not hHasFoundMatch) then
				item = game_array:next(item);
			end
		end
	elseif(match_method ~= "simple") then
		
		local item = game_array:first();
		while (item) do
			local game_info = item.game_info;
			game_info.match_tick = (game_info.match_tick or 0) + 1;
			local hHasFoundMatch;
			if(System.options.version == "teen" and game_info.match_tick < 40) then
				
			else
				if(System.options.version == "kids") then
					pvp_radius_grow_per_sec = 2;
					if(self.is_2v2) then
						pvp_radius_grow_per_sec = 10;
					end
				end

				local down_score_diff_radius = game_info.match_tick * (pvp_radius_grow_per_sec or 1); 
		
				local score1 = game_info:get_rank_score();

				--if(use_ai_bot_score and score1 < use_ai_bot_score and game_info.match_tick > use_ai_bot_ticks) then
				-- 青年版不走机器人逻辑  2014 10 23
				if(false) then
					-- checking for AI opponents
					local match_info = match_info:new();
					match_info.teams = {game_info, nil}; --  when ai bot is used, the second team is always nil. 
					item = self:DeleteGameItem(item);
						
					matches = matches or {};
					matches[#matches+1] = match_info;
					count = count + 1;
					hHasFoundMatch = true;
				else
					local timeover = false;
					local closest_item = nil;
					if(System.options.version == "teen") then
						--max_match_ticks_teen = 60;
						if(game_info.match_tick >= max_match_ticks_teen) then
							timeover = true;
						elseif(game_info.match_tick > 80) then
							down_score_diff_radius = math.ceil(score1*0.2);
						elseif(game_info.match_tick > 60) then
							down_score_diff_radius = math.ceil(score1*0.1);
						elseif(game_info.match_tick >= 40) then
							down_score_diff_radius = math.ceil(score1*0.05);
						end
					end

					-- checking for human opponents
					local candidate_item = game_array:next(item);
			
					while(candidate_item) do
						local meetCondition = false;
						local game_info2 = candidate_item.game_info;
						if(game_info:is_in_same_region(game_info2) ) then
							local score2 = game_info2:get_rank_score();
							-- NOTE: this is the formula to locate the best match
							local score_diff = (score1 - score2);

							-- LOG.std(nil, "system", "GSL_LobbyMatchMaker", "match found with score %.2f %.2f, score_diff(%.2f), down_score_diff_radius(%.2f): between owner %s %s", score1, score2, score_diff, down_score_diff_radius, tostring(game_info.owner_nid), tostring(game_info2.owner_nid));

							if(System.options.version == "kids") then
								if(score1 < 1800 and score2 < 1800 and self.is_1v1) then
									meetCondition = true;
								elseif( max_allowed_pvp_score_diff and score_diff>=max_allowed_pvp_score_diff )  then
									-- break immediately if native score differs a lot. 
									break;
								elseif(score1 >= 1800 and score2 >= 1800 and self.is_1v1) then
									if(score_diff<down_score_diff_radius) then
										meetCondition = true;
									end
								elseif( max_allowed_pvp_score_diff and score_diff<=max_allowed_pvp_score_diff )  then
									if(self.is_2v2) then
										if(score_diff<down_score_diff_radius) then
											meetCondition = true;
										else
											meetCondition = false;
										end
									else
										meetCondition = true;
									end
								end
							elseif(System.options.version == "teen") then
								--if( score2 < strict_pvp_score and score1 < strict_pvp_score) then
									---- if both in strict mapping
									--if( math_floor(score1/100) == math_floor(score2/100)) then
										---- we may find a good match. continue
									--else
										---- break immediately
										--break;
									--end
								--elseif(score2 < strict_pvp_score) then
									---- break immediately if score2 is in strict match range while score 1 is not. 
									--break;
								--elseif( max_allowed_pvp_score_diff and score_diff>=max_allowed_pvp_score_diff )  then
									---- break immediately if native score differs a lot. 
									--break;
								--end

								if(timeover) then
									if(not closest_item) then
										closest_item = candidate_item;
									else
										if(closest_item.game_info.match_tick < game_info2.match_tick) then
											closest_item = candidate_item;
										end
							
									end
								else
									if(score_diff < down_score_diff_radius) then
										--meetCondition = true;
										if(not closest_item) then
											closest_item = candidate_item;
										else
											if(closest_item.game_info.match_tick < game_info2.match_tick) then
												closest_item = candidate_item;
											end
							
										end
									end
								end

								--if(score_diff<down_score_diff_radius) then
									--meetCondition = true;
								--end
							end


							--if( score2 < strict_pvp_score and score1 < strict_pvp_score) then
								---- if both in strict mapping
								--if( math_floor(score1/100) == math_floor(score2/100)) then
									---- we may find a good match. continue
								--else
									---- break immediately
									--break;
								--end
							--elseif(score2 < strict_pvp_score) then
								---- break immediately if score2 is in strict match range while score 1 is not. 
								--break;
							--elseif( max_allowed_pvp_score_diff and score_diff>=max_allowed_pvp_score_diff )  then
								---- break immediately if native score differs a lot. 
								--break;
							--end

			
							if(meetCondition) then
								-- we will forbid family members to match in a PvP duel. 
								-- and we will forbid two game owners to be best friend with one another. 
								if( game_info:can_make_match_with(game_info2) )  then
									local match_info = match_info:new();
									match_info.teams = {game_info, game_info2};
									self:DeleteGameItem(candidate_item);
									item = self:DeleteGameItem(item);
						
									matches = matches or {};
									matches[#matches+1] = match_info;
									count = count + 1;
									hHasFoundMatch = true;
									LOG.std(nil, "system", "GSL_LobbyMatchMaker", "accurate match found with score %.2f %.2f, score_diff(%.2f), down_score_diff_radius(%.2f): between owner %s %s", score1, score2, score_diff, down_score_diff_radius, tostring(game_info.owner_nid), tostring(game_info2.owner_nid));
									break;
								end
							end
						end
						candidate_item = game_array:next(candidate_item);
						if((not candidate_item) and closest_item and System.options.version == "teen") then
							if( game_info:can_make_match_with(closest_item.game_info) )  then
								local match_info = match_info:new();
								match_info.teams = {game_info, closest_item.game_info};
								self:DeleteGameItem(closest_item);
								item = self:DeleteGameItem(item);
						
								matches = matches or {};
								matches[#matches+1] = match_info;
								count = count + 1;
								hHasFoundMatch = true;
								local colse_game_info = closest_item.game_info;
								local close_score = colse_game_info:get_rank_score();
								LOG.std(nil, "system", "GSL_LobbyMatchMaker", "accurate match found with score %.2f %.2f, score_diff(%.2f), down_score_diff_radius(%.2f): between owner %s %s", score1, close_score, score1 - close_score, down_score_diff_radius, tostring(game_info.owner_nid), tostring(colse_game_info.owner_nid));
								break;
							end
						end
					end
				end
			end
			if(not hHasFoundMatch) then
				item = game_array:next(item);
			end
		end
	else
		
		local item = game_array:first();
		while (item) do
			local candidate_item = game_array:next(item);
			if(candidate_item) then
				LOG.std(nil, "system", "GSL_LobbyMatchMaker", "simple match found between owner %s %s", tostring(item.game_info.owner_nid), tostring(candidate_item.game_info.owner_nid));

				local match_info = match_info:new();
				match_info.teams = {item.game_info, candidate_item.game_info};
				self:DeleteGameItem(candidate_item);
				item = self:DeleteGameItem(item);
						
				matches = matches or {};
				matches[#matches+1] = match_info;
				count = count + 1;
			else
				break;
			end
		end
	end
	
	return matches, count;
end

-----------------------
-- the singleton class
------------------------
local MatchMaker = commonlib.gettable("Map3DSystem.GSL.Lobby.MatchMaker");

-- get an array of candidates map.
function MatchMaker.GetCandidates(game_key)
	if(game_key) then
		local candidates = game_candidates[game_key];
		if(not candidates) then
			-- id_map is mapping from id to game_info, so that we can easily find if a given game_info already exist in the match.  
			candidates = MatchCandidates:new();
			game_candidates[game_key] = candidates;
			if(game_key:match("1v1")) then
				candidates.is_1v1 = true;
			elseif(game_key:match("2v2")) then
				candidates.is_2v2 = true;
			end
		end
		return candidates;
	end
end

-- whether the two game can make a match 
-- @param game_template: optional game template, usually nil. only used on first creation
function MatchMaker.AddGame(game_info, game_template)
	local candidates = MatchMaker.GetCandidates(game_info:get_keyname());
	if(candidates) then
		if(game_template) then
			candidates.match_method = game_template.match_method
		end
		candidates:AddGame(game_info);
	end
end

-- remove a given game
function MatchMaker.RemoveGame(game_info)
	local candidates = MatchMaker.GetCandidates(game_info:get_keyname());
	if(candidates) then
		candidates:RemoveGame(game_info);
	end
end


-- this function is called by the lobby_server every few seconds to find matches from waiting games.
-- @param lobby_server: the lobby server
-- @return: return the matches found. it may be nil, if there is no match found.
function MatchMaker.FrameMove(lobby_server)
	if(System.options.version == "kids") then
		MatchMaker.init(lobby_server);
		--MatchMaker.GenerateVirtualTeam(lobby_server)
		MatchMaker.Generate3V3Candidates(lobby_server)
	end
	local matches;
	local game_key, candidates;
	for game_key, candidates in pairs(game_candidates) do
		--echo("game_key");
		--echo(game_key);
		--if(candidates.id_map) then
			--echo("candidates.id_map value");
			--echo(type(candidates.id_map));
			--echo(candidates.id_map);
		--else
			--echo("candidates.id_map is nil");
		--end
		matches = candidates:FrameMove(lobby_server, matches);
	end
	
	--for i = 1,#game_info_ids_for_3v3 do
		--local game_id = game_info_ids_for_3v3[i];
		--lobby_server.games[game_id] = nil;
	--end
		
	return matches;
end

local one_team_key_name = "HaqiTown_LafeierCastle_PVP_OneTeam";
local one_team_world_name = "HaqiTown_LafeierCastle_PVP_OneTeam";

local two_team_key_name = "HaqiTown_LafeierCastle_PVP_TwoTeam";
local two_team_world_name = "HaqiTown_LafeierCastle_PVP_TwoTeam";

local three_team_key_name = "HaqiTown_LafeierCastle_PVP_ThreeTeam";
local three_team_world_name = "HaqiTown_LafeierCastle_PVP_ThreeTeam";

local pvp_3v3_key_name = "HaqiTown_LafeierCastle_PVP_Matcher";
local pvp_3v3_worldname = "HaqiTown_LafeierCastle_PVP_Matcher";


--local one_team_key_name = "HaqiTown_FairPlayArena1v1Practice_low";
--local one_team_world_name = "HaqiTown_TrialOfChampions_Amateur1v1";
--
--local two_team_key_name = "HaqiTown_FairPlayArena4v4Practice_low";
--local two_team_world_name = "HaqiTown_TrialOfChampions_Amateur";
--
--local pvp_3v3_key_name = "HaqiTown_FairPlayArena4v4Practice_high";
--local pvp_3v3_worldname = "HaqiTown_TrialOfChampions_Intermediate";

local pvp_3v3_game_settings;
--local pvp_3v3_game_settings = {
	--keyname = pvp_3v3_key_name,
	--worldname = pvp_3v3_worldname,
	--game_type = "PvP",
	--max_players = 3,
	--min_level = 48,
	--max_level = 55,
	--leader_text = "",
	--requirement_tag = "storm|fire|life|death|ice",	
--}

function MatchMaker.init(lobby_server)
	if(not MatchMaker.inited) then
		
		local game_tmpl = lobby_server:GetGameTemplate(pvp_3v3_key_name)

		pvp_3v3_game_settings = 
		{
			name = game_tmpl.name or "",
			keyname = game_tmpl.keyname,
			worldname = game_tmpl.worldname,
			game_type = game_tmpl.game_type,
			min_level = game_tmpl.min_level,
			max_level = game_tmpl.max_level,
			max_players = game_tmpl.max_players,
			leader_text = "",
			requirement_tag = "storm|fire|life|death|ice",
		}


		MatchMaker.inited = true;
	end
end

function MatchMaker.TranslateOneTeam(three_player_items, two_player_items,one_player_items,lobby_server)
	if(three_player_items) then
		local three_player_game_info = three_player_items[1].game_info;

		local game_info = lobby_server:CreateNewTemporaryGame(pvp_3v3_game_settings);

		if(game_info) then
			local nid,user;

			-- add the three_plyer_team user
			local three_player_users = three_player_game_info.players;

			for nid,user in pairs(three_player_users) do
				game_info:add_user(nid, user)
			end

			---- if the two player team ,the total gear_score add 100;
			--local three_player_gear_score = game_info:get_gear_score();
			--game_info:set_gear_score(three_player_gear_score + 50);

			game_info.need_delete_game_info_ids = game_info.need_delete_game_info_ids or {};
			game_info.need_delete_game_info_ids[three_team_key_name] = game_info.need_delete_game_info_ids[three_team_key_name] or {};
			game_info.need_delete_game_info_ids[three_team_key_name][three_player_game_info.id] = true;

			return true,game_info;

		else
			LOG.std(nil, "error", "lobbyserver", "failed to create game for PvP3v3,persistent_games_filename:%s",lobby_server.persistent_games_filename);
		end
	end

	if(two_player_items and one_player_items) then
		local two_player_item = two_player_items[1];
		local one_player_item = one_player_items[1];

		local two_player_game_info = two_player_items[1].game_info;
		local one_player_game_info = one_player_items[1].game_info;

	
		
		local meetCondition = false;

		--judge the two_player_item and one_player_item can generate a new pvp3v3 game_info;

		local meetCondition_school = false;
		local one_player_school = one_player_game_info:get_school();
		local player;
		for _,player in pairs(two_player_game_info.players) do
			if(player.school ~= one_player_school) then
				meetCondition_school = true;
				break;
			end
		end
		--if(meetCondition_school) then
			--echo("meetCondition_school is meet condition!");
		--end
		--local meetCondition_win_rate = false;		
		--local one_player_rate = one_player_game_info:get_pvp_3v3_win_rate();
		--local two_player_rate = two_player_game_info:get_pvp_3v3_win_rate();
--
		--if(two_player_rate <= 60 and two_player_rate > 55) then
			--if(one_player_rate >= 40 and one_player_rate < 45) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 55 and two_player_rate > 53) then
			--if(one_player_rate >= 45 and one_player_rate < 47) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 53 and two_player_rate > 50) then
			--if(one_player_rate >= 47 and one_player_rate < 50) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 50 and two_player_rate > 47) then
			--if(one_player_rate >= 50 and one_player_rate < 53) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 47 and two_player_rate > 45) then
			--if(one_player_rate >= 53 and one_player_rate < 55) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 45 and two_player_rate >= 40) then
			--if(one_player_rate >= 55 and one_player_rate <= 60) then
				--meetCondition_win_rate = true;
			--end
		--end
		--if(meetCondition_win_rate) then
			--echo("meetCondition_win_rate is meet condition!");
		--else
			--echo("meetCondition_win_rate is not meet condition!");
			--echo(two_player_rate);
			--echo(one_player_rate);
		--end
		--if(math.abs(one_player_rate + two_player_rate - 100) <= 3) then
			--meetCondition_win_rate = true;
		--end

		local meetCondition_gear_score = false;
		local one_player_gear_score = one_player_game_info:get_gear_score();
		local two_player_gear_score = two_player_game_info:get_gear_score();

		if(math.abs(one_player_gear_score - two_player_gear_score) <= 200) then
			meetCondition_gear_score = true;
		end

		--if(meetCondition_gear_score) then
			--echo("meetCondition_gear_score is meet condition!");
		--else
			--echo("meetCondition_gear_score is not meet condition!");
			--echo(one_player_gear_score);
			--echo(two_player_gear_score);
		--end

		--if(meetCondition_school and meetCondition_win_rate and meetCondition_gear_score) then
		if(meetCondition_school and meetCondition_gear_score) then
			meetCondition = true;
		end
		--echo("111111111111111111111");
		if(two_player_items) then
			--echo(two_player_items);
		end
		if(one_player_items) then
			--echo(one_player_items);
		end
		--echo(meetCondition);
		if(meetCondition) then

			local game_info = lobby_server:CreateNewTemporaryGame(pvp_3v3_game_settings);

			if(game_info) then
				local nid,user;

				-- add the two_plyer_team user
				local two_player_users = two_player_game_info.players;

				for nid,user in pairs(two_player_users) do
					game_info:add_user(nid, user)
				end


				-- add the one_plyer_team user

				local one_player_users = one_player_game_info.players;

				--echo("one_player_users")
				if(one_player_users) then
					--echo(one_player_users);
				end

				for nid,user in pairs(one_player_users) do
					game_info:add_user(nid, user)
				end

				-- if the two player team ,the total gear_score add 100;
				local three_player_gear_score = game_info:get_gear_score();
				game_info:set_gear_score(three_player_gear_score + 50);

				game_info.need_delete_game_info_ids = game_info.need_delete_game_info_ids or {};
				game_info.need_delete_game_info_ids[two_team_key_name] = game_info.need_delete_game_info_ids[two_team_key_name] or {};
				game_info.need_delete_game_info_ids[two_team_key_name][two_player_game_info.id] = true;
				game_info.need_delete_game_info_ids[one_team_key_name] = game_info.need_delete_game_info_ids[one_team_key_name] or {};
				game_info.need_delete_game_info_ids[one_team_key_name][one_player_game_info.id] = true;

				return true,game_info;

			else
				LOG.std(nil, "error", "lobbyserver", "failed to create game for PvP3v3,persistent_games_filename:%s",lobby_server.persistent_games_filename);
			end
		end
	end


	if(#one_player_items == 3) then
		
		local meetCondition = false;

		--judge these one_player_items can generate a new pvp3v3 game_info;

		local meetCondition_school = false;
		local school;
		for i = 1,3 do
			local one_player_school = one_player_items[i].game_info:get_school();

			if(not school) then
				school = one_player_school;
			elseif(school ~= one_player_school) then
				meetCondition_school = true;
				break;
			end
		end

		--if(meetCondition_school) then
			--echo("meetCondition_school is meet condition!");
		--end
		
		--local meetCondition_win_rate = false;		
		--local rate = {}
		--for i = 1,3 do
			--local one_player_win_rate = one_player_items[i].game_info:get_pvp_3v3_win_rate();
--
			--if(#rate == 0) then
				--table.insert(rate,one_player_win_rate);
			--else
				--for j = 1,#rate do
					--local win_rate_item = rate[j];
					--if(one_player_win_rate < win_rate_item) then
						--table.insert(rate,j,one_player_win_rate);
					--else
						--if(j == #rate) then
							--table.insert(rate,one_player_win_rate);
						--end
					--end
--
				--end
			--end
		--end
--
		--local two_player_rate = (rate[1]+rate[3])/2;
		--local one_player_rate = rate[2];
--
		--if(two_player_rate <= 60 and two_player_rate > 55) then
			--if(one_player_rate >= 40 and one_player_rate < 45) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 55 and two_player_rate > 53) then
			--if(one_player_rate >= 45 and one_player_rate < 47) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 53 and two_player_rate > 50) then
			--if(one_player_rate >= 47 and one_player_rate < 50) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 50 and two_player_rate > 47) then
			--if(one_player_rate >= 50 and one_player_rate < 53) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 47 and two_player_rate > 45) then
			--if(one_player_rate >= 53 and one_player_rate < 55) then
				--meetCondition_win_rate = true;
			--end
		--elseif(two_player_rate <= 45 and two_player_rate >= 40) then
			--if(one_player_rate >= 55 and one_player_rate <= 60) then
				--meetCondition_win_rate = true;
			--end
		--end

		--if(meetCondition_win_rate) then
			--echo("meetCondition_win_rate is meet condition!");
		--else
			--echo("meetCondition_win_rate is not meet condition!");
			--echo(rate);
		--end

		--local rate_offset = math.abs((rate[1]+rate[3])/2 + rate[2] - 100);
		--if(rate_offset <= 3) then
			--meetCondition_win_rate = true;
		--end

		local meetCondition_gear_score = false;

		local gear_score = {}
		for i = 1,3 do
			local one_player_gear_score = one_player_items[i].game_info:get_gear_score();
			if(#gear_score == 0) then
				table.insert(gear_score,one_player_gear_score);
			else
				for j = 1,#gear_score do
					local gear_score_item = gear_score[j];
					if(one_player_gear_score < gear_score_item) then
						table.insert(gear_score,j,one_player_gear_score);
						break;
					else
						if(j == #gear_score) then
							table.insert(gear_score,one_player_gear_score);
						end
					end

				end
			end
		end
		if(math.abs(gear_score[1]-gear_score[3]) <= 200) then
			local gear_score_offset = math.abs((gear_score[1]+gear_score[3])/2 - gear_score[2]);
			if(gear_score_offset <= 200) then
				meetCondition_gear_score = true;
			end	
		end
		
		--if(meetCondition_gear_score) then
			--echo("meetCondition_gear_score is meet condition!");
		--else
			--echo("meetCondition_gear_score is not meet condition!");
			--echo(gear_score);
		--end

		--if(meetCondition_school and meetCondition_win_rate and meetCondition_gear_score) then
		if(meetCondition_school and meetCondition_gear_score) then
			meetCondition = true;
		end

		if(meetCondition) then

			local game_info = lobby_server:CreateNewTemporaryGame(pvp_3v3_game_settings);

			if(game_info) then
				local nid,user;

				-- add the one_plyer_team user

				for i = 1,3 do
					local one_player_item = one_player_items[i];

					local one_player_users = one_player_item.game_info.players;

					for nid,user in pairs(one_player_users) do
						game_info:add_user(nid, user)
					end

					game_info.need_delete_game_info_ids = game_info.need_delete_game_info_ids or {};
					game_info.need_delete_game_info_ids[one_team_key_name] = game_info.need_delete_game_info_ids[one_team_key_name] or {};
					game_info.need_delete_game_info_ids[one_team_key_name][one_player_item.game_info.id] = true;

				end			

				return true,game_info;

			else
				LOG.std(nil, "error", "lobbyserver", "failed to create game for PvP3v3,persistent_games_filename:%s",lobby_server.persistent_games_filename);
			end
		end
	end


	return false,nil;
end

function MatchMaker.Generate3V3Candidates(lobby_server)
	game_candidates[pvp_3v3_key_name] = nil;
	game_info_ids_for_3v3 = {};
	local game_key_3v3_one_player = one_team_key_name;
	local game_key_3v3_two_player = two_team_key_name;
	local game_key_3v3_three_player = three_team_key_name;
	

	local candidate_one_player = MatchMaker.GetCandidates(game_key_3v3_one_player);
	local game_array_one_player;
	if(candidate_one_player.game_array) then

		game_array_one_player = candidate_one_player.game_array:Clone();

		local size = game_array_one_player:size();
		if(size >= 4) then
			local item = game_array_one_player:first();
			local nSize = game_array_one_player:size();
			local randPercent = 0.5;
			for i = 1, nSize do
				if(item) then
					if(math.random()<randPercent) then
						local old_item = item;
						item = game_array_one_player:remove(item);
						game_array_one_player:push_front(old_item);
					else
						item = item.next;
					end
				else
					break;
				end
			end
		end
		
	end

	local candidate_two_player = MatchMaker.GetCandidates(game_key_3v3_two_player);
	local game_array_two_palyer;
	if(candidate_two_player.game_array) then
		game_array_two_palyer = candidate_two_player.game_array:Clone();
	end

	local candidate_three_player = MatchMaker.GetCandidates(game_key_3v3_three_player);
	local game_array_three_palyer;
	if(candidate_three_player.game_array) then
		game_array_three_palyer = candidate_three_player.game_array:Clone();
	end


	local item1 = {};
	local item2 = {};

	if(game_candidates[game_key_3v3_one_player] and game_candidates[game_key_3v3_two_player]) then
		
		--local game_array_one_player = candidate_two_player.game_array;
		local next_item;
		if(game_array_two_palyer) then
			
			local two_player_item = next_item or game_array_two_palyer:first();
			while (two_player_item) do
				local beFoundMeetCondition = false;				
				
				local one_player_item = game_array_one_player:first();


				local canTranslateOneTeam;
				while(one_player_item) do
					--echo("222222222222222");
					if(one_player_item and one_player_item.info and one_player_item.info.players) then
						--echo(one_player_item.info.players);
					end
					item1[1], item2[1] = two_player_item, one_player_item;
					local canTranslateOneTeam,new_game_info = MatchMaker.TranslateOneTeam(nil,item1,item2,lobby_server);
					if(canTranslateOneTeam and new_game_info) then
						--echo("333333333333333333333");
						table.insert(game_info_ids_for_3v3,new_game_info.id);
						next_item = two_player_item.next;

						two_player_item = game_array_two_palyer:remove(two_player_item);
						game_array_one_player:remove(one_player_item);

						local game_template = lobby_server:GetGameTemplate(pvp_3v3_key_name)
						MatchMaker.AddGame(new_game_info, game_template)
						beFoundMeetCondition = true;
						break;
					else
						one_player_item = game_array_one_player:next(one_player_item);
					end
					--one_player_item = game_array_one_player:next(one_player_item);
				end
				if(not beFoundMeetCondition) then
					two_player_item = game_array_two_palyer:next(two_player_item);
				end
				
			end
		end
	end

	if(game_candidates[game_key_3v3_one_player]) then
		--local candidate_one_player = MatchMaker.GetCandidates(game_key_3v3_one_player);
		--local game_array_one_player;
		--if(candidate_one_player.game_array) then
			--game_array_one_player = candidate_one_player.game_array:Clone();
		--end

		local items = {};

		local next_item;
		while(game_array_one_player:size() >= 3) do
			local beFoundMeetCondition = false;

			local first_item = next_item or game_array_one_player:first();
			local second_item = first_item.next;
			if(not second_item) then
				break;
			end
			local third_item = second_item.next;
			if(not third_item) then
				break;
			end
				
			while(second_item.next) do
				third_item = second_item.next;

				while(third_item) do
					items[1], items[2], items[3] = first_item,second_item,third_item;

					local canTranslateOneTeam,new_game_info = MatchMaker.TranslateOneTeam(nil,nil,items,lobby_server);

					if(canTranslateOneTeam and new_game_info) then
						table.insert(game_info_ids_for_3v3,new_game_info.id);
						if(first_item.next ~= second_item) then
							next_item = first_item.next;
						elseif(second_item.next ~= third_item) then
							next_item = second_item.next;
						else
							next_item = third_item.next;
						end

						game_array_one_player:remove(first_item);
						game_array_one_player:remove(second_item);
						game_array_one_player:remove(third_item);

						local game_template = lobby_server:GetGameTemplate(pvp_3v3_key_name)
						MatchMaker.AddGame(new_game_info, game_template)
						beFoundMeetCondition = true;
						break;
					else
						third_item = third_item.next;
					end
							
				end	

				if(beFoundMeetCondition) then
					break;
				else
					second_item = second_item.next;
				end
			end

			if(beFoundMeetCondition) then
		
			else
				game_array_one_player:remove(first_item);
			end
		end
	end
	
	if(game_candidates[game_key_3v3_three_player]) then
		local next_item = game_array_three_palyer:first();
		while (next_item) do
			local canTranslateOneTeam,new_game_info = MatchMaker.TranslateOneTeam({next_item},nil,nil,lobby_server);
			if(canTranslateOneTeam and new_game_info) then
				local game_template = lobby_server:GetGameTemplate(pvp_3v3_key_name)
				MatchMaker.AddGame(new_game_info, game_template)
				next_item = next_item.next;
			end
		end
	end
end

--- test 3v3 match 

local one_player_team = {
	--"333333333",
	--"111111111",
	--"555555555",
	--"777777777",
	};

local two_player_team = {
	--{"222222222","444444444",},
	--{"666666666","888888888",}
	};

local last_virtual_array = {};

local password = "111111111"

function MatchMaker.GenerateVirtualTeam(lobby_server)
	
	if(not MatchMaker.loadedVirtualCandiates) then
		local file = "config/Aries/Combat/PvP3v3TestData.xml";
		local xmlRoot = ParaXML.LuaXML_ParseFile(file);
		if(xmlRoot) then
			local one_team_players;
			for one_team_players in commonlib.XPath.eachNode(xmlRoot, "/teams/oneteam/players") do
				--echo("111111111111111111111111111111111111");
				--echo(one_team_players);
				local team = {};
				local player;
				for player in commonlib.XPath.eachNode(one_team_players, "/player") do
					local attr = player.attr;
					local item = {};
					item.nid	= tonumber(attr.nid);
					item.level	= tonumber(attr.level);
					item.score	= tonumber(attr.score);
					item.school = attr.school;
					item.gear_score = tonumber(attr.gear_score);
					item.pvp_3v3_win_rate = tonumber(attr.pvp_3v3_win_rate);
					table.insert(team,item);
				end
				table.insert(one_player_team,team);
			end
			--echo(one_player_team);
			local two_team_players;
			for two_team_players in commonlib.XPath.eachNode(xmlRoot, "/teams/twoteam/players") do
				--echo("22222222222222222222222222222222222");
				--echo(two_team_players);
				local team = {};
				local player
				for player in commonlib.XPath.eachNode(two_team_players, "/player") do
					local attr = player.attr;
					local item = {};
					item.nid	= tonumber(attr.nid);
					item.level	= tonumber(attr.level);
					item.score	= tonumber(attr.score);
					item.school = attr.school;
					item.gear_score = tonumber(attr.gear_score);
					item.pvp_3v3_win_rate = tonumber(attr.pvp_3v3_win_rate);
					table.insert(team,item);
				end
				table.insert(two_player_team,team);
			end
			--echo(two_player_team);
		end
		MatchMaker.loadedVirtualCandiates = true;
	end
	if(true) then
		if(next(last_virtual_array)) then
			if(last_virtual_array[one_team_key_name]) then
				local candidates = MatchMaker.GetCandidates(one_team_key_name);
				local game_array = candidates.game_array;
				if(game_array:size() >= 0) then
					local item = game_array:first();
					while (item) do
						local game_info = item.game_info;
						local id = game_info.id;
						if(last_virtual_array[one_team_key_name][id]) then
							item = candidates:DeleteGameItem(item);
						else
							item = game_array:next(item);
						end
					end
				end
			end
			
			if(last_virtual_array[two_team_key_name]) then
				local candidates = MatchMaker.GetCandidates(two_team_key_name);
				local game_array = candidates.game_array;
				if(game_array:size() >= 0) then
					local item = game_array:first();
					while (item) do
						local game_info = item.game_info;
						local id = game_info.id;
						if(last_virtual_array[two_team_key_name][id]) then
							item = candidates:DeleteGameItem(item);
						else
							item = game_array:next(item);
						end
					end
				end
			end		
		end

		last_virtual_array = {}

		local keyname = one_team_key_name;
		local worldname = one_team_world_name
		--echo("find error");
		for i = 1,#one_player_team do
			--echo("genereate virtual data one player team start");
			
			local game_settings = {
				keyname = keyname,
				worldname = worldname,
				game_type = "PvP",
				max_players = 1,
				min_level = 48,
				max_level = 55,
				is_persistent = true,
				leader_text = "",
				requirement_tag = "storm|fire|life|death|ice",	
			}

			local game_info = lobby_server:CreateNewGame(game_settings);

			-- add the first user
			--local user_info = player_info:new({nid = nid, score=game_settings.score, school=game_settings.school, level = game_settings.level, fid = game_settings.family_id, bf = game_settings.best_friends, proxy_nid=proxy_nid, serverid = game_settings.serverid})
			local players = one_player_team[i];
			for j = 1,#players do
				local player = players[j];
				local nid = player.nid; 
				local user_info = player_info:new(player)
				if(user_info) then
					game_info:add_user(nid, user_info)
				end
			end
			
			
			
			last_virtual_array[keyname] = last_virtual_array[keyname] or {};
			--table.insert(last_virtual_array[key],game_info.id)
			last_virtual_array[keyname][game_info.id] = true;
			

			local game_template = lobby_server:GetGameTemplate(keyname)
			MatchMaker.AddGame(game_info, game_template)

--			local candidates = MatchMaker.GetCandidates(keyname);
			--echo("genereate virtual data one player team end");
			--echo(candidates.id_map);
		end


		local keyname = two_team_key_name;
		local worldname = two_team_world_name
		for i = 1,#two_player_team do
			password = password + 1;
			--echo("genereate virtual data two player team start");
			local game_settings = {
				keyname = keyname,
				worldname = worldname,
				game_type = "PvP",
				max_players = 2,
				min_level = 48,
				max_level = 55,
				leader_text = "",
				is_persistent = true,
				requirement_tag = "storm|fire|life|death|ice",	
				password = password,
			}

			local game_info = lobby_server:CreateNewGame(game_settings);


			local players = two_player_team[i];
			for j = 1,#players do
				local player = players[j];
				local nid = player.nid; 
				local user_info = player_info:new(player)
				if(user_info) then
					game_info:add_user(nid, user_info)
				end
			end

			-- add the first user
			--local user_info = player_info:new({nid = nid, score=game_settings.score, school=game_settings.school, level = game_settings.level, fid = game_settings.family_id, bf = game_settings.best_friends, proxy_nid=proxy_nid, serverid = game_settings.serverid})
			

			local game_template = lobby_server:GetGameTemplate(keyname)
			MatchMaker.AddGame(game_info, game_template)
			--echo(keyname);
			local candidates = MatchMaker.GetCandidates(keyname);
			--echo("genereate virtual data two player team end");
			--echo(game_candidates[keyname]["id_map"]);
			--echo(candidates.id_map);
			last_virtual_array[keyname] = last_virtual_array[keyname] or {};
			last_virtual_array[keyname][game_info.id] = true;
			--table.insert(last_virtual_array[key],game_info.id)

		end

		MatchMaker.initVirtualCandidated = true;
	end	
end



local function GetNewGameArray(keyname,worldname,nid)
	--- keyname:HaqiTown_FairPlayArena1v1Practice_low, HaqiTown_FairPlayArena4v4Practice_low
	local table={
		nSize=1,
		tail={
			game_info={
				game_type="PvP",
				id=7,
				last_user_tick=curtime,
				max_players=1,
				min_level=48,
				players={
					[nid]={
						level=55,
						rank_index=1,
						school="storm",
						proxy_nid="1015",
						nid=nid,
						serverid="224.",
						score=1700,
					},
				},
				owner_nid=nid,
				score=1700,
				status="match_making",
				leader_text="",
				mode=1,
				keyname=keyname,
				serverid="224.",
				requirement_tag="storm|fire|life|death|ice",
				worldname=worldname,
				max_level=55,
				region_id=0,
				name="一起去PK吧！",
				player_count=1,
			},
		},
		head={
			game_info={
				game_type="PvP",
				id=7,
				last_user_tick=curtime,
				max_players=1,
				min_level=48,
				players={
					[nid]={
						level=55,
						rank_index=1,
						school="storm",
						proxy_nid="1015",
						nid=nid,
						serverid="224.",
						score=1700,
					},
				},
				owner_nid=nid,
				score=1700,
				status="match_making",
				leader_text="",
				mode=1,
				keyname=keyname,
				serverid="224.",
				requirement_tag="storm|fire|life|death|ice",
				worldname=worldname,
				max_level=55,
				region_id=0,
				name="一起去PK吧！",
				player_count=1,
			},
		},
	}
	return table;
end


