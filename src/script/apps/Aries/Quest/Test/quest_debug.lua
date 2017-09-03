--[[
Title: 
Author(s): Leio
Date: 2011/06/27
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/Test/quest_debug.lua");
local quest_debug = commonlib.gettable("MyCompany.Aries.Quest.quest_debug");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
-- create class
local quest_debug = commonlib.gettable("MyCompany.Aries.Quest.quest_debug");
quest_debug.list = {};
function quest_debug.OnInit()
	local self = quest_debug;
	self.page = document:GetPageCtrl();
end
function quest_debug.DS_Func_Items(index)
	local self = quest_debug;
	if(not self.list)then return 0 end
	if(index == nil) then
		return #(self.list);
	else
		return self.list[index];
	end
end
function quest_debug.Load_Quests()
	local self = quest_debug;
	local provider = QuestClientLogics.GetProvider();
	if(provider and not self.loaded)then
		self.loaded = true;
		local templates = provider:GetTemplateQuests();
		local k,template;
		for k,template in pairs(templates) do
			local Role = template.Role;
			local isMyRole = provider:Role_Equals(Role);
			if(isMyRole)then
				table.insert(self.list,template);
			end
		end
		table.sort(self.list,function(a,b)
			local id_1 = a.Id or -1;
			local id_2 = b.Id or -1;
			return id_1 < id_2
		end);
		if(self.page)then
			self.page:Refresh(0);
		end
	end
end
function quest_debug.DoClick(id)
	local self = quest_debug;
	self.selected_id = id;	
	if(self.page)then
		self.page:Refresh(0);
	end
end