--[[
Title: Orion
Author(s):  LiXizhi, WangTian
Date: 2008/10/24
Desc: Hello Chat is a sample that shows you how to develop application with NPL, MCML and ParaWorld API
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Orion/app_main.lua");
------------------------------------------------------------
]]
-- create class
commonlib.setfield("MyCompany.Orion", {});

-- requires
NPL.load("(gl)script/apps/Orion/Desktop/OrionDesktop.lua");

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of System.App.ConnectMode. 
function MyCompany.Orion.OnConnection(app, connectMode)
	if(connectMode == System.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Orion command link in the main menu 
		local commandName = "Profile.Orion.Login";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "登录", icon = app.icon, });
			
			commandName = "Profile.Orion.Register";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, ButtonText = "注册新用户",  icon = app.icon, });			
				
			commandName = "Profile.Orion.HomePage";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Orion Front Page", icon = app.icon, });	
				
			commandName = "Profile.Orion.Rooms";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Orion Rooms Page", icon = app.icon, });		
				
			commandName = "Profile.Orion.Actions";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Actions Page", icon = app.icon, });	
				
			commandName = "Profile.Orion.CreateRoom";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Create Room Page", icon = app.icon, });
			
			commandName = "Profile.Orion.MyIncome";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "My income page", icon = app.icon, });	
				
			commandName = "Profile.Orion.ShowAssetBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, icon = app.icon, });	
			
			commandName = "Profile.Orion.ShowBCSBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, icon = app.icon, });		
				
			commandName = "Profile.Orion.AddSelectionToAssetBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
			
			commandName = "Profile.Orion.SysCommandLine";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
			
			commandName = "Profile.Orion.DoSkill";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });			
				
			commandName = "Profile.Orion.EnterChat";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });				
			
			commandName = "Profile.Orion.Task";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });					
			
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		MyCompany.Orion.app = app; -- keep a reference
		app.about = "Simple chat with avatar and actions"
		app.HomeButtonText = "Hello Chat";
		
		local commandName = "File.EnterHelloWorld";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Enter the world", icon = app.icon, });
		end				
	end
end

-- Receives notification that the Add-in is being unloaded.
function MyCompany.Orion.OnDisconnection(app, disconnectMode)
	if(disconnectMode == System.App.DisconnectMode.UserClosed or disconnectMode == System.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = System.App.Commands.GetCommand("Profile.Orion.Login");
		if(command == nil) then
			command:Delete();
		end
	end
	-- TODO: just release any resources at shutting down. 
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type System.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in System.App.CommandStatus.
function MyCompany.Orion.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == System.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in System.App.CommandStatus.
		--if(commandName == "Profile.Orion.Login") then
			-- return enabled and supported 
			return (System.App.CommandStatus.Enabled + System.App.CommandStatus.Supported)
		--end
	end
end

-- @param cmdline: parse command line params. 
-- @return: table[1] contains the url, and table.fieldname contains other fields. 
local function GetURLCmds(cmdline)
	local cmdURL = string.match(cmdline, "paraworldviewer://(.*)");
	local params = {};
	if(cmdURL) then
		local section
		for section in string.gfind(cmdURL, "[^;]+") do
			local name, value = string.match(section, "%s*(%w+)%s*=%s*(.*)");
			if(not name) then
				table.insert(params, section);
			else
				params[name] = value;
			end
		end
	end	
	return params;
end
		
-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function MyCompany.Orion.OnExec(app, commandName, params)
	if(commandName == "Profile.Orion.Login") then
		local title, cmdredirect;
		if(type(params) == "string") then
			title = params;
		elseif(type(params) == "table")	then
			title = params.title;
			cmdredirect = params.cmdredirect;
		end
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Orion/Desktop/LoginPage.html", {cmdredirect=cmdredirect}), 
			name="HelloLogin.Wnd", 
			app_key=app.app_key, 
			text = title or "登陆窗口",
			icon = "Texture/3DMapSystem/common/lock.png",
			
			directPosition = true,
				align = "_ct",
				x = -320/2,
				y = -230/2,
				width = 320,
				height = 230,
				bAutoSize=true,
			zorder=3,
		});
	elseif(commandName == "Profile.Orion.Register") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Orion/Registration/OrionReg.html", 
			name="HelloReg.Wnd", 
			app_key=app.app_key, 
			text = "注册新用户",
			icon = "Texture/3DMapSystem/common/lock.png",
			DestroyOnClose = true,
			directPosition = true,
				align = "_ct",
				x = -640/2,
				y = -480/2,
				width = 640,
				height = 480,
				bAutoSize=true,
		});
	elseif(commandName == "Profile.Orion.CreateRoom") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Orion/Registration/OrionRegRoom.html", 
			name="HelloReg.Wnd", 
			app_key=app.app_key, 
			text = "申请我的社区",
			icon = "Texture/3DMapSystem/common/lock.png",
			DestroyOnClose = true,
			directPosition = true,
				align = "_ct",
				x = -640/2,
				y = -480/2,
				width = 640,
				height = 480,
				bAutoSize=true,
		});	
	elseif(commandName == "Profile.Orion.Task") then	
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Orion/Task/HelloTask.html", 
			name="HelloTask.Wnd", 
			app_key=app.app_key, 
			text = "任务",
			icon = "Texture/3DMapSystem/AppIcons/Tasks_64.dds",
			bToggleShowHide = true, 
			directPosition = true,
				align = "_ct",
				x = -400/2,
				y = -450/2,
				width = 400,
				height = 450,
				bAutoSize=true,
		});	
	elseif(commandName == "Profile.Orion.SysCommandLine") then		
		-- this function is called when the engine receives an external command, such as internet web browser to login to a given world. 
		local cmdParams = GetURLCmds(params);
		if(cmdParams[1] and cmdParams[1]~="") then
			-- let us load the world and/or movie
			System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), {worldpath = cmdParams[1], movie=cmdParams.movie});
		end	
			
	elseif(commandName == "File.EnterHelloWorld") then
		-- Our custom load world function
		if(type(params) ~= "table") then return end
		
		if(params.worldpath == nil or params.worldpath == "") then
			-- load the command line world or just the default chat world. 
			local cmdParams = GetURLCmds(ParaEngine.GetAppCommandLine());
			params.worldpath = cmdParams[1] or "worlds/MyWorlds/KongFuChat"
			params.movie = cmdParams.movie;
		end
		if(not ParaIO.DoesFileExist(params.worldpath, true)) then
			commonlib.log(params.worldpath.." does not exist\n")
			-- TODO: if the world is not downloaded or does not exist, use a default world and download in the background. 
			params.worldpath = "worlds/MyWorlds/KongFuChat";
		end
		
		ParaNetwork.EnableNetwork(false, "","");
		local res = System.LoadWorld({
				worldpath=params.worldpath,
				-- use exclusive desktop mode
				bExclusiveMode = true,
			})
		params.res = res;
		if(res==true) then
			-- switch to Orion app_main desktop and make it default.
			System.UI.AppDesktop.SetDefaultApp("Orion_GUID", true);
			
			-- Do something after the load	
			if(not params.role) then
				-- no role is specified. 
				if(System.World.readonly) then
					System.User.SetRole("poweruser");
				else
					System.User.SetRole("administrator");
				end
			else
				-- role is specified. 
				System.User.SetRole(params.role);
				if(params.role == "administrator") then
					if(System.World.readonly) then
						System.User.SetRole("poweruser");
					end
				end
			end
			
			-- when client and server connect, they must exchange their session keys. By regenerating session keys, we 
			-- will reject any previous established JGSL game connections. we need to regenerate session when we load a different world.
			NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
			System.JGSL.Reset();
			
			if(params.server or params.autolobby) then
				if(System.JGSL.GetJC() == nil) then
					System.SendMessage_game({type = System.msg.GAME_LOG, text=L"还没有建立同游戏服务的链接, 请稍候尝试连接"})
					return 
				end 
			end	
			
			if(params.autolobby) then
				-- if lobby is on,  paraworld.lobby.* api will be used to either host or join an existing world with given worldpath
				-- connect to the lobby server
				System.App.worlds.EnableAutoLobby = params.autolobby;
			
				if(not params.uid or not params.server) then	
					NPL.load("(gl)script/kids/3DMapSystemApp/worlds/AutoLobbyPage.lua");
					System.App.worlds.AutoLobbyPage.Reset();
					System.App.worlds.AutoLobbyPage.AutoJoinRoom();
				end	
			elseif(params.uid or params.server) then
				if(not string.match(params.server, "^%w+://")) then
					params.server = "jgsl://"..params.server; -- this allow input to ignore jgsl:// header
				end
				NPL.load("(gl)script/kids/3DMapSystemApp/worlds/AutoLobbyPage.lua");
				System.App.worlds.AutoLobbyPage.Reset();
				System.App.worlds.AutoLobbyPage.JoinRoom(params.uid, params.server)
			end	
		
			if(params.movie and params.movie~="") then
				System.App.Commands.Call("File.PlayMovieScript", params.movie);
			end
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	elseif(commandName == "Profile.Orion.EnterChat") then
		-- TODO: user pressed enter key to chat. 
		if(commonlib.getfield("MyCompany.Orion.ChatWnd.Show")) then
			MyCompany.Orion.ChatWnd.Show(true);
		end
		
	elseif(commandName == "Profile.Orion.DoSkill") then	
		if(type(params) == "table") then
			local player = ParaScene.GetPlayer();
			-- play animation
			if(params.anim) then
				System.Animation.PlayAnimationFile(params.anim, player);
			end	
			-- change headonmodel or headonchar
			if(params.headonmodel or params.headonchar) then
				player:ToCharacter():RemoveAttachment(11);
				local asset;
				if(params.headonmodel) then 
					asset = ParaAsset.LoadStaticMesh("", params.headonmodel);
				elseif(params.headonchar) then 
					asset = ParaAsset.LoadParaX("", params.headonchar);
				end	
				if(asset~=nil and asset:IsValid()) then
					player:ToCharacter():AddAttachment(asset, 11);
				end
			else
				player:ToCharacter():RemoveAttachment(11);
			end
			
			-- play effect, as well
			-- TODO: demo effects. 
			--ParaScene.FireMissile(headon_speech.GetAsset("tag"), distH/0.6, to_x, to_y+distH, to_z, to_x, to_y, to_z);
		end
	elseif(commandName == "Profile.Orion.ShowBCSBag") then	
		-- TODO: 
		--System.App.Commands.Call("Creation.NormalCharacter");
		System.App.Commands.Call("Creation.BuildingComponents");
		
		-- hide asset bag
		System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", 
			app_key = app.app_key, 
			bShow = false,
		});
	elseif(commandName == "Profile.Orion.ShowAssetBag") then
		-- show the asset bag. 
		if(type(params) == "string") then 
			params = {url=params};
		elseif(type(params) ~= "table") then 
			return 
		end
		System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", 
			url=params.url, 
			app_key = app.app_key, 
			bToggleShowHide = true,
			icon = params.icon or "Texture/3DMapSystem/common/ViewFiles.png",
			text = params.text or "我的资源包",
			directPosition = true,
				align = "_rb",
				x = -175,
				y = -82-380,
				width = 175,
				height = 380,
				bAutoSize = true,
		});
		-- hide BCS
		System.App.Commands.Call("Creation.BuildingComponents", {bShow=false});
	elseif(commandName == "Profile.Orion.AddSelectionToAssetBag") then	
		-- add selection to bag
		if(type(params) ~= "string") then return end
		local dataSource = params;
		local objParams = System.obj.GetObjectParams("selection");
		if(not objParams or not objParams.AssetFile) then 
			_guihelper.MessageBox("请先在3D场景中选择一个要添加的物体");
			return;
		end
		if(type(dataSource) == "string") then
			if(string.match(dataSource, "http://")) then
				-- TODO: remote xml or web serivce bag
			else
				-- local disk xml file. 
				local xmlRoot = ParaXML.LuaXML_ParseFile(dataSource);
				if(not xmlRoot) then 
					commonlib.log("pe:bag xml file %s is created. \n", dataSource);
					xmlRoot = {name="pe:mcml", n=0}
				end
				NPL.load("(gl)script/ide/XPath.lua");
				local fileNode, bagNode;
				local result = commonlib.XPath.selectNodes(xmlRoot, string.format("//pe:asset[@src='%s']", objParams.AssetFile));
				if(result and #result > 0) then
					_guihelper.MessageBox("当前选择的物品已经在背包中了");
					return;
				end
				-- add to the last bag in the file
				for fileNode in commonlib.XPath.eachNode(xmlRoot, "//pe:bag") do
					bagNode = fileNode;
				end
				if(not bagNode) then
					bagNode = {name="pe:bag", n=0};
					xmlRoot[#xmlRoot+1] = bagNode;
				end
				-- add new asset node. 
				local newNode = {name="pe:asset", attr={}};
				
				newNode.attr["src"] = objParams.AssetFile;
				if(objParams.IsCharacter) then
					newNode.attr["type"] = "char";
				end
				bagNode[#bagNode+1] = newNode;
				
				-- output project file.
				ParaIO.CreateDirectory(dataSource);
				local file = ParaIO.open(dataSource, "w");
				if(file:IsValid()) then
					file:WriteString([[<?xml version="1.0" encoding="utf-8"?>]]);
					file:WriteString("\r\n");
					-- change encoding to "utf-8" before saving
					file:WriteString(ParaMisc.EncodingConvert("", "utf-8", commonlib.Lua2XmlString(xmlRoot)));
					file:close();
				end
				-- refresh the page. 
				System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", app_key=app.app_key, bRefresh=true});
			end
		end
		-- TODO: need to update bag and play some marker animation perhaps.
	
	elseif(System.UI.AppDesktop.CheckUser(commandName)) then	
		-- all functions below requres user is logged in. 	
		if(commandName == "Profile.Orion.HomePage") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Orion/Desktop/LoggedInHomePage.html", name="HelloPage", title="我的首页", DisplayNavBar = true});
		elseif(commandName == "Profile.Orion.Rooms") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Orion/Desktop/RoomsPage.html", name="HelloPage", title="邻居聊天室", DisplayNavBar = true});
		elseif(commandName == "Profile.Orion.Actions") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Orion/Desktop/ActionsPage.html", name="HelloPage", title="动作", DisplayNavBar = true});
		elseif(commandName == "Profile.Orion.MyIncome") then	
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Orion/Desktop/MyIncome.html", name="HelloPage", title="我的收益", DisplayNavBar = true});
		end
	elseif(app:IsHomepageCommand(commandName)) then
		MyCompany.Orion.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		MyCompany.Orion.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		MyCompany.Orion.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function MyCompany.Orion.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function MyCompany.Orion.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function MyCompany.Orion.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function MyCompany.Orion.DoQuickAction()
end

-- whenever this application becomes active. Init UI of this app.
function MyCompany.Orion.OnActivateDesktop()
	MyCompany.Orion.Desktop.InitDesktop();
	MyCompany.Orion.Desktop.SendMessage({type = MyCompany.Orion.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
	
	System.UI.AppDesktop.ChangeMode("chat");
end

function MyCompany.Orion.OnDeactivateDesktop()
end

-- user clicks to register
function MyCompany.Orion.OnUserRegister(btnName, values, bindingContext)
	local L = CommonCtrl.Locale("ParaWorld");
	if(btnName == "register") then
		local errormsg = "";
		-- validate name
		if(string.len(values.username)<3) then
			errormsg = errormsg..L"名字太短了\n"
		end
		-- validate password
		if(string.len(values.password)<6) then
			errormsg = errormsg..L"密码太短了\n"
		elseif(values.password~=values.password_confirm) then
			errormsg = errormsg..L"确认密码与密码不一致\n"
		end
		-- validate email
		values.email = string.gsub(values.email, "^%s*(.-)%s*$", "%1")
		if(not string.find(values.email, "^%s*[%w%._%-]+@[%w%.%-]+%.[%a]+%s*$")) then
			errormsg = errormsg..L"Email地址格式不正确\n"
		end
		if(errormsg~="") then
			paraworld.ShowMessage(errormsg)
		else
			local msg = {
				-- is this app key needed?
				appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e00",
				username = values.username,
				password = values.password,
				email = values.email,
				referrer = values.referrer,
			};
			paraworld.ShowMessage(L"正在连接注册服务器, 请等待")
			paraworld.users.Registration(msg, "login", function(msg)
				if(paraworld.check_result(msg, true)) then
					paraworld.ShowMessage(L"恭喜！注册成功！\n 请您查收Email激活您的登录帐号.");
					-- start login procedure
					--NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoginProcedure.lua");
					--Map3DSystem.App.Login.Proc_Authentication(values);
				end	
			end);
		end
	end
end
-------------------------------------------
-- client world database function helpers.
-------------------------------------------

------------------------------------------
-- all related messages
------------------------------------------
-----------------------------------------------------
-- APPS can be invoked in many ways: 
--	Through app Manager 
--	mainbar or menu command or buttons
--	Command Line 
--  3D World installed apps
-----------------------------------------------------
function MyCompany.Orion.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == System.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		MyCompany.Orion.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == System.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		MyCompany.Orion.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == System.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = MyCompany.Orion.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == System.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		MyCompany.Orion.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == System.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		MyCompany.Orion.OnRenderBox(msg.mcml);
		
	elseif(msg.type == System.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		MyCompany.Orion.Navigate();
	
	elseif(msg.type == System.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		MyCompany.Orion.GotoHomepage();
	
	elseif(msg.type == System.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		MyCompany.Orion.DoQuickAction();
	
	elseif(msg.type == System.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		MyCompany.Orion.OnActivateDesktop();
		
	elseif(msg.type == System.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		MyCompany.Orion.OnDeactivateDesktop();
		
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end