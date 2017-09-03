--[[
Title: Main game loop
Author(s): LiXizhi
Date: 2008/10/28
Desc: Entry point and game loop
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/HelloChat/main_loop.lua");
set the bootstrapper to point to this file, see config/bootstrapper.xml
Or run application with command line: bootstrapper="script/apps/HelloChat/bootstrapper.xml"
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes

-- uncomment this line to display our logo page. 
-- main_state="logo";

-- some init stuffs that are only called once at engine start up, but after System.init()
local bHelloChat_Init;
local function HelloChat_Init()
	if(bHelloChat_Init) then return end
	bHelloChat_Init = true;
	
	-- replace the default window style with our own customization
	CommonCtrl.WindowFrame.DefaultStyle = {
		name = "DefaultStyle",
		
		window_bg = "Texture/HelloChat/frame_32bits.png; 0 0 32 61 : 14 35 14 8",
		fillBGLeft = 0,
		fillBGTop = 0,
		fillBGWidth = 0,
		fillBGHeight = 0,
		
		titleBarHeight = 31,
		toolboxBarHeight = 48,
		statusBarHeight = 32,
		borderLeft = 4,
		borderRight = 4,
		borderBottom = 4,
		
		textcolor = "255 255 255",
		
		iconSize = 16,
		iconTextDistance = 16, -- distance between icon and text on the title bar
		
		CloseBox = {alignment = "_rt",
					x = -40, y = 0, size = 31,
					icon = "Texture/HelloChat/frame_32bits.png; 33 0 31 31",},
		MinBox = {alignment = "_rt",
					x = -75, y = 2, size = 20,
					icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",},
		MaxBox = {alignment = "_rt",
					x = -55, y = 2, size = 20,
					icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",},
		PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
					x = 2, y = 2, size = 20,
					icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
					icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
		
		resizerSize = 24,
		resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
	};
	
	-- install the HelloChat app, if it is not installed yet.
	local app = System.App.AppManager.GetApp("HelloChat_GUID")
	if(not app) then
		app = System.App.Registration.InstallApp({app_key="HelloChat_GUID"}, "script/apps/HelloChat/IP.xml", true);
	end
	-- change the login machanism to use our own login module
	System.App.Commands.SetDefaultCommand("Login", "Profile.HelloChat.Login");
	-- change the load world command to use our own module
	System.App.Commands.SetDefaultCommand("LoadWorld", "File.EnterHelloWorld");
	-- change the handler of system command line. 
	System.App.Commands.SetDefaultCommand("SysCommandLine", "Profile.HelloChat.SysCommandLine");
	-- change the handler of enter to chat. 
	System.App.Commands.SetDefaultCommand("EnterChat", "Profile.HelloChat.EnterChat");
			
	-- change the loader UI, remove following lines if u want to use default paraworld loader ui.
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	System.UI.LoaderUI.items = {
		{name = "HelloChat.UI.LoaderUI.bg", type="container",bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.logoTxt", type="container",bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.logo", type="container",bg="Texture/HelloChat/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",alignment = "_ct", left=-100, top=160, width=200, height=22, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.text", type="text", text="正在加载...", alignment = "_ct", left=-100+10, top=160+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "HelloChat.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/3DMapSystem/Loader/progressbar_filled.png:7 7 13 7", alignment = "_ct", left=-100, top=160, width=20, max_width=200, height=22,anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	}
end


-- this script is activated every 0.5 sec. it uses a finite state machine (main_state). 
-- State nil is the inital game state. state 0 is idle.
local function activate()
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		-- initialization 
		main_state = System.init();
		if(main_state~=nil) then
			HelloChat_Init();
			
			---- sample code to immediately load the world if app platform is not used. 
			--local res = System.LoadWorld({
				--worldpath="worlds/MyWorlds/KongFuChat",
				---- use exclusive desktop mode
				--bExclusiveMode = true,
			--})
			
			local params = {worldpath = ""}
			System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
			if(params.res) then
				-- succeed loading
			end
		end
	elseif(main_state=="logo") then
		NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/LogoPage.lua");
		System.UI.Desktop.LogoPage.Show(79, {
			{name = "LogoPage_PE_bg", bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logoTxt", bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logo", bg="Texture/HelloChat/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, color="255 255 255 0", anim="script/apps/HelloChat/Desktop/Motion/Logo_motion.xml"},
		})
	end	
end
NPL.this(activate);