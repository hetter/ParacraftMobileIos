NPL.load("(gl)script/ide/commonlib.lua");

local DBSettings = commonlib.gettable("DBServer.DBSettings");
DBSettings.cnfFile = nil;
DBSettings.cns = nil;
DBSettings.lucks = nil;
DBSettings.dbindex = -1;
DBSettings.dbcnt = -1;
DBSettings.tbcnt = -1;
DBSettings.weekStart = -1;


function DBSettings.getCnfFile()
	if(not DBSettings.cnfFile) then
		local _filePath = "config/LibraryCenter.dll.config";
		DBSettings.cnfFile = ParaXML.LuaXML_ParseFile(_filePath);
		if(not DBSettings.cnfFile) then
			commonlib.log("cannot load LibraryCenter.dll.config");
		end
	end
	return DBSettings.cnfFile;
end


function DBSettings.getCN(cnKey)
	if(not DBSettings.cns) then
		local _cnf = DBSettings.getCnfFile();
		if(_cnf) then
			DBSettings.cns = {};
			local _node;
			for _node in commonlib.XPath.eachNode(_cnf, "/configuration/connectionStrings/add") do
				if(_node.attr and _node.attr.name and _node.attr.connectionString) then
					local _cn = {};
					for _key, _value in _node.attr.connectionString:gmatch("%s*([a-zA-Z0-9]+%s*[a-zA-Z0-9]*)%s*=%s*([a-zA-Z0-9_%.]+)%s*") do
						_cn[_key] = _value;
					end
					--DBSettings.cns[_node.attr.name] = _node.attr.connectionString;
					DBSettings.cns[_node.attr.name] = _cn;
				end
			end
		end
	end

	if(DBSettings.cns and DBSettings.cns[cnKey]) then
		return DBSettings.cns[cnKey];
	else
		return nil;
	end
end


function DBSettings.getLucks()
	if(not DBSettings.lucks) then
		local _n, _cnt, _ary = 5, 100, {};
		for _i = 1, _cnt do
			_ary[_i] = _cnt;
		end
		local _dt = os.date("*t");
		local _d = (_dt.year * 100 + _dt.month) * 100 + _dt.day;
		math.randomseed(_d);
		for _i = 1, _cnt do
			local _i0, _i1 = math.random(_cnt), math.random(_cnt);
			if(_ary[_i0] ~= _ary[_i1]) then
				local _t = _ary[_i0];
				_ary[_i0] = _ary[_i1];
				_ary[_i1] = _t;
			end
		end
		DBSettings.lucks = _ary;
	end
	return DBSettings.lucks;
end


function DBSettings.getDBIndex()
	if(DBSettings.dbindex == nil or DBSettings.dbindex < 0) then
		local _cnf = DBSettings.getCnfFile();
		if(_cnf) then
			local _node;
			for _node in commonlib.XPath.eachNode(_cnf, "/configuration/appSettings/add") do
				if(_node.attr and _node.attr.key and _node.attr.key == "dbindex") then
					DBSettings.dbindex = tonumber(_node.attr.value);
					break;
				end
			end
		end
	end
	return DBSettings.dbindex;
end


function DBSettings.getDBCnt()
	if(DBSettings.dbcnt == nil or DBSettings.dbcnt < 0) then
		local _cnf = DBSettings.getCnfFile();
		if(_cnf) then
			local _node;
			for _node in commonlib.XPath.eachNode(_cnf, "/configuration/appSettings/add") do
				if(_node.attr and _node.attr.key and _node.attr.key == "dbcnt") then
					DBSettings.dbcnt = tonumber(_node.attr.value);
					break;
				end
			end
		end
	end
	return DBSettings.dbcnt;
end


function DBSettings.getTBCnt()
	if(DBSettings.tbcnt == nil or DBSettings.tbcnt < 0) then
		local _cnf = DBSettings.getCnfFile();
		if(_cnf) then
			local _node;
			for _node in commonlib.XPath.eachNode(_cnf, "/configuration/appSettings/add") do
				if(_node.attr and _node.attr.key and _node.attr.key == "tbcnt") then
					DBSettings.tbcnt = tonumber(_node.attr.value);
					break;
				end
			end
		end
	end
	return DBSettings.tbcnt;
end


-- 修改昵称需消耗的魔豆
function DBSettings.changeNName_ConsumeM()
	return 200;
end


function DBSettings.getWeekStart()
	if(DBSettings.weekStart == nil or DBSettings.weekStart < 0) then
		local _cnf = DBSettings.getCnfFile();
		if(_cnf) then
			local _node;
			for _node in commonlib.XPath.eachNode(_cnf, "/configuration/LibraryCenter/GSCntInTimeSpan") do
				if(_node.attr and _node.attr.weekStart) then
					DBSettings.weekStart = tonumber(_node.attr.weekStart);
					break;
				end
			end
		end
	end
	return DBSettings.weekStart;
end