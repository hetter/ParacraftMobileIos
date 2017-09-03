--[[
Author: LiXizhi
Date: 2009-7-20
Desc: database server main activation file. It will dispatch requests to handler files of DBServer.dll C# scripts 
in random worker threads. 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/DBServer.lua");
DBServer:Start();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/apps/DBServer/DBServer_API.lua");

local format = format;

if(not DBServer) then  DBServer = {} end

-- default config settings
DBServer.config = {
	host = "127.0.0.1",
	port = "60001",
	nid = "1001",
	public_files = "config/NPLPublicFiles.xml",
	api_file = "config/WebAPI.power.config.xml",
};
-- default array of worker states and their attributes
DBServer.worker_states = {
	-- {name="1"},
};
DBServer.worker_count = #(DBServer.worker_states);

-- for login
DBServer.router_script = "router1:script/apps/NPLRouter/NPLRouter.lua"
-- for ordinary messages
DBServer.router_dll = "router1:NPLRouter.dll"
-- time of seconds to timeout if unable to connect to router
DBServer.connect_timeout = 10;
-- array of router state names that the database server should send message back to (evently)
DBServer.router_states = {};
DBServer.router_states_count = 0;

-- write service log
function DBServer.log(...)
	-- TODO: 
end

-- load the api config file. 
-- @param filename: if nil, it will be "config/WebAPI.config.xml"
function DBServer:load_api_config(filename)
	filename = filename or "config/WebAPI.power.config.xml"
	
	commonlib.log("debug: webapi config file loaded: %s\n", tostring(filename));
	
	-- read all web API from api config file
	local api_root = ParaXML.LuaXML_ParseFile(filename);
	if(not api_root) then
		commonlib.log("warning: failed loading config file %s\n", filename);
	else
		local node;
		for node in commonlib.XPath.eachNode(api_root, "/WebAPI/web_services/service") do
			if(node.attr and node.attr.provider and node.attr.provider=="gameserver" and node.attr.shortname) then
				local service_desc = self.API[node.attr.shortname] or {};
				if(node.attr.allow_anonymous and node.attr.allow_anonymous=="true") then
					service_desc.allow_anonymous = true;
				else
					service_desc.allow_anonymous = nil;
				end
				if(node.attr.handler) then
					service_desc.filename = node.attr.handler;
				end
				self.API[node.attr.shortname] = service_desc;
			end	
		end	
	end	
end

-- load config from a given file. 
-- @param filename: if nil, it will be "config/DBServer.config.xml"
-- @param start_worker_thread: true to start worker thread. this is false when initializing dispatcher thread. 
function DBServer:load_config(filename, start_worker_thread)
	filename = filename or "config/DBServer.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading db server config file %s\n", filename);
		return;
	end	
	
	-- read config and start server
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/DBServer/config")[1];
	if(config_node and config_node.attr) then
		commonlib.partialcopy(self.config, config_node.attr)
	end
	if(self.config.is_router == "true") then
		NPL.load("(gl)script/apps/NPLRouter/NPLRouter.lua");
		local router_config_filename = filename:gsub("DBServer", "NPLRouter");
		NPLRouter:Start(router_config_filename);
	end
	if(self.config.is_imserver == "true") then
		NPL.load("(gl)script/apps/IMServer/IMServer.lua");
		local im_config_filename = filename:gsub("DBServer", "IMServer");
		IMServer:Start(im_config_filename);
	end
	if(self.config.is_payserver == "true") then
		local pay_config_filename = filename:gsub("DBServer", "PayServer");
		NPL.load("(gl)script/apps/PayServer/PayServer.lua");
		PayServer:Start(pay_config_filename);
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

	-- whether use compression on incoming connections, the current compression method is super light-weighted and is mostly for data encrption purposes. 
	local compress_incoming;
	if (self.config.compress_incoming and self.config.compress_incoming=="true") then
		compress_incoming = true;
	else
		compress_incoming = false;
	end
	NPL.SetUseCompression(compress_incoming, false);
	
	if(self.config.CompressionLevel) then
		att:SetField("CompressionLevel", tonumber(self.config.CompressionLevel));
	end
	if(self.config.CompressionThreshold) then
		att:SetField("CompressionThreshold", tonumber(self.config.CompressionThreshold));
	end

	-- read all web API from api config file
	self:load_api_config(self.config.api_file);
	
	if(start_worker_thread) then
		NPL.StartNetServer(self.config.host, self.config.port);
		
		-- add all public files
		NPL.LoadPublicFilesFromXML(self.config.public_files);
	
		---- this is a dispatcher thread, which dispatches incoming messages randomly to one of the worker threads. 
		--local dispatcher_thread = NPL.CreateRuntimeState("d", 0);
		--dispatcher_thread:Start();
		---- load api config file in the dispatcher thread. 
		--NPL.activate("(d)script/apps/DBServer/DBServer.lua", {config_file=filename})
	end	
			
	-- read attributes of npl worker states
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/DBServer/npl_states/npl_state") do
		if(node.attr and node.attr.name) then
			self.worker_states[#(self.worker_states) + 1] = node.attr;
		end	
	end
	self.worker_count = #(self.worker_states);
	
	-- get all router runtime states names
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/DBServer/router_states/router_state") do
		if(node.attr and node.attr.name) then
			if(node.attr.name ~= "") then
				self.router_states[#(self.router_states) + 1] = "("..node.attr.name..")";
			end	
		end	
	end
	self.router_states_count = #(self.router_states);
	
	if(start_worker_thread) then
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
		for node in commonlib.XPath.eachNode(xmlRoot, "/DBServer/npl_runtime_addresses/address") do
			if(node.attr) then
				NPL.AddNPLRuntimeAddress(node.attr);
			end	
		end
		
		-- establish connection with the NPLRouter and send the first authentication message
		--if( NPL.activate_async_with_timeout(self.connect_timeout, self.router_script, {my_nid = self.config.nid,}) ~=0 ) then 
		--	commonlib.applog(string.format("WARNING: db server (%s) can not connect to NPLRouter", self.config.nid))
		--else
		--	commonlib.applog(string.format("db server (%s) is connected to NPLRouter", self.config.nid))
		--end
	end	
	
	-- create a monitor to keep track of all worker state. 
	if(self.config.use_monitor and self.config.use_monitor == "true") then
		LOG.std(nil, "system", "DBServer", "DB monitor is enabled")
		NPL.load("(gl)script/ide/NPLStatesMonitor.lua");
		self.monitor = self.monitor or commonlib.NPLStatesMonitor:new();
		
		local worker_states_names = {};
		local i;
		for i, node in ipairs(self.worker_states) do
			worker_states_names[#worker_states_names + 1] = node.name;
		end	
		self.monitor:start({npl_states = worker_states_names, update_interval = 2000, load_sample_interval = 10000,
			enable_log = true, log_interval = 20000,
			candidate_percentage = 0.8,
			});
	else
		LOG.std(nil, "warn", "DBServer", "monitor is not used. It is advised to use monitor by specify config/use_monitor in DBServer.config.xml\n")	
	end	
end

local is_started = false;
-- start the database server
-- @param filename: if nil, it will be "config/DBServer.config.xml"
function DBServer:Start(filename)
	-- load config
	self:load_config(filename, true);
	
	-- in win32, there can only be one mono state, so initialize using the first db thread. 
	local worker_name = DBServer.worker_states[1].name;
	NPL.activate(format("(%s)%s", worker_name, "DBServer.dll/DBServer.DBServer.cs"), {start_main = true})

	-- NPL.activate("DBServer.dll/DBServer.DBServer.cs", {start_main = true});
	LOG.std(nil, "system", "DBServer", "DB Server is started");
	
	is_started = true;
	-- TestCase: test activate function
	--msg = {data_table = {url = "CheckUName"}}
	--NPL.activate("script/apps/DBServer/DBServer.lua", msg)
	--NPL.activate("script/apps/DBServer/DBServer.lua", msg)
	--NPL.activate("script/apps/DBServer/DBServer.lua", msg)
	--NPL.activate("script/apps/DBServer/DBServer.lua", msg)
	--NPL.activate("script/apps/DBServer/DBServer.lua", msg)
end

local last_req = 1;
-- receives a message from router to db server
-- e.g. {ver="1.0",result=0, my_nid=1901,game_nid=2001,user_nid=10089,data_table={url="AuthUser",req={UserName="1"},},}
local function activate()
	if(not is_started) then
		LOG.std(nil, "warn", "DBServer", "DBServer.lua is activated when it has not been started. ")
	end
	local msg = msg;
	-- commonlib.log("DB server received msg\n");commonlib.echo(msg);
	--if(not msg.nid) then
	if(msg.tid) then
		-- quick authentication, just accept any connection as client
		NPL.accept(msg.tid, "router1");
		LOG.std(nil, "system", "DBServer", "router connection established")
		commonlib.echo({msg.tid, msg.nid});
	end
	if(msg.data_table) then
		-- just forward sequentially to one of the worker states
		local handler = DBServer.API[msg.data_table.url];
		if(handler and handler.filename) then
			last_req = last_req + 1;
			
			-- commonlib.echo({url=msg.data_table.url, user_nid = msg.user_nid, req = msg.data_table.req, seq = msg.data_table.seq})
			if(handler.handler_func) then
				handler.handler_func(msg);
			else
				-- insert the router run time state name that the database server should reply to.
				msg.rs = (DBServer.router_states[last_req % DBServer.router_states_count + 1])
				-- commonlib.echo({DBServer.worker_states, name=__rts__:GetName()})
				
				local worker_name;
				if(DBServer.monitor) then
					-- worker_name = DBServer.monitor:GetNextCandidateState(last_req);
					worker_name = DBServer.monitor:GetNextFreeState(); -- this gives more accurate free stat. 
				else
					worker_name = DBServer.worker_states[last_req % (DBServer.worker_count) + 1].name;
				end
				
				NPL.activate(format("(%s)%s", worker_name, handler.filename), msg)
				-- commonlib.echo(msg);
			end	
			
			-- emulate a reply to router here
			--NPL.activate("(r)router1:NPLRouter.dll", {dest = "game", data_table = {result="reply from database server"}, 
			--	user_nid = msg.user_nid, d_rts = msg.d_rts, g_rts = msg.g_rts, user_nid = msg.user_nid, ver = msg.ver, game_nid = msg.game_nid})
		end	
	elseif(msg.config_file) then	
		-- load config file in the dispatcher thread. 
		DBServer:load_config(msg.config_file);
	end
end
NPL.this(activate)

