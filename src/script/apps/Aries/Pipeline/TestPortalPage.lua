--[[
Title: code behind for page TestPortalPage.html
Author(s): WangTian
Date: 2010/3/25
Desc:  script/apps/Aries/Pipeline/TestPortalPage.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local TestPortalPage = {};
commonlib.setfield("MyCompany.Aries.Pipeline.TestPortalPage", TestPortalPage);

local page;
-- purchase the item directly from global store
function TestPortalPage.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = TestPortalPage.OnClose;
end

function TestPortalPage.OnClose()
end

function TestPortalPage.OnCancel()
	page:CloseWindow();
end

function TestPortalPage.OnClickEmptyTool()
	_guihelper.MessageBox("TestPortalPage.OnClickEmptyTool");
	TestPortalPage.OnCancel();
end