---++ Lobby Server in GSL
Author: LiXizhi
Date: 2010.3.6

---+++ Overview
A lobby is in essence a collection of games, where players can create, join, leave or watch. 

game_info = {
	id,
	-- the player nid who can change game settings, kick user and issue the start of the game. 
	owner_nid,
	password,
	max_players,
	name,
	game_type, -- a string that may be PvE, PvP, PvP_rank
	-- the current game flags: 1 locked, 2 closed, 4 in progress
	status_flag,
	-- mapping from player nid to player_info,
	players,
	-- it can be "manual", "auto". if "auto", the game will start automatically when max_players is reached. 
	start_mode,
	-- if true, only friends of the owner can join the game. 
	friends_join_only,
}

player_info = {
	nid,
	-- players in a game can be devided in to teams. Each team can has at most 4 players. Such as in a pvp game, one side has team_index 1, the other is 2. 
	team_index,
	display_name,
	school,
	level,
	-- a string of ready, 
	status_flag,
}

---+++ Requirements
   * Cross servers: games can connect users connected via multiple game servers
   * Auto match and quick join: we can find the most suitable game for a given player according to its level, school, ranking, etc. 
   * Fast game browsing and filtering: the client can filter the view list of currently open games in the lobby. 
   * Auto start and auto create: this ensures that minimum click is requirement in order to launch a team game.

---+++ Architecture
There are four logics units: a lobby client, a lobby  server proxy, a game gridnode, and a lobby server

lobby client is part of the game client, and is connected with a game server. 
Each game server hosts a lobby server proxy, which acts as a broker between the client and the real lobby server.
The real lobby server is a global place that stores all the game_infos in the lobby. 

---+++ Message Sequence Graph
A GSL_client is always associated with an instance of GSL_LobbyClient.

---++++ View or refresh available rooms according to a given rule. 
Client                                 GameServer                           LobbyServer
GSL_LobbyClient: view_game request ---> GSL_LobbyServerProxy
                                          if there is a cached result, return it immediately. 
										  if not: send view_game request  ---> GSL_LobbyServer
display the in mcml UI page        <---  Cache result by url             <--- GSL_LobbyServer 

---++++ Create a new game 
Client                                 GameServer                           LobbyServer
create_game request             --->    if the user is already in a game  ---> leave_game request
                                                                          <--- send back event to all other members
                                        and then						  ---> create_game request
												                          <--- reply with new game id 
---++++ Leave a new game 
Client                                 GameServer                           LobbyServer
leave_game request             --->    remove from local last room cache   ---> leave_game request

---++++ Client connection lost
                                       GameServer                              LobbyServer
									   if the user is already in a game  ---> leave_game request
									                                     <--- send back event to all other members
---++++ Join a game 
Client                                 GameServer                           LobbyServer
join_game request             --->    if the user is in a different game  ---> leave_game request
                                        and then						  ---> join_game request
												                          <--- reply with if success(maybe full)
																		  <---join_game event to all other members

---++++ Start a PvE game 
Only the game owner can start the game. Once the game is started no other user can join the game any more. 
The start_game request may fail if any of the said players are no longer responsive. 

Client                                 GameServer                           LobbyServer
game owner: start_game request             --->    just forward             ---> start_game(owner) request, game is in started state
                                                                              generate gridnode_key and set to game_info
game owner: start_game_ack        <-- just forward                       <--- and send "start_game_ack" to all players
  - game owner enters the game 
All other players: start_game_ack(pending with key)  <-- just forward   
  - Display confirm dialog

(within 2 mins, if other players clicks yes) 
  - enter the game world with gridnode_key
  - send "team_join" to game owner  --------->----------------------> IMServer
Game owner will receive "team_join" request:  <--------------- <----- IMServer
  - game owner automatically accept team member  ----> ------------>  IMServer
  (So the team relationship is established)

---++++ Start a PvP game   
Only the game owner can put the game into the PvP match making queue by sending "match_making" msg to server. Once the game is in "match_making" status, 
any user can still leave or join the team after 5 seconds (The client ensures 5 seconds). 
When server process will try to make pairs in a frame move process. Once it has discovered a match, it will send "match_start" message to all users in the match with complete match_info.

Client                                 GameServer                           LobbyServer
[Client telling the server to enroll in a match making]
game owner: match_making request          --->    just forward             ---> add the game to MatchMaker for later processing. 
all users knows that we are in the match queue<-- just forward             <--- and send "match_making" to all players
(During the match making time, the users are still allowed to leave the current game. but the client better ensures that one can only do so after 5 seconds, etc)                                                                              

[Server telling the client that a match can be started]
all users know that match is started. <-- just forward             <--- and send "match_start" to all players with match_info as parameter

(within 2 mins, if other players clicks yes) 
  - enter the game world with gridnode_key
  - send "team_join" to game owner  --------->----------------------> IMServer
Game owner will receive "team_join" request:  <--------------- <----- IMServer
  - game owner automatically accept team member  ----> ------------>  IMServer
  (So the team relationship is established)
  


