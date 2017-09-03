--[[
Title: Main game loop
Author(s): LiXizhi, WangTian
Date: 2008/10/28
Desc: Entry point and game loop
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/Orion/main_loop.lua");
set the bootstrapper to point to this file, see config/bootstrapper.xml
Or run application with command line: bootstrapper="script/apps/Orion/bootstrapper.xml"
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes

-- uncomment this line to display our logo page. 
-- main_state="logo";

-- some init stuffs that are only called once at engine start up, but after System.init()
local bOrion_Init;
local function Orion_Init()
	if(bOrion_Init) then return end
	bOrion_Init = true;
	
	-- load default theme
	NPL.load("(gl)script/apps/Orion/DefaultTheme.lua");
	Orion_LoadDefaultTheme();
	
	-- install the Orion app, if it is not installed yet.
	local app = System.App.AppManager.GetApp("Orion_GUID")
	if(not app) then
		app = System.App.Registration.InstallApp({app_key="Orion_GUID"}, "script/apps/Orion/IP.xml", true);
	end
	-- change the login machanism to use our own login module
	System.App.Commands.SetDefaultCommand("Login", "Profile.Orion.Login");
	-- change the load world command to use our own module
	System.App.Commands.SetDefaultCommand("LoadWorld", "File.EnterHelloWorld");
	-- change the handler of system command line. 
	System.App.Commands.SetDefaultCommand("SysCommandLine", "Profile.Orion.SysCommandLine");
	-- change the handler of enter to chat. 
	System.App.Commands.SetDefaultCommand("EnterChat", "Profile.Orion.EnterChat");
	
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
			Orion_Init();
			
			-- sample code to immediately load the world if app platform is not used. 
			local res = System.LoadWorld({
				worldpath="worlds/MyWorlds/1111111111111",
				-- use exclusive desktop mode
				bExclusiveMode = true,
			})
			
			-- show login window
			NPL.load("(gl)script/apps/Orion/Login/MainLogin.lua");
			MyCompany.Orion.MainLogin.Show();
			--pp: to test _guihelper.MessageBox("Hello ParaEngine!")
			--_guihelper.MessageBox("Hello ParaEngine!")         
 
 			--local params = {worldpath = ""}
			--System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
			--if(params.res) then
				---- succeed loading
			--end
			
			--[[
			--create a new window called "mainwindow" at (50,20) with size 600*400
                local window=ParaUI.CreateUIObject("container","mainwindow","_lt",150,200,400,400);
            --attach the control to root
               window:AttachToRoot();
                               
            --create a new text box called "txt" at (50,50) with size 500*300
                 local text=ParaUI.CreateUIObject("text","txt","_lt",150,200,500,300);
            --attach the text to the window
                window:AddChild(text);
                text.text="ParaEmail";
                
            --create a new button called "btnok" at (50,500) with size 70*30
               local button=ParaUI.CreateUIObject("button","btnok","_lt",50,350,70,30);
            --attach the button to the window
               window:AddChild(button);
               button.text="OK";
            --if the button is clicked, close the window
               button.onclick = ";ParaUI.Destroy(\"mainwindow\")"
               ]]
               --local groot = ParaUI.CreateUIObject("container","Mail","_lt",0, 0, 0, 0)
			   --groot.background = "Texture/speak_box.png:15 15 15 15";
			   --groot.zorder = 200
			   --groot:AttachToRoot()
			   local node = ParaUI.CreateUIObject("editbox","MailShowArea_EditboxTo","_lt",200, 200+110, 600, 30)
			   node.background = "Texture/speak_box.png:15 15 15 15";
			   node.zorder = 20
               node:AttachToRoot()
               
				NPL.load("(gl)script/ide/MultiLineEditbox.lua");
				local ctl = CommonCtrl.MultiLineEditbox:new{
					name = "MultiLineEditbox_Mail_Compose",
					alignment = "_lt",
					left = 200, 
					top = 150,
					width = 200,
					height = 50, 
					WordWrap = false,
					container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4",
					parent = node.parent,
				};
				ctl:Show(true);
				ctl:SetText("Please Compose Here:\r");
				log(ctl:GetText());
			
               
			   --groot:AddChild(node)
               
               function TestParaIO(wndname)
				local f = ParaIO.open("mail/test.txt", "w")
				if(f:IsValid()) then
					--f:WriteString(ParaGlobal.GetDateFormat("yyyy-M-d"))
					local node = ParaUI.GetUIObject("MailShowArea_EditboxTo")
					if(node) then f:WriteString(node.text) end
					--local t = f:GetText()
					--local u = ParaUI.GetUIObject(wndname)
					--if(u) then
					--	u.text = t 
					--end
					--log("\n ppp:"..t)
					f:close()
				end
               end
               
               local node = ParaUI.CreateUIObject("button", "TestParaIO","_lt", 200, 200, 200, 100)
               --node.background = "Texture/box.png: 32 32 32 32"
               node.text = "Test ParaIO"
               node.onclick = string.format(";TestParaIO(%q);", "TestParaIO")--";TestParaIO();"
               node.zorder = 20
               --groot:AddChild(node)
               node:AttachToRoot()
               
		end
	elseif(main_state=="logo") then
		NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/LogoPage.lua");
		System.UI.Desktop.LogoPage.Show(79, {
			{name = "LogoPage_PE_bg", bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logoTxt", bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logo", bg="Texture/Orion/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, color="255 255 255 0", anim="script/apps/Orion/Desktop/Motion/Logo_motion.xml"},
		})
	end	
end      
         
NPL.this(activate);

