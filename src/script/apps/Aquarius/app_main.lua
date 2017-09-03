--[[
Title: Aquarius
Author(s):  LiXizhi, WangTian
Date: 2008/12/2
Desc: Project Aquarius app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/app_main.lua");
------------------------------------------------------------
]]
-- create class
commonlib.setfield("MyCompany.Aquarius", {});

-- requires
NPL.load("(gl)script/apps/Aquarius/Desktop/AquariusDesktop.lua");

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of System.App.ConnectMode. 
function MyCompany.Aquarius.OnConnection(app, connectMode)
	if(connectMode == System.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Aquarius command link in the main menu 
		local commandName = "Profile.Aquarius.Login";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "登录", icon = app.icon, });
			
			commandName = "Profile.Aquarius.Register";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, ButtonText = "注册新用户",  icon = app.icon, });			
				
			commandName = "Profile.Aquarius.HomePage";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Aquarius Front Page", icon = app.icon, });	
				
			commandName = "Profile.Aquarius.EditProfile";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "个人信息编辑", icon = app.icon, });	
				
			commandName = "Profile.Aquarius.ViewProfile";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "个人信息", icon = app.icon, });	
			
			commandName = "Profile.Aquarius.EscPage";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "控制台", icon = app.icon, });		
				
			commandName = "Profile.Aquarius.Settings";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "社区设置", icon = app.icon, });	

			commandName = "Profile.Aquarius.FeedPage";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "我的动态", icon = app.icon, });	
				
			commandName = "Profile.Aquarius.FriendsPage";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "我的朋友", icon = app.icon, });	


			commandName = "Profile.Aquarius.UploadProfilePhoto";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "上传个人头像", icon = app.icon, });					
			
			commandName = "Profile.Aquarius.Rooms";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Aquarius Rooms Page", icon = app.icon, });		
				
			commandName = "Profile.Aquarius.Actions";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Actions Page", icon = app.icon, });	
				
			commandName = "Profile.Aquarius.CreateRoom";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Create Room Page", icon = app.icon, });
			
			commandName = "Profile.Aquarius.MyIncome";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "My income page", icon = app.icon, });	
				
			commandName = "Profile.Aquarius.ShowAssetBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, icon = app.icon, });	
			
			commandName = "Profile.Aquarius.ShowBCSBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, icon = app.icon, });		
				
			commandName = "Profile.Aquarius.AddToAssetBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
			
			commandName = "Profile.Aquarius.SysCommandLine";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
			
			commandName = "Profile.Aquarius.DoSkill";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });			
				
			commandName = "Profile.Aquarius.EnterChat";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });				
			
			commandName = "Profile.Aquarius.Task";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
				
			commandName = "Profile.Aquarius.LocalMap";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
				
			commandName = "Profile.Aquarius.Dialog";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });	
				
			commandName = "Profile.Aquarius.TeleportToUser";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Aquarius.AddAsFriend";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Aquarius.MinimapZoomIn";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Aquarius.MinimapZoomOut";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Aquarius.NA";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Aquarius.GameEscKey";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Aquarius.Help";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Help Page", icon = app.icon, });	
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		MyCompany.Aquarius.app = app; -- keep a reference
		app.about = "Project Aquarius"
		app.HomeButtonText = "Aquarius";
		app:SetHelpPage("script/apps/Aquarius/Desktop/WelcomePage.html");
		
		local commandName = "File.EnterAquariusWorld";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Enter World", icon = app.icon, });
		end				
		local commandName = "File.ConnectAquariusWorld";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Connect World", icon = app.icon, });
		end
		
		local commandName = "Profile.Aquarius.SwitchApp";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Switch Aapp", icon = app.icon, });
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function MyCompany.Aquarius.OnDisconnection(app, disconnectMode)
	if(disconnectMode == System.App.DisconnectMode.UserClosed or disconnectMode == System.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = System.App.Commands.GetCommand("Profile.Aquarius.Login");
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
function MyCompany.Aquarius.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == System.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in System.App.CommandStatus.
		--if(commandName == "Profile.Aquarius.Login") then
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
function MyCompany.Aquarius.OnExec(app, commandName, params)
	if(commandName == "Profile.Aquarius.Login") then
		local title, cmdredirect;
		if(type(params) == "string") then
			title = params;
		elseif(type(params) == "table")	then
			title = params.title;
			cmdredirect = params.cmdredirect;
		end
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Desktop/LoginPage.html", {cmdredirect=cmdredirect}), 
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
	elseif(commandName == "Profile.Aquarius.Register") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Aquarius/Registration/AquariusReg.html", 
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
	elseif(commandName == "Profile.Aquarius.CreateRoom") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Aquarius/Registration/AquariusRegRoom.html", 
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
	elseif(commandName == "Profile.Aquarius.Task") then	
		-- 'L' key to open quest list
		NPL.load("(gl)script/apps/Aquarius/Quest/Quest_ListWnd.lua");
		MyCompany.Aquarius.Quest_ListWnd.Show()
	elseif(commandName == "Profile.Aquarius.LocalMap") then
		-- 'M' key to open local map
		NPL.load("(gl)script/apps/Aquarius/Desktop/LocalMap.lua");
		MyCompany.Aquarius.Desktop.LocalMap.Show();
	
	elseif(commandName == "Profile.Aquarius.SwitchApp") then
		NPL.load("(gl)script/apps/Aquarius/Desktop/Dock.lua");
		local app_key;
		if(type(params) == "string") then
			app_key = params;
		end	
		MyCompany.Aquarius.Desktop.Dock.SwitchApp(app_key);
		
	elseif(commandName == "Profile.Aquarius.SysCommandLine") then		
		-- this function is called when the engine receives an external command, such as internet web browser to login to a given world. 
		local cmdParams = GetURLCmds(params);
		if(cmdParams[1] and cmdParams[1]~="") then
			-- let us load the world and/or movie
			System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), {worldpath = cmdParams[1], movie=cmdParams.movie});
		end	
	elseif(commandName == "File.ConnectAquariusWorld") then			
		-- connecting to aquarius world using JGSL server
		-- Note: calling this multiple times, will disconnect previous gateway and reconnect. 
		-- this function is called whenever Jabber connection is established. 
		-- however, if jc is ready before we enter the world, we need to find out a way to automatically call this function. 
		params = params or {};
		
		commonlib.log("File.ConnectAquariusWorld is called for %s\n", ParaWorld.GetWorldDirectory());
		
		-- never connect for initial empty world or worlds outside "worlds/" directory. 
		if(not string.match(ParaWorld.GetWorldDirectory(), "^worlds")) then
			return;
		end
		
		-- NOTE: "1100@chatdomain" is the default JGSL gateway server for this release. 
		params.server = params.server or string.format("jgsl://%s@%s", System.options.ForceGateway or "1100", paraworld.TranslateURL("%CHATDOMAIN%"))
		
		-- when client and server connect, they must exchange their session keys. By regenerating session keys, we 
		-- will reject any previous established JGSL game connections. we need to regenerate session when we load a different world.
		NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
		System.JGSL.ResetIfNot();
		
		if(params.server or params.autolobby) then
			if(System.JGSL.GetJC() == nil) then
				-- System.SendMessage_game({type = System.msg.GAME_LOG, text="还没有建立同游戏服务的链接, 请稍候尝试连接"})
				log("not connected yet, let us wait some more until jabber is authenticated before loggin to the current world.")
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
			
	elseif(commandName == "File.EnterAquariusWorld") then
		-- Our custom load world function
		if(type(params) ~= "table") then return end
		
		if(params.worldpath == nil or params.worldpath == "") then
			-- load the command line world or just the default chat world. 
			local cmdParams = GetURLCmds(ParaEngine.GetAppCommandLine());
			params.worldpath = cmdParams[1] or "worlds/MyWorlds/AlphaWorld"
			params.movie = cmdParams.movie;
			params.role = "guest"
		end
		if(not ParaIO.DoesFileExist(params.worldpath, true)) then
			commonlib.log(params.worldpath.." does not exist\n")
			-- TODO: if the world is not downloaded or does not exist, use a default world and download in the background. 
			params.worldpath = "worlds/MyWorlds/AlphaWorld";
			params.role = "guest"
		end
		
		ParaNetwork.EnableNetwork(false, "","");
		local res = System.LoadWorld({
				worldpath = params.worldpath,
				-- use exclusive desktop mode
				bExclusiveMode = true,
			}, 
			-- perserve all user interface
			true)
		params.res = res;
		if(res == true) then
			-- switch to Aquarius app_main desktop and make it default.
			System.UI.AppDesktop.SetDefaultApp("Aquarius_GUID", true);
			
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
			
			if(params.movie and params.movie~="") then
				System.App.Commands.Call("File.PlayMovieScript", params.movie);
			end
			
			---- init the quest system
			--NPL.load("(gl)script/apps/Aquarius/Quest/main.lua");
			--MyCompany.Aquarius.Quest.Init();
			
			-- connect to JGSL server
			System.App.Commands.Call("File.ConnectAquariusWorld");
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	elseif(commandName == "Profile.Aquarius.EnterChat") then
		-- user pressed enter key to chat. 
		if(commonlib.getfield("MyCompany.Aquarius.BBSChatWnd.EnterChat")) then
			MyCompany.Aquarius.BBSChatWnd.EnterChat();
		end
		
	elseif(commandName == "Profile.Aquarius.DoSkill") then	
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
	elseif(commandName == "Profile.Aquarius.ShowBCSBag") then	
		-- TODO: 
		--System.App.Commands.Call("Creation.NormalCharacter");
		System.App.Commands.Call("Creation.BuildingComponents");
		
		-- hide asset bag
		System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", 
			app_key = app.app_key, 
			bShow = false,
		});
	elseif(commandName == "Profile.Aquarius.ShowAssetBag") then
		-- show the asset bag. 
		if(type(params) == "string") then 
			params = {url=params};
		elseif(type(params) ~= "table") then 
			return 
		end
		System.App.Commands.Call("File.MCMLWindowFrame", {name="AssetBag", 
			url=params.url, 
			app_key = app.app_key, 
			bToggleShowHide = true,
			icon = params.icon or "Texture/3DMapSystem/common/ViewFiles.png",
			text = params.text or "我的背包",
			bShow = true,
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
	elseif(commandName == "Profile.Aquarius.AddToAssetBag") then	
		-- add to asset bag
		if(type(params) ~= "table") then return end
		
		commonlib.echo(params);
		
		local dataSource = params.dataSource;
		local objParams = {};
		objParams.AssetFile = params.AssetFile;
		if(not objParams or not objParams.AssetFile) then 
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
				--if(result and #result > 0) then
					--_guihelper.MessageBox("物品已经在背包中了");
					--return;
				--end
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
				System.App.Commands.Call("File.MCMLWindowFrame", {name="AssetBag", app_key=app.app_key, bRefresh=true});
			end
		end
		-- TODO: need to update bag and play some marker animation perhaps.
	
	
	elseif(commandName == "Profile.Aquarius.Dialog") then
		if(type(params) ~= "table") then 
			return 
		end
		-- show the dialog window
		NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DialogWnd.lua");
		MyCompany.Aquarius.Quest_DialogWnd.OnDialog(params.obj);
	
	elseif(commandName == "Profile.Aquarius.AddAsFriend") then
		if(type(params) ~= "table") then 
			return 
		end
		NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
		-- add as friend 
		System.App.profiles.ProfileManager.AddAsFriend(params.uid);
		-- add as IM friend
		System.App.Commands.Call("Profile.Chat.AddContactImmediate", {uid = params.uid});
		
	elseif(commandName == "Profile.Aquarius.TeleportToUser") then
		if(type(params) ~= "table") then 
			return 
		end
		NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
		System.App.profiles.ProfileManager.TeleportToUser(params.uid);
		
	elseif(commandName == "Profile.Aquarius.MinimapZoomIn") then
		mouse_wheel = 2;
		System.UI.MiniMapWnd.OnMouseWheel()
		
	elseif(commandName == "Profile.Aquarius.MinimapZoomOut") then
		mouse_wheel = -2;
		System.UI.MiniMapWnd.OnMouseWheel()
		
	elseif(commandName == "Profile.Aquarius.NA") then
		_guihelper.MessageBox("本功能此版本中未开放，敬请期待");
		
	elseif(commandName == "Profile.Aquarius.GameEscKey") then
		System.App.Commands.Call("Profile.Aquarius.EscPage");
		
	elseif(commandName == "Profile.Aquarius.Help") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Help/HelpPortal.html", {}), 
				name="Aquarius.Help", 
				app_key=app.app_key, 
				text = "系统帮助",
				directPosition = true,
					align = "_ct",
					x = -320/2,
					y = -360/2,
					width = 320,
					height = 360,
			});
	elseif(System.UI.AppDesktop.CheckUser(commandName)) then	
		-- all functions below requres user is logged in. 	
		if(commandName == "Profile.Aquarius.HomePage") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Aquarius/Desktop/LoggedInHomePage.html", name="HelloPage", title="我的首页", DisplayNavBar = true});
		elseif(commandName == "Profile.Aquarius.EditProfile") then	
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Profile/userprofile.html", {}), 
				name="Aquarius.EditProfile", 
				app_key=app.app_key, 
				text = "我的个人信息",
				directPosition = true,
					align = "_ct",
					x = -550/2,
					y = -420/2,
					width = 550,
					height = 420,
			});
		elseif(commandName == "Profile.Aquarius.FeedPage") then	
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Profile/feed.html", {}), 
				name="Aquarius.FeedPage", 
				app_key=app.app_key, 
				text = "我的动态",
				directPosition = true,
					align = "_ct",
					x = -550/2,
					y = -420/2,
					width = 550,
					height = 420,
			});
		elseif(commandName == "Profile.Aquarius.FriendsPage") then	
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Desktop/FriendsPage.html", {}), 
				name="Aquarius.FriendsPage", 
				app_key=app.app_key, 
				text = "我的朋友",
				directPosition = true,
					align = "_ct",
					x = -550/2,
					y = -420/2,
					width = 550,
					height = 420,
			});	
		elseif(commandName == "Profile.Aquarius.EscPage") then	
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Desktop/EscPage.html", {}), 
				name="Aquarius.EscPage", 
				app_key=app.app_key, 
				bToggleShowHide = true,
				text = "控制台",
				directPosition = true,
					align = "_ct",
					x = -150/2,
					y = -150/2,
					width = 150,
					height = 150,
				zorder = 10,	
			});	
			
		elseif(commandName == "Profile.Aquarius.Settings") then	
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Desktop/SettingsPage.html", {}), 
				name="Aquarius.Settings", 
				app_key=app.app_key, 
				text = "社区设置",
				directPosition = true,
					align = "_ct",
					x = -600/2,
					y = -510/2,
					width = 600,
					height = 510,
			});
			
		elseif(commandName == "Profile.Aquarius.ViewProfile") then	
			local uid = "loggedinuser";
			if(type(params) == "string") then
				uid = params;
			elseif(type(params) == "table" and params.uid) then	
				uid = params.uid;
			end
			System.App.Commands.Call("File.MCMLWindowFrame", {
				-- TODO:  Add uid to url
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Profile/userprofile_view.html", {uid=uid}), 
				name = "Aquarius.ViewProfile"..uid, 
				app_key=app.app_key, 
				text = "个人信息",
				
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				
				initialPosX = 100,
				initialPosY = 100,
				initialWidth = 540, 
				initialHeight = 370, 
				--directPosition = true,
					--align = "_ct",
					--x = -550/2,
					--y = -420/2,
					--width = 550,
					--height = 420,
			});
			-- fill back the user name
			local _frame = CommonCtrl.WindowFrame.GetWindowFrame2(app._app.name, "Aquarius.ViewProfile"..uid);
			if(_frame) then
				local _text = _frame:GetTextUIObject();
				if(_text ~= nil and _text:IsValid() == true) then
					MyCompany.Aquarius.Desktop.FillUIObjectWithNameFromNID(_text, uid, nil, "%s的个人信息");
				end
			end
		elseif(commandName == "Profile.Aquarius.UploadProfilePhoto") then	
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aquarius/Profile/uploadphoto.html", {uid=nil}), 
				name="Aquarius.UploadProfilePhoto", 
				app_key=app.app_key, 
				text = "上传个人头像",
				directPosition = true,
					align = "_ct",
					x = -500/2,
					y = -300/2,
					width = 500,
					height = 300,
				zorder = 1,	
			});	
			
		elseif(commandName == "Profile.Aquarius.Rooms") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Aquarius/Desktop/RoomsPage.html", name="HelloPage", title="邻居聊天室", DisplayNavBar = true});
		elseif(commandName == "Profile.Aquarius.Actions") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Aquarius/Desktop/ActionsPage.html", name="HelloPage", title="动作", DisplayNavBar = true});
		elseif(commandName == "Profile.Aquarius.MyIncome") then	
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Aquarius/Desktop/MyIncome.html", name="HelloPage", title="我的收益", DisplayNavBar = true});
		end
	elseif(app:IsHomepageCommand(commandName)) then
		MyCompany.Aquarius.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		MyCompany.Aquarius.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		MyCompany.Aquarius.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function MyCompany.Aquarius.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function MyCompany.Aquarius.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function MyCompany.Aquarius.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function MyCompany.Aquarius.DoQuickAction()
end

-- whenever this application becomes active. Init UI of this app.
function MyCompany.Aquarius.OnActivateDesktop()
	
	NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
	Map3DSystem.Item.ItemManager.Init();
	
	NPL.load("(gl)script/apps/Aquarius/Desktop/AquariusDesktop.lua");
	MyCompany.Aquarius.Desktop.InitDesktop();
	MyCompany.Aquarius.Desktop.SendMessage({type = MyCompany.Aquarius.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
	
	-- register timer for user name and profile picture update
	MyCompany.Aquarius.Desktop.RegisterDoFillUIObjectTimer();
	
	-- update the self profile user name
	MyCompany.Aquarius.Desktop.Profile.UpdateUserName();
	MyCompany.Aquarius.Desktop.Profile.UpdateUserPhoto();
	MyCompany.Aquarius.Desktop.Profile.UpdateUserApperence();
	
	-- update the minimap world name
	MyCompany.Aquarius.Desktop.MiniMap.UpdateWorldName();
	System.UI.AppDesktop.ChangeMode("game");
	
	local worldDir = ParaWorld.GetWorldDirectory()
	if(worldDir == "worlds/MyWorlds/AlphaWorld/") then
		System.UI.AppDesktop.ChangeMode("game");
	elseif(worldDir == "worlds/MyWorlds/DoodleWorld/") then
		System.UI.AppDesktop.ChangeMode("edit");
	end
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/autotips.lua");
	autotips.Show(false);
	
	-- help page
	System.App.Commands.Call("File.WelcomePage", {url="script/apps/Aquarius/Desktop/WelcomePage.html"})
end

function MyCompany.Aquarius.OnDeactivateDesktop()
end

-- user clicks to register
function MyCompany.Aquarius.OnUserRegister(btnName, values, bindingContext)
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


function MyCompany.Aquarius.OnWorldLoad()
	NPL.load("(gl)script/apps/Aquarius/Quest/Quest_NPCStatus.lua");
	-- get all nearby NPCs
	MyCompany.Aquarius.Quest_NPCStatus.GetNearbyNPCs();
	
	NPL.load("(gl)script/apps/Aquarius/EventHandler_Mouse.lua");
	-- register event mouse cursor and right click handler
	MyCompany.Aquarius.app.GetCursorFromSceneObject = MyCompany.Aquarius.HandleMouse.GetCursorFromSceneObject;
	MyCompany.Aquarius.app.OnMouseRightClickObj = MyCompany.Aquarius.HandleMouse.OnMouseRightClickObj;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
	-- register OnRoster message handler timer
	Map3DSystem.App.Chat.MainWnd.RegisterDoPendingMSGTimer();
	
	NPL.load("(gl)script/apps/Aquarius/BBSChat/BBSChatWnd.lua");
	--MyCompany.Aquarius.BBSChatWnd.ClearChannelMessges()
	MyCompany.Aquarius.BBSChatWnd.UpdateChannelName()
	
	-- manually refresh the minimap page, since the ui is preserved in Aquarius
	local _minimapPage = commonlib.getfield("MyCompany.Aquarius.Desktop.MiniMap.MinimapPage");
	if(_minimapPage) then
		_minimapPage:Refresh();
	end
	MyCompany.Aquarius.Desktop.MiniMap.UpdateWorldName();
	
	MyCompany.Aquarius.Desktop.Dock.QuitApp();
end

function MyCompany.Aquarius.OnWorldClosed()
	NPL.load("(gl)script/apps/Aquarius/EventHandler_Mouse.lua");
	-- unregister event mouse cursor and right click handler
	MyCompany.Aquarius.app.GetCursorFromSceneObject = nil;
	MyCompany.Aquarius.app.OnMouseRightClickObj = nil;
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
function MyCompany.Aquarius.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == System.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		MyCompany.Aquarius.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == System.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		MyCompany.Aquarius.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == System.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = MyCompany.Aquarius.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == System.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		MyCompany.Aquarius.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == System.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		MyCompany.Aquarius.OnRenderBox(msg.mcml);
		
	elseif(msg.type == System.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		MyCompany.Aquarius.Navigate();
	
	elseif(msg.type == System.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		MyCompany.Aquarius.GotoHomepage();
	
	elseif(msg.type == System.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		MyCompany.Aquarius.DoQuickAction();
	
	elseif(msg.type == System.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		MyCompany.Aquarius.OnActivateDesktop();
		
	elseif(msg.type == System.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		MyCompany.Aquarius.OnDeactivateDesktop();
		
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_LOAD) then
		-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
		MyCompany.Aquarius.OnWorldLoad();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSING) then
		-- called whenever a world is being closed.
		MyCompany.Aquarius.OnWorldClosed();
		
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end