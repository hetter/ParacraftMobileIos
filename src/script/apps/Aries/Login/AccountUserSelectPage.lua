--[[
Title: Account user select page
Author(s): LiXizhi
Date: 2012/11/3
Desc:  script/apps/Aries/Login/AccountUserSelectPage.html
if the user has saved logged in user before, this page allows user to quick select a user and log in. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/AccountUserSelectPage.lua");
MyCompany.Aries.AccountUserSelectPage.ShowPage(users);
-------------------------------------------------------
]]
local AccountUserSelectPage = commonlib.gettable("MyCompany.Aries.AccountUserSelectPage");

local DefaultConfigFile = "config/LocalUsers.table"
-- local users: loaded from config/LocalUsers.table
AccountUserSelectPage.displayUsers = {};
AccountUserSelectPage.News = {};

local max_accounts_per_user = 5;
local page;


--@param users : array of nids
--@param platform_params: {username, token, plat, etc}
--@param callbackFunc: function(user_nid) end
function AccountUserSelectPage.ShowPage(users, platform_params, callbackFunc)
	local self = AccountUserSelectPage;
	self.callbackFunc = callbackFunc;
	self.platform_params = platform_params;
	if(users and #users>0) then
		NPL.load("(gl)script/apps/Aries/Login/LocalUserSelectPage.lua");
		MyCompany.Aries.LocalUserSelectPage:LoadFromFile();

		self.displayUsers = {};
		local _, user_nid
		for _, user_nid in ipairs(users) do
			local user = MyCompany.Aries.LocalUserSelectPage:GetUserByNid(tostring(user_nid))
			self.displayUsers[#(self.displayUsers)+1] = user or {user_nid = tostring(user_nid)};
		end
	end
	-- display the local LocalUserSelectPage.html
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = if_else(System.options.version=="kids",  "script/apps/Aries/Login/AccountUserSelectPage.html", "script/apps/Aries/Login/AccountUserSelectPage.teen.html"), 
		name = "AccountUserSelectPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 0,
		click_through = true,
		allowDrag = false,
		directPosition = true,
			align = "_ct",
			x = -960/2,
			y = -560/2,
			width = 960,
			height = 560,
		cancelShowAnimation = true,
	});
end
-- load users from file
-- @param configfile: it can be nil, it will default to DefaultConfigFile:"config/LocalUsers.table"
-- @return the number of users
function AccountUserSelectPage:LoadFromFile(filename)
	return #(self.displayUsers);
end

-- The data source function. 
function AccountUserSelectPage.DS_Func(index, pageCtrl)
	if(index == nil) then
		-- return #(AccountUserSelectPage.dsUsers);
		return #(AccountUserSelectPage.displayUsers);
	else
		-- return AccountUserSelectPage.dsUsers[index];
		return AccountUserSelectPage.displayUsers[index];
	end
end

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- init
function AccountUserSelectPage.OnInit()
	page = document:GetPageCtrl();
end

function AccountUserSelectPage.OnClickDelete(index)
	_guihelper.MessageBox("暂时不能删除角色， 每个帐号最多绑定5个角色。");
end

function AccountUserSelectPage.CloseWindow()
	if(page) then
		page:CloseWindow();
	end
end

function AccountUserSelectPage.OnClickUseOtherAccount()
	local self = AccountUserSelectPage;
	AccountUserSelectPage.CloseWindow();
	if(self.callbackFunc) then
		self.callbackFunc();
	end
end

function AccountUserSelectPage.OnClickRegAccount()
	local user_count = AccountUserSelectPage.DS_Func(nil);
	if( user_count >= max_accounts_per_user) then
		_guihelper.MessageBox(format("每个账户只能创建%d个角色", max_accounts_per_user));
		return;
	end

	local self = AccountUserSelectPage;
	if(self.platform_params) then
		local values = self.platform_params;
		local params = {
			userName = values.username,
			password = values.password,
			plat = values.plat,
			token = values.token,
			key = values.key,
			time = values.time,
			oid = values.oid,
			website = values.website,
			sid = values.sid,
			game = values.game,
		};
		paraworld.users.Registration(params, "Register", function(msg)
			if(msg and msg.nid) then
				-- send log information
				paraworld.PostLog({reg_nid = tostring(msg.nid), action = "regist_success"}, "regist_success_log", function(msg) end);
				local user_nid = tonumber(msg.nid);
				AccountUserSelectPage.OnSelectUser(user_nid);
			else
				LOG.std("", "error","Login", "Registration failed");
				if(msg and msg.errorcode == 433) then
					_guihelper.MessageBox("无法创建更多的角色");
				else
					_guihelper.MessageBox("无法创建角色");
				end
			end
		end, nil, 20000, function(msg)
			-- timeout request
			_guihelper.MessageBox("无法创建角色");
		end)
	end
end

-- The news_data source function. 
function AccountUserSelectPage.News_DS_Func(index)
	local self = AccountUserSelectPage;
	if(index == nil) then
		return #(AccountUserSelectPage.News);
	else
		return AccountUserSelectPage.News[index];
	end
end

-- The loadNews function. 
function AccountUserSelectPage:LoadNews()
	local xmlRoot = System.SystemInfo.GetField("login_news_page_data");
	if(xmlRoot) then
		local news = commonlib.XPath.selectNode(xmlRoot, "//haqi:news");
		if(news) then
			local i;
			local m = #(news);
			for i=1, m  do
				if(news[i].attr) then
					local news_item = {news=news[i].attr.text,};
					table.insert(AccountUserSelectPage.News,news_item);
					-- AccountUserSelectPage.News[i]={news=news[i].attr.text,};
				end
			end
		end
	end
	commonlib.echo(AccountUserSelectPage.News);
end

-- select and login with the given user. 
function AccountUserSelectPage.OnSelectUser(user_nid)
	AccountUserSelectPage.CloseWindow();
	local self = AccountUserSelectPage;
	if(self.callbackFunc) then
		self.callbackFunc(user_nid);
	end
end