---++ Hello Chat Application

---+++ Introduction
KongFuChat.com (code name HelloChat) is 3d chat application created on top of ParaWorld platform. 
It is a demo of creating MMORPG style games using ParaEngine.

In this app, we will shot you how to develop application with NPL, MCML and ParaWorld API
	In this sample application, we will show you how to create a brand new application step by step.
	It will cover chating, character customization, animations and basic social network.

---+++ Running the application
Make sure you have all source and assets files to this application.
run application with command line: bootstrapper="script/apps/HelloChat/bootstrapper.xml"
external command: 
| e.g. | ==paraworldviewer://worlds/MyWorlds/KongFuChat;movie=Movie20081153190-40.xml;== |

---+++ Building & Deployment
To build and deploy the application. follow the following steps. 

Press F12 and run following command
<verbatim>
	NPL.load("(gl)script/installer/BuildParaWorld.lua");
	commonlib.BuildParaWorld.BuildParaWorldViewer()
</verbatim>

Compile NSI installer file ==parawroldviewer_installer_v1.nsi==

The installer will be at [sdkroot]/release/parawroldviewer_installer_[VERSION].exe

---+++ Code Explanation

---++++ Main Loop

==main_loop.lua== is the entry file.  In it, we need to choose a core ParaWorld system to use. See below
<verbatim>
NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes
</verbatim>

Now the ==System== contains a rich set of classes and functions that one can use to interact with the ParaWorld system.

e.g. ==System.init()== needs to be called when the engine start. 
e.g. ==System.LoadWorld()== can be called to load a given virtual world. 

---++++ ParaWorld Application Architecture
In paraworld, we can add/remove applications dynamically. One can use the DeveloperApp's NewPackage dialog to create an empty app.
It will generate two files ==app_main.lua== and ==IP.xml==.

One can programmatically install an application to ParaWorld like below
<verbatim>
	-- install the HelloChat app, if it is not installed yet.
	local app = System.App.AppManager.GetApp("HelloChat_GUID")
	if(not app) then
		app = System.App.Registration.InstallApp({app_key="HelloChat_GUID"}, "script/apps/HelloChat/IP.xml", true);
	end
</verbatim>

One can set a given application as the default application when a given world is loaded, like below
<verbatim>
	System.UI.AppDesktop.SetDefaultApp("HelloChat_GUID", true);
</verbatim>

if one looks at the automatically genereated ==app_main.lua==, one will notice that there are already several messsage handlers.
e.g. ==System.App.MSGTYPE.APP_ACTIVATE_DESKTOP== will be fired whenever an application desktop becomes active. 
One can usually create desktop related UI in its msg handler like below.
<verbatim>
	function MyCompany.HelloChat.OnActivateDesktop()
		-- TODO: create UI of this app.
	end
</verbatim>

---++++ How to customize startup logo 
The logo page is usually the animation shown when the executable starts. To add a custom logo page is really simple. 

in your main_loop file. Set the initial state to e.g. "logo". and then call ==System.UI.Desktop.LogoPage.Show==
see below.
<verbatim>
main_state="logo";

-- in your loop file, write following.
if(main_state=="logo") then
	NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/LogoPage.lua");
	System.UI.Desktop.LogoPage.Show(79, {
			{name = "LogoPage_PE_bg", bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logoTxt", bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
			{name = "LogoPage_PE_logo", bg="Texture/HelloChat/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, color="255 255 255 0", anim="script/apps/HelloChat/Desktop/Motion/Logo_motion.xml"},
	})
end	
</verbatim>

---++++ How to customize world-loading UI
World-loading UI is the UI to be shown when a world is being loaded. it usually displays a progress bar
To add customize it is really simple. 

Just change the LoaderUI.items with your specific ones before calling System.LoadWorld(), like below.
<verbatim>
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	System.UI.LoaderUI.items = {
		{name = "HelloChat.UI.LoaderUI.bg", type="container",bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.logoTxt", type="container",bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.logo", type="container",bg="Texture/HelloChat/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",alignment = "_ct", left=-100, top=160, width=200, height=22, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "HelloChat.UI.LoaderUI.text", type="text", text="ÕýÔÚ¼ÓÔØ...", alignment = "_ct", left=-100+10, top=160+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "HelloChat.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/3DMapSystem/Loader/progressbar_filled.png:7 7 13 7", alignment = "_ct", left=-100, top=160, width=20, max_width=200, height=22,anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	}
</verbatim>	

---++++ How to replace the login module	
To change the login machanism to use our own login module, we need to call the following function, 
where "Profile.HelloChat.Login" is a user supplied command.
<verbatim>
	System.App.Commands.SetLoginCommand("Profile.HelloChat.Login");
</verbatim>

In ==app_main.lua== file, we can add and implement the "Profile.HelloChat.Login" command to show a MCML page for the actual login. see below
<verbatim>
function MyCompany.HelloChat.OnExec(app, commandName, params)
	if(commandName == "Profile.HelloChat.Login") then
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/HelloChat/Desktop/LoginPage.html", name="HelloLogin.Wnd", 
			app_key=app.app_key, 
			text = "Login window",
			isShowTitleBar = true, 
			allowResize = false,
			initialPosX = (1020-320)/2,
			initialPosY = 50,
			initialWidth = 320,
			initialHeight = 290,
			zorder=3,
		});
	end	
end
</verbatim>

---++++ How to replace the default load world command
The default load world command is "File.EnterWorld". load world command is used in a number of places, such as pe_world tag, etc. 
If your application use none of these UI. There is no need to replace the load world command. However, it is good practice to always supply a 
load world command with the same interface as the core system, and load all your worlds via this command. 

==File.EnterWorld== command interface

Host and/or Join a given homeworld using the lobby server.
| *Property*	| *Descriptions*				 |
| worldpath		| the downloaded local world path from which to load the world |
| role			| the role of the current user that will join the world. values may be "guest", "administrator", "poweruser", "friend". If this is nil, it will be default to "guest" or "administrator" depending on the server type. |
| server		| if this is nil, it will be loaded as an offline world unless autolobby is specified. if it is like "jgsl://username@domain", it will login to the server according to server type. In most cases, it is JGSL. |
| autolobby		| if this is true, paraworld.lobby.* api will be used to either host or join an existing world with given worldpath.|

*example*
<verbatim>
	-- load an ordinary offline world
	System.App.Commands.Call("File.EnterWorld", {worldpath = "worlds/Templates/Empty/smallisland"});
	-- load an downloaded online world and join or host using paraworld.lobby API. 
	System.App.Commands.Call("File.EnterWorld", {worldpath = "worlds/Templates/Empty/smallisland", autolobby=true});
</verbatim>

To replace above load world module, we will now create a load world command called File.EnterHelloWorld, or you can simply use the same name as the default. See example below.

<verbatim>
	-- when this to switch the command at startup
	System.App.Commands.SetLoadWorldCommand("File.EnterHelloWorld");
	-- call this whenever you want to load a world
	System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), {worldpath = "worlds/Templates/Empty/smallisland"});
</verbatim>

---++++ How to replace the default system command line handler
<verbatim>
	-- change the handler of system command line. 
	System.App.Commands.SetSysCommandLineCommand("Profile.HelloChat.SysCommandLine");
</verbatim>

---++++ How to replace default window style
We can change the look and feel for windows in the game, by replacing the default window frame style at startup. 
In your startup init code, write some code like below. 
If one wants to change the style when a window is already shown, please use windowframe's ApplyStyle function.
<verbatim>
	CommonCtrl.WindowFrame.DefaultStyle = {
		name = "DefaultStyle",
		
		window_bg = "Texture/HelloChat/frame_32bits.png; 0 0 32 61 : 14 35 14 8",
		fillBGLeft = 0,
		fillBGTop = 0,
		fillBGWidth = 0,
		fillBGHeight = 0,
		
		titleBarHeight = 32,
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
					x = -68, y = 2, size = 20,
					icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",},
		MaxBox = {alignment = "_rt",
					x = -46, y = 2, size = 20,
					icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",},
		PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
					x = 2, y = 2, size = 20,
					icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
					icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
		
		resizerSize = 24,
		resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
	};
</verbatim>	