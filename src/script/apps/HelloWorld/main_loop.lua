--[[
Title: Main game loop
Author(s): LiXizhi
Date: 2008/10/28
Desc: Entry point and game loop
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/HelloWorld/main_loop.lua");
set the bootstrapper to point to this file, see config/bootstrapper.xml
Or run application with command line: bootstrapper="script/apps/HelloWorld/bootstrapper.xml"
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/IDE.lua");

-- when ParaEngine starts, call following function only once to load all packages/startup/*.zip
-- Remove this line, if do not need to load any packages.
commonlib.package.Startup();

-- this script is activated every 0.5 sec. it uses a finite state machine (main_state). 
-- State nil is the inital game state. state 0 is idle.
local function activate()
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		main_state = 0;
		-- initialization 
		ParaUI.SetCursorFromFile(":IDR_DEFAULT_CURSOR");
		
		local _this=ParaUI.CreateUIObject("text","MyText", "_lt",400,200,200,20);
		_this:AttachToRoot();
		_this.text="Hello World!";
	end	
end
NPL.this(activate);