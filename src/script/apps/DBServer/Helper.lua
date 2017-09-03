--[[
NPL.load("(gl)script/apps/DBServer/Helper.lua");
local Helper = commonlib.gettable("DBServer.Helper");
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/DateTime.lua");

local Helper = commonlib.gettable("DBServer.Helper");


Helper.String = {};

Helper.String.isNullOrEmpty = function(str)
	return str == nil or str == "";
end;

Helper.String.replace = function(str, oldWords, newWords)
	return str:gsub(oldWords, newWords);
end;

Helper.String.split = function(str, separator)
	-- TODO:
end;

Helper.String.join = function(ary, separator)
	return table.concat(ary, separator);
end;

Helper.String.trim = function(str)
	return str:gsub("^%s+",""):gsub("%s+$","");
end;



Helper.DateTime = {};

Helper.DateTime.parse = function(str)
	local _y, _M, _d, _h, _m, _s = str:match("^(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)$");
	if(_y) then
		_y = tonumber(_y);
		if(_M) then
			_M = tonumber(_M);
		else
			_M = 1;
		end
		if(_d) then
			_d = tonumber(_d);
		else
			_d = 1;
		end
		if(_h) then
			_h = tonumber(_h);
		else
			_h = 0;
		end
		if(_m) then
			_m = tonumber(_m);
		else
			_m = 0;
		end
		if(_s) then
			_s = tonumber(_s);
		else
			_s = 0;
		end
		return {year=_y, month=_M, day=_d, hour=_h, minute=_m, second=_s};
	else
		return nil;
	end
end;


Helper.DateTime.toString = function(dt)
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", _now.year, _now.month, _now.day, _now.hour, _now.minute, _now.second);
end;


Helper.DateTime.date = function(dt)
	return {year=dt.year, month=dt.month, day=dt.day, hour=0, minute=0, second=0};
end;


Helper.DateTime.compare = function(dt0, dt1)
	local _t0 = dt0.year * 10000000000 + dt0.month * 100000000 + dt0.day * 1000000 + dt0.hour * 10000 + dt0.minute * 100 + dt0.second;
	local _t1 = dt1.year * 10000000000 + dt1.month * 100000000 + dt1.day * 1000000 + dt1.hour * 10000 + dt1.minute * 100 + dt1.second;
	if(_t0 > _t1) then
		return 1;
	elseif(_t0 == _t1) then
		return 0;
	else
		return -1;
	end
end;


Helper.DateTime.now = function()
	return os.date("*t");
end;


Helper.DateTime.dayOfWeek = function(dt)
	return commonlib.timehelp.get_day_of_week(dt.year, dt.month, dt.day);
end;


-- 原日期数据会发生改变
Helper.DateTime.addYears = function(dt, adds)
	dt.year = dt.year + adds;
	return dt;
end;


Helper.DateTime.addMonths = function(dt, adds)
	local _addY = math.floor(adds / 12);
	local _addM = math.mod(adds, 12);
	local _m = dt.month + _addM;
	if(_m > 12) then
		_addY = _addY + 1;
		_m = _m - 12;
	elseif(_m <= 0) then
		_addY = _addY - 1;
		_m = 12 + _m;
	end
	if(_y ~= 0) then
		dt = Helper.DateTime.addYears(dt, _addY);
	end
	dt.month = _m;
	local _maxD = 31;
	if(_m == 4 or _m == 6 or _m == 9 or _m == 11) then
		_maxD = 30;
	elseif(_m == 2) then
		if(commonlib.timehelp.isleapyear(dt.year)) then
			_maxD = 29;
		else
			_maxD = 28;
		end
	end
	if(dt.day > _maxD) then
		dt.day = _maxD;
	end
	return dt;
end;


Helper.DateTime.addDays = function(dt, adds)
	local _y, _m, _d = commonlib.timehelp.get_next_date(dt.year, dt.month, dt.day, adds);
	dt.year = _y;
	dt.month = _m;
	dt.day = _d;
	return dt;
end;


Helper.DateTime.addHours = function(dt, adds)
	local _addD = math.floor(adds / 24);
	local _addH = math.mod(adds, 24);
	local _h = dt.hour + _addH;
	if(_h >= 24) then
		_addD = _addD + 1;
		_h = _h - 24;
	elseif(_h < 0) then
		_addD = _addD - 1;
		_h = 24 + _h;
	end
	if(_addD ~= 0) then
		dt = Helper.DateTime.addDays(dt, _addD);
	end
	dt.hour = _h;
	return dt;
end;


Helper.DateTime.addMinutes = function(dt, adds)
	local _addH = math.floor(adds / 60);
	local _addM = math.mod(adds, 60);
	local _m = dt.minute + _addM;
	if(_m >= 60) then
		_addH = _addH + 1;
		_m = _m - 60;
	elseif(_m < 0) then
		_addH = _addH - 1;
		_m = 60 + _m;
	end
	if(_addH ~= 0) then
		dt = Helper.DateTime.addHours(dt, _addH);
	end
	_dt.minute = _m;
	return _dt;
end;


Helper.DateTime.addSeconds = function(dt, adds)
	local _addM = math.floor(adds / 60);
	local _addS = math.mod(adds, 60);
	local _s = _dt.second + _addS;
	if(_s >= 60) then
		_addM = _addM + 1;
		_s = _s - 60;
	elseif(_s < 0) then
		_addM = _addM - 1;
		_s = 60 + _s;
	end
	if(_addM ~= 0) then
		dt = Helper.DateTime.addMinutes(dt, _addM);
	end
	_dt.second= _s;
	return _dt;
end;



Helper.Array = {};

Helper.Array.trueForAll = function(ary, func)
	for _i = 1, #(ary) do
		if(not func(ary[_i])) then
			return false;
		end
	end
	return true;
end;

Helper.Array.any = function(ary, func)
	for _i = 1, #(ary) do
		if(func(ary[_i])) then
			return true;
		end
	end
	return false;
end

Helper.Array.max = function(ary, func)
	local _re, _rev = nil, nil;
	if(#(ary) > 0) then
		_re = ary[1];
		_rev = (func and func(_re)) or _re;
		for _i = 2, #(ary) do
			local _v = (func and func(ary[_i])) or ary[_i];
			if(_v > _rev) then
				_re = ary[_i];
				_rev = _v;
			end
		end
	end
	return _re, _rev;
end;

Helper.Array.min = function(ary, func)
	local _re, _rev = nil, nil;
	if(#(ary) > 0) then
		_re = ary[1];
		_rev = (func and func(_re)) or _re;
		for _i = 2, #(ary) do
			local _v = (func and func(ary[_i])) or ary[_i];
			if(_v < _rev) then
				_re = ary[_i];
				_rev = _v;
			end
		end
	end
	return _re, _rev;
end;

Helper.Array.select = function(ary, func)
	local _newary = {};
	if(ary) then
		for _i = 1, #(ary) do
			_newary[#(_newary) + 1] = func(ary[_i]);
		end
	end
	return _newary;
end;

Helper.Array.find = function(ary, func)
	for _i = 1, #(ary) do
		if(func(ary[_i])) then
			return ary[_i];
		end
	end
	return nil;
end;

Helper.Array.findAll = function(ary, func)
	local _list = {};
	for _i = 1, #(ary) do
		if(func(ary[_i])) then
			_list[#(_list) + 1] = ary[_i];
		end
	end
	return _list;
end

Helper.Array.indexOf = function(ary, item)
	for _i = 1, #(ary) do
		if(ary[_i] == item) then
			return _i;
		end
	end
	return -1;
end;

Helper.Array.contains = function(ary, item)
	return Helper.Array.indexOf(ary, item) > 0;
end;

Helper.Array.distinct = function(ary)
	if(ary) then
		local _newary = {};
		for _i = 1, #(ary) do
			local _item = ary[_i];
			if(not Helper.Array.contains(_newary, _item)) then
				_newary[#(_newary) + 1] = _item;
			end
		end
		return _newary;
	end
	return nil;
end;

Helper.Array.forEach = function(ary, func)
	for _i = 1, #(ary) do
		func(ary[_i]);
	end
end;

Helper.Array.concat = function(ary0, ary1)
	Helper.Array.forEach(ary1, function(_item)
			ary0[#(ary0) + 1] = _item;
		end);
	return ary0;
end;

Helper.Array.sum = function(ary, func)
	local _v = 0;
	Helper.Array.forEach(ary, function(_item)
			_v = _v + func(_item);
		end);
	return _v;
end;