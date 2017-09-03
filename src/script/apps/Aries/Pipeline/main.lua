--[[
Title: Pipeline Entry for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Pipeline/main.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AriesPipeline";
local Pipeline = {};
commonlib.setfield("MyCompany.Aries.Pipeline", Pipeline);

-- Pipeline.init()
function Pipeline.Init()
end

-- check if in pipeline mode
function Pipeline.IsPipelineMode()
	local _pipelineArea = ParaUI.GetUIObject("Aries_PipelineArea");
	if(_pipelineArea:IsValid() == true) then
		if(_pipelineArea.visible == true) then
			return true;
		end
	end
	return false;
end

-- show or hide the Pipeline area, toggle the visibility if bShow is nil
function Pipeline.Show(bShow)
	local preMode = Pipeline.IsPipelineMode()
	local _pipelineArea = ParaUI.GetUIObject("Aries_PipelineArea");
	if(_pipelineArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _pipelineArea.visible;
		end
		_pipelineArea.visible = bShow;
	else
		local btn_size = 32;
		local btn_spacing = 5;
		local stack_buttons = {
			-- add more debug buttons here
			{icon="Texture/3DMapSystem/AppIcons/chat_64.dds", onclick=";MyCompany.Aries.Pipeline.ShowPortalPage();", tooltip="提交战斗BUG点", },
			{icon="Texture/3DMapSystem/AppIcons/Environment_64.dds", url="script/apps/Aries/Pipeline/PortalPage.html", tooltip="portal page", },
			{icon="Texture/3DMapSystem/AppIcons/Inventory_64.dds", url="script/apps/Aries/Debug/GlobalStoreView.html", tooltip="global store", },
			{icon="Texture/3DMapSystem/AppIcons/Settings_64.dds", url="script/apps/Aries/Debug/AdvItemView.html?bag=0", tooltip="adv items", },
			{icon="Texture/3DMapSystem/AppIcons/Tasks_64.dds", url="script/apps/Aries/Quest/Test/quest_debug.html", tooltip="quest debug", },
			{icon="Texture/3DMapSystem/AppIcons/Pet_64.dds", url="script/apps/Aries/Debug/ResetQuestState.html", tooltip="reset quest state", },
			{icon="Texture/3DMapSystem/AppIcons/painter_64.dds", url="script/kids/3DMapSystemApp/Developers/ArtToolsPage.html", tooltip="art tool page", },
		}

		local _pipelineArea = ParaUI.CreateUIObject("container", "Aries_PipelineArea", "_ctt", 0, 0, (#stack_buttons)*(btn_size+btn_spacing)-btn_spacing, btn_size);
		_pipelineArea.background = "Texture/alphadot.png";
		_pipelineArea.zorder = 100;
		_pipelineArea:AttachToRoot();
		
		local _this;
		local left = 0;
		local i, button
		for i, button in ipairs(stack_buttons) do
			_this = ParaUI.CreateUIObject("button", "btn"..i, "_lt", left, 0, btn_size, btn_size);
			_this.background = button.icon;
			_this.animstyle = 22;
			_this.onclick = button.onclick or format([[;Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="%s", name="MyBrowser", title="My browser", y=32, width=960, height=560,DisplayNavBar = true, DestroyOnClose=true});]], button.url);
			if(button.tooltip) then _this.tooltip = button.tooltip; end
			_pipelineArea:AddChild(_this);
			left = left + btn_size + 5;
		end
	end
	if(preMode == true and Pipeline.IsPipelineMode() == false) then
		-- leave pipeline mode
		Pipeline.OnLeavePipelineMode();
	elseif(preMode == false and Pipeline.IsPipelineMode() == true) then
		-- enter pipeline mode
		Pipeline.OnEnterPipelineMode();
	end
end

-- enter pipeline mode
function Pipeline.OnEnterPipelineMode()
	Map3DSystem.bAllowTeleport = true;
	--System.App.worlds.Global_RegionRadar.End();
end

-- leave pipeline mode
function Pipeline.OnLeavePipelineMode()
	Map3DSystem.bAllowTeleport = false;
	--System.App.worlds.Global_RegionRadar.Start();
end


-- show the pipeline manager
function Pipeline.ShowPortalPage()
	
	MyCompany.Aries.Combat.MsgHandler.OnCheckMyGearScore()

	_guihelper.MessageBox("提交GS查询...");

	do return end

	MyCompany.Aries.Combat.MsgHandler.OnMarkDebugPoint()

	_guihelper.MessageBox("提交BUG标注...");
	do return end
	
	-- show portal page
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		url = "script/apps/Aries/Pipeline/PortalPage.html", 
		name = "Aries.Pipeline.PortalPage", 
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = true,
		text = "Aries Pipeline",
		allowDrag = true,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		zorder = 2,
		directPosition = true,
			align = "_ct",
			x = -800/2,
			y = -520/2,
			width = 802,
			height = 500,
	});
end

-- execute empty pipeline tool
function Pipeline.OnClickEmptyTool()
	
end