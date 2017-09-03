--[[
Title: For broadcasting user or system messages
Author(s): LiXizhi
Date: 2011/3/6
Desc: This service is used internally by GSL to broadcastuser or system messages via all GSL gridnodes on the current thread. 
Broadcast service on different thread or machines may also coordinate to broadcast messages to even wider areas.
The game server logics may charge the user for wider area broadcast. Internally it will implement a prioritized message queue 
so that the client can receive messages at constant rate. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_BroadcastService.lua");
local BroadcastService = commonlib.gettable("Map3DSystem.GSL.Lobby.BroadcastService");
BroadcastService.AddGridNodeManager(gridnode_manager)
-----------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
local tostring = tostring;
local GSL = commonlib.gettable("Map3DSystem.GSL");
local BroadcastService = commonlib.gettable("Map3DSystem.GSL.Lobby.BroadcastService");
BroadcastService.src = "script/apps/GameServer/LobbyService/BroadcastService.lua";
Map3DSystem.GSL.system:AddService("BroadcastService", BroadcastService)

-- 1000ms for the tick timer. 
BroadcastService.timer_interval = 1000;
-- max number of messages per second in the queue. This is actually the queue size during BroadcastService.timer_interval
local max_messages = 2;
-- max text length per message. 
local max_text_length = 512;
-- all registered gridnode manager
local gridnode_managers = {};


-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function BroadcastService:Init(system)
	local options = Map3DSystem.GSL.config:FindModuleBySrc(self.src);
	
	-- trade service must wait until power item service is inited
	--local dependent_module = system:GetService("PowerItemService");
	--if(not dependent_module or not dependent_module:IsLoaded() ) then 
		--return 
	--end
	
	BroadcastService.state = "loaded";
	LOG.std(nil, "system", "BroadcastService", "BroadcastService is loaded");

	BroadcastService.OnInit();

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function BroadcastService:IsLoaded()
	return BroadcastService.state == "loaded";
end

-----------------------------------------------
-- thead local: singleton class method
-----------------------------------------------

local msg_queue;
-- now init a given stuff 
function BroadcastService.OnInit()
	if(not BroadcastService.is_inited) then
		BroadcastService.is_inited = true;
		msg_queue = commonlib.List:new();
	end
end

-- push a message to the local thread's message queue according to priority. 
-- @param text: the text file to add. The caller need to varify its length. 
-- @param nid: who send the message. 
-- @param priority: if nil, it default to 0. the higher the more frontier the item in the queue. 
-- @return true if succeed, otherwise it means that the queue is full or higher priority text is in. 
function BroadcastService.PushMessage(text, nid, priority)
	priority = priority or 0;
	if(type(text) ~= "string") then
		return;
	elseif(#text > max_text_length) then
		return;
	end

	-- push by priority. 
	local item = msg_queue:first();
	while (item) do
		if(item.priority < priority) then
			msg_queue:insert_before({text=text, nid=nid, priority=priority}, item);
			if(msg_queue:size() > max_messages) then
				msg_queue:remove(msg_queue:last());
			end
			return true;
		end
		item = msg_queue:next(item)
	end
	if(msg_queue:size() < max_messages) then
		msg_queue:push_back({text=text, nid=nid, priority=priority})
		return true;
	end
end

local tick_times = 0;
local last_raw_data = {};
local last_raw_data_tick;

-- call this function every normal update frame move, only once per frame in the thread. 
function BroadcastService.OnFrameMove()
	tick_times = tick_times + 1;
	-- prefetch all messages 
	local opCodeData = BroadcastService.GetPendingMessageStream(true);
	
	if(opCodeData and #gridnode_managers > 0) then
		-- insert messages to each users' realtime message queue.
		local function AddMsgToAllUsers(gridnode)
			gridnode:AddRealtimeMessage(0, opCodeData);
		end

		for i=1, #gridnode_managers do
			local gridnode_manager = gridnode_managers[i];
			gridnode_manager:OnEachActiveGridNode(AddMsgToAllUsers);
		end
	end
end

-- The broadcast service will then forward messags to all users in the gridnode mananger. 
function BroadcastService.AddGridNodeManager(gridnode_manager)
	gridnode_managers[#gridnode_managers + 1] = gridnode_manager;

	if(not BroadcastService.timer) then
		BroadcastService.timer = commonlib.Timer:new({callbackFunc = function(timer)
			BroadcastService.OnFrameMove();
		end})
		BroadcastService.timer:Change(BroadcastService.timer_interval, BroadcastService.timer_interval)
	end
end


-- get all messages in the sending message format (chat opcode). 
-- it will clear all pending messages.
-- @return nil, or a text stream. 
function BroadcastService.GetPendingMessageStream()
	if(last_raw_data_tick == tick_times) then
		return last_raw_data;
	else
		last_raw_data_tick = tick_times;

		if( msg_queue:size() > 0 ) then
			last_raw_data = nil;
			local item = msg_queue:first();
			while (item) do
				last_raw_data = GSL.SerializeToStream("chat", item.text, last_raw_data);
				item = msg_queue:next(item)
			end
		else
			last_raw_data = nil;
		end
		-- clear pending messages
		msg_queue:clear(); 

		return last_raw_data;
	end
end

