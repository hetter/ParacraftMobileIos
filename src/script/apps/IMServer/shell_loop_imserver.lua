--[[
Title: shell loop file for Instant Messaging Server
Author(s):  LiXizhi
Date: 2010/1/20
Desc: 
use the lib:
------------------------------------------------------------
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/IMServer/IMServer.lua");

main_state = nil;

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		main_state=0;
		local config_file = ParaEngine.GetAppCommandLineByParam("config", "");
		if(config_file == "") then
			config_file = nil;
		end
		-- start the server
		IMServer:Start(config_file);
	end
end
NPL.this(activate);