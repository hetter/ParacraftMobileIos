NPL.load("(gl)script/ide/mysql/mysql.lua");
NPL.load("(gl)script/apps/DBServer/DBSettings.lua");

local luasql = commonlib.luasql;
local DBSettings = commonlib.gettable("DBServer.DBSettings");

local DataAccess = commonlib.gettable("DBServer.DataAccess");

function DataAccess:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function DataAccess:getTbIndex(nid)
	return math.mod(nid, DBSettings.tbCnt());
end

function DataAccess:getDbIndex(nid)
	return math.floor(self:getTbIndex(nid) / DBSettings.dbCnt());
end

function DataAccess:getConnectionCnf(nid)
	local iDBIndex = self:getDbIndex(nid);
    return DBSettings.getCN("cn" .. tostring(iDBIndex));
end


function DataAccess:convertConnection(cnfCn)
	local _env = assert(luasql.mysql());
	return {env = _env, cn = _env:connect(cnfCn["Initial Catalog"], cnfCn["user id"], cnfCn["password"], cnfCn["Data Source"])};
end

function DataAccess:getConnection(nid)
	local _cnf = self:getConnectionCnf(nid);
	if(_cnf) then
		return self:convertConnection(_cnf);
	end
	return nil;
end

function DataAccess:getConnection_Items()
	local _cnf = DBSettings.getCN("mySQLItems");
	if(_cnf) then
		return self:convertConnection(_cnf);
	end
	return nil;
end


--[[
function DataAccess:execReader(cn, sql)
  local _cur = assert(cn:execute(sql));
  return function()
    return _cur:fetch({}, "a");
  end;
end
]]

function DataAccess:execReader(cn, sql, ctoFun, isLock)
	local _list = {};
	if isLock then
		cn:setautocommit(false);
	end
	local _cur = assert(cn:execute(sql));
	local _row = _cur:fetch ({}, "a");
	while _row do
		table.insert(_list, ctoFun(_row));
		_row = _cur:fetch(_row, "a");
	end
	_cur:close();
	return _list;
end