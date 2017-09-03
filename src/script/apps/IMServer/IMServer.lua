--[[
Title: IM server
Author: LiXizhi
Date: 2009-7-20
-----------------------------------------------
NPL.load("(gl)script/apps/IMServer/IMServer.lua");
IMServer:Start();
-----------------------------------------------
]]

if(not IMServer) then  IMServer = {} end

-- default config settings
IMServer.config = {
	host = "127.0.0.1",
	port = "64001",
	nid = "1601",
    user_table_count="5000",
    roster_table_count="500",
    group_table_count="500",
	time_out="4",
	check_time_span="4",
    max_offline_msg_count="5",
    max_offline_group_msg_count="3",
	offline_msg_path="/usr/local/server/im/offline",
	group_path="/usr/local/server/im/group",
	public_files = "config/NPLPublicFiles.xml",
	game_server_script = "script/apps/IMServer/IMserver_broker.lua",
	load_family_info = "false",
	kick_online_group_member = "false";
};
-- default array of worker states and their attributes
IMServer.worker_states = {
-- this is both the runtime state name and the virtual world id
-- {name="1", },
};
IMServer.router_states = {};

-- for login
IMServer.router_script = "router1:script/apps/NPLRouter/NPLRouter.lua"
-- for ordinary messages
IMServer.router_dll = "router1:NPLRouter.dll"

IMUsers={};

-- write service log
function IMServer.log(...)
	-- TODO: 
end

-- load config from a given file. 
-- @param filename: if nil, it will be "config/IMServer.config.xml"
function IMServer:load_config(filename)
	filename = filename or "config/IMServer.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading game server config file %s\n", filename);
		return;
	end	
	
	-- read config and start server
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/IMServer/config")[1];
	if(config_node and config_node.attr) then
		commonlib.partialcopy(self.config, config_node.attr)
	end	

	-- set NPL attributes before starting the server. 
	local att = NPL.GetAttributeObject();
	if(self.config.TCPKeepAlive) then
		att:SetField("TCPKeepAlive", self.config.TCPKeepAlive=="true");
	end
	if(self.config.KeepAlive) then
		att:SetField("KeepAlive", self.config.KeepAlive=="true");
	end
	if(self.config.IdleTimeout) then
		att:SetField("IdleTimeout", self.config.IdleTimeout=="true");
	end
	if(self.config.IdleTimeoutPeriod) then
		att:SetField("IdleTimeoutPeriod", tonumber(self.config.IdleTimeoutPeriod));
	end
	local npl_queue_size = tonumber(self.config.npl_queue_size);
	if(npl_queue_size) then
		NPL.activate("script/ide/config/NPLStateConfig.lua", {type="SetAttribute", attr={MsgQueueSize=npl_queue_size,}});
	end
	
	-- add all public files
	NPL.LoadPublicFilesFromXML(self.config.public_files);
	
	-- read attributes of npl worker states
	--commonlib.log("loading %s\n", filename);
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/IMServer/npl_states/npl_state") do
		self.worker_states[#(self.worker_states) + 1] = node.attr;
	end

	-- start all worker states
	local i;
	for i, node in ipairs(self.worker_states) do
		local worker = NPL.CreateRuntimeState(node.name, 0);
		worker:Start();
		if(npl_queue_size) then
			NPL.activate(format("(%s)script/ide/config/NPLStateConfig.lua", node.name), {type="SetAttribute", attr={MsgQueueSize=npl_queue_size,}});
		end
	end	
	
	-- add all NPL runtime addresses
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/IMServer/npl_runtime_addresses/address") do
		if(node.attr) then
			NPL.AddNPLRuntimeAddress(node.attr);
			--commonlib.echo(node.attr);
		end	
	end
	NPL.StartNetServer(self.config.host, self.config.port);	
	commonlib.log("loading ok %s\n", filename);
	
	--msg = '{ver="1.0", nid=1000,response_nid=' .. self.config.nid .. ',count=' .. i .. ',' .. msg .. '}';
	local tabMsg = {};
	tabMsg["ver"] = "1.0";
	tabMsg["action"] = "config";
	tabMsg["max_offline_msg_count"] = tonumber(self.config.max_offline_msg_count);
	tabMsg["max_offline_group_msg_count"] = tonumber(self.config.max_offline_group_msg_count);
	tabMsg["game_server_script"] = self.config.game_server_script;
	tabMsg["offline_msg_path"] = self.config.offline_msg_path;
	tabMsg["group_path"] = self.config.group_path;
	tabMsg["time_out"] = tonumber(self.config.time_out);
	tabMsg["check_time_span"] = tonumber(self.config.check_time_span);
	tabMsg["load_family_info"] = self.config.load_family_info;
	tabMsg["kick_online_group_member"] = self.config.kick_online_group_member;
	tabMsg["user_table_count"] = tonumber(self.config.user_table_count);
	tabMsg["roster_table_count"] = tonumber(self.config.roster_table_count);
	tabMsg["group_table_count"] = tonumber(self.config.group_table_count);
	
	--commonlib.echo(tabMsg);
	NPL.activate("IMServer.dll",tabMsg);
	--commonlib.log("active IMServer.dll ok\n");
	
	-- set the server timer for kick timeout users.
	NPL.load("(gl)script/ide/timer.lua");
	self.mytimer = self.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
		curTime = ParaGlobal.timeGetTime();
		self:KickTimeoutUser(curTime);
	end})
	self.mytimer:Change(3, self.config.check_time_span * 1000);

	--commonlib.echo(self.config);
	--commonlib.echo(self.worker_states);
	--commonlib.echo(self.router_states);
end

-- kick timeout users
function IMServer:KickTimeoutUser(curTime)
	local tabMsg = {};
	tabMsg["ver"] = "1.0";
	tabMsg["action"] = "kickto";	
	
	--commonlib.echo(tabMsg);
	NPL.activate("IMServer.dll",tabMsg);
	--commonlib.log("Timer active  IMServer.dll ok\n");
end

-- start the database server
-- @param filename: if nil, it will be "config/IMServer.config.xml"
function IMServer:Start(filename)
	-- load config
	self:load_config(filename);
	commonlib.applog("IM  Server is started");
end

local function activate()
	--commonlib.applog("IMServer received message");
	--commonlib.echo(msg);
	if(not msg.nid) then
		-- quick authentication, just accept any connection as client
		if(msg.my_nid or msg.game_nid) then
			msg.nid = tostring(msg.my_nid or msg.game_nid);
			NPL.accept(msg.tid, msg.nid);
			LOG.std(nil, "system", "IMServer", "game server connection %s is accepted as %s", tostring(msg.tid), tostring(msg.nid));
		end
	end
	--if(msg.game_nid) then
		--NPL.activate("(r)IMServer.dll", {ver="1.0",dest=msg.action,game_nid=msg.game_nid,g_rts=msg.g_rts,d_rts=msg.d_rts,nid=msg.nid,user_nid=msg.user_nid,data_table=msg.data_table,});
		NPL.activate("IMServer.dll", msg);
	--end
end
NPL.this(activate)