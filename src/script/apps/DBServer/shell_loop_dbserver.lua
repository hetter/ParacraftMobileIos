--[[
Title: shell game loop file
Author(s):  LiXizhi
Date: 2009/7/15
Desc: 
use the lib:
------------------------------------------------------------
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"script/apps/DBServer/bootstrapper_dbserver.xml\""
- under linux shell script, it is 'bootstrapper="script/apps/DBServer/bootstrapper_dbserver.xml"'
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/DBServer.lua");

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
		DBServer:Start(config_file);
	end	
end
NPL.this(activate);