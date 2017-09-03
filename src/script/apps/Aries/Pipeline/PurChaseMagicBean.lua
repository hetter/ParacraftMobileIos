--[[
Title: code behind for page PurchaseMagicBean.html
Author(s): Spring
Date: 2010/12/10
Desc:  script/apps/Aries/VIP/PurChaseMagicBean.lua
Use Lib:
NPL.load("(gl)script/apps/Aries/Pipeline/PurChaseMagicBean.lua");
-------------------------------------------------------
-------------------------------------------------------
]]
local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");

local item_name, item_gsid;
function PurchaseMagicBean.OnInit()
	PurchaseMagicBean.timer = timer or commonlib.Timer:new({callbackFunc = function(timer)
		PurchaseMagicBean.CheckCount(item_name, item_gsid)
	end})
end

function PurchaseMagicBean.StartTimer(name, gsid)
	item_name, item_gsid = name, gsid;
	PurchaseMagicBean.timer:Change(0,30);
end

function PurchaseMagicBean.StopTimer()
	PurchaseMagicBean.timer:Change();
end

PurchaseMagicBean.lastValidValue = "3";
function PurchaseMagicBean.CheckCount(name, gsid)
	local ctl = CommonCtrl.GetControl(name);
	if(ctl) then
		local init_value = ctl:GetValue("count");
		local value = init_value;
		if(value) then
			if(string.match(value, "([^%d]+)")) then
				value = PurchaseMagicBean.lastValidValue;
			elseif(value == "") then
				value = PurchaseMagicBean.lastValidValue;
			else
				local count = tonumber(value);
				if(count > 1000) then
					value = "1000";
				elseif(count <10) then
					value = "300";
				else
					value = tostring(tonumber(value));
				end
			end
		else
			value = "300";
		end
		
		-- record the last valid count value and refresh the control is needed
		PurchaseMagicBean.lastValidValue = value;
		if(init_value ~= value) then
			ctl:SetValue("count", tostring(value));
		end
		local count=tonumber(value);
		local s = string.format("%d个魔豆需要%d米币，你确认要购买吗？",count,count*0.1);
		ctl:SetValue("buydesc", s);
	end
end

function PurchaseMagicBean.Show()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Pipeline/PurChaseMagicBean.html", 
		name = "PurChaseMagicBean", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 10,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -560/2,
			y = -320/2,
			width = 560,
			height = 320,
		});
end
