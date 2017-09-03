--[[
Author: LiXizhi
Date: 2013-5-8
Desc: request manager for db server. It will spawn a new coroutine for each DBrequest, and automatically handle timeout if no request is returned. 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/DBServerRequestManager.lua");
local RequestManager = commonlib.gettable("DBServer.RequestManager")
RequestManager.Init()
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
local RequestManager = commonlib.gettable("DBServer.RequestManager")

-- global default timeout in milliseconds. 
local default_timeout = 5000;
-- in milliseconds. 
local framemove_interval = 1000;

-- all request coroutines that is running and not returned. we will check them periodialy, and send timeout. 
local request_co_map = {};

local format = format;

function RequestManager.Init()
	RequestManager.mytimer = RequestManager.mytimer or commonlib.Timer:new({callbackFunc = RequestManager.FrameMove})
	RequestManager.mytimer:Change(framemove_interval, framemove_interval);
end

-- this function should be called once every second, to terminate and discard unused request. 
function RequestManager.FrameMove()
	-- TODO: remove timed out requests. may be resume co with error message?
end

-- handle a given request
-- @param filename: the API filename
-- @param msg: the msg
-- @param timeout: timeout 
function RequestManager.HandleRequest(filename, msg, timeout)
	local co = coroutine.create(RequestManager.HandleRequest_Coroutine)
	local status, result = coroutine.resume(co, filename, msg, co);
	if not status then
		LOG.std(nil, "error", "TableDAL", debug.traceback(co));
	else
		-- suspended, running, and dead
		if(coroutine.status(co) ~= "dead") then
			-- adding to a pool for time out handling
			if(timeout) then
				-- TODO:
				-- request_co_map[co] = timeout;
			end
		end
	end
end

-- this is coroutine handler for all requests
function RequestManager.HandleRequest_Coroutine(filename, msg, co)
	-- TODO: for each filename, call the file handler. 
	-- example code
	if(filename == "GetInBag") then
		local msg, msg1;
		msg = InstanceBLL.getInBag(nid, bag, co);
		msg1 = UserBLL.getByNID(nid, co);
		if(msg and msg1) then
			-- TODO: return to user
		end
	end
end

