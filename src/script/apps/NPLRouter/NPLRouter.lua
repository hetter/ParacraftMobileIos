--[[
Author: Gosling
Date: 2009-7-13
Desc: router
-----------------------------------------------
NPL.load("(gl)script/apps/NPLRouter/NPLRouter.lua");
router_start_server();
-----------------------------------------------

------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/ide/log.lua");

if(not NPLRouter) then  NPLRouter = {} end;

-- default config settings
NPLRouter.config = {
	host = "127.0.0.1",
	port = "60001",
	nid = 1901,
	public_files = "config/NPLPublicFiles.xml",
	game_server_script = "script/test/network/MyTestServer.lua",
	db_server_script = "script/test/network/MyTestServer.lua";
};
-- default array of worker states and their attributes
NPLRouter.worker_states = {
	-- {name="1"},
};

-- load config from a given file. 
-- @param filename: if nil, it will be "config/NPLRouter.config.xml"
function NPLRouter:load_config(filename)
	filename = filename or "config/NPLRouter.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "error", "NPLRouter", "warning: failed loading npl router config file %s", filename);
		return;
	end	
	
	-- read config and start server
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/NPLRouter/config")[1];
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
	
	-- add all NPL runtime addresses
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/NPLRouter/npl_runtime_addresses/address") do
		if(node.attr) then
			NPL.AddNPLRuntimeAddress(node.attr);
			--commonlib.echo(node.attr);
		end	
	end

	-- add all public files
	NPL.LoadPublicFilesFromXML(self.config.public_files);

	NPL.StartNetServer(self.config.host, self.config.port);

	LOG.std("", "system", "NPLRouter", self.config.public_files);

	-- read attributes of npl worker states
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/NPLRouter/npl_states/npl_state") do
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
    
    -- specify the the table id to nid
	local node;
	local i=0,data_name;
	local tabMsg = {};
	for node in commonlib.XPath.eachNode(xmlRoot, "/NPLRouter/table_nid_config/table") do
		if(node.attr) then
			--commonlib.partialcopy(table_configs, node.attr)			
			--commonlib.echo(node.attr.table_begin);
			--msg = msg ..'data' .. i .. '={table_begin=' .. node.attr.table_begin .. ',table_end=' .. node.attr.table_end .. ',db_nid=' .. node.attr.nid .. '},';
			data_name = 'data' .. i;
			tabMsg[data_name] = {
				table_begin = tonumber(node.attr.table_begin);
				table_end = tonumber(node.attr.table_end);
				db_nid = tonumber(node.attr.nid);
			};
			i = i + 1;
		end			
	end
	
	--msg = '{ver="1.0", nid=1000,response_nid=' .. self.config.nid .. ',count=' .. i .. ',' .. msg .. '}';
	tabMsg["ver"] = "1.0";
	tabMsg["dest"] = "config";
	tabMsg["nid"] = 1000;
	tabMsg["response_nid"] = tonumber(self.config.nid);
	tabMsg["count"] = i;
	tabMsg["game_server_script"] = self.config.game_server_script;
	tabMsg["db_server_script"] = self.config.db_server_script;
	
	LOG.std("", "system", "NPLRouter", tabMsg);
	NPL.activate("NPLRouter.dll",tabMsg);
	
	NPL.load("(gl)script/apps/NPLRouter/IMDispatcher.lua");
	req = {username="10000",password="1234567",callback="script/apps/NPLRouter/IMDispatcher.lua"}
	data_table = {url="Auth_10000",req=req};
	tabMsg={};
	tabMsg["ver"] = "1.0";
	tabMsg["dest"] = "random";
	tabMsg["d_rts"] = "r";
	tabMsg["user_nid"] = 10000;
	tabMsg["game_nid"] = "";
	tabMsg["g_rts"] = "";
	tabMsg["data_table"] = data_table;
	
	LOG.std("", "system", "NPLRouter", tabMsg);
	NPL.activate("NPLRouter.dll",tabMsg);
	tabMsg={};
	tabMsg["type"] = "start";
	tabMsg["content"] = "nil";
	NPL.activate("(gl)script/apps/NPLRouter/IMDispatcher.lua",tabMsg);
	
	--commonlib.echo(self.config);
	--commonlib.echo(self.worker_states);
end

-- start the npl router server
-- @param filename: if nil, it will be "config/GameServer.config.xml"
function NPLRouter:Start(filename)
	-- load config
	self:load_config(filename);
	
	LOG.std("", "system", "NPLRouter", "NPL Router is started");
end

local function activate()
	local msg = msg;
	--commonlib.applog("NPLRouter received message");
	if(not msg.nid and msg.my_nid) then
		-- quick authentication, just accept any connection as client
		msg.nid = tostring(msg.my_nid);
		NPL.accept(msg.tid, msg.nid);
		LOG.std("", "system", "NPLRouter", {"accepted connection", msg.tid, msg.nid});
	end
	if(msg.game_nid) then
		-- log("nid=" .. msg.nid .. " \n");
		if(not msg.d_rts) then
			msg.d_rts = "";
		end
		if(not msg.g_rts) then
			msg.g_rts = "";
		end
		NPL.activate("(r)NPLRouter.dll", {ver="1.0",dest=msg.dest,game_nid=msg.game_nid,g_rts=msg.g_rts,d_rts=msg.d_rts,nid=msg.nid,user_nid=msg.user_nid,data_table=msg.data_table,});
	end	
end
NPL.this(activate)
