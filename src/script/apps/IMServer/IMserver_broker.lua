 --[[
Author: Gosling,LiXizhi
Date: 2010-5-15
Desc: IMServer broker of game server
LiXizhi: security applied, only established connection is allowed. 
-----------------------------------------------
NPL.load("(gl)script/apps/IMServer/IMserver_broker.lua");
IMServer_broker:init({type="init", gameserver_nid = self.config.nid, IMServer_states = self.IMServer_states});
IMServer_broker:StartSendingHeartBeat(imserver_interval)
-----------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_clientproxy.lua");
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/apps/GameServer/GSL_gateway.lua");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local LOG = LOG;
local format=format;
local IMServer_broker = commonlib.gettable("IMServer_broker");


IMServer_broker.output_msg = {
	ver = "1.0",
	game_nid = 2001, 
	g_rts = 0,
	action = "",	
	data_table = {roster_list = ""}
};
-- total number of messages sent
IMServer_broker.outmsg_count = 0;
IMServer_broker.IMServer_states_count = 0;
IMServer_broker.IMServer_states = {};
local IMServer_nid = "IMServer1";
local router_nid = "router1";
IMServer_broker.IMServer_dll = IMServer_nid..":IMServer.dll";
IMServer_broker.IMServer_script = IMServer_nid..":script/apps/IMServer/IMServer.lua";
IMServer_broker.reply_file = "script/apps/IMServer/IMserver_client.lua";

--local IMServer_broker = {
	--output_msg = {};
	--outmsg_count = 0;
	--IMServer_states_count = 0;
	--IMServer_states = {};
	--IMServer_dll = "IMServer1:IMServer.dll";
	--reply_file = "script/apps/IMServer/IMserver_client.lua";	
--};
--
--Map3DSystem.GSL.IMServer_broker = IMServer_broker;

-- do some one time init here
function IMServer_broker:init(input)
	--commonlib.echo(input)
	LOG.std(nil, "system","imserver",input);
	self.output_msg.game_nid = tonumber(input.gameserver_nid);
	
	self.IMServer_script = IMServer_nid..":script/apps/IMServer/IMServer.lua";
	self.IMServer_dll = IMServer_nid..":IMServer.dll";
	self.IMServer_states = input.IMServer_states or {""};
	self.IMServer_states_count = #(self.IMServer_states);
	local i
	for i = 1, self.IMServer_states_count do
		if(self.IMServer_states[i] ~= "" and not self.IMServer_states[i]:match("^%(")) then
			self.IMServer_states[i] = "("..self.IMServer_states[i]..")";
		end
	end
		
	self.reply_file = input.reply_file or self.reply_file; -- "to which client file to reply"
	
	local msg = {action = "", game_nid = tostring(input.gameserver_nid)};
	NPL.activate(IMServer_broker:GetIMServerAddress(), msg);
	
	LOG.std(nil, "system","imserver","IMserver connection is initialized");
	LOG.std(nil, "system","imserver",self.output_msg);
end

-- get next IMServer address based on IMServer.outmsg_count
function IMServer_broker:GetIMServerAddress()
	self.outmsg_count = self.outmsg_count + 1;
	local index = self.outmsg_count % self.IMServer_states_count + 1
	return (self.IMServer_states[index] or "")..self.IMServer_dll
end

-- send a url request to IMServer
function IMServer_broker:SendRequest(msg)
	if(not msg.game_nid) then
		msg.game_nid=self.output_msg.game_nid;
	end
	local address = IMServer_broker:GetIMServerAddress();
	local ret = NPL.activate(address, msg);
	if(ret  ~=0 ) then
		-- unable to reach IM Server
		LOG.std(nil, "error","imserver_broker","unable to reach IM Server,ret=%d,address:%s,msg:%s",ret,address,commonlib.serialize_compact(msg));
	end
	--LOG.std(nil, "debug","imserver_broker","send IM Server success,ret=%d,address:%s,msg:%s",ret,address,commonlib.serialize_compact(msg));
end

local npl_stats_msg_templ = {connection_count = true, nids_str=true}

-- start a timer that periodically send heart beat. 
function IMServer_broker:StartSendingHeartBeat(imserver_interval)
	imserver_interval = imserver_interval or 5000;
	local game_nid = tonumber(self.output_msg.game_nid);
	if(game_nid and imserver_interval>0) then
		-- sending heart beat for IM server
		self.imserver_timer = self.imserver_timer or commonlib.Timer:new({callbackFunc = function(timer)
				local stats = NPL.GetStats(npl_stats_msg_templ);
				--commonlib.log("IM Heart Beat user_count:%d\n",stats.connection_count);
				-- send online users to the IMServer for heart beat. 
				self:SendGameHeart({game_nid = game_nid, g_rts = "main",users = stats.nids_str});
			end})
		-- send IM heart beat messages every 5000 seconds. 	
		self.imserver_timer:Change(imserver_interval, imserver_interval);
	end
end

function IMServer_broker:SendGameHeart(input)
	--commonlib.echo(input);
	self.output_msg.action="gameheart";
	self.output_msg.g_rts = input.g_rts;
	self.output_msg.game_nid = input.game_nid;
	self.output_msg.data_table.roster_list=input.users;
	--commonlib.applog("Game Server is sending IMServer_broker request to IMServer ...")
	--commonlib.applog(string.format("g_rts=%d",self.output_msg.g_rts));
	--commonlib.echo(self.output_msg);
	IMServer_broker:SendRequest(self.output_msg);
end


-- handle a IMServer_broker request. it sends to IMServer for processing
function IMServer_broker:handle_request(msg)
	if(not msg.data_table) then
		msg.data_table = {};
	end
	if(msg.nid) then
		msg.data_table.user_nid = tonumber(msg.nid);
	end
	if(msg.action == "sendmsg") then
		msg.data_table.src_nid = tonumber(msg.nid);
		if(msg.data_table.src_nid < 10000) then
			LOG.std(nil, "error", "IMServer_broker", "sendrequest error,src_nid<10000");
			commonlib.echo(msg);
			return;
		end
	end 
	if(msg.action == "delmember") then
		msg.data_table.del_user_nid = tonumber(nid);
	end 
	IMServer_broker:SendRequest(msg);
end

-- handle a reply msg from the IMServer
function IMServer_broker:handle_response(msg)
	if(msg.user_nid ~= 0) then
		if(msg.action == "kickuser") then
			-- this will prevent the same user to login to two game world simultaneously.
			local nid = tostring(msg.user_nid);
			-- NPL.reject(nid);
			NPL.reject({nid=nid, reason = 1});
			LOG.std(nil, "debug", "IMServer_broker", "kickuser %s", nid);
		else
			local user = gateway:GetUser(msg.user_nid);
			if(msg.action ~= "normalmsg" or (user and user:RateLimitCheck())) then 
				--LOG.std(nil, "debug", "IMServer_broker", msg);
				local ret=NPL.activate(format("%s:%s", msg.user_nid, IMServer_broker.reply_file), msg);
				if(ret ~= 0) then --send to client fail, if msg type is user message from friends. save back to imserver.
					if(msg.action and ( msg.action == "normalmsg" or msg.action == "offline_msg" )) then
						LOG.std(nil, "debug", "IMServer_broker", "note:send msg to client failed");
						--commonlib.applog("SendMsg Failed,Save back to imserver offline msg.")
						--commonlib.echo(msg);
						IMServer_broker:SendRequest(msg);
					else
						-- note: for other online messages, we will simply drop off the message with no log. 
					end		
				end
			end
		end
	end
end

local function activate()
	local msg = msg;
	
	if(msg.dest == "imserver") then
		-- this is a message from client to imserver, so we need to verify nid
		if(msg.nid) then
			IMServer_broker:handle_request(msg)
		else
			LOG.std(nil,"warn", "IMServer_broker", "user %s not authenticated. message is dropped.", tostring(msg.nid or msg.tid));
		end
	elseif(msg.dest == "imclient") then	
		-- this is a message from imserver to client, so we need to verify that nid is IMServer
		if(msg.nid == IMServer_nid or msg.nid == router_nid) then
			--msg.nid = tostring(self.output_msg.game_nid);
			--NPL.accept(msg.tid, msg.nid);
			IMServer_broker:handle_response(msg)
		else
			LOG.std(nil,"warn", "IMServer_broker", "unknown imserver nid %s. message is dropped.", tostring(msg.nid or msg.tid));
		end
	elseif(msg.type == "init") then	
		-- the above ensures that only local files can activate the following code. 
		if(not msg.nid and not msg.tid) then
			IMServer_broker:init(msg);
		else
			LOG.std(nil,"warn", "IMServer_broker", "init() method not allowed for %s", tostring(msg.nid or msg.tid));
		end
	end
end
NPL.this(activate)