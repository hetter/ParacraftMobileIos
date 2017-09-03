--[[
Title: load default UI theme
Author(s): WangTian
Date: 2008/12/2
Desc: load the default theme for the ui objects and common controls
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/DefaultTheme.lua");
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
function Aquarius_LoadDefaultTheme()

	-- ParaUI.SetUseSystemCursor(true);
	ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",0,8);
	
	ParaUI.GetUIObject("root").cursor = "Texture/kidui/main/cursor.tga"
	-- how many minutes are there in a day.
	ParaScene.SetDayLength(900);
	
	
	-- NOTE: choose a font carefully for Aquarius
	
	--System.DefaultFontFamily = "Tahoma"; -- Windows default font
	--System.DefaultFontFamily = "helvetica"; -- Macintosh default font
	--System.DefaultFontFamily = "Verdana"; -- famous microsoft font
	
	--System.DefaultFontFamily = "System";
	System.DefaultFontFamily = "Tahoma"
	System.DefaultFontSize = 12;
	System.DefaultFontWeight = "norm";
	
	local fontStr = string.format("%s;%d;%s", 
				System.DefaultFontFamily, 
				System.DefaultFontSize, 
				System.DefaultFontWeight);
	
	-- TODO: artist should design the font family, size and bold type combination to utilize different text appearance
	-- SUGGESTION: use font with only alphabetical letter and number(not including Chinese characters) for pure visual(not informitive) text
	System.DefaultFontString = "Tahoma;12;norm";
	System.DefaultBoldFontString = "Tahoma;12;bold";
	System.DefaultLargeFontString = "Tahoma;14;norm";
	System.DefaultLargeBoldFontString = "Tahoma;14;bold";
				
	local _this;
	_this = ParaUI.GetDefaultObject("scrollbar");
	local states = {[1] = "highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};
	local i;
	for i = 1, 4 do
		_this:SetCurrentState(states[i]);
		texture=_this:GetTexture("track");
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_Track_32bits.png";
		texture.texture="Texture/Aquarius/Common/Scrollbar_Track_32bits.png";
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_Track_32bits.png; 0 0 15 15";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_track.png";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_track.png: 2 2 2 2";
		texture=_this:GetTexture("up_left");
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_UpLeft_32bits.png";
		texture.texture="Texture/Aquarius/Common/Scrollbar_UpLeft_32bits.png";
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_UpLeft_32bits.png; 0 0 15 15";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_upleft.png";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_upleft.png; 0 0 24 24 : 2 2 2 2";
		texture=_this:GetTexture("down_right");
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_DownRight_32bits.png";
		texture.texture="Texture/Aquarius/Common/Scrollbar_DownRight_32bits.png";
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_DownRight_32bits.png; 0 0 15 15";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_downright.png; 0 0 24 24 : 2 2 2 2";
		texture=_this:GetTexture("thumb");
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_Thumb_32bits.png";
		texture.texture="Texture/Aquarius/Common/Scrollbar_Thumb_32bits.png";
		--texture.texture="Texture/Aquarius/Andy/Scrollbar_Thumb_32bits.png; 0 0 15 21: 7 9 7 8";
		--texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_thumb.png: 2 2 2 2";
	end
	
	_this=ParaUI.GetDefaultObject("button");
	_this.font = fontStr;
	--_this.background = "Texture/Aquarius/Button_Normal.png:8 8 7 7";
	_this.background = "Texture/3DMapSystem/common/checkbox_hovered.png: 5 5 5 5";
	--_this.background = "Texture/Aquarius/Common/Button_32bits.png: 5 11 5 8";
	
	_this=ParaUI.GetDefaultObject("listbox");
	_this.font = fontStr;
	--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/listbox_bg.png: 4 4 4 4";
	_this.background = "Texture/Aquarius/Common/Listbox_32bits.png: 4 4 6 6";
	
	_this=ParaUI.GetDefaultObject("container");
	--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4";
	_this.background = "Texture/Aquarius/Common/Container_32bits.png: 4 4 4 4";

	_this=ParaUI.GetDefaultObject("editbox");
	_this.font = fontStr;
	--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/editbox_bg.png: 4 4 4 4";
	_this.background = "Texture/Aquarius/Common/Editbox_32bits.png: 4 4 4 4";
	_this.spacing = 2;
	
	_this=ParaUI.GetDefaultObject("imeeditbox");
	_this.font = fontStr;
	--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/editbox_bg.png: 4 4 4 4";
	_this.background = "Texture/Aquarius/Common/Editbox_32bits.png: 4 4 4 4";
	_this.spacing = 2;
	
	_this=ParaUI.GetDefaultObject("text");
	_this.font = fontStr;
	
	_this=ParaUI.GetDefaultObject("slider");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7"; 
	_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
	
	NPL.load("(gl)script/ide/RadioBox.lua");
	CommonCtrl.radiobox.checked_bg = "Texture/Aquarius/Common/RadioBox_radio_32bits.png";
	CommonCtrl.radiobox.unchecked_bg = "Texture/Aquarius/Common/RadioBox_unradio_32bits.png";
	System.mcml_controls.pe_editor_radio.checked_bg = "Texture/Aquarius/Common/RadioBox_radio_32bits.png";
	System.mcml_controls.pe_editor_radio.unchecked_bg = "Texture/Aquarius/Common/RadioBox_unradio_32bits.png";
	
	NPL.load("(gl)script/ide/CheckBox.lua");
	CommonCtrl.checkbox.checked_bg = "Texture/Aquarius/Common/CheckBox_checked_32bits.png; 0 0 21 21";
	CommonCtrl.checkbox.unchecked_bg = "Texture/Aquarius/Common/CheckBox_Unchecked_Norm_32bits.png; 0 0 21 21";
	CommonCtrl.checkbox.unchecked_over_bg = "Texture/Aquarius/Common/CheckBox_Unchecked_Over_32bits.png; 0 0 21 21";
	System.mcml_controls.pe_editor_checkbox.checked_bg = "Texture/Aquarius/Common/CheckBox_checked_32bits.png; 0 0 21 21";
	System.mcml_controls.pe_editor_checkbox.unchecked_bg = "Texture/Aquarius/Common/CheckBox_Unchecked_Norm_32bits.png; 0 0 21 21";
	System.mcml_controls.pe_editor_checkbox.iconSize = 21;
	
	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	CommonCtrl.dropdownlistbox.dropdownBtn_bg = "Texture/Aquarius/Common/Dropdownlistbox_Btn_32bits.png";
	CommonCtrl.dropdownlistbox.editbox_bg = "";
	CommonCtrl.dropdownlistbox.container_bg = "Texture/Aquarius/Common/Dropdownlistbox_Container_32bits.png: 4 4 4 4";
	CommonCtrl.dropdownlistbox.listbox_bg = "Texture/Aquarius/Common/Dropdownlistbox_Listbox_32bits.png: 4 4 8 8";
	System.mcml_controls.pe_select.dropdownBtn_bg = "Texture/Aquarius/Common/Dropdownlistbox_Btn_32bits.png";
	System.mcml_controls.pe_select.editbox_bg = "";
	System.mcml_controls.pe_select.container_bg = "Texture/Aquarius/Common/Dropdownlistbox_Container_32bits.png: 4 4 4 4";
	System.mcml_controls.pe_select.listbox_bg = "Texture/Aquarius/Common/Dropdownlistbox_Listbox_32bits.png: 4 4 8 8";
	
	System.mcml_controls.pe_progressbar.Default_blockimage = "Texture/Aquarius/Loader/ProgressBar_Filled_32bits.png:20 15 20 16"
	System.mcml_controls.pe_progressbar.Default_background = "Texture/Aquarius/Loader/ProgressBar_BG_32bits.png:20 15 20 16"
	System.mcml_controls.pe_progressbar.Default_height = 32;
	
	---- replace the default messagebox background with Aquarius customization
	--_guihelper.MessageBox_BG = "Texture/Aquarius/MessageBox.png:24 24 24 24";
	---- default toplevel dialogbox bg
	--_guihelper.DialogBox_BG = "Texture/Aquarius/MessageBox.png:24 24 24 24";
	
	-- replace the default messagebox background with Aquarius customization
	_guihelper.MessageBox_BG = "Texture/Aquarius/Login/MessageBox_32bits.png:8 8 16 16";
	-- default toplevel dialogbox bg
	_guihelper.DialogBox_BG = "Texture/Aquarius/Login/MessageBox_32bits.png:8 8 16 16";
	
	-- TODO: change the following background
	_guihelper.OK_BG = "Texture/Aquarius/Button_HighLight.png:8 8 7 7";
	
	_guihelper.Cancel_BG = "Texture/Aquarius/Button_Normal.png:8 8 7 7";
	
	--_guihelper.QuestionMark_BG = "Texture/Aquarius/Login/Question_32bits.png";
	_guihelper.QuestionMark_BG = "Texture/3DMapSystem/QuestionMark_BG.png";
	
	_guihelper.ExclamationMark_BG = "Texture/3DMapSystem/ExclamationMark_BG.png";
	
	NPL.load("(gl)script/ide/ContextMenu.lua");
	CommonCtrl.ContextMenu.DefaultStyle = {
		borderTop = 4,
		borderBottom = 4,
		borderLeft = 0,
		borderRight = 0,
		
		fillLeft = -20,
		fillTop = -15,
		fillWidth = -19,
		fillHeight = -24,
		
		menu_bg = "Texture/Aquarius/Common/ContextMenu_BG_32bits.png: 31 27 31 36",
		shadow_bg = nil,
		separator_bg = "Texture/Aquarius/Common/ContextMenu_Separator.png: 1 1 1 4",
		item_bg = "Texture/Aquarius/Common/ContextMenu_ItemBG_32bits.png: 1 1 1 1",
		expand_bg = "Texture/Aquarius/Common/ContextMenu_Expand.png",
		expand_bg_mouseover = "Texture/Aquarius/Common/ContextMenu_Expand_MouseOver.png",
		
		menuitemHeight = 22,
		separatorHeight = 8,
		titleHeight = 22,
		
		titleFont = System.DefaultLargeBoldFontString;
	};
	
	-- replace the default window style with Aquarius customization
	CommonCtrl.WindowFrame.DefaultStyle = {
		name = "DefaultStyle",
		
		--window_bg = "Texture/Aquarius/Common/frame2_32bits.png:8 25 8 8",
		window_bg = "Texture/Aquarius/Common/Frame3_32bits.png:32 46 20 17",
		fillBGLeft = 0,
		fillBGTop = 0,
		fillBGWidth = 0,
		fillBGHeight = 0,
		
		shadow_bg = "Texture/Aquarius/Common/Frame3_shadow_32bits.png: 16 16 32 32",
		fillShadowLeft = -5,
		fillShadowTop = -4,
		fillShadowWidth = -9,
		fillShadowHeight = -10,
		
		titleBarHeight = 36,
		toolboxBarHeight = 48,
		statusBarHeight = 32,
		borderLeft = 1,
		borderRight = 1,
		borderBottom = 16,
		
		textfont = System.DefaultBoldFontString;
		textcolor = "35 35 35",
		
		iconSize = 16,
		iconTextDistance = 16, -- distance between icon and text on the title bar
		
		IconBox = {alignment = "_lt",
					x = 13, y = 12, size = 16,},
		TextBox = {alignment = "_lt",
					x = 32, y = 12, height = 16,},
					
		CloseBox = {alignment = "_rt",
					x = -24, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Close_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Close_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Close_pressed_32bits.png; 0 0 17 16",
					},
		MinBox = {alignment = "_rt",
					x = -60, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Min_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Min_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Min_pressed_32bits.png; 0 0 17 16",
					},
		MaxBox = {alignment = "_rt",
					x = -42, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Max_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Max_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Max_pressed_32bits.png; 0 0 17 16",
					},
		PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
					x = 2, y = 2, size = 20,
					icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
					icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
		
		resizerSize = 24,
		resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
	};
	
	---- replace the default window style with Aquarius customization
	--CommonCtrl.WindowFrame.DefaultStyle = {
		--name = "DefaultStyle",
		--
		--window_bg = "Texture/Aquarius/Common/frame2_32bits.png:8 25 8 8",
		--fillBGLeft = 0,
		--fillBGTop = 0,
		--fillBGWidth = 0,
		--fillBGHeight = 0,
		--
		--shadow_bg = "Texture/Aquarius/Common/frame2_shadow.png: 30 30 30 30",
		--fillShadowLeft = -21,
		--fillShadowTop = -6,
		--fillShadowWidth = -21,
		--fillShadowHeight = -28,
		--
		--titleBarHeight = 25,
		--toolboxBarHeight = 48,
		--statusBarHeight = 32,
		--borderLeft = 2,
		--borderRight = 2,
		--borderBottom = 2,
		--
		--textcolor = "255 255 255",
		--
		--iconSize = 16,
		--iconTextDistance = 16, -- distance between icon and text on the title bar
		--
		--CloseBox = {alignment = "_rt",
				--x = -24, y = 2, size = 20,
				--icon = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",},
		--MinBox = {alignment = "_rt",
					--x = -75, y = 2, size = 20,
					--icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",},
		--MaxBox = {alignment = "_rt",
					--x = -55, y = 2, size = 20,
					--icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",},
		--PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
					--x = 2, y = 2, size = 20,
					--icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
					--icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
		--
		--resizerSize = 24,
		--resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
	--};
	
	-- change the loader UI, remove following lines if u want to use default paraworld loader ui.
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	System.UI.LoaderUI.items = {
		{name = "Aquarius.UI.LoaderUI.bg", type="container",bg="Texture/Aquarius/Login/BG_32bits.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "Aquarius.UI.LoaderUI.logoTxt", type="container",bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aquarius.UI.LoaderUI.logo", type="container",bg="Texture/Aquarius/Login/Logo_32bits.png", alignment = "_ct", left=-128, top=-100, width=256, height=128, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aquarius.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/Aquarius/Loader/ProgressBar_BG_32bits.png:20 15 20 16",alignment = "_ct", left=-100, top=160, width=200, height=32, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aquarius.UI.LoaderUI.text", type="text", text="正在装载世界...", alignment = "_ct", left=-100+10, top=160+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "Aquarius.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/Aquarius/Loader/ProgressBar_Filled_32bits.png:20 15 20 16", alignment = "_ct", left=-100, top=160, width=20, max_width=200, height=32, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	}
	-- unbind post world load animation
	System.UI.LoaderUI.ifBoundAnimation = false;
end


			--style = {
				--window_bg = "Texture/Aquarius/Andy/Frame_55_32bits.png:8 56 20 3",
				--fillBGLeft = 0,
				--fillBGTop = 0,
				--fillBGWidth = 0,
				--fillBGHeight = 0,
				--
				--shadow_bg = "Texture/Aquarius/Common/frame2_shadow.png: 30 30 30 30",
				--fillShadowLeft = -21,
				--fillShadowTop = -6,
				--fillShadowWidth = -21,
				--fillShadowHeight = -28,
				--
				--titleBarHeight = 22,
				--
				--borderLeft = 0,
				--borderRight = 0,
				--borderBottom = 1,
				--resizerSize = 24,
				--resizer_bg = "",
				--
				--textcolor = "0 0 0",
				--
				--iconSize = 16,
				--iconTextDistance = 16, -- distance between icon and text on the title bar
				--
				--CloseBox = {alignment = "_lt",
						--x = 8, y = 6, size = 18,
						--icon = "Texture/Aquarius/Andy/Close_32bits.png; 3 2 18 18",},
				--MinBox = {alignment = "_lt",
						--x = 29, y = 6, size = 18,
						--icon = "Texture/Aquarius/Andy/Minimize_32bits.png; 3 2 18 18",},
				--MaxBox = {alignment = "_lt",
						--x = 50, y = 6, size = 18,
						--icon = "Texture/Aquarius/Andy/Maximize_32bits.png; 3 2 18 18",},
				--
				--resizerSize = 16,
				--resizer_bg = "Texture/Aquarius/Common/Resizer_32bits.png",
			--},