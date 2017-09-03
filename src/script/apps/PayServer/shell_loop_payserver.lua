--[[
Title: shell pay loop file
Author(s):  Gosling, 
Date: 2009/12/23, added local dev by LiXizhi 2010.9.8
Desc: 
command line params:
e.g. bootstrapper="script/apps/PayServer/shell_loop_payserver.lua" config=""
e.g. bootstrapper="script/apps/PayServer/shell_loop_payserver.lua" config="config/AriesDevLocal.PayServer.config.xml"
e.g. in win32 bat file, start ParaEngineServer.exe "bootstrapper=\"script/apps/PayServer/shell_loop_gameserver.lua\" config=\"config/AriesDevLocal.PayServer.config.xml\""
| config | can be omitted which defaults to config/PayServer.config.xml |

use the lib:
------------------------------------------------------------
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/PayServer/PayServer.lua");

main_state = nil;

-- init UI console
local function InitUIConsole()
	if(ParaUI and ParaUI.CreateUIObject and not ParaEngine.GetAttributeObject():GetField("IsServerMode", false)) then
		-- load game server console
		NPL.load("(gl)script/ide/Debugger/MCMLConsole.lua");
		local init_page_url = nil;
		commonlib.mcml_console.show(true, init_page_url);
	end
end

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main pay loop
		
	elseif(main_state==nil) then
		main_state=0;
		
		LOG.std(nil, "system", "PayServer", "Pay Server starting")

		InitUIConsole();

		-- start the server
		local config_file = ParaEngine.GetAppCommandLineByParam("config", "");
		if(config_file == "") then
			config_file = nil;
		end
		PayServer:Start(config_file);
	end
end
NPL.this(activate);