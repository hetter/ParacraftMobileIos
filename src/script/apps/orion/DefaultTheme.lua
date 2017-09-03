--[[
Title: load default UI theme
Author(s): WangTian
Date: 2008/11/24
Desc: load the default theme for the ui objects and common controls
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Orion/DefaultTheme.lua");
------------------------------------------------------------
]]

-- load the default theme or style for the following ui objects and common controls
--		Cursor: default cursor
--		Day Length:
--		Default ui objects: scroll bar, button, text, editbox .etc
--		Font: default font
--		MessageBox: background
--		WindowFrame: frame background and close button
--		World Loader: background, logo, progress bar and text
function Orion_LoadDefaultTheme()

	-- ParaUI.SetUseSystemCursor(true);
	ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",0,8);
	ParaUI.GetUIObject("root").cursor = "Texture/kidui/main/cursor.tga"
	
	-- how many minutes are there in a day.
	ParaScene.SetDayLength(900);
	
	
	-- NOTE: choose a font carefully for Orion
	
	--System.DefaultFontFamily = "Tahoma"; -- Windows default font
	--System.DefaultFontFamily = "helvetica"; -- Macintosh default font
	--System.DefaultFontFamily = "Verdana"; -- famous microsoft font
	
	System.DefaultFontFamily = "System";
	System.DefaultFontSize = 12;
	System.DefaultFontWeight = "norm";
	
	local fontStr = string.format("%s;%d;%s", 
				System.DefaultFontFamily, 
				System.DefaultFontSize, 
				System.DefaultFontWeight);
				
	local _this;
	_this = ParaUI.GetDefaultObject("scrollbar");
	local states = {[1] = "highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};
	local i;
	for i = 1, 4 do
		_this:SetCurrentState(states[i]);
		texture=_this:GetTexture("track");
		texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_track.png";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_track.png: 2 2 2 2";
		texture=_this:GetTexture("up_left");
		texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_upleft.png";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_upleft.png; 0 0 24 24 : 2 2 2 2";
		texture=_this:GetTexture("down_right");
		texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_downright.png";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_downright.png; 0 0 24 24 : 2 2 2 2";
		texture=_this:GetTexture("thumb");
		texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_thumb.png";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_thumb.png: 2 2 2 2";
	end
	
	_this=ParaUI.GetDefaultObject("button");
	_this.font = fontStr;
	_this.background = "Texture/Orion/Button_Normal.png:8 8 7 7";

	_this=ParaUI.GetDefaultObject("listbox");
	_this.font = fontStr;
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/listbox_bg.png: 4 4 4 4";
	
	_this=ParaUI.GetDefaultObject("container");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4";

	_this=ParaUI.GetDefaultObject("editbox");
	_this.font = fontStr;
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/editbox_bg.png: 4 4 4 4";
	_this.spacing = 2;
	
	_this=ParaUI.GetDefaultObject("imeeditbox");
	_this.font = fontStr;
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/editbox_bg.png: 4 4 4 4";
	_this.spacing = 2;
	
	_this=ParaUI.GetDefaultObject("text");
	_this.font = fontStr;
	
	_this=ParaUI.GetDefaultObject("slider");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7"; 
	_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
	
	
	-- replace the default messagebox background with orion customization
	_guihelper.MessageBox_BG = "Texture/Orion/MessageBox.png:24 24 24 24";
	-- default toplevel dialogbox bg
	_guihelper.DialogBox_BG = "Texture/Orion/MessageBox.png:24 24 24 24";
	
	-- TODO: change the following background
	_guihelper.OK_BG = "Texture/Orion/Button_HighLight.png:8 8 7 7";
	
	_guihelper.Cancel_BG = "Texture/Orion/Button_Normal.png:8 8 7 7";
	
	_guihelper.QuestionMark_BG = "Texture/3DMapSystem/QuestionMark_BG.png";
	
	_guihelper.ExclamationMark_BG = "Texture/3DMapSystem/ExclamationMark_BG.png";
	
	--pp: test Messagebox
	--_guihelper.MessageBox("Hello ParaEngine!")
	
	-- replace the default window style with orion customization
	CommonCtrl.WindowFrame.DefaultStyle = {
		name = "DefaultStyle",
		
		window_bg = "Texture/Orion/WindowFrame_32bits.png:25 45 25 18",
		fillBGLeft = 0,
		fillBGTop = 0,
		fillBGWidth = 0,
		fillBGHeight = 0,
		
		titleBarHeight = 45,
		toolboxBarHeight = 48,
		statusBarHeight = 32,
		borderLeft = 13,
		borderRight = 13,
		borderBottom = 10,
		
		textcolor = "255 255 255",
		
		iconSize = 16,
		iconTextDistance = 16, -- distance between icon and text on the title bar
		
		CloseBox = {alignment = "_rt",
					x = -48, y = 9, size = 32,
					icon = "Texture/Orion/close_32bits.png",},
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
	
	-- change the loader UI, remove following lines if u want to use default paraworld loader ui.
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	System.UI.LoaderUI.items = {
		{name = "Orion.UI.LoaderUI.bg", type="container",bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "Orion.UI.LoaderUI.logoTxt", type="container",bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Orion.UI.LoaderUI.logo", type="container",bg="Texture/Orion/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Orion.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",alignment = "_ct", left=-100, top=160, width=200, height=22, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Orion.UI.LoaderUI.text", type="text", text="正在加载...", alignment = "_ct", left=-100+10, top=160+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "Orion.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/3DMapSystem/Loader/progressbar_filled.png:7 7 13 7", alignment = "_ct", left=-100, top=160, width=20, max_width=200, height=22,anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	}
end