--[[
Title: Instant Messaging client for IMServer
Author: LiXizhi
Date: 2010-5-20
Desc: This is client side class for communicating with game server based IM server. 
It provides the same class interface as the native C++ jabber/XMPP interface. 
It also provides additional features such as function callbacks, etc. The performance is better than native implementation. 
One can use either jabber_client or IMServer_client. Only needs to overwrite the global "JabberClientManager" table to change it. 
@see test code in NPL.load("(gl)script/test/TestGSL.lua");
-----------------------------------------------
NPL.load("(gl)script/apps/IMServer/IMserver_client.lua");
-- this will replace the default(real) jabber client with the one implemented by our own game server based IM server. Make sure this is done before you use it in the app code.
JabberClientManager = commonlib.gettable("IMServer.JabberClientManager");

-- one can use JabberClientManager.type to check current implementation used. 
if(JabberClientManager.type == "IMServer.JabberClientManager") then
end
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); 
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/ide/STL.lua");

local LOG = LOG;
local string_gsub = string.gsub;
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");

-- set to true to output all IO to log, this should be nil in release build. 
local debug_stream = true;

--------------------
-- NPLJabberClient: a single client connection
--	it has the same interface as the native NPLJabberClient
--------------------
local NPLJabberClient = commonlib.inherit(nil, commonlib.gettable("IMServer.NPLJabberClient"))

local function JidToNid(jid)
	if(type(jid) == "string") then
		jid = string.match(jid, "^%d+")
		if(jid) then
			return tonumber(jid);
		end	
	else
		return jid;
	end	
end

-- constructor
function NPLJabberClient:ctor()
	-- jid of this client. it is usually same as NPL's nid, if the jabber server supports NPL authentication. 
	self.jid = "";
	self.nid = nil; -- number: auto set with SetJID();
	self.User = "";
	self.Priority = 0;
	self.Password = "";
	self.AutoLogin = true;
	self.AutoRoster = true;
	self.AutoIQErrors = true;
	self.Resource = "PE";
	self.IsAuthenticated = false;
	self.Server = "";
	self.SetNetworkHost = "";
	self.PlaintextAuth = true;
	self.SSL = false;
	self.AutoStartTLS = false;
	self.AutoStartCompression = false;
	self.KeepAlive = true;
	self.AutoReconnect = true;
	self.RequiresSASL = false;
	self.TimerInterval = 2000; -- in milliseconds
	-- array of {jid=string:jid, nid=number:nid, name=string,subscription=int:SubscriptionEnum, online=true, groups={string, string, ...}, resources={name={presence=int, priority=int, message=string}, ...},},
	self.roster = {};
	-- mapping from nid to roster item. This provides a faster way to find nid by item. 
	self.roster_members = {};
	-- family group id that the user is currently joined. -1 means that the user hasnot joined any group. 
	self.group_id = -1;
	-- mapping from nid to online member in the family nid = {jid=string:jid, nid=number:nid, name=string,subscription=int:SubscriptionEnum, online=true, },
	self.group_members = {};
	-- maping from nid to true, if we received an online message from a nid recently, we will add it to this list. 
	self.online_nids = {};
	-- linked list of {nid=number:nid,}, the first one is always the team leader. 
	self.team = commonlib.List:new();
	self.others_team = commonlib.List:new();
	-- private: 
	self.pending_requests = {};
	self.events = commonlib.EventDispatcher:new();
	self.event_cb_scripts = {};

	NPL.load("(gl)script/ide/Network/StreamRateController.lua");
	local StreamRateController = commonlib.gettable("commonlib.Network.StreamRateController");
	self.streamRateCtrler = StreamRateController:new({name="", history_length = 5, max_msg_rate=0.5})
end

-- create simple direct property
local function CreateProperty(propertyName)
	NPLJabberClient["Get"..propertyName] = function (self) return self[propertyName] end;
	NPLJabberClient["Set"..propertyName] = function (self, value) self[propertyName] = value end;
end
CreateProperty("User");CreateProperty("Priority");CreateProperty("Password");
CreateProperty("AutoLogin");CreateProperty("AutoRoster");CreateProperty("AutoIQErrors");
CreateProperty("Resource");CreateProperty("IsAuthenticated");CreateProperty("Server");
CreateProperty("SetNetworkHost");CreateProperty("PlaintextAuth");CreateProperty("SSL");
CreateProperty("AutoStartTLS");CreateProperty("AutoStartCompression");CreateProperty("KeepAlive");
CreateProperty("AutoReconnect");CreateProperty("RequiresSASL");

-- private: 
function NPLJabberClient:SetJID(jid)
	self.jid = jid;
	self.nid = JidToNid(self.jid);
end

-- check if object is invalid. .
function NPLJabberClient:IsValid()
	return self.jid and self.jid ~= "";
end

--[[ Returns a StatisticsStruct containing byte and stanza counts for the current active connection. 
-- @param inout: the input|output table. usually this is an empty table. 
-- @return: a struct containing the current connection's statistics. 
-- e.g. local stats = jc:GetStatistics({}); stats
]]
function NPLJabberClient:GetStatistics( output )
	output = output or {};
	output.totalBytesSent = 0;
	output.totalBytesReceived = 0;         
	output.compressedBytesSent = 0;        -- < Total number of bytes sent over the wire after compression was applied. 
	output.compressedBytesReceived = 0;    -- < Total number of bytes received over the wire before decompression was applied. 
	output.uncompressedBytesSent = 0;      -- < Total number of bytes sent over the wire before compression was applied. 
	output.uncompressedBytesReceived = 0;  -- < Total number of bytes received over the wire after decompression was applied. 
	output.totalStanzasSent = 0;           -- < The total number of Stanzas sent. 
	output.totalStanzasReceived = 0;       -- < The total number of Stanzas received. 
	output.iqStanzasSent = 0;              -- < The total number of IQ Stanzas sent. 
	output.iqStanzasReceived = 0;          -- < The total number of IQ Stanzas received. 
	output.messageStanzasSent = 0;         -- < The total number of Message Stanzas sent. 
	output.messageStanzasReceived = 0;     -- < The total number of Message Stanzas received. 
	output.s10nStanzasSent = 0;            -- < The total number of Subscription Stanzas sent. 
	output.s10nStanzasReceived = 0;        -- < The total number of Subscription Stanzas received. 
	output.presenceStanzasSent = 0;        -- < The total number of Presence Stanzas sent. 
	output.presenceStanzasReceived = 0;    -- < The total number of Presence Stanzas received. 
	output.encryption = nil;                -- < Whether or not the connection (to the server) is encrypted. 
	output.compression = nil;               -- < Whether or not the stream (to the server) gets compressed. 
	return output;
end

-- Connect to the server.  This happens asynchronously, and could take a couple of seconds to get the full handshake
-- completed.  This will auth, send presence, and request roster info, if the Auto-- properties are set.
-- @param rest_client: the rest_client object to be associated with the IMServer. If nil, we will use the default one. 
-- @return true if already connected. 
function NPLJabberClient:Connect(rest_client)
	LOG.std("", "system", "IM", "IMServer_client connecting as %s...", self.jid)
	NPL.load("(gl)script/apps/GameServer/GSL.lua");
	
	self.nid = JidToNid(self.jid);
	
	-- we will grab the global GSL_client, a better way 
	if(rest_client) then
		self.client = rest_client;
	else
		self.client = self.client or commonlib.gettable("GameServer.rest.client");
	end
	self.streamRateCtrler.name = tonumber(self.nid);

	GSL_msg = GSL_msg or commonlib.gettable("Map3DSystem.GSL.GSL_msg");
	
	self.mytimer = self.mytimer or commonlib.Timer:new({
		callbackFunc = function(timer)
			self:OnTimer(timer);
		end});
	
	self.OnConnectCalled = false;
	self.OnAuthenticatedCalled = false;
	-- tick every 2000 milliseconds
	self.mytimer:Change(100, self.TimerInterval);
	
	return self.IsConnected or self.client:IsConnected();
end

--  send a message to IM server
--  @param msg: the messsage to send. 
--  @param bIgnoreRateController: true to ignore message send rate controller. 
--  @return true if sent
function NPLJabberClient:Send(msg, bIgnoreRateController)
	if(self.client) then
		if(debug_stream) then
			LOG.std("", "system", "IM", "IMServer_client send:");
			LOG.std("", "system", "IM", msg);
		end
		
		-- apply the message		
		if(bIgnoreRateController or self.streamRateCtrler:AddMessage()) then
			msg.type = msg.type or GSL_msg.CS_IM;
			if(not self.client:SendToGateway(msg)) then
				LOG.std("", "warning", "IM", "warning: Unable to send IM server msg");
			else
				return true;
			end
		else
			LOG.std("", "warning", "IM", "warning: you are sending too fast. message is dropped."..commonlib.serialize_compact(msg));
		end
	end
end

-- private: jid to nid
function NPLJabberClient:JidToNid(jid)
	return JidToNid(jid);
end

-- private: create jid from nid
function NPLJabberClient:GetJidFromNid(nid)
	return nid..string_gsub(self.jid, "^(%d+)", "");
end

-- Close down the connection, as gracefully as possible.*/
function NPLJabberClient:Close()
	self.IsAuthenticated = false;
	self.IsConnected = false;
	
	if(self.mytimer) then
		-- kill timer. 
		self.mytimer:Change();
	end
	
	-- Note: shall we reset event listener as well?
	-- self:ResetAllEventListeners();
end

-- activate or sending a message to a target This function is similar to NPL.activate(), except that it only accept Jabber ID as destination. .
-- 
-- @param sDestination: format: JID[:neuron_filepath]
-- JID or jabber ID is in the format:  username@servername
--  e.g.
--  	"lixizhi@paraengine.com:script/network/client.lua". the target NPL runtime's neuron file  will receive message by its activation function.
--  	"lixizhi@paraengine.com" if no neuron file is specified. the sCode will be regarded as an ordinary Jabber:XMPP:Chat message body. 
-- @Note: please Node that offline message is NOT supported when a neuron_filepath is specified. 
--  TODO: when a neuron file receives a msg. The msg table automatically has following addition fields filled with valid values
--    msg.sender: the sender's JID
--    msg.time: the time at which the sender send a message. 
-- @param sCode: If it is a string, it is regarded as a chunk of secure msg code that should be executed in the destination neuron file's runtime. 
--  	If this is a table or number, it will be transmitted via a internal variable called "msg". When activating neurons on a remote network, only pure data table is allowed in the sCode.
-- @param bIgnoreRateController: true to ignore rate controller. 
-- @note: pure data table is defined as table consisting of only string, number and other table of the above type. 
--   NPL.activate function also accepts ParaFileObject typed message data type. ParaFileObject will be converted to base64 string upon transmission. There are size limit though of 10MB.
--   one can also programmatically check whether a script object is pure date by calling NPL.SerializeToSCode() function. Please note that data types that is not pure data in sCode will be ignored instead of reporting an error.
-- @return: if true, message is put to the output queue. if output queue is full, the function will return false. And one should possible report service unavailable. 
function NPLJabberClient:activate(sDestination, sCode, bIgnoreRateController)
	local jid, filename = string.match(sDestination, "^(.*):(.*)$");
	if(jid and filename) then
		if(type(sCode) == "table") then
			sCode = commonlib.serialize_compact(sCode);
			if(sCode) then
				sCode = "msg="..sCode;
			end
		end
		-- msg format is: act,[filename]#[scode]
		local body = string.format("act,%s#%s", filename, sCode);
		return self:Send({action="sendmsg",data_table={dest_nid=JidToNid(jid),msg=body}}, bIgnoreRateController);
	end
	return true;
end

-- Send a NPL message. 
-- @param to: JID such as lxz@paraengine.com
-- @param neuronfile: a NPL table converted to secure code.
-- @param sCode: must be pure msg data, such as "msg = {x=0}"
function NPLJabberClient:WriteNPLMessage(to, neuronfile,  sCode)
	-- TODO:
end

-- Send raw string. 
function NPLJabberClient:WriteRawString(rawstring)
	-- TODO:
end

-- Initiate the auth process.
function NPLJabberClient:Login()
	self.OnAuthenticatedCalled = false;
end

--[[ Send a presence packet to the server
@param t: [not supported] -1
@param status: [not supported] "How to show us?" 
@param show: the signature or short message. If nil, it maintains the old value.
@param priority: [not supported] How to prioritize this connection. Higher number mean higher priority.  0 minumum, 127 max.  -1 means this is a presence-only connection.</param>
@param group_id:[optional] the family group id.  If nil, it maintains the old value. This field is only supported by the im server not XMPP. 
]]
function NPLJabberClient:SetPresence(t,status,show,priority, group_id)
	if(show and self.signature ~= show) then
		self.signature = show;
		self.IsPresenceChanged = true;
	end
	if(group_id) then
		if(self.group_id ~= group_id) then
			self.IsPresenceChanged = true;
			if(self.group_id ~= -1) then
				-- if user leaves its old group, we shall remove it. 
				self:Send({action="delmember", data_table={group_id=self.group_id, del_user_nid=self.nid}}, true)
			end				
			self.group_id = group_id;
		end	
	end
end

-- message type
NPLJabberClient.MessageType = {
	normal = -1,
	error,
	chat,
	groupchat,
	headline,
	online_only = 100, -- added by LiXizhi, 2011.6.13
}
--[[ Send a message packet to another user
<param name="t">What kind?
	public enum MessageType
	{
		normal = -1,
		error,
		chat,
		groupchat,
		headline,
		online_only = 100, -- added by LiXizhi, 2011.6.13
	}
</param>
<param name="to">Who to send it to?</param>
<param name="body">The message.</param>
]]
function NPLJabberClient:Message(t, to, body)
	if(type(t) ~= "number" and not body) then
		return self:Message2(t, to);
	end
	-- commonlib.echo({"NPLJabberClient:Message", t, to, body})
	
	if(t == -1) then
		-- msg format is: #[msg]
		body = "#"..(body or "");
		return self:Send({action="sendmsg", data_table={src_nid=self.nid,dest_nid=JidToNid(to),msg=body}})

	elseif(t == self.MessageType.online_only) then
		-- For online only messages 	
		body = "#"..(body or "");
		return self:Send({action="sendmsg_to_any", data_table={src_nid=self.nid,dest_nid=JidToNid(to),msg=body}})
	end	
end

function NPLJabberClient:Message2(to, body)
	return self:Message(-1, to, body);
end

--[[ Get a full roster 
-- @return: the returned string is NPL table of the following 
{
	{jid=string:jid, name=string,subscription=int:SubscriptionEnum, online=true, groups={string, string, ...}, resources={name={presence=int, priority=int, message=string}, ...},},
	{jid=string:jid, name=string,subscription=int:SubscriptionEnum, online=true, groups={string, string, ...}, resources={name={presence=int, priority=int, message=string}, ...},},
	{jid=string:jid, name=string,subscription=int:SubscriptionEnum, groups={string, string, ...}, resources={name={presence=int, priority=int, message=string}, ...},},
	...
}
In most cases, each jid has only one resource, but multiple is supported. Item presence info is in resources[name] table.
{presence=int, priority=int, message=string}, where priority is resource priority, presence is the Presence Enum, message is the user message after its name. 
]]
function NPLJabberClient:GetRoster()
	return self.roster;
end

-- Use this function to subscribe to a new JID. The contact is added to the roster automatically
-- (by compliant servers, as required by RFC 3921).
-- @param jid The address to subscribe to.
-- @param name The displayed name of the contact.
-- @param groups A list of groups the contact belongs to. separated by ";". Currently only one group is supported. 
-- @param msg A message sent along with the request.
function NPLJabberClient:Subscribe(jid, name, groups, msg)
	local user_nid = JidToNid(jid)
	-- commonlib.echo({"NPLJabberClient:Subscribe", user_nid, name, groups, msg})
	
	-- Anyway, the logics in the simplified server is that we can subcribe to some one without their consent. 
	self.IsRosterChanged = self:UpdateRosterItem(JidToNid(jid), nil, nil) or self.IsRosterChanged;
end


-- Use this function to unsubscribe from a contact's presence. You will no longer
-- receive presence from this contact.
-- This will have the side-effect of bi-directionally unsubscribing to/from the user.
-- @param to: The JID to remove
-- @param msg A message to send along with the request.
function NPLJabberClient:Unsubscribe(to, msg)
	self.IsRosterChanged = true;
	
	local nid = JidToNid(to)
	
	local bFound;
	local index, r
	for index, r in ipairs(self.roster) do
		if(r.nid == nid) then
			bFound = true;
			break;
		end
	end
	if(bFound) then
		table.remove(self.roster, index);
		self.roster_members[nid] = nil;
	end
end

-- this function is called in OnSubscription method to confirm or refuse a subscription request from another user. 
-- @param to: the JID
-- @param bAllow: true to allow subscription, false to deny
function NPLJabberClient:AllowSubscription(to, bAllow)
	-- Anyway, the logics in the simplified IM server is that we can subscribe to some one without their consent. 
	if(bAllow) then
		self:Subscribe(to, "", nil, nil);
	else	
		-- TODO: shall we refuse it by telling the server to remove me from the caller 's roster?
	end
end

-- Not supported: all event types
local JABBERLISTENER_TYPE = {
	[0] = "JE_OnFamilyPresence",
}

-- add a NPL call back script to a given even listener
-- there can only be one listener per type per instance. 
-- @param ListenerType: number or string JABBERLISTENER_TYPE
-- @param callbackScript: the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
--   if callbacksScript is string and convertable to a global function such as "a.b.callback()", it will be saved as a function pointer. 
function NPLJabberClient:AddEventListener(ListenerType, callbackScript)
	if(type(ListenerType) == "number") then
		ListenerType = JABBERLISTENER_TYPE[ListenerType]
	end
	
	if(type(callbackScript) == "function") then
		self.events:AddEventListener(ListenerType, callbackScript, self);
	elseif(type(callbackScript) == "string") then
		-- commonlib.echo({"jc event registered", ListenerType, callbackScript})
		local funcCallback = commonlib.getfield(callbackScript);
		if(type(funcCallback) == "function") then
			callbackScript = funcCallback;
		end
		self.event_cb_scripts[ListenerType] = callbackScript;
	end
end

-- remove a NPL call back script from a given even listener
-- @param ListenerType: number or string JABBERLISTENER_TYPE
-- @param callbackScript: if nil, all callback of the type is removed. the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
function NPLJabberClient:RemoveEventListener(ListenerType, callbackScript)
	if(callbackScript == nil) then
		if(type(ListenerType) == "number") then
			ListenerType = JABBERLISTENER_TYPE[ListenerType]
		end
		
		if(ListenerType ~= "") then
			if(type(ListenerType) == "number") then
				ListenerType = JABBERLISTENER_TYPE[ListenerType]
			end
			self.events:RemoveEventListener(ListenerType);
			self.event_cb_scripts[ListenerType] = nil;
		end
	else
		-- TODO: remove only the given callback 
	end	
end
-- clear all NPL call back script from a given even listener
-- @param ListenerType: number or string JABBERLISTENER_TYPE
function NPLJabberClient:ClearEventListener(ListenerType)
	return self:RemoveEventListener(ListenerType);
end

-- clear all registered event listeners
function NPLJabberClient:ResetAllEventListeners()
	self.events:ClearAllEvents();
	self.event_cb_scripts = {};
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type, ...}, where the type is the event_name or id(JABBERLISTENER_TYPE), other fields will sent as they are. 
function NPLJabberClient:FireEvent(event)
	if(type(event.type) == "number") then
		event.type = JABBERLISTENER_TYPE[event.type];
	end
	
	event.jckey = self.jid;
	self.events:DispatchEvent(event, self)
	
	local callbackFunc = self.event_cb_scripts[event.type];
	if(callbackFunc) then
		msg = event;
		-- commonlib.echo({"jc event fired", self.event_cb_scripts[event.type], msg})
		if(type(callbackFunc) == "function") then
			callbackFunc(self, msg);
		else
			NPL.DoString(callbackFunc);
		end	
	end
end

-- private: called when roster item is added or updated
-- if there is roster item, we will add one
-- @param nid: number
-- @param presence: 0 or "offline" if online, 5 or "offline" if offline.  This can be nil, which does not change previous value. 
-- @param msg: the signature message
-- @return true if at least some field is updated. 
function NPLJabberClient:UpdateRosterItem(nid, presence, msg)
	if(type(presence) == "string") then
		if(presence == "online") then
			presence = 0;
		else
			presence = 5;
		end
	end
	
	local bUpdated, bPresenceChanged; 
	local r = self.roster_members[nid];
	if(r) then
		-- update existing item
		r.name = tostring(nid);
		if(presence~=nil and r.presence ~=presence) then
			bUpdated = true;
			r.presence = presence
			r.online = (presence == 0);
			r.resources["pe"].presence = presence;
			bPresenceChanged = true;
		end
		r.groups = nil;
		if(msg~=nil and r.msg ~=msg) then
			bUpdated = true;
			r.msg = msg;
			r.resources["pe"].msg = msg;
		end	
	else
		-- insert if not exist
		bUpdated = true;
		local online = (presence==0);
		if(presence == nil) then
			presence = 5;
		end
		bPresenceChanged = online;
		local item = {jid = self:GetJidFromNid(nid), nid = nid, name=tostring(nid), subscription = 4, presence = presence, online = online, msg = msg, groups = {}, resources={["pe"] = {presence = presence, priority=0, message = msg}}};
		self.roster[#(self.roster) + 1] = item
		self.roster_members[nid] = item;
	end	
	return bUpdated, bPresenceChanged;
end


-- public: return true if nid is online. 
function NPLJabberClient:IsOnline(nid)
	local res = (self:GetPresence(nid) == 0);
	if(not res) then
		return self.online_nids[tonumber(nid)];
	else
		return res;	
	end
end

-- public: search if a given friedn member is online or not. 
-- @param nid; nid number
-- @return: 0 if online, 5 if offline or does not exist. 
function NPLJabberClient:GetPresence(nid)
	local item = self.roster_members[tonumber(nid)]
	if(item) then
		return item.presence;
	else	
		return 5;
	end
end

-- private: this makes nid online, if we have just received a message from a given nid, we will make it online immediately. 
function NPLJabberClient:MakeOnline(nid)
	local nid = tonumber(nid);
	self.online_nids[nid] = true;
	local item = self.roster_members[nid];
	if(item and not item.online) then
		item.presence = 0;
		item.online = true;
	end
	
	local item = self.group_members[nid];
	if(item and item.presence~=0) then
		item.presence = 0;
		item.online = true;
	end
end

-------------------------
-- group, family, MUC related functions
-------------------------
-- private: called when a group member is online or offline. 
function NPLJabberClient:UpdateGroupItem(nid, presence)
	if(type(presence) == "string") then
		if(presence == "online") then
			presence = 0;
		else
			presence = 5;
		end
	end
	nid = tonumber(nid);
	local bUpdated, bPresenceChanged; 
	local r = self.group_members[nid];
	if(r) then
		r.name = tostring(nid);
		if(presence~=nil and r.presence ~=presence) then
			bUpdated = true;
			r.presence = presence
			r.online = (presence == 0);
			bPresenceChanged = true;
		end
	else
		-- insert if not exist
		bUpdated = true;
		local online = (presence==0);
		bPresenceChanged = online;
		self.group_members[nid] = {jid = self:GetJidFromNid(nid), nid = nid, name=tostring(nid), subscription = 4, presence = presence or 5, online = online,};
	end	
	return bUpdated, bPresenceChanged;
end

-- private: called when roster item is changed
-- @param nid: number
-- @param presence: "online", "offline"
-- @param msg: string of signature or message
-- @param group: "family", "normal".  whether presence is for user in our family group or friend group.  
function NPLJabberClient:UpdatePresence(nid, presence, msg, group)
	if(presence == "online") then
		presence = 0; -- "available"
	else
		presence = 5; -- "Unavailable"
	end
	
	if(presence == 5) then
		-- remove from online presence list if explicitly received an offline message. 
		self.online_nids[nid] = nil;
	end
	
	if(group == "normal") then
		-- add or update roster item
		local _, bPresenceChanged = self:UpdateRosterItem(nid, presence, msg)
		if(bPresenceChanged) then
			self:FireEvent({type="JE_OnRosterPresence", jid = self:GetJidFromNid(nid), msg = msg, presence = presence, resource="pe"})
		end	
		
	elseif(group == "family") then
		-- add or update family member presence
		-- add or update roster item
		local _, bPresenceChanged = self:UpdateGroupItem(nid, presence, nil)
		if(bPresenceChanged) then
			self:FireEvent({type="JE_OnFamilyPresence", nid = nid, jid = self:GetJidFromNid(nid), msg = msg, presence = presence, resource="pe"})
		end	
	end
end

-- join a given room and leave previous one. 
-- @param room_id: number of family id (self.group_id). -1 means leave room. 
function NPLJabberClient:JoinRoom(room_id)
	if(self.group_id ~= room_id) then
		self.group_id = room_id;
		-- this will cause the group_id to be sent in the next update message. 
		self.IsPresenceChanged = true;
	end
end

-- leave current room. 
function NPLJabberClient:LeaveRoom()
	--if(self.group_id > 0) then
		--self:Send({action="delmember", data_table={group_id=self.group_id, del_user_nid=self.nid}}, true);
	--end
	self:JoinRoom(-1);
end

-- send muc message to the room. 
-- @param text: the string to send, it will be received via the BBS chat interface. 
function NPLJabberClient:SendMucMessage(text)
	-- send MUC message to the current room
	return self:Send({action="sendgroupmsg", data_table={msg=text, group_id = self.group_id},});
end

-- get all online users in the room
-- mapping from nid(number) to {presence=0(online):5(offline)}
function NPLJabberClient:GetRoomUsers()
	return self.group_members;
end

-- return true if nid is online. 
function NPLJabberClient:IsGroupMemberOnline(nid)
	return (self:GetGroupMemberPresence(nid) == 0)
end

-- search if a given family member is online or not. 
-- @return: 
function NPLJabberClient:GetGroupMemberPresence(nid)
	local m = self.group_members[tonumber(nid)];
	if(m) then
		return m.presence
	else
		return 5;
	end
end

-- called periodically. 
function NPLJabberClient:OnTimer(timer)
	-- check current game server for connection and authentication status. 
	if(not self.client) then return end
	
	local isConnected = self.client:IsConnected();
	local isAuthenticated = self.client:IsSignedIn();
	
	if(not self.OnConnectCalled and self.IsConnected) then
		self.OnConnectCalled = true;
		self:FireEvent({type="JE_OnConnect", })
	end
	if(not self.OnAuthenticatedCalled and self.IsAuthenticated) then
		self.OnAuthenticatedCalled = true;
		self:FireEvent({type="JE_OnAuthenticate", })
		
		-- send the first login message to router. 
		-- TODO: needs to update signature and group_id here. 
		-- self.IsPresenceChanged = true;
	end
	if(self.IsConnected and not isConnected) then
		self.OnConnectCalled = false;
		self.OnAuthenticatedCalled = false;
		self:FireEvent({type="JE_OnDisconnect", })
	end
	self.IsConnected = isConnected;
	self.IsAuthenticated = isAuthenticated;
	
	if(isAuthenticated) then
		-- send roster or presence changes if any. 
		if(self.IsRosterChanged) then
			self.IsRosterChanged = false;
			self.IsPresenceChanged = false;
			local roster_ = {};
			local _, r
			for _, r in ipairs(self.roster) do
				roster_[#roster_+1] = JidToNid(r.jid);
			end
			local roster_list = table.concat(roster_, ",")..",";
			self:Send({action="setroster", data_table={signature=self.signature,roster_list=roster_list, last_online_time=0,group_id=self.group_id}}, true);
		end			
		if(self.IsPresenceChanged) then
			self.IsPresenceChanged = false;
			-- msg={action="setpresence", game_nid=1002,g_rts=1,data_table={[presence="online"|"offline"], signature="1@1002-14431795",group_id=1},}
			self:Send({action="setpresence", data_table={signature=self.signature, group_id = self.group_id},}, true);
			--if(self.group_id and self.group_id > 0) then
				--self:Send({action="setpresence", data_table={signature=self.signature, group_id = self.group_id},}, true);
			--else
				--self:Send({action="setpresence", data_table={presence="offline", signature=self.signature, group_id = self.group_id},}, true);
			--end
		end
	end
	-- TODO: sync all friends list every 5 mins. 
end

--------------------
-- team related methods
--------------------
-- get the team member
function NPLJabberClient:GetTeam()
	return self.team;
end

function NPLJabberClient:PrintTeam()
	commonlib.echo({"dumping for nid", nid = self.nid});
	local item = self.team:first();
	while (item) do
		commonlib.echo({item.nid, });
		item = self.team:next(item)
	end
end

-- whether current user is the team leader. 
function NPLJabberClient:IsTeamLeader()
	local first_member = self.team:first();
	if(first_member) then
		if(first_member.nid == tonumber(self.nid)) then
			return true;
		end
	end
end

-- is nid the current player. 
function NPLJabberClient:IsSelf(nid)
	return (tonumber(self.nid) == tonumber(nid)) 
end

-- return the team leader nid. if not in a team, this function will return nil.
function NPLJabberClient:GetTeamLeaderNid()
	local first_member = self.team:first();
	if(first_member) then
		return first_member.nid;
	end
end

-- whether we are in a team. 	
function NPLJabberClient:IsInTeam()
	if(self.team:size() > 1) then
		return true;
	end
end

-- whether we are in a team. 	
function NPLJabberClient:IsInOtherTeam()
	if(self.others_team:size() > 1) then
		return true;
	end
end

-- whether we are in a team. 	
function NPLJabberClient:IsTeamFull()
	if(self.team:size() >= 4) then
		return true;
	end
end

-- get a team member by its nid. 
-- @return nil if not found. 
function NPLJabberClient:GetTeamMemberByNid(nid)
	nid = tonumber(nid);
	if(nid) then
		item = self.team:first();
		while (item) do
			if(item.nid == nid) then
				return item;
			end
			item = self.team:next(item)
		end
	end
end

-- current index(position) of the player in the team
function NPLJabberClient:GetTeamMemberIndexByNid(nid)
	nid = tonumber(nid);
	if(nid) then
		local nIndex = 1;
		item = self.team:first();
		while (item) do
			if(item.nid == nid) then
				return nIndex;
			end
			nIndex = nIndex + 1;
			item = self.team:next(item)
		end
	end
end

-- sending a message to the entire team 
-- @param msg: a table or a string. 
-- @param bIgnoreRateControl: true to ignore sending message rate controller. 
function NPLJabberClient:SendTeamMessage(msg, bIgnoreRateControl)
	return self:Send({action="sendteammsg", data_table={msg=msg},}, bIgnoreRateControl);
end

-- Only the team leader can call this function to make a given user member of the current team. 
-- @param nid: the new team member's nid.
function NPLJabberClient:AddTeamMember(nid)
	nid = tonumber(nid);
	if(nid) then
		return self:Send({action="addteam_member", data_table={dest_nid=nid},}, true);
	end
end

-- Only the team leader can call this function to make a given user leader of the current team. 
-- @param nid: the new team leader's nid. This member may or may not be an existing team leader. 
function NPLJabberClient:SetTeamLeader(nid)
	nid = tonumber(nid);
	if(nid) then
		return self:Send({action="setteam_leader", data_table={dest_nid=nid},}, true);
	end
end
		
-- The team leader can call this function to delete a given user member from the current team. 
-- If the team member calls this function it will leaves its current team. 
-- @param nid: the team member's nid to delete. It can be self's nid, in which case it means that the local nid leaves the current team. 
function NPLJabberClient:DelTeamMember(nid)
	nid = tonumber(nid);
	if(nid) then
		return self:Send({action="delteam_member", data_table={dest_nid=nid},}, true);
	end
end

-- any one can call this function to join a remote team. 
function NPLJabberClient:TeamJoinMember(nid)
	nid = tonumber(nid);
	if(nid) then
		return self:Send({action="team_join", data_table={dest_nid=nid},});
	end
end

-- any one can call this function to reject a user apply for team. 
function NPLJabberClient:TeamRejectJoin(nid)
	nid = tonumber(nid);
	if(nid) then
		return self:Send({action="join_reject", data_table={dest_nid=nid},}, true);
	end
end

-- any one can call this function to invite a member to its current team. The team leader of the current team will receive the message. 
function NPLJabberClient:TeamInviteMember(nid)
	nid = tonumber(nid);
	if(nid) then
		return self:Send({action="team_invite", data_table={dest_nid=nid},});
	end
end

-- this will cause the "setteam" message to be sent by the server to update the current team. 
-- it is recommended to call this function to resume the team status upon login. 
function NPLJabberClient:TeamQuery(nid)
	if (not nid) then
		return self:Send({action="queryteam", data_table={queried_nid=tonumber(self.nid)},});
	else
		return self:Send({action="queryteam", data_table={queried_nid=tonumber(nid)},});
	end
end

--------------------
-- ClientManager: a client manager or factory
--  it has the same interface as the native JabberClientManager
--------------------
local JabberClientManager = commonlib.gettable("IMServer.JabberClientManager");

-- one can use this to determine which JabberClientManager we are using
JabberClientManager.type = "IMServer.JabberClientManager";

-- all known clients, mapping from server_jid string to client object. 
local clients = {};

local invalid_client = NPLJabberClient:new();

-- get an existing jabber client instance interface by its JID.
-- If the client is not created using CreateJabberClient() before, function may return an invalid object.
-- @param jid: such as "lixizhi@paraengine.com"
function JabberClientManager.GetJabberClient(jid)
	return clients[jid] or invalid_client;
end

-- Create a new jabber client instance with the given jabber client ID. It does not open a connection immediately.
-- @param sJID: such as "lixizhi@paraweb3d.com"
function JabberClientManager.CreateJabberClient(jid)
	jid = jid or "";
	if(not clients[jid]) then
		-- create one 
		local client = NPLJabberClient:new();
		client:SetJID(jid);
		clients[jid] = client;
	end
	return JabberClientManager.GetJabberClient(jid);
end

-- close a given jabber client instance. Basically, there is no need to close it, 
-- unless one wants to reopen it with different credentials
-- @param jid: such as "lixizhi@paraweb3d.com", if this is "", it will close all jabber clients.
function JabberClientManager.CloseJabberClient(jid)
	if(not jid or jid=="") then
		local client,_
		for _, client in pairs(clients) do
			client:Close();
		end
	else
		local client = JabberClientManager.GetJabberClient(jid);
		client:Close();
	end
	return true;
end

-- add string a string mapping. We will automatically encode NPL filename string if it is in this string map. It means shorter message sent over the network. 
-- use AddStringMap whenever you want to add a string to the map. Please note, that the sender and the receiver must maintain the same string map in memory in order to have consistent string translation result.
-- the function is static, it will apply to all client instances. 
-- @param nID: the integer to encode the string. it is usually positive. 
-- @param sString: the string for the id. if input is NULL, it means removing the mapping of nID. 
function JabberClientManager.AddStringMap(nID, sString)
	LOG.std("", "error", "IM", "AddStringMap Not Implemented\n");
end

function JabberClientManager.ClearStringMap()
	LOG.std("", "error", "IM", "ClearStringMap Not Implemented\n");
end

-- for trusted files
local trusted_files;

-- add a public file, so that NPLJabberClient:AddPublicFile(filename, id)
-- this function is similar to NPL.AddPublicFile()
-- @param filename: any string of file name. case sensitive. 
-- @param id: id of the file. 
function JabberClientManager.AddPublicFile(filename, id)
	if(not trusted_files) then
		NPL.load("(gl)script/ide/stringmap.lua");
		trusted_files = commonlib.stringmap:new()
	end
	trusted_files:add(filename, id);
end

-- whether the file is trusted. 
function JabberClientManager.IsFileTrusted(filename)
	if(trusted_files) then
		return (trusted_files:GetID(filename)~=nil)
	else
		-- security alert: one should call AddPublicFile() instead of trust all files. 
		return true;	
	end
end

-- protected: Find client by jid or nid. 
-- @param nid: nid or jid. both string or number are supported. 
function JabberClientManager.FindJabberClient(nid)
	nid = JidToNid(nid);
	local jid, c, client;
	for jid,c in pairs(clients) do
		if(c.nid == nid) then
			client = c;
			break;
		end
	end	
	return client
end

-- private: parse roster from string
-- @param roster_nids: such as "111,222,333,", it can either end with or without commar
-- @param roster_sigs: such as "aaa,bbb,ccc,", it can either end with or without commar
-- @return: { {nid = 111, sig="aaa"},  {nid = 222, sig="bbb"},  {nid = 333, sig="ccc"},},  {[111]=true, [222]=true, [333] = true}
function JabberClientManager.ParseRosterListString(roster_nids, roster_sigs)
	local roster = {};
	local nid_maps = {};
		
	local nids = {};
	local nid;
	for nid in string.gmatch(roster_nids, "%d+") do
		nid = tonumber(nid);
		table.insert(roster, {nid = nid})
		nid_maps[nid] = true;
	end
	
	local sigs = {};
	local sig;
	local i = 1;
	for sig in string.gmatch(roster_sigs, "([^,]*),?") do
		if(roster[i]) then
			roster[i].sig = sig;
			i = i + 1;
		else
			break;
		end
	end
	return roster, nid_maps;
end

function JabberClientManager.Activate(msg)
	if(debug_stream) then
		LOG.std("", "info", "IM", "IMServer_client received:");
		LOG.std("", "info", "IM", msg);
	end	
	
	if(not msg.nid) then return end
	
	local client = JabberClientManager.FindJabberClient(msg.user_nid);
	if(not client) then
		LOG.std("", "warning", "IM", "warning: unknown nid %s msg from IMServer_client", msg.user_nid);
		return;
	end
	local from, from_nid;
	if(msg.data_table and msg.data_table.src_nid) then
		from_nid = msg.data_table.src_nid;
		from = client:GetJidFromNid(from_nid);
	end
	
	local action = msg.action;
	if(action == "normalmsg" or action == "offline_msg") then
		-- msg={action="normalmsg",data_table={dest_nid=8509696,msg="send to online user,not friend!",src_nid=14431795,},dest="imclient",user_nid=8509696,ver="1.0",}
		-- msg={action="offline_msg",data_table={dest_nid=2440510,msg="send to offline user,friend!",msg_time=1274233935,src_nid=14431795,},dest="imclient",user_nid=2440510,ver="1.0",}
		if(from) then
			local is_offline_msg = (action == "offline_msg")
			if(not is_offline_msg) then
				-- if we received a real time message from a given nid, then we will mark it online. 
				client:MakeOnline(from_nid);
			end
			
			local header, body = string.match(msg.data_table.msg, "^([^#]*)#(.*)$");
			if(header == "") then
				client:FireEvent({type="JE_OnMessage", subtype = 1, from = from, subject="", body = body, is_offline = is_offline_msg, msg_time=msg.data_table.msg_time});
			elseif(header) then
				-- this is an activate message. 
				local filename = string.match(header, "^act,(.*)$");

				if(filename and body) then
					-- verify with trusted list here. 
					if( JabberClientManager.IsFileTrusted(filename) ) then
						local body = string.match(body, "^msg=(.*);?$");
						if(body) then
							body = NPL.LoadTableFromString(body);
							if(body) then
								body.jckey = client.jid;
								NPL.activate("(gl)"..filename, body);
							end
						end	
					else
						LOG.std("", "warning", "IM", "warning: you do not have access to activate the file %s using jc:activate. Please call jc:AddPublicFile()", filename);
					end	
				end
			end	
		else
			LOG.std("", "system", "IM", "IMServer_client: normalmsg missing from field")	
		end
	
	elseif(action == "set_presence") then
		-- msg={action="set_presence",data_table={friend_nid=8509696,friend_type="family",presence="online",signature="1@1002-8509696",},dest="imclient",user_nid=14431795,ver="1.0",}
		if(msg.data_table and msg.data_table.friend_nid) then
			client:UpdatePresence(msg.data_table.friend_nid, msg.data_table.presence, msg.data_table.signature, msg.data_table.friend_type);
		end
	elseif(action == "set_online_friend_list") then
		-- msg={action="set_online_friend_list",data_table={online_roster="123026,14431795,",signature_list="1@1002-123026,1@1002-14431795,",},dest="imclient",user_nid=12345671,ver="1.0",}
		if(msg.data_table and msg.data_table.online_roster and msg.data_table.signature_list) then
			-- make offline for all friends not in the list. and make online for all in the list
			local roster, nid_maps = JabberClientManager.ParseRosterListString(msg.data_table.online_roster, msg.data_table.signature_list);
			
			local _, r 
			for _, r in ipairs(roster) do
				client:UpdatePresence(r.nid, "online", r.sig, "normal");
			end
			for _, r in ipairs(client.roster) do
				if(not nid_maps[r.nid]) then
					client:UpdatePresence(r.nid, "offline", r.sig, "normal");
				end
			end
		end
		-- mark self as available. 
		client:FireEvent({type="JE_OnSelfPresence", jid = client.jid, presence = 0, resource="pe"})
		
	elseif(action == "set_online_group_list") then
		-- msg={action="set_online_group_list",data_table={online_roster="14431795,8509696,123026,12345671,",signature_list="1@1002-14431795,1@1002-8509696,1@1002-123026,1@1002-12345671,",},dest="imclient",user_nid=12345671,ver="1.0",}
		local roster, nid_maps = JabberClientManager.ParseRosterListString(msg.data_table.online_roster, msg.data_table.signature_list);
			
		local _, r 
		for _, r in ipairs(roster) do
			client:UpdatePresence(r.nid, "online", r.sig, "family");
		end
		for _, r in pairs(client.group_members) do
			if(not nid_maps[r.nid]) then
				client:UpdatePresence(r.nid, "offline", r.sig, "family");
			end
		end
		
	elseif(action == "group_message" or action == "offline_group_msg") then
		-- msg={action="group_message",data_table={friend_type="normal",group_id=1,msg="test send group msg", src_nid=14431795,},dest="imclient",user_nid=12345671,ver="1.0",}
		-- msg={action="offline_group_msg",data_table={dest_nid=14431795,msg="test send group msg",msg_time=1273564488,src_nid=14431795,},dest="imclient",user_nid=14431795,ver="1.0",}
		
		if(from) then
			local is_offline_msg = (action == "offline_group_msg")
			if(not is_offline_msg) then
				-- if we received a real time message from a given nid, then we will mark it online. 
				client:MakeOnline(from_nid);
			end
			
			client:FireEvent({type="JE_OnFamilyMessage", from = from_nid, group_id = client.group_id, is_offline = is_offline_msg, msg = msg.data_table.msg});
		else
			LOG.std("", "system", "IM", "IMServer_client: normalmsg missing from field")	
		end
	elseif(action == "setteam") then
		-- received whenever the team member has changed. 
		-- msg={action="setteam",data_table={team_member="14431795,8509696,123026,",team_number=3,},dest="imclient",user_nid=12345671,ver="1.0",}
		if(msg.data_table and msg.data_table.team_member) then
			local team_member = msg.data_table.team_member;
			local nIndex = 0;
			local member_nid;
			local cur_team = client.team:first();
			local local_nid = tonumber(client.nid);
			local bHasLocalUser;
			local new_team = {};
			for member_nid in string.gmatch(team_member, "%d+") do
				member_nid = tonumber(member_nid);
				if(member_nid) then
					if(member_nid == local_nid) then
						bHasLocalUser = true;
					end
					new_team[#new_team+1] = client:GetTeamMemberByNid(member_nid) or  {nid = member_nid};
				end
			end
			local index, member

			if(not bHasLocalUser or #new_team <= 1) then
				-- if there is no current user or there is only local user in the team, clear all. 
				-- the client is no longer in any team. 
				client.team:clear();
			else
				client.team:clear();
				for index, member in ipairs(new_team) do
					client.team:add(member);
				end
			end
			-- send team update
			client:FireEvent({type="JE_OnTeamUpdate", team = client.team});
		end
	elseif(action == "setteam_other") then
		-- received whenever the team member has changed. Queryteam by other's nid, and get other's team.
		-- msg={action="setteam",data_table={team_member="14431795,8509696,123026,",team_number=3,},dest="imclient",user_nid=12345671,ver="1.0",}
		if(msg.data_table and msg.data_table.team_member) then
			local team_member = msg.data_table.team_member;
			local nIndex = 0;
			local member_nid;
			local cur_team = client.others_team:first();
			local new_team = {};
			for member_nid in string.gmatch(team_member, "%d+") do
				member_nid = tonumber(member_nid);
				if(member_nid) then
					new_team[#new_team+1] = {nid = member_nid};
				end
			end
			local index, member

			if( #new_team <= 1) then
				client.others_team:clear();
			else
				client.others_team:clear();
				for index, member in ipairs(new_team) do
					client.others_team:add(member);
				end
			end
			-- send team update
			client:FireEvent({type="JE_OnTeamUpdate", others_team = client.others_team});
		end
	elseif(action == "team_message") then
		-- received a team message
		if(msg.data_table and msg.data_table.msg) then
			client:FireEvent({type="JE_OnTeamMessage", msg = msg.data_table.msg, from = tonumber(msg.data_table.src_nid)});
		end
	elseif(action == "join_reject") then
		if(msg.data_table) then
			client:FireEvent({type="JE_OnTeamMessage", msg = {type = action}, from = tonumber(msg.data_table.src_nid)});
		end
	elseif(action == "invite_unable" or action == "addteammember_fail" or action == "join_fail") then
		if(msg.data_table) then
			client:FireEvent({type="JE_OnTeamMessage", msg = {type = action}, from = tonumber(msg.data_table.dest_nid)});
		end
	elseif(action == "team_join" or action == "team_invite") then
		if(msg.data_table) then
			local sWorldId = tonumber(msg.data_table.src_worldid) or 0;
			local sGameId = tonumber(msg.data_table.src_gameid) or 0;
			client:FireEvent({type="JE_OnTeamMessage", msg = {type = action, src_worldid=sWorldId, src_gameid=sGameId}, from = tonumber(msg.data_table.src_nid)});
		end
	end
end

local function activate()
	JabberClientManager.Activate(msg);
end

NPL.this(activate)