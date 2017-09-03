--[[
Title: ParaWorldIntro app for Paraworld: it includes the 30 mins, game intro, credits, tutorial page, App development intro, help, and CG page. 
Author(s): LiXizhi
Date: 2008/1/28
Desc: 
the 30 mins intro teaches you to register account, create an avatar, join a CITY, learn the basics 3D operations, build and explore profiles and applications. 
db registration insert script
INSERT INTO apps VALUES (NULL, 'ParaWorldIntro_GUID', 'ParaWorldIntro', '1.0.0', 'http://www.paraengine.com/apps/ParaWorldIntro_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/ParaworldIntro/IP.xml', '', 'script/kids/3DMapSystemUI/ParaworldIntro/app_main.lua', 'Map3DSystem.App.ParaWorldIntro.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.ParaWorldIntro", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.ParaWorldIntro.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a ParaWorldIntro command link in the main menu 
		local commandName = "Help.Howto";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "如何... (F1键)", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to front.
			command:AddControl("mainmenu", pos_category, 1);
			
			commandName = "Help.Tutorials";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "帕拉巫教程", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to last.
			command:AddControl("mainmenu", pos_category, 2);
			
			commandName = "Help.ParaworldWebSite";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "帕拉巫官网", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to last.
			command:AddControl("mainmenu", pos_category);
			
			commandName = "Help.ParaEngineWebSite";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "ParaEngine官网", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to last.
			command:AddControl("mainmenu", pos_category);
			
			commandName = "Help.Credits";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "版本 & 制作群", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to last.
			command:AddControl("mainmenu", pos_category);
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about = "ParaWorld intro"
		Map3DSystem.App.ParaWorldIntro.app = app; 
		app.HideHomeButton = true;
		
		--------------------------------------------
		-- add a desktop icon. 
		local commandName = "Startup.ParaworldIntro";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			--command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				--ButtonText = "帕拉巫介绍", icon = "Texture/3DMapSystem/Desktop/Startup/Intro2.png", OnShowUICallback = function(bShow, _parent, parentWindow)
					--NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/PWIntroPage.lua");
					--Map3DSystem.App.ParaworldIntro.PWIntroPage.Show(bShow,_parent,parentWindow)
				--end});
			--local pos_category = commandName;	
			--command:AddControl("desktop", pos_category, 6);	
		end	
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.ParaWorldIntro.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Help.Howto");
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
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.ParaWorldIntro.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Help.Howto") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.ParaWorldIntro.OnExec(app, commandName, params)
	if(commandName == "Help.Howto") then
		--NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/PWIntroPage.lua");
		--Map3DSystem.App.ParaworldIntro.PWIntroPage.ShowWnd(app._app)
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemUI/MyDesktop/WelcomePage.html", title="如何..."});
		
	elseif(commandName == "Help.Tutorials") then
		--NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/TutorialsPage.lua");
		--Map3DSystem.App.ParaworldIntro.TutorialsPage.Show(bShow, _parent, parentWindow);
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Login/TutorialPage.html?tab=offline", title="教程"});
					
	elseif(commandName == "Help.Credits") then
		--NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/CreditsPage.lua");
		--Map3DSystem.App.ParaworldIntro.CreditsPage.ShowWnd(app._app);
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Login/CreditsPage.html", title="制作群"});
	
	elseif(commandName == "Help.ParaEngineWebSite") then
		Map3DSystem.App.Commands.Call("File.WebBrowser", "http://www.paraengine.com");
		
	elseif(commandName == "Help.ParaworldWebSite") then
		--NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/PWWebPage.lua");
		--Map3DSystem.App.ParaworldIntro.PWWebPage.ShowWnd(app._app);
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Login/OfficialWebPage.html", title="官网"});
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.ParaWorldIntro.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.ParaWorldIntro.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.ParaWorldIntro.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.ParaWorldIntro.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.ParaWorldIntro.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.ParaWorldIntro.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.ParaWorldIntro.DoQuickAction()
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
function Map3DSystem.App.ParaWorldIntro.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.ParaWorldIntro.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.ParaWorldIntro.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.ParaWorldIntro.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.ParaWorldIntro.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.ParaWorldIntro.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.ParaWorldIntro.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.ParaWorldIntro.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.ParaWorldIntro.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end