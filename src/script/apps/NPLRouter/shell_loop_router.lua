--[[
Title: Empty shell game loop file
Author(s):  LiXizhi
Date: 2009/5/3
Desc: this is mostly used to test modules by server. 
This loop file can be activated by bootstrapper file "config/bootstrapper_emptyshell.xml"
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/bootstrapper_emptyshell.xml\"". 
- under linux shell script, it is 'bootstrapper="config/bootstrapper_emptyshell.xml"'
use the lib:
------------------------------------------------------------
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/bootstrapper_emptyshell.xml\"". 
- under linux shell script, it is 'bootstrapper="config/bootstrapper_emptyshell.xml"'
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		main_state=0;
		log("Hello World from script/shell_loop_router.lua\n");
		
		--NPL.activate("NPLRouter.dll", {ver="1.0", my_nid=1000,count=3,data0={table_begin=0,table_end=287,db_nid=1001},data1={table_begin=288,table_end=575,db_nid=1001},data2={table_begin=576,table_end=863,db_nid=1001},});
		NPL.load("(gl)script/apps/NPLRouter/NPLRouter.lua");
		NPLRouter:Start();
		--router_start_server();

	end	
end
NPL.this(activate);