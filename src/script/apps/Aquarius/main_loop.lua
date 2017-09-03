--[[
Title: Main game loop
Author(s): LiXizhi, WangTian
Date: 2008/12/2
Desc: Entry point and game loop
command line params
| *name*| *desc* |
| gateway | force the gateway to use, usually for debugging purposes. such as "1100" |
e.g. 
<verbatim>
	paraworld.exe username="1100@paraengine.com" password="1100@paraengine.com" servermode="true" d3d="false" chatdomain="192.168.0.233" domain="test.pala5.cn"
	paraworld.exe username="LiXizhi1" password="" gateway="1100"
</verbatim>
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/Aquarius/main_loop.lua");
set the bootstrapper to point to this file, see config/bootstrapper.xml
Or run application with command line: bootstrapper="script/apps/Aquarius/bootstrapper.xml"
------------------------------------------------------------
]]
-- mainstate is just a dummy to set some ReleaseBuild=true
NPL.load("(gl)script/mainstate.lua"); 
main_state = nil;

NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes

-- if asset is not found locally, we will look in this place
ParaAsset.SetAssetServerUrl("http://asset.test.pala5.cn/");

-- uncomment this line to display our logo page. 
-- main_state="logo";

if(not ReleaseBuild) then
	System.options.IsEditorMode = true;
end

-- some init stuffs that are only called once at engine start up, but after System.init()
local bAquarius_Init;
local function Aquarius_Init()
	if(bAquarius_Init) then return end
	bAquarius_Init = true;
	
	-- load default theme
	NPL.load("(gl)script/apps/Aquarius/DefaultTheme.lua");
	Aquarius_LoadDefaultTheme();
	
	-- some default settings
	-- limit the number of character triangles to drawn for this edition. 
	ParaScene.GetAttributeObject():SetField("MaxCharTriangles", 30000);
	-- turn off menu
	ParaEngine.GetAttributeObject():SetField("ShowMenu", false);
	
	-- install the Aquarius app, if it is not installed yet.
	local app = System.App.AppManager.GetApp("Aquarius_GUID")
	if(not app) then
		app = System.App.Registration.InstallApp({app_key="Aquarius_GUID"}, "script/apps/Aquarius/IP.xml", true);
	end
	-- change the login machanism to use our own login module
	System.App.Commands.SetDefaultCommand("Login", "Profile.Aquarius.Login");
	-- change the load world command to use our own module
	System.App.Commands.SetDefaultCommand("LoadWorld", "File.EnterAquariusWorld");
	-- change the handler of system command line. 
	System.App.Commands.SetDefaultCommand("SysCommandLine", "Profile.Aquarius.SysCommandLine");
	-- change the handler of enter to chat. 
	System.App.Commands.SetDefaultCommand("EnterChat", "Profile.Aquarius.EnterChat");
	-- on game esc key command
	System.App.Commands.SetDefaultCommand("OnGameEscKey", "Profile.Aquarius.GameEscKey");
		
	System.options.ViewProfileCommand = "Profile.Aquarius.ViewProfile";
	System.options.EditProfileCommand = "Profile.Aquarius.EditProfile";
	System.options.SwitchAppCommand = "Profile.Aquarius.SwitchApp";
end


-- this script is activated every 0.5 sec. it uses a finite state machine (main_state). 
-- State nil is the inital game state. state 0 is idle.
local function activate()
	
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		-- initialization 
		main_state = System.init({useDefaultTheme = false});
		if(main_state~=nil) then
			Aquarius_Init();
			
			NPL.load("(gl)script/apps/Aquarius/Quest/main.lua");
			
			---- sample code to immediately load the world if app platform is not used. 
			--local res = System.LoadWorld({
				--worldpath="worlds/MyWorlds/AlphaWorld",
				---- use exclusive desktop mode
				--bExclusiveMode = true,
			--})
			--
			---- show login window
			--NPL.load("(gl)script/apps/Aquarius/Login/MainLogin.lua");
			--MyCompany.Aquarius.MainLogin.Show();
			
			local onlinemode = true;
			
			if(onlinemode == true) then
				-- offline mode COMPLETELY DEPRECATED in Aquarius
				NPL.load("(gl)script/apps/Aquarius/Login/MainLogin.lua");
				MyCompany.Aquarius.MainLogin.Show();
				
				if(ParaEngine.GetAttributeObject():GetField("HasNewConfig", false)) then
					ParaEngine.GetAttributeObject():SetField("HasNewConfig", false);
					_guihelper.MessageBox("您上次运行时更改了图形设置. 是否保存目前的显示设置.", function()	
						ParaEngine.WriteConfigFile("config/config.txt");
					end)
				end
			else
				local params = {worldpath = "worlds/MyWorlds/AlphaWorld"};
				System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
				if(params.res) then
					-- succeed loading
					NPL.load("(gl)script/apps/Aquarius/Quest/main.lua");
					-- init the quest system
					MyCompany.Aquarius.Quest.Init();
				end
			end
		end
	elseif(main_state=="logo") then
		NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/LogoPage.lua");
		System.UI.Desktop.LogoPage.Show(79, {
			{name = "LogoPage_PE_bg", bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logoTxt", bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logo", bg="Texture/Aquarius/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, color="255 255 255 0", anim="script/apps/Aquarius/Desktop/Motion/Logo_motion.xml"},
		})
	end	
end
NPL.this(activate);