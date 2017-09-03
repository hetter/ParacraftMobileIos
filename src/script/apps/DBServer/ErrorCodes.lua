--[[
NPL.load("(gl)script/apps/DBServer/ErrorCodes.lua");
local ErrorCodes = commonlib.gettable("DBServer.ErrorCodes");
]]

NPL.load("(gl)script/ide/commonlib.lua");

local ErrorCodes = commonlib.gettable("DBServer.ErrorCodes");

ErrorCode["P币和信用度不够"] = 411;
ErrorCode["用户不存在或不可用"] = 419;
ErrorCode["购买数量超过限制"] = 424;
ErrorCodes["条件不符"] = 427;
ErrorCode["超过单日购买限制"] = 428;
ErrorCode["超过周购买限制"] = 429;
ErrorCode["超过小时总购买数"] = 436;
ErrorCode["超过当天总购买数"] = 437;
ErrorCode["魔豆不足"] = 443;
ErrorCodes["语法错误"] = 494;
ErrorCodes["数据不存在或已被删除"] = 497;