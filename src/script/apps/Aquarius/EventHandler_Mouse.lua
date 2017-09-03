--[[
Title: Mouse Cursor and click management for Aquarius App
Author(s): WangTian
Date: 2008/12/16
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/EventHandler_Mouse.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktopCursor";
local HandleMouse = {};
commonlib.setfield("MyCompany.Aquarius.HandleMouse", HandleMouse);

-- show cursor text like tooltip of ui object
-- @param text: text shown in cursor text area, if nil or empty string, it will hide the cursor text
-- NOTE: this function make an assumption that HandleMouse.GetCursorFromSceneObject() function is called on every mouse move
--		otherwise the tooltip position and content will not be updated
function HandleMouse.ShowCursorText(text, font, fontcolor)
	local _cursorText = ParaUI.GetUIObject("AquariusCursorText");
	if(_cursorText:IsValid() == false) then
		-- NOTE: create the cursor text beyond the screen area and translation the object to the cursor position
		_cursorText = ParaUI.CreateUIObject("button", "AquariusCursorText", "_lt", 0, -100, 1000, 30); 
		_cursorText.enabled = false;
		_cursorText.background = "Texture/tooltip2_32bits.PNG: 6 8 5 6";
		_cursorText.zorder = 1000; -- stay above all other ui objects
		_guihelper.SetUIColor(_cursorText, "255 255 255")
		_cursorText:AttachToRoot();
	end
	if(text == nil or text == "") then
		_cursorText.visible = false;
		return;
	end
	
	_cursorText.text = text;
	if(font) then
		_cursorText.font = font;
	end
	if(fontcolor) then
		_guihelper.SetFontColor(_cursorText, fontcolor)
	end
	local width = _guihelper.GetTextWidth(text, font or System.DefaultFontString);
	local mouseX, mouseY = ParaUI.GetMousePosition();
	_cursorText.translationx = mouseX;
	_cursorText.translationy = 100 + mouseY + 24;
	_cursorText.width = width + 16;
	_cursorText.visible = true;
end

-- get the cursor from game scene object
-- this function is called on mouse move in system event handler
-- @param obj:
function HandleMouse.GetCursorFromSceneObject(obj)
	if(obj ~= nil and obj:IsValid() and obj:IsCharacter()) then
		local head = string.sub(obj.name, 1, 4);
		if(head == "NPC:") then
			local x, y, z = obj:GetPosition();
			local x_p, y_p, z_p = ParaScene.GetPlayer():GetPosition();
			local distSquare = math.pow((x_p - x), 2) + 
							   math.pow((y_p - y), 2) + 
							   math.pow((z_p - z), 2);
			if(distSquare >= System.options.NpcTalkDistSq) then
				HandleMouse.ShowCursorText(obj.name, System.DefaultFontString, "35 35 35");
				return "talkgrey";
			else
				HandleMouse.ShowCursorText(obj.name, System.DefaultFontString, "35 35 35");
				return "talk";
			end
		end
	end
	HandleMouse.ShowCursorText("");
end


-- handler object right click
-- contect menu is shown when the creator application is active
-- @param obj:
-- @return: true if continue common mouse click procedure, false to finish
function HandleMouse.OnMouseRightClickObj(obj)
	if(obj ~= nil and obj:IsValid() and obj:IsCharacter()) then
		-- select the character first
		if(Map3DSystem.UI.DesktopMode.CanSelectCharacter) then
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj=obj});
		end	
		
		-- if name begins with NPC: 
		local head = string.sub(obj.name, 1, 4);
		if(head == "NPC:") then
			local dist = ParaScene.GetPlayer():DistanceTo(obj)
			if(dist < System.options.CharClickDist) then
				-- call the Aquarius dialog
				-- we directly call the dialog window in aquarius if the command exists
				-- TODO: change the context menu to allow modification, AddMenuItem, RemoveMenuItem .etc
				local command = System.App.Commands.GetCommand("Profile.Aquarius.Dialog");
				if(command) then
					command:Call({obj = obj,});
				end
			end
			return false;
		else
			-- if OPC, don't continue with mouse right actions, e.g. right click move
			local att = obj:GetAttributeObject();
			local isOPC = att:GetDynamicField("IsOPC", false);
			if(isOPC == true) then
				return false;
			else
				return true;
			end
		end
	else
		return true;
	end
end