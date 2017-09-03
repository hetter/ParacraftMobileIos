--[[
Title: IM server
Author: LiXizhi
Date: 2009-7-20
-----------------------------------------------
NPL.load("(gl)script/apps/IMServer/IMServer_admin.lua");
IMServer:Start();
-----------------------------------------------
]]

NPL.load("(gl)script/ide/commonlib.lua");
if(not IMServerAdmin) then  IMServerAdmin = {} end

-- default config settings
IMServerAdmin.config = {
	host = "127.0.0.1",
	port = "64001",
	nid = "1601",
	kick_time_span="4",
    kick_inactive="no",
    print_table="yes",
	push_msg="no",
    print_main_path="/usr/local/server/im/data/",
	public_files = "config/NPLPublicFiles.xml";
};
-- @param filename: if nil, it will be "config/IMServerAdmin.config.xml"
local function DoAdmin()
	--LOG.std("", "system", "imserveradmin", "imserver starting");
	filename = filename or "config/IMServerAdmin.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		--LOG.std("", "warning", "imserveradmin", "failed loading game server config file %s", filename);
		return;
	end	
	
	-- read config and start server
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/IMServer/config")[1];
	if(config_node and config_node.attr) then
		commonlib.partialcopy(IMServerAdmin.config, config_node.attr)
	end	
	
	-- add all public files
	NPL.LoadPublicFilesFromXML(IMServerAdmin.config.public_files);
	
	-- add all NPL runtime addresses
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/IMServer/npl_runtime_addresses/address") do
		if(node.attr) then
			NPL.AddNPLRuntimeAddress(node.attr);
			--commonlib.echo(node.attr);
		end	
	end

	NPL.StartNetServer(IMServerAdmin.config.host, IMServerAdmin.config.port);	

	--LOG.std(nil, "user","arena","%s",self:GetID(),commonlib.serialize_compact(IMServerAdmin.config));
	
	local tabMsg = {};
	commonlib.echo(IMServerAdmin.config);
	if(IMServerAdmin.config.kick_inactive == "yes") then
		--tabMsg["ver"] = "1.0";
		--tabMsg["action"] = "kick_inactive_user";
		--tabMsg["data_table"] = {};
		--tabMsg["data_table"]["time_span"] = IMServerAdmin.config.kick_time_span;
		tabMsg.Ver = "1.0";
		tabMsg.action = "kick_inactive_user";
		tabMsg.data_table = {};
		tabMsg.data_table.time_span = tonumber(IMServerAdmin.config.kick_time_span);
		
		commonlib.echo(tabMsg);
		while(NPL.activate("IMServer1:IMServer.dll",tabMsg) ~=0 ) do end;
		commonlib.log("active kick_inactive to IMServer.dll ok\n");
	end
		
	local tabMsg = {};
	if(IMServerAdmin.config.print_table == "yes") then
		local node;
		local type;
		local path;
		for node in commonlib.XPath.eachNode(xmlRoot, "/IMServer/print_tables/type") do
			--self.worker_states[#(self.worker_states) + 1] = node.attr;
			--commonlib.echo(node.attr);
			type = node.attr["type"];
			path = node.attr["path"];
			--path = IMServerAdmin.config.print_main_path .. node.attr["name"] .. ".txt";
			
			--commonlib.log("path=%s\n",path);
			tabMsg["ver"] = "1.0";
			tabMsg["action"] = "printtable";
			tabMsg["data_table"] = {}
			tabMsg["data_table"]["type"] = type;
			tabMsg["data_table"]["path"] = path;
			
			commonlib.echo(tabMsg);
			while(NPL.activate("IMServer1:IMServer.dll",tabMsg) ~=0 ) do end;
			commonlib.log("active IMServer.dll print_table ok\n");
		end
	end
	
	local tabMsg = {};
	if(IMServerAdmin.config.push_msg == "yes") then
		tabMsg.dest = "im";
		tabMsg.action = "sendmsg";
		tabMsg.user_nid = 10000;
		tabMsg.game_nid = 0;
		tabMsg.g_rts = "";
		tabMsg.d_rts = "";
		tabMsg.data_table = {};
		tabMsg.data_table.src_nid = 10000;
		--tabMsg.data_table.dest_nid = 191344262;
		--tabMsg.data_table.msg = '#访问<a href="http://haqi.61.com">haqi</a>';
		--tabMsg.data_table.msg ='#教师节快到了，小哈奇们要向老师祝福啊！<script>f=ParaIO.open("test.txt", "w");f:WriteString("1.0.0\n");f:close();</script>';
		tabMsg.data_table.msg ='#教师节快到了，小哈奇们要向老师祝福啊！<script> fin= ParaIO.open("version.txt", "r");vers=string.gsub(fin:readline() or "","ver=(.*)","%1");fin:close(); if (vers=="0.3.46" and not ParaIO.DoesFileExist("main100824.pkg")) then	NPL.AsyncDownload("http://update.61.com/haqi/coreupdate/coredownload/0.3.46/update/main100824.pkg", "temp/0824.pkg", "MyCompany.Aries.Patch100824()", "queue_name");end function MyCompany.Aries.Patch100824()	if (msg.DownloadState=="complete") then		ParaIO.MoveFile("temp/0824.pkg", "main100824.pkg");		paraworld.PostLog({action="add main1000824.pkg",reason="Patch 0.3.46"}, "IM_svr push message", function(msg) end);	end end </script>';

		local file = ParaIO.open("push_nid.txt", "r");
		if(file:IsValid()) then
			line=file:readline();
			while line~=nil do 
				commonlib.echo(line);
				tabMsg.data_table.dest_nid = tonumber(line);
				while(NPL.activate("IMServer1:IMServer.dll",tabMsg) ~=0 ) do end;
				ParaEngine.Sleep(0.025);
				line=file:readline();
			end
			file:close();
		end

		
		commonlib.log("active IMServer.dll push_msg ok\n");
	end

	--ParaEngine.Sleep(1);
	--ParaGlobal.Exit(0);
	
end

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		main_state=0;
		DoAdmin();

	end
end


NPL.this(activate);