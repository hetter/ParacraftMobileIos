--[[
Title: paraworld community introduction or getting started page: it contains everything the user needs to know
Author(s): LiXizhi
Date: 2007/11/2
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/ParaworldIntro/PWIntroPage.lua");
Map3DSystem.App.ParaworldIntro.PWIntroPage.ShowWnd(_app)
Map3DSystem.App.ParaworldIntro.PWIntroPage.Show(bShow,_parent,parentWindow)
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/ide/event_mapping.lua");

-- create class
commonlib.setfield("Map3DSystem.App.ParaworldIntro.PWIntroPage", {});

-- display the main inventory window for the current user.
function Map3DSystem.App.ParaworldIntro.PWIntroPage.ShowWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("PWIntroPage") or _app:RegisterWindow("PWIntroPage", nil, Map3DSystem.App.ParaworldIntro.PWIntroPage.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
			iconSize = 48,
			text = "帕拉巫介绍",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 1024,
			maximumSizeY = 768,
			minimumSizeX = 640,
			minimumSizeY = 480,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = true,
			initialPosX = 10,
			initialPosY = 50,
			initialWidth = 700,
			initialHeight = 530,
			
			ShowUICallback =Map3DSystem.App.ParaworldIntro.PWIntroPage.Show,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
end


-----------------------------------
-- special pages
-----------------------------------
Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage = {
	-- must be unique
	name = nil, 
	--[[ it can be one of the following: 
		"UI": (call the OnShow/OnClose method to display NPL UI) | 
		"external URL": (which display UI to ask to open in external browser) | 
		"web browser": (use internal mozilla browser to view in place) | 
		"text": just display some text and title
		nil: (which is empty)
	]]
	type = nil,
	url = nil, 
	title = nil, -- string
	text = nil,-- string
	icon = nil ,-- string path
	image = nil,-- string path
	-- function of format function(_parent) end where _parent is the parent container
	OnShow = nil, 
	-- function of format function(_parent) end where _parent is the parent container
	OnClose = nil, 
};
-- constructor
function Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	return o
end

function Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage:Show(bShow)
	local _parent=ParaUI.GetUIObject("Map3DSystem.App.ParaworldIntro.PWIntroPage"):GetChild("MainCont");
	if(not _parent:IsValid()) then 
		return
	end
	-- ensure that last page is closed first
	if(bShow) then
		if(Map3DSystem.App.ParaworldIntro.PWIntroPage.CurrentPage~=nil) then
			Map3DSystem.App.ParaworldIntro.PWIntroPage.CurrentPage:Show(false);
		end
	end
	-- then open or close this page
	if(self.type == nil) then
	elseif(self.type == "UI") then
		-- "UI": (call the OnShow/OnClose method to display NPL UI)
		if(bShow) then
			if(self.OnShow~=nil) then
				self.OnShow(_parent);
			end	
		else
			if(self.OnClose~=nil) then
				self.OnClose(_parent);
			end	
		end
	elseif(self.type == "external URL" or self.type == "text") then
		-- "text": just display some text and title
		if(bShow) then
			local _,_, width, height = _parent:GetAbsPosition();
			local left, top = 10, 20;
			if(self.title~=nil) then	
				local _this = ParaUI.CreateUIObject("text", "title", "_lt", left, top, width-20, 20)
				_this.text = self.title;
				_this:GetFont("text").color = "65 105 225";
				_parent:AddChild(_this);
				top = top+30
			end	
			
			if(self.type == "external URL" and self.url~=nil) then
				-- "external URL": (which display UI to ask to open in external browser or internal browser)
				local _this = ParaUI.CreateUIObject("text", "body", "_lt", left, top, width-20, 20)
				_this.text = "点击<外部打开>将使用外部浏览器访问网址:\n"..self.url;
				_parent:AddChild(_this);
				top = top+30;
				
				local _this = ParaUI.CreateUIObject("button", "b", "_lt", left+30, top, 80, 24)
				_this.text = "外部打开";
				_this.onclick = string.format([[;ParaGlobal.ShellExecute("open", "iexplore.exe", %q, nil, 1);]], self.url);
				_parent:AddChild(_this);
				
				--local _this = ParaUI.CreateUIObject("button", "b", "_lt", left+120, top, 80, 24)
				--_this.text = "直接访问";
				--_parent:AddChild(_this);
				
				top = top+50
			end
			
			if(self.text~=nil) then	
				local _this = ParaUI.CreateUIObject("text", "body", "_lt", left, top, width-20, 20)
				_this.text = self.text;
				_parent:AddChild(_this);
			end	
		end
	elseif(self.type == "web browser") then
		-- "web browser": (use internal mozilla browser to view in place) 
		NPL.load("(gl)script/kids/3DMapSystemUI/InGame/WebBrowser.lua");
		Map3DSystem.UI.WebBrowser.BrowserName = "<html>";
		Map3DSystem.UI.WebBrowser.DisplayNavBar = false; -- do not allow linking to other page. 
		Map3DSystem.UI.WebBrowser.Show(bShow, _parent);
		if(bShow) then
			Map3DSystem.UI.WebBrowser.NavigateTo(self.url);
		end	
	end
	
	-- ensure that current UI is properly closed
	if(not bShow) then
		_parent:RemoveAll();
	else
		Map3DSystem.App.ParaworldIntro.PWIntroPage.CurrentPage = self;
	end
end

----------------------------------------
-- sub page instances
----------------------------------------
Map3DSystem.App.ParaworldIntro.PWIntroPage.WelcomePage = Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage:new{name = "WelcomePage", type = "UI"}; -- see WelcomePage.OnShow()
Map3DSystem.App.ParaworldIntro.PWIntroPage.RegisterPage = Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage:new{name = "RegisterPage", type = "external URL", title = "注册新用户", text = "如果您已经注册了,请直接登录", url="http://www.minixyz.com/cn_01/register.aspx"};
Map3DSystem.App.ParaworldIntro.PWIntroPage.LandPage = Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage:new{name = "LandPage", type = "text", title="申请你的虚拟土地", text = "免费发放10万份虚拟土地。大家快来申请！",};
Map3DSystem.App.ParaworldIntro.PWIntroPage.CreationPage = Map3DSystem.App.ParaworldIntro.PWIntroPage.BasePage:new{name = "CreationPage", type = "web browser", url = "local://readme.txt",};

-- current displayed page
Map3DSystem.App.ParaworldIntro.PWIntroPage.CurrentPage = Map3DSystem.App.ParaworldIntro.PWIntroPage.WelcomePage;

----------------------------------------
-- main window
----------------------------------------
function Map3DSystem.App.ParaworldIntro.PWIntroPage.Show(bShow,_parent,parentWindow)
	local _this;
	Map3DSystem.App.ParaworldIntro.PWIntroPage.parentWindow = parentWindow;

	-- display a dialog asking for options
	_this=ParaUI.GetUIObject("Map3DSystem.App.ParaworldIntro.PWIntroPage");
	if(_this:IsValid()) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		if(bShow == false) then
			Map3DSystem.App.ParaworldIntro.PWIntroPage.OnDestory();
		end
	else
		if(bShow == false) then return end
		local width, height = 461, 240

		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","Map3DSystem.App.ParaworldIntro.PWIntroPage", "_ct",-width/2,-height/2-50,width, height);
			_this:AttachToRoot();
		else
			_this=ParaUI.CreateUIObject("container","Map3DSystem.App.ParaworldIntro.PWIntroPage", "_fi",5,5,5,5);
			_this.background = "";
			_parent:AddChild(_this);
		end
		_parent = _this;
		
		-------------------------
		-- a simple 3d scene using mini scene graph
		-------------------------
		local scene = ParaScene.GetMiniSceneGraph("miniGameScene_intro");
		------------------------------------
		-- init render target
		------------------------------------
		-- set size
		scene:SetRenderTargetSize(1024, 256);
		-- reset scene, in case this is called multiple times
		scene:Reset();
		-- enable camera and create render target
		scene:EnableCamera(true);
		-- render it each frame automatically. 
		scene:EnableActiveRendering(true);
		
		local att = scene:GetAttributeObject();
		att:SetField("BackgroundColor", {1, 1, 1});  -- blue background
		att:SetField("ShowSky", false);
		att:SetField("EnableFog", false)
		--[[att:SetField("EnableFog", true);
		att:SetField("FogColor", {1, 1, 1}); -- red fog
		att:SetField("FogStart", 5);
		att:SetField("FogEnd", 25);
		att:SetField("FogDensity", 1);]]
		att:SetField("EnableLight", false)
		att:SetField("EnableSunLight", false)
		scene:SetTimeOfDaySTD(0.3);
		-- set the mini map scene to semitransparent background color
		scene:SetBackGroundColor("255 255 255 0");
		------------------------------------
		-- init camera
		------------------------------------
		scene:CameraSetLookAtPos(0,0.7,0);
		scene:CameraSetEyePosByAngle(0, 0.3, 5);
		------------------------------------
		-- init scene content
		------------------------------------
		NPL.load("(gl)script/ide/MinisceneManager.lua");
		-- load attribute and main scene
		local worldinfo = CommonCtrl.MinisceneManager.GetWorldAttribute("worlds/login_world/login_world.attribute.db");
		-- load mesh: use player location as origin
		CommonCtrl.MinisceneManager.LoadFromOnLoadScript(scene, "worlds/login_world/script/login_world_0_0.onload.lua", worldinfo.PlayerX,worldinfo.PlayerY, worldinfo.PlayerZ)
		-- load NPC: use player location as origin
		CommonCtrl.MinisceneManager.LoadFromOnNPCdb(scene, "worlds/login_world/login_world.NPC.db", worldinfo.PlayerX,worldinfo.PlayerY, worldinfo.PlayerZ);
		-- main player: at 0,0,0
		local obj,player, asset;
		--asset = ParaAsset.LoadParaX("","character/v1/02animals/01land/chevalier/chevalier.x");
		asset = ParaAsset.LoadParaX("","character/v3/Pet/MGBB/mgbb.xml");
		--asset = ParaAsset.LoadParaX("","character/v1/01human/girl/girl.x");
		obj = ParaScene.CreateCharacter("player", asset, "", true, 0.35, 0.5, 1);
		obj:SetPosition(0, 0, 0);
		obj:SetScaling(2.5);
		obj:SetFacing(2);
        
		scene:AddChild(obj);
		
		-- Test effect params. 
		--NPL.load("(gl)script/test/TestMeshLOD.lua");
		--TestMeshEffectParams(scene);
		
		--scene:Draw(0);
		------------------------------------
		-- canvas
		------------------------------------
		NPL.load("(gl)script/ide/Canvas3D.lua");
		local ctl = CommonCtrl.Canvas3D:new{
			name = "miniGameScene_intro",
			alignment = "_mb",
			left=0, top=-7,
			width = 0,
			height = 196,
			parent = _parent,
			IsActiveRendering = true,
			miniscenegraphname = "PWIntroPage",
		};
		ctl:Show();
		-- call following 
		ctl:ShowMiniscene("miniGameScene_intro");

		---------------------------------
		-- middle content container
		---------------------------------
		_this = ParaUI.CreateUIObject("container", "MainCont", "_fi", 143, 48, 139, 196)
		_this.background = "Texture/3DMapSystem/IntroPage/frontpage_dialog.png:23 23 23 23";
		_parent:AddChild(_this);
		
		_parent:UpdateRect();
		_this = ParaUI.CreateUIObject("button", "a", "_ctb", 0, -167, 32, 32)
		_this.background = "Texture/3DMapSystem/IntroPage/frontpage_dialog_arrow.png";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "b", "_lt", 14, 12, 256, 32)
		--_this.text = "欢迎来到帕拉巫世界";
		--_this:GetFont("text").color = "65 105 225";
		_this.enabled=false;
		_this.background = "Texture/3DMapSystem/IntroPage/welcometext.png";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		local nav = {
			[1] = {text = "注册用户", onclick = ";Map3DSystem.App.ParaworldIntro.PWIntroPage.RegisterPage:Show(true);",},
			[2] = {text = "申请土地", onclick = ";Map3DSystem.App.ParaworldIntro.PWIntroPage.LandPage:Show(true);",},
			[3] = {text = "创作交流", onclick = ";Map3DSystem.App.ParaworldIntro.PWIntroPage.CreationPage:Show(true);",},
		}
		local i, item;
		local nSize = table.getn(nav);
		local top = 48;
		for i = 1, nSize do
			item = nav[i];
			_this = ParaUI.CreateUIObject("button", "b", "_lt", 12, top, 32, 32)
			
			local texLeft, texTop = math.mod(i, 4)*32,  math.floor((i)/4)*32;
			_guihelper.SetVistaStyleButtonBright(_this, string.format("Texture/3DMapSystem/IntroPage/16number.png;%d %d 32 32",texLeft, texTop), "Texture/3DMapSystem/IntroPage/circle.png");
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "b", "_lt", 46, top+3, 70, 27)
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			_this.scalingx = 1.05;
			_this.scalingy = 1.05;
			_this.text = item.text;
			if(item.onclick~=nil) then
				_this.onclick = item.onclick;
			end	
			_parent:AddChild(_this);
			
			if(i<nSize) then
				_this = ParaUI.CreateUIObject("button", "b", "_lt", 64, top+32, 32, 32)
				_this.background = "Texture/3DMapSystem/IntroPage/downflow.png";
				_this.enabled = false;
				_guihelper.SetUIColor(_this, "255 255 255");
				_parent:AddChild(_this);
			end	
			
			top = top + 64;
		end
		
		
		_this = ParaUI.CreateUIObject("text", "label2", "_rt", -107, 12, 80, 20)
		_this.text = "社区简介";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewIntroFuncs",
			alignment = "_mr",
			left = 3,
			top = 48,
			width = 129,
			height = 196,
			parent = _parent,
			DefaultIndentation = 18,
			DefaultNodeHeight = 18,
		};
		local node = ctl.RootNode;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "什么是帕拉巫？", Name = "WhatIsIt", Expanded = false, NodeHeight=25}) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "世界地图", Name = "Map", Expanded = false, NodeHeight=25}) );
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "和地球一样大", Name = "EarthScale", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "拥有虚拟土地", Name = "virtualLand", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "全球经济", Name = "economy", }) );
		node = node.parent;
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "探索与交流", Name = "Discover", Expanded = false, NodeHeight=25 }) );
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "找朋友", Name = "FindFriends", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "周游世界", Name = "Explorer", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "3D即时通讯", Name = "Chat", }) );
		node = node.parent;
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "我的3D世界", Name = "Creation", Expanded = false, NodeHeight=25}) );
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "3D角色", Name = "CCS", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "建筑系统", Name = "BCS", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "游戏系统", Name = "Game", }) );
		node = node.parent;
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "高级创作", Name = "VR", Expanded = false, NodeHeight=25}) );
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "3D电子书", Name = "EBook", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "3D电影", Name = "Movie", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "MMORPG网游", Name = "MMORPG", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "电子商务", Name = "EBusiness", }) );
		node = node.parent;
		node = node.parent;
		ctl:Show();
		
		-- register a timer for UI animation
		NPL.SetTimer(109, 0.03, ";Map3DSystem.App.ParaworldIntro.PWIntroPage.OnTimer();");
		
		-- reopen last page
		Map3DSystem.App.ParaworldIntro.PWIntroPage.CurrentPage:Show(true);
	end	
end

----------------------------------
-- methods
----------------------------------
-- destory the control
function Map3DSystem.App.ParaworldIntro.PWIntroPage.OnDestory()
	ParaUI.Destroy("Map3DSystem.App.ParaworldIntro.PWIntroPage");
	ParaScene.DeleteMiniSceneGraph("miniGameScene_intro");
	NPL.KillTimer(109);
end

function Map3DSystem.App.ParaworldIntro.PWIntroPage.OnClose()
	if(Map3DSystem.App.ParaworldIntro.PWIntroPage.parentWindow~=nil) then
		-- send a message to its parent window to tell it to close. 
		Map3DSystem.App.ParaworldIntro.PWIntroPage.parentWindow:SendMessage(Map3DSystem.App.ParaworldIntro.PWIntroPage.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		Map3DSystem.App.ParaworldIntro.PWIntroPage.OnDestory()
	end
end

-- go to a given url.
-- @param url: such as "www.paraengine.com", "http://www.lixizhi.net", 
-- it can also contain relative path like "local://Texture/3DMapSystem/HTML/Credits.html"
function Map3DSystem.App.ParaworldIntro.PWIntroPage.NavigateTo(url)
	--TODO: show content page
end

----------------------------------------------------
-- window events 
----------------------------------------------------

function Map3DSystem.App.ParaworldIntro.PWIntroPage.OnTimer()
	local _this=ParaUI.GetUIObject("Map3DSystem.App.ParaworldIntro.PWIntroPage");
	if(not _this:IsValid()) then
		Map3DSystem.App.ParaworldIntro.PWIntroPage.OnDestory()
	elseif(not CommonCtrl.Canvas3D.IsMouseDown) then
		-- some camera animations for the camera goes on here. 
		local scene = ParaScene.GetMiniSceneGraph("miniGameScene_intro");
		if(scene:IsValid()) then
			local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
			fRotY = fRotY+0.001; --how many degrees per frame
			scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
		end
	end
end

-----------------------------------------------
-- special sub pages of the main intro page
-----------------------------------------------
function Map3DSystem.App.ParaworldIntro.PWIntroPage.WelcomePage.OnShow(_parent)
	local _,_, width, height = _parent:GetAbsPosition();
	local left, top = 10, 30;
	
	local _this = ParaUI.CreateUIObject("text", "title", "_lt", left, top, width-20, 20)
	_this.text = string.format("您好, %q  我是小魔女。\n", Map3DSystem.User.Name);
	_this:GetFont("text").color = "65 105 225";
	_parent:AddChild(_this);
	top = top+30
	
	local _this = ParaUI.CreateUIObject("text", "title", "_lt", left, top, width-20, 20)
	_this.text = [[您使用的是演示版。 您可以提前体验<帕拉巫世界> - 地球尺度的3D创作社区

让我把<帕拉巫世界>介绍给你的朋友吧,请输入你的朋友的Email地址:]];
	_parent:AddChild(_this);
	top = top+60
	
	_this = ParaUI.CreateUIObject("text", "", "_lt", left, top+3, 40, 20)
	_this.text = "Email:"
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("editbox", "", "_lt", left+50, top, 220, 20)
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "", "_lt", left+280, top, 60, 20)
	_this.text = "确定";
	_this.onclick = [[;_guihelper.MessageBox(";谢谢！如果您介绍更多的朋友到帕拉巫世界中，我会奖励给你更多的虚拟土地. :-)")]];
	_parent:AddChild(_this);
end

function Map3DSystem.App.ParaworldIntro.PWIntroPage.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.ParaworldIntro.PWIntroPage.parentWindow.app.name, msg.wndName);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end