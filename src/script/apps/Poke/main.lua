--[[
Title: poke app for Paraworld
Author(s): wangtian
Date: 2007/12/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Poke/main.lua");
------------------------------------------------------------
]]

if(not apps) then apps = {} end

apps.Poke = {};

-- for main menu IP
-- TODO for andy: ur specifications here
apps.Poke.mainbarKidsMovie = {
	SubIconSet = {
	[1] = {
		Name = "状态",
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Status.png; 0 0 48 48",
		onclick = "",
		},
	[2] = {
		ShowIcon = true;
		ToolTip = "Exit";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Exit.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Menu_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/exit_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/exit_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Exit.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Exit.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Exit.OnMouseLeave;
		},
	}
}

-- for creation IP
-- TODO for andy: ur specifications here
apps.Poke.db_assets = {};
apps.Poke.db_assets.normalmodel = {};
apps.Poke.db_assets.CCS = {};
apps.Poke.db_assets.BCS = {
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = "民房",
  ["ModelFilePath"] = "model/01building/v1/01house/mingfang/mingfang.x",
  ["IconFilePath"] = "model/01building/v1/01house/mingfang/mingfang.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = "民房",
  ["ModelFilePath"] = "model/01building/v1/01house/minfang2/minfang2.x",
  ["IconFilePath"] = "model/01building/v1/01house/minfang2/minfang2.x.png",
}
};

-- basic IP onclick event handler
function apps.Poke.OnClickMainBarIP()
	_guihelper.MessageBox();
end

function apps.Poke.OnMainWndMsg()
	-- TODO: remove the "Map3DSystem.msg." make the message Map3DSystem independent
	if(msg.type == Map3DSystem.msg.APP_INIT) then
	elseif(msg.type == Map3DSystem.msg.APP_ON_ADD_APP) then
	elseif(msg.type == Map3DSystem.msg.APP_ON_REMOVE_APP) then
	elseif(msg.type == Map3DSystem.msg.APP_ON_HOMEPAGE) then
	elseif(msg.type == Map3DSystem.msg.APP_ON_PROFILE_ACTION) then
	elseif(msg.type == Map3DSystem.msg.APP_ON_START_UI) then
	end
end

-- app entry point
local function activate()
	-- each application must create an application with the given name.
	apps.Poke.app = CommonCtrl.os.CreateGetApp("sample");
	
	-- each application should have a default "main" window.
	apps.Poke.MainWnd = apps.Poke.app:RegisterWindow("main", nil, apps.Poke.OnMainWndMsg);
end
NPL.this(activate);