--[[
Title: Lobby server proxy
Author(s): LiXizhi
Date: 2011/3/6
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyServerProxy.lua");
local proxy = Map3DSystem.GSL.Lobby.GSL_LobbyServerProxy:new();
-----------------------------------------------
]]
local tostring = tostring;
local GSL_LobbyServerProxy = commonlib.gettable("Map3DSystem.GSL.Lobby.GSL_LobbyServerProxy");
local LOG = LOG;
local format=format;
-- the global instance, because there is only one instance of this object
local g_singleton;
-- whether to output log by default. 
local enable_debug_log = false;
local LobbyServer_nid = "lobbyserver";
local toserver_msg_template = {};
-- mapping from nid to true
local user_map = {};

local lobbyserver_script = "script/apps/GameServer/LobbyService/GSL_LobbyServer.lua";
GSL_LobbyServerProxy.LobbyServer_script = LobbyServer_nid..":"..lobbyserver_script;
GSL_LobbyServerProxy.reply_file = "script/apps/GameServer/LobbyService/GSL_LobbyClient.lua";
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

function GSL_LobbyServerProxy:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	-- enable debugging here
	o.debug_stream = o.debug_stream or enable_debug_log;
	return o
end

-- get the global singleton.
function GSL_LobbyServerProxy.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_LobbyServerProxy:new();

		-- register the system event
		NPL.load("(gl)script/apps/GameServer/GSL_system.lua");
		Map3DSystem.GSL.system:AddEventListener("OnUserDisconnect", g_singleton.OnUserDisconnect);
	end
	return g_singleton;
end

-- whenever a user leaves
function GSL_LobbyServerProxy.OnUserDisconnect(system, msg)
	local user_nid = msg.nid;
	if(user_nid and user_map[user_nid])then
		user_map[user_nid] = nil;
		--LOG.std(nil, "debug","lobbyserverproxy", "my_nid:%s signed out", user_nid);
		-- connection to server may be lost
		GSL_LobbyServerProxy.GetSingleton():SendToServer(user_nid, "user_connection_lost", nil)
	end
end

-- do some one time init here
-- @param msg: {my_nid=string, lobbyserver_nid = string, LobbyServer_threadname=string, debug_stream="true"}
function GSL_LobbyServerProxy:init(msg)
	self.my_nid = msg.my_nid;
	LobbyServer_nid = msg.lobbyserver_nid or LobbyServer_nid;
	toserver_msg_template.proxy_nid = self.my_nid;
	self.proxy_thread_name = msg.proxy_thread_name;
	if(msg.debug_stream == "true") then
		self.debug_stream = true;
	end
	if(LobbyServer_nid ~= self.my_nid) then
		self.LobbyServer_script = format("(%s)%s:%s", msg.LobbyServer_threadname or "1", LobbyServer_nid, lobbyserver_script);

		-- create a timer that periodically ping the lobby server. 
		self.lobby_ping_timer = self.lobby_ping_timer or commonlib.Timer:new({callbackFunc = function(timer)
			self:SendToServer(0, "ping")
		end})
		self.lobby_ping_timer:Change(300, 10000); -- ping every 10 seconds
	else
		self.LobbyServer_script = format("(%s)%s", msg.LobbyServer_threadname or "1", lobbyserver_script);
	end

	self.reply_file = msg.reply_file or self.reply_file; -- "to which client file to reply"
	LOG.std(nil, "system","lobbyserverproxy", "started: lobby proxy: %s, my_nid:%s", LobbyServer_nid, self.my_nid or "");
end

-- set a message from lobby proxy to lobby server
function GSL_LobbyServerProxy:SendToServer(user_nid, msg_type, msg_data,seq)
	if(self.debug_stream) then
		LOG.std(nil, "debug", "lobbyserverproxy", "send type %s: data:%s", tostring(msg_type), commonlib.serialize_compact(msg_data));
	end	
	toserver_msg_template.type = msg_type;
	toserver_msg_template.user_nid = user_nid;
	toserver_msg_template.msg = msg_data;
	toserver_msg_template.seq = seq;
	
	if( NPL.activate(self.LobbyServer_script, toserver_msg_template) ~=0 ) then
		-- connection to server may be lost
		LOG.std(nil, "warning", "lobbyserverproxy", "unable to send request to "..self.LobbyServer_script);
	end
end

local touser_msg_template = {};
local lost_connection_msg_template = {};
function GSL_LobbyServerProxy:SendToUser(user_nid, msg_type, msg_data, seq)
	-- game server address
	local user_address = format("%s:%s", user_nid, self.reply_file);

	if(self.debug_stream) then
		LOG.std(nil, "debug", "lobbyserverproxy", "send type %s: data:%s", tostring(msg_type), commonlib.serialize_compact(msg_data));
	end	
	touser_msg_template.type = msg_type;
	touser_msg_template.msg = msg;
	touser_msg_template.seq = seq;
	if( NPL.activate(user_address, touser_msg_template) ~=0 ) then
		-- connection to server may be lost
		lost_connection_msg_template.nid = user_nid;
		self:OnUserDisconnect(lost_connection_msg_template);
	else
		user_map[user_nid] = true;
	end
end

-- this is a message from lobbyserver to this proxy
function GSL_LobbyServerProxy:handle_server_msg(msg_type, user_nid, msg_data, seq)
	if(msg_type == "ping") then
	elseif(msg_type == "s_chat") then
		-- broadcast to all gateway threads on this server
		NPL.activate("(main)script/apps/GameServer/GameServer.lua", {type="s_chat", msg=msg_data});
	elseif(msg_type == "fs_chat") then
		-- forward s_chat message to bbs server. This allows any game server to initiate a "s_chat" request to lobby server. 
		self:SendToServer(user_nid, "s_chat", msg_data, seq);
	elseif(msg_type == "s_shared_loot") then
		-- the lobby server has confirmed the loot. so do it here. 
		NPL.activate(format("(%s)script/apps/GameServer/GSL_system.lua", msg_data.threadname or "main"), {type="s_shared_loot", msg=msg_data});
		
	elseif(msg_type == "fs_shared_loot") then
		-- forward s_shared_loot message to bbs server. This allows any game server to initiate a "s_shared_loot" request to lobby server. 
		self:SendToServer(user_nid, "s_shared_loot", msg_data, seq);
	elseif(user_nid == 0) then
		self:SendToServer(user_nid, msg_type, msg_data, seq);
	else
		self:SendToUser(user_nid, msg_type, msg_data, seq)
	end
end

-- this is a message from client to this proxy
function GSL_LobbyServerProxy:handle_client_msg(msg_type, user_nid, msg_data, seq)
	--if(msg_type == "leave_game" or msg_type == "create_game" or msg_type == "join_game" or msg_type == "start_game") then
	if(msg_type) then
		self:SendToServer(user_nid, msg_type, msg_data, seq);
	end
end

local function activate()
	local msg = msg;
	local self = GSL_LobbyServerProxy.GetSingleton();

	if(not msg.nid) then
		if(msg.tid) then
			return
		else
			-- local message
			if(msg.type == "init") then
				self:init(msg);
				return
			else
				self:handle_server_msg(msg.type, msg.user_nid, msg.msg, msg.seq);
				return
			end 
		end
	end
	
	if(msg.nid == LobbyServer_nid) then
		self:handle_server_msg(msg.type, msg.user_nid, msg.msg, msg.seq)
	else
		self:handle_client_msg(msg.type, msg.nid, msg.msg, msg.seq)
	end
end
NPL.this(activate)