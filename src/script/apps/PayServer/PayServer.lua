--[[
Author: LiXizhi
Date: 2009-7-20
Desc: REST interface of game server
-----------------------------------------------
NPL.load("(gl)script/apps/PayServer/PayServer.lua");
PayServer:Start();
-----------------------------------------------
]]
if(not PayServer) then  PayServer = {} end

PayServer.requests_pool= {};
PayServer.seq_id = 0;

-- default config settings
PayServer.config = {
	host = "127.0.0.1",
	port = "63001",
	nid = "2999",
	public_files = "config/NPLPublicFiles.xml",
	rest = {reply_file = "script/apps/PayServer/test/test_client_rest.lua"},
	-- if it is pure server, router and rest interface will not be used. 
	IsPureServer = false,
};
-- default array of worker states and their attributes
PayServer.worker_states = {
-- this is both the runtime state name and the virtual world id
-- {name="1", },
};
PayServer.router_states = {};

-- for orders manage from http pay
PayServer.payorder={};

-- for login
PayServer.router_script = "router1:script/apps/NPLRouter/NPLRouter.lua"
-- for ordinary messages
PayServer.router_dll = "router1:NPLRouter.dll"

local reply_file = "script/apps/GameServer/rest_client.lua";
local reply_file_pre = ":"..reply_file;

-- write service log
function PayServer.log(...)
	-- TODO: 
end

function PayServer.get_next_seq()
	PayServer.seq_id = tonumber(PayServer.seq_id)+1;
	return PayServer.seq_id;
end

-- load config from a given file. 
-- @param filename: if nil, it will be "config/PayServer.config.xml"
function PayServer:load_config(filename)
	filename = filename or "config/PayServer.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "PayServer", "failed loading pay server config file %s", filename);
		return;
	end	
	LOG.std(nil, "system", "PayServer", "config file %s", filename);

	-- start the web server
	-- create the run time state for REST interface
	NPL.CreateRuntimeState("ws", 0):Start();
	NPL.activate("(ws)script/apps/WebServer/WebServer.lua", {type="StartServerAsync",configfile=filename});
	--NPL.activate("(ws)WebServer.dll/WebServer.WebServer.cs", [[msg={action="start"}]]);

	--if(NPL.activate("(ws)WebServer.dll/WebServer.WebServer.cs", {action="start"}) ==0) then
		--LOG.std(nil, "system", "PayServer", "HTTP Web Server started");
	--else
		--LOG.std(nil, "system", "PayServer", "HTTP WebServer.dll not found");
	--end

	-- read config and start server
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/PayServer/config")[1];
	if(config_node and config_node.attr) then
		commonlib.partialcopy(self.config, config_node.attr)
		-- read the REST interface settings
		local rest_node = commonlib.XPath.selectNodes(config_node, "/rest")[1];
		if (rest_node and rest_node.attr) then
			commonlib.partialcopy(self.config.rest, rest_node.attr)
		end
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
		att:SetField("IdleTimeoutPeriod", tonumber(self.config.IdleTimeoutPeriod) or 10000);
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
	for node in commonlib.XPath.eachNode(xmlRoot, "/PayServer/npl_runtime_addresses/address") do
		if(node.attr) then
			NPL.AddNPLRuntimeAddress(node.attr);
			-- commonlib.echo(node.attr);
		end	
	end
	
	-- add all public files
	NPL.LoadPublicFilesFromXML(self.config.public_files);
	
	-- start the net server. 
	NPL.StartNetServer(self.config.host, self.config.port);

	-- read attributes of npl worker states
	--local node;
	--for node in commonlib.XPath.eachNode(xmlRoot, "/PayServer/npl_states/npl_state") do
		--self.worker_states[#(self.worker_states) + 1] = node.attr;
	--end
	
	-- get all home world servers 
	self.hosts_allow = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/PayServer/hosts_allow/host") do
		self.hosts_allow[#(self.hosts_allow) + 1] = node.attr;
	end
	--commonlib.echo({"hosts_allow", self.hosts_allow});
	LOG.std(nil, "system", "PayServer", "hosts_allow: %s", commonlib.serialize_compact(self.hosts_allow));
	
	local debug_server;
	if (self.config.debug and self.config.debug=="true") then
		debug_server = true;
	end
	-- start all world server worker states
	--local i;
	--for i, node in ipairs(self.worker_states) do
		--local worker = NPL.CreateRuntimeState(node.name, 0);
		--worker:Start();
		---- start the worker as GSL server mode
		--NPL.activate("("..node.name..")script/apps/GameServer/GSL_system.lua", {type="restart", 
			--config = {
				--nid = self.config.nid, 
				--ws_id = node.name, 
				--addr = string.format("(%s)%s", node.name, self.config.nid),
				--homegrids = nil,
				--debug = debug_server,
			--}
		--});
	--end	

	
	-- get all router runtime states names
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/PayServer/router_states/router_state") do
		if(node.attr and node.attr.name) then
			self.router_states[#(self.router_states) + 1] = node.attr.name;
		end	
	end

	local _locale = "zhCN";
	local _bonus_title = "";
	local _bonus_content = "";
	local _admin_goldguid = 1;
	if(self.config.locale) then
		_locale = self.config.locale;
	end

	if(self.config.bonus_title) then
		_bonus_title = self.config.bonus_title;
	end
	if(self.config.bonus_content) then
		_bonus_content = self.config.bonus_content;
	end
	if(self.config.admin_goldguid) then
		_admin_goldguid = self.config.admin_goldguid;
	end
	LOG.std(nil, "system", "PayServer", "locale: %s", _locale);
		
	-- create the run time state for REST interface
	NPL.CreateRuntimeState("rest", 0):Start();
	-- init the REST interface
	NPL.activate("(rest)script/apps/PayServer/PayServer.lua", 
		{type="init", 
		 reply_file = self.config.rest.reply_file, 
		 gameserver_nid = self.config.nid, 
		 router_dll = self.router_dll, 
		 router_script = self.router_script, 
		 router_states = self.router_states, 
		 api_file = self.config.rest.api_file,
		 locale = _locale,
		 bonus_title = _bonus_title,
		 bonus_content = _bonus_content,
		 admin_goldguid = _admin_goldguid,
		 })
	-- NPL.activate("(rest)script/apps/GameServer/rest.lua", {type="init", reply_file = self.config.rest.reply_file, PayServer_nid = self.config.nid, router_dll = self.router_dll, router_script = self.router_script, router_states = self.router_states, api_file = self.config.rest.api_file})
	
		
	-- get all world server name for stat and show
	-- no need now by gosling. set it right to db by web. 11.12
	--NPL.load("(gl)script/apps/PayServer/GSL_stat.lua");
	--Map3DSystem.GSL.GSL_stat:SetServerProperty();
	
	--commonlib.echo(self.config);
	--commonlib.echo(self.worker_states);
	--commonlib.echo(self.router_states);
	-- set log properties before using the log
	commonlib.servicelog.GetLogger("pay"):SetLogFile("pay.log")
	commonlib.servicelog.GetLogger("pay"):SetAppendMode(true);
	commonlib.servicelog.GetLogger("pay"):SetForceFlush(true);

	commonlib.servicelog.GetLogger("pay_joint"):SetLogFile("payjoint.log")
	commonlib.servicelog.GetLogger("pay_joint"):SetAppendMode(true);
	commonlib.servicelog.GetLogger("pay_joint"):SetForceFlush(true);

	commonlib.servicelog.GetLogger("pay_warn"):SetLogFile("pay_warn.log")
	commonlib.servicelog.GetLogger("pay_warn"):SetAppendMode(true);
	commonlib.servicelog.GetLogger("pay_warn"):SetForceFlush(true);

	if (PayServer.locale ~= "zhCN") then
		commonlib.servicelog.GetLogger("pay_bonus"):SetLogFile("paybonus.log")
		commonlib.servicelog.GetLogger("pay_bonus"):SetAppendMode(true);
		commonlib.servicelog.GetLogger("pay_bonus"):SetForceFlush(true);

		commonlib.servicelog.GetLogger("pay_bonus_warn"):SetLogFile("paybonus_warn.log")
		commonlib.servicelog.GetLogger("pay_bonus_warn"):SetAppendMode(true);
		commonlib.servicelog.GetLogger("pay_bonus_warn"):SetForceFlush(true);
	end
	--commonlib.servicelog("pay", "test");
end

-- whenever we can not sent message to router or we received a message from unknown router. we will try to reconnect with router. 
-- @param timeoutSeconds: how many seconds to time out. 
local function ReconnectRouter(timeoutSeconds)
	LOG.std(nil, "system", "PayServer", {"reconnecting to router...", PayServer.router_script, PayServer.config.nid, });
	while(NPL.activate(PayServer.router_script, {my_nid = PayServer.config.nid,}) ~= 0) do 
		ParaEngine.Sleep(0.1);
		if(timeoutSeconds) then
			timeoutSeconds = timeoutSeconds - 0.1;
			if(timeoutSeconds<0) then
				LOG.std(nil, "warning", "PayServer", {"failed to reconnect with router(timed out)...", PayServer.router_script, PayServer.config.nid});
				return false;
			end
		end
	end
	LOG.std(nil, "system", "PayServer", {"connection reestablished with router...", PayServer.router_script, PayServer.config.nid, });
	return true;
end

-- Send Rest Request
local function SendRequest(address,out_msg)
	-- LOG.std(nil, "debug", "REST", {"rest:SendRequest to router", out_msg});
	local nRes = NPL.activate(address, out_msg);
	if( nRes ~=0 ) then
		-- unable to reach paysvr itself WAN port. 
		LOG.std(nil, "warning", "PayServer", "unable to reach "..LOG.tostring(address)..LOG.tostring(out_msg));
		-- waiting 0.5 seconds
		ParaEngine.Sleep(0.5);
		--if(ReconnectRouter(1)) then			
			LOG.std(nil, "warning", "PayServer", "waiting 0.5 seconds resend.");
			nRes = NPL.activate(address, out_msg);
		
		--else
		--	LOG.std(nil, "warning", "PayServer", "failed to reconnect with router. and message is dropped");
		--end
	end
	return nRes;
end



-- start the database server
-- @param filename: if nil, it will be "config/PayServer.config.xml"
function PayServer:Start(filename)
	-- load config
	self:load_config(filename);
	LOG.std(nil, "system", "PayServer", "Pay Server is started");
		
	if(not self.config.IsPureServer or self.config.IsPureServer=="false") then
		-- establish connection with the NPLRouter and send the first authentication message
		if( ReconnectRouter(1) ) then
			--ParaEngine.Sleep(0.1) 
			LOG.std(nil, "system", "PayServer", "Pay Server is connected to NPLRouter");
		end
		--LOG.std(nil, "system", "PayServer", "PayServer (%s) is connected to NPLRouter", self.config.nid)
	else
		LOG.std(nil, "warning", "PayServer", "warning: PayServer (%s) is started in pure server mode. REST and NPL router are not used. Remove IsPureServer option in gameserver.config.xml", self.config.nid)
	end	
end
-- handle the payment message here
local function HandlePayMsg(msg)
	LOG.std(nil, "system", "PayServer", "PayServer HandlePayMsg %s", commonlib.serialize_compact(msg));
	NPL.load("(gl)script/apps/GameServer/GSL.lua");
	local req = msg.req;
	local httpcallback = msg.callback;
	local req_orderno = req.orderno;
	if (req_orderno=="") then
		req_orderno=nil;
	end

	local function CanPay(httpid,orderid)
		if (not httpid) then
			return true
		elseif (not orderid) then
				return false;
		elseif (not PayServer.payorder[orderid]) then
				return true		
		end
		return false;
	end

	if(req) then
		local id=nil
		if(req.type == 0) then
			id = req.gsid;
			--if(id and id == 310000) then
					--id = 998;
			--end
		else
			id = req.gbid;
		end

		local input_seq = msg.seq;
		local input_nid = (msg.tid or msg.nid);

		-- req.from  0：淘米，<>0: 其他联运商
		if (not req.from) then
			req.from = 0;
		end

		if(msg.url and string.lower(msg.url)=="pay") then
			LOG.std(nil, "system", "PayServer", "PayServer Pay req:%s", commonlib.serialize_compact(req));
			local is_test = tonumber(req.is_test);
			if(not is_test) then
				req.is_test = 0;
			end
			if(not req.to_nid) then
				req.to_nid = req.user_nid;
			end
			if(not req.method) then
				req.method = 0;
			end

			if (CanPay(httpcallback,req_orderno)) then
				-- bonus check
				local _cnt,_bonus = 0,0;
				local _chk_bonus = 0;
				if (req.count) then
					_cnt = tonumber(req.count);
					if (req.bonus) then
						_bonus =  tonumber(req.bonus);
					end				
				else -- 没有充值 金币数量
					local outmsg={seq=input_seq,result=1};
					if (httpcallback) then
						NPL.activate(httpcallback, outmsg);
					else
						SendRequest(input_nid..reply_file_pre, outmsg);
					end					
					return
				end

				if (_bonus>0) then
					_chk_bonus = _bonus/_cnt*100;
				end
				
				local send_msg = {
					nid = req.user_nid,
					to_nid = req.to_nid,
					_nid = req.user_nid,
					gsid   = req.gsid,
					cnt = _cnt,
					from = req.from,
				};
				
				paraworld.PowerAPI.payment.Pay(send_msg, nil, function(msg)
					--commonlib.echo(msg);
					LOG.std(nil, "system", "PayServer", "PayServer Pay msg:%s", commonlib.serialize_compact(msg));
					local outmsg={};
					if(msg.issuccess == true) then	
						if (req_orderno) then
							commonlib.servicelog("pay_joint", "%s|%d|%d|%d|%d|%d|%s|%d|%d|%s",tostring(req.user_nid),req.type,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,req_orderno);
						end
						commonlib.servicelog("pay", "%s|%d|%d|%d|%d|%d|%s|%d|%d",tostring(req.user_nid),req.type,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from);						

						LOG.std(nil, "system", "PayServer", "locale:%s, _chk_bonus:%d ", PayServer.locale, _chk_bonus);
						if (PayServer.locale == "zhTW") then	
							LOG.std(nil, "system", "PayServer", "_chk_bonus:%d ", _chk_bonus);					
							if (req_orderno and _bonus >0 ) then
								if (_chk_bonus > 15) then
									outmsg={seq=input_seq,result=0,bonuslimit=1,count=req.count,bonus=_bonus};
									commonlib.servicelog("pay_bonus_warn", "%s|%d|%d|%d|%d|%d|%s|%d|%d|%s|%d",tostring(req.user_nid),req.type,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,req_orderno,_bonus);
								else									
									local _paychannel = string.sub(req_orderno,13,14);								
									local sendmail_msg={
										tonid = req.to_nid,
										title = PayServer.bonus_title,
										content =  string.format(PayServer.bonus_content,_cnt,req.bonus),
										attaches = string.format("%d,%d",PayServer.admin_goldguid,req.bonus),
										_nid = 0,
										nid = 0,
									}
									paraworld.PowerAPI.email.Send(sendmail_msg, nil, function(msg)								
										if (msg.issuccess) then
											commonlib.servicelog("pay_bonus", "%s|%d|%d|%d|%d|%d|%s|%d|%d|%s|%d",tostring(req.user_nid),_paychannel,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,req_orderno,_bonus);
										else
											commonlib.servicelog("pay_bonus_warn", "%s|%d|%d|%d|%d|%d|%s|%d|%d|%s|%d",tostring(req.user_nid),_paychannel,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,req_orderno,_bonus);
										end
									end)				
									outmsg={seq=input_seq,result=0,bonuslimit=0};
								end
							else
								outmsg={seq=input_seq,result=0};
							end			
						else
							outmsg={seq=input_seq,result=0};
						end -- if (PayServer.locale == "zhTW") 
					else	
						outmsg={seq=input_seq,result=1};
						commonlib.servicelog("pay_warn", "%s|%d|%d|%d|%d|%d|%s|%d|%d|pay fail:%s",tostring(req.user_nid),req.type,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,commonlib.serialize_compact(msg));
					end

					if (httpcallback) then  -- 如果是 http 接口过来的msg			
						local callbackfunc = httpcallback;						
						--保存该订单支付后的状态 1: 该订单已成功支付, 2:该订单支付失败
						PayServer.payorder[req_orderno]=tonumber(outmsg.result)+1;
						outmsg.orderno = req_orderno;
						LOG.std(nil, "debug", "PayServer", "%s callback msg:%s", callbackfunc, commonlib.serialize_compact(outmsg));
						NPL.activate(callbackfunc, outmsg);
					else  -- TCP 过来的 msg
						local nRes = SendRequest(input_nid..reply_file_pre, outmsg);
						if (nRes ~=0 and outmsg.result==0 ) then
							commonlib.servicelog("pay_warn", "%s|%d|%d|%d|%d|%d|%s|%d|%d|send fail:%s",tostring(req.user_nid),req.type,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,commonlib.serialize_compact(outmsg));
						end
					end		
				end,nil,2000,function(msg)					
					commonlib.servicelog("pay_warn", "%s|%d|%d|%d|%d|%d|%s|%d|%d|pay timeout:%s",tostring(req.user_nid),req.type,id,req.count,req.money,req.is_test,tostring(req.to_nid),req.method,req.from,commonlib.serialize_compact(msg));
				end);
			elseif (httpcallback) then  -- CanPay(httpcallback,req_orderno)==false, http 接口过来的msg
				local outmsg={};
				if (req_orderno) then
					--result 2: 订单号重复，该订单已成功支付, 3:订单号重复，该订单支付失败
					local result_reorder=tonumber(PayServer.payorder[req_orderno])+1;
					outmsg={seq=input_seq,result=result_reorder,orderno=req_orderno,};
					LOG.std(nil, "debug", "PayServer", "re-pay order, outmsg:%s", commonlib.serialize_compact(outmsg));
				else --result 4: 错误，无订单号
					outmsg={seq=input_seq,result=4,};
					LOG.std(nil, "debug", "PayServer", "no orderno, outmsg:%s", commonlib.serialize_compact(outmsg));
				end
				local callbackfunc = httpcallback;
				NPL.activate(callbackfunc, outmsg);
			end
		elseif(msg.url and string.lower(msg.url)=="querycount") then			
			LOG.std(nil, "system", "PayServer", "msg.url is %s", msg.url);
			local send_msg = {
				nid = msg.req.user_nid,
				_nid = msg.req.user_nid,
				gsid = msg.req.gsid,				
				from = req.from,
			};
			--commonlib.echo(send_msg);
			LOG.std(nil, "system", "PayServer", "PayServer send_msg %s", commonlib.serialize_compact(send_msg));
			paraworld.PowerAPI.payment.GetState(send_msg, nil, function(msg)
				LOG.std(nil, "system", "PayServer", "PayServer getstate msg:%s", commonlib.serialize_compact(msg));
				local outmsg={};
				if(msg.allow ~= nil) then
					outmsg={seq=input_seq,result=0,allow=msg.allow,count=msg.cnt,max=msg.max};
				else
					if (msg.errorcode == 419) then
						outmsg={seq=input_seq,result=2};
					else
						outmsg={seq=input_seq,result=1};
					end
				end

				if (httpcallback) then  -- 如果是 http 接口过来的msg			
					local callbackfunc = httpcallback;
					NPL.activate(callbackfunc, outmsg);
					LOG.std(nil, "system", "PayServer", outmsg);
				else  -- TCP 过来的 msg
					SendRequest(input_nid..reply_file_pre, outmsg);
				end					
			end)
			return
		elseif(msg.url and string.lower(msg.url)=="querynid") then			
			LOG.std(nil, "system", "PayServer", "msg.url is %s", msg.url);
			local send_msg = {
				plat = msg.req.plat,
				oid = msg.req.oid,
		        _nid = msg.req.oid,
                nid = msg.req.oid,
			};
			--commonlib.echo(send_msg);
			LOG.std(nil, "system", "PayServer", "PayServer send_msg %s", commonlib.serialize_compact(send_msg));
			paraworld.PowerAPI.users.GetNIDByOtherAccountID(send_msg, nil, function(msg)
				LOG.std(nil, "system", "PayServer", "PayServer GetNIDByOtherAccountID msg:%s", commonlib.serialize_compact(msg));
				local outmsg={};
				if(msg.nid ~= "-1") then
					outmsg={seq=input_seq,result=0,nidlist=msg.nid};
				else
					outmsg={seq=input_seq,result=1};
				end

				if (httpcallback) then  -- 如果是 http 接口过来的msg			
					local callbackfunc = httpcallback;
					NPL.activate(callbackfunc, outmsg);
					LOG.std(nil, "system", "PayServer", outmsg);
				else  -- TCP 过来的 msg
					SendRequest(input_nid..reply_file_pre, outmsg);
				end					
			end)
			return
		end
	end
end

-- only called in the rest thread to init rest_API
local function activate()
	local msg = msg;

	if(msg.type == "init") then
		-- tricky: we will modify the rest thread name so that we can use the rest thread for power API. 
		rest_thread_name = "no_rest_thread";
		NPL.load("(gl)script/apps/GameServer/rest.lua");
		
		-- init the rest interface
		local rest = commonlib.gettable("GameServer.rest");
		rest:init(msg);

		-- create payment related API handlers programmatically here
		local pay_handler = {
			allow_anonymous = true, -- since we use IP for authorizition, there is no need to use NPL auth here. 
			handler_func = HandlePayMsg,
		};

		PayServer.locale = msg.locale;
		PayServer.bonus_title = msg.bonus_title;
		PayServer.bonus_content = msg.bonus_content;
		PayServer.admin_goldguid = msg.admin_goldguid;

		rest.API["Pay"] = pay_handler;
		rest.API["QueryCount"] = pay_handler;
		rest.API["QueryNid"] = pay_handler;
		rest.API["QueryHomeCount"] = pay_handler;

		-- now init the power API
		NPL.load("(gl)script/kids/3DMapSystemApp/API/AriesPowerAPI/AriesServerPowerAPI.lua");
	end
end
NPL.this(activate)