--[[
Title: code behind for page PortalPage.html
Author(s): WangTian
Date: 2010/3/25
Desc:  script/apps/Aries/Desktop/PortalPage.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local PortalPage = {};
commonlib.setfield("MyCompany.Aries.Pipeline.PortalPage", PortalPage);

local page;
-- purchase the item directly from global store
function PortalPage.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = PortalPage.OnClose;
end

function PortalPage.OnClose()
end

function PortalPage.OnCancel()
	page:CloseWindow();
end

function PortalPage.OnClickEmptyTool()
	_guihelper.MessageBox("PortalPage.OnClickEmptyTool");
	PortalPage.OnCancel();
end

function PortalPage.OnFlushLocalCache()
	
	local input_msg = {
		pass = "5C0FC13CD3A14012863EF318CC16FE98",
	};
	
	paraworld.FlushLocalCache(input_msg, nil, function(msg)
		_guihelper.MessageBox("finished!")
		log("========== paraworld.FlushLocalCache ==========\n")
		commonlib.echo(msg)
		commonlib.echo(msg)
		commonlib.echo(msg)
	end, "access plus 0 day", timeout, timeout_callback);
end

function PortalPage.OnTestPowerPipTutorial()

	System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
		name = "CombatTutorial", on_finish = function()
	    NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatPipTutorial.teen.lua");
        MyCompany.Aries.Quest.NPCs.CombatPipTutorial.main(function()
		    NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
		    local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		    -- teleport back from instance world
		    WorldManager:TeleportBack();
        end);
	end, });
end

function PortalPage.OnClickPrintManuals()
	NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
	local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
	ItemGuides.PrintManualAll();
	_guihelper.MessageBox("Please check  temp/guides/ directory");
end

function PortalPage.OnCheckConfigPublishProcess()
	NPL.load("(gl)script/apps/Aries/Debug/PublishProcess.lua");
    local PublishProcess = commonlib.gettable("MyCompany.Aries.Debug.PublishProcess");
    PublishProcess.main();
end
