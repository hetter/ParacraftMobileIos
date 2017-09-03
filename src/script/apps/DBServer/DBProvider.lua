NPL.load("(gl)script/apps/DBServer/DAL/MySqlGlobalStoreProvider.lua");
NPL.load("(gl)script/apps/DBServer/DAL/MySqlServerObjectProvider.lua");

local MySqlGlobalStoreProvider = commonlib.gettable("DBServer.DAL.MySqlGlobalStoreProvider");
local MySqlServerObjectProvider = commonlib.gettable("DBServer.DAL.MySqlServerObjectProvider");

local DBProvider = commonlib.gettable("DBServer.DBProvider");



function DBProvider.getGlobalStore()
	if(not DBProvider.GlobalStore) then
		DBProvider.GlboalStore = MySqlGlobalStoreProvider:new();
	end
	return DBProvider.GlboalStore;
end


function DBProvider.getServerObject()
	if(not DBProvider.ServerObject) then
		DBProvider.ServerObject = MySqlServerObjectProvider:new();
	end
	return DBProvider.ServerObject;
end