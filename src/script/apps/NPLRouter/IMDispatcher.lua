--[[
Title: IM(instant messaging) dispatcher
Author: LiXizhi
Date: 2009-11-16
Desc: allowing DB servers or game servers to send IM (online/offline)messages to any user via jabber_client interface. 
use the lib:
-----------------------------------------------
NPL.load("(gl)script/apps/NPLRouter/IMDispatcher.lua");
------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/ide/log.lua");

NPL.load("(gl)script/apps/IMServer/IMserver_broker.lua");

NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/jabber_client.lua");
NPL.load("(gl)script/ide/Json.lua");

local IMDispatcher = {};
local config = {ChatDomain="tm.test.pala5.cn",ChatPort=8080}

-- load config from a given file. 
-- @param filename: if nil, it will be "config/NPLRouter.config.xml"
function IMDispatcher:load_config(filename)
	-- TODO: 
	commonlib.applog("Dispatcher loadconfig is started");
	filename = "config/GameClient.config.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading game client config file %s\n", filename);
		return;
	end	
	local node;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/chat_server_addresses")[1];
	if(node and node.attr) then
		config.api_file = node.attr.api_file or self.config.api_file;
	else
		commonlib.applog("Dispatcher loadconfig error");
	end
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/chat_server_addresses/address")[1];
	if(node and node.attr) then
		config.ChatDomain = node.attr.host;
		config.ChatPort = tonumber(node.attr.port);
		commonlib.log("config of chat server: %s(port:%d)\n", config.ChatDomain, config.ChatPort);
	else
		commonlib.applog("Dispatcher loadconfig error");
	end
end

-- start the npl router server
-- @param filename: if nil, it will be "config/GameServer.config.xml"
--function IMDispatcher:Start(filename)
function IMDispatcher:Start(jabberid,password)
	-- load config
	local filename = "config/GameServer.config.xml"
	self:load_config(filename);
	commonlib.applog("NPL dispatcher is started");
	
	-- jabber client
	--self.jabber_client = GameServer.jabber.client:new({})
	--self.jabber_client:AddEventListener("OnAuthenticate", IMDispatcher.JE_OnAuthenticate, self);
	--self.jabber_client:AddEventListener("OnMessage", IMDispatcher.JE_OnMessage, self);
	--
	--jabberid=jabberid .."@"..config.ChatDomain;
	--commonlib.applog("id:%s,session:%s\n",jabberid, password);
	--self.jabber_client:start(jabberid, password);

	--self.jabber_client:start("78975924@test.pala5.cn", "3220009145538408")
	--IMDispatcher:SendMessage("13220", "hello,world")
end

-- TODO: 
--function IMDispatcher:SendMessage(nid, content)
	--local jid = nid.."@"..config.ChatDomain
	--commonlib.applog("send message,%s,%s",jid,content)
	--local jc = self.jabber_client:GetClient();
	--if(jc) then
		----jc:Message(nid.."@test.pala5.cn", commonlib.serialize(msg));
		--jc:Message(jid, commonlib.serialize(content));
	--end
--end

function IMDispatcher:SendMessage(nid, content)
	local msg={};
	msg.dest = "im";
	msg.action = "sendmsg";
	msg.user_nid = 10000;
	msg.game_nid = 0;
	msg.g_rts = "";
	msg.d_rts = "";
	msg.data_table = {};
	msg.data_table.src_nid = 10000;
	msg.data_table.dest_nid = tonumber(nid);
	msg.data_table.msg = content;

	------- Router 中不能调用如下代码，会导致Router 崩溃
	-- IMServer_broker:SendRequest(msg);   
	--if(NPL.activate("(1)IMServer1:IMServer.dll", msg) ~= 0 ) then
		--commonlib.applog("error:unable to reach IM Server:")
		--commonlib.echo(msg);
	--end

	------- 直接调用 NPLRouter.dll 将 msg 通过 libNPLRouter.so 转发给 IMSVR
	if(NPL.activate("NPLRouter.dll", msg) ~= 0 ) then
		commonlib.applog("error:unable to reach IM Server:")
		commonlib.echo(msg);
	end
end
------------------------------------------------
-- jabber event callback
------------------------------------------------
function IMDispatcher:JE_OnAuthenticate(event)
	commonlib.applog("IM dispatcher jabber client authenticated")
end

function IMDispatcher:JE_OnMessage(event)
	commonlib.echo("11111111111111111111111111")
	commonlib.echo(event)
end


local function activate()
	commonlib.applog("NPLRouter received message");
	commonlib.applog("rts:%s",__rts__:GetName());
	commonlib.echo(msg)
	if(not msg.type) then
		msg.type="";
	end	
	if(not msg.content) then
		return;
	end
	--local retData;
	--if(msg.data_table ~= nil) then
		--commonlib.echo(msg.data_table.data);
		--retData = commonlib.Json.Decode(msg.data_table.data);
		--msg.type = retData.type;
		--commonlib.applog("type = %s",msg.type);
	--end
	
	--if(type == "test") then
		--NPL.activate("(main)script/apps/NPLRouter/IMDispatcher.lua", {type="start"});
		--
		--for i= 1, 10 do 
			--ParaEngine.Sleep(5)
			--NPL.activate("(main)script/apps/NPLRouter/IMDispatcher.lua", {nid="78975924", content="hello world!"});
		--end			
	--else
	
	if(msg.type == "start") then
		commonlib.echo("dispacher start... ")
		--local session = retData.ejabberdsession;
		--IMDispatcher:Start("10000",session);
		local msg = {action = ""};
		NPL.activate("(1)IMServer1:IMServer.dll", msg);		
		--IMDispatcher:SendMessage(78975924, "hello,world");
	else
		msg.content = "#" .. msg.content;
		commonlib.applog("send message,%s,%s",msg.to_nid,msg.content)
		IMDispatcher:SendMessage(msg.to_nid, msg.content)
	end
end
NPL.this(activate)
