--[[
Author: LiXizhi
Date: 2009-7-20
Desc: Edit this file to expose new REST API for the game server
config/WebAPI.config.xml will merge settings with this file. 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/DBServer_API.lua");
-----------------------------------------------
]]
if(not DBServer) then  DBServer = {} end

-- a list of API. If an API allows anonymous access, specify allow_anonymous = true
-- To handle API using a custom function, provide handler_func like in the "ping". 
-- filename is the script to process the message, see AuthUser for example. 
DBServer.API = {
["AuthUser"] = {filename = "DBServer.dll/DBServer.API.Auth.AuthUser.cs",allow_anonymous = true,},
["ping"] = {
	allow_anonymous = true,
	handler_func = function(msg)
		log("ping received\n")
		commonlib.echo(msg)
	end,
},
["RequireLogin"] = {filename = "any_script_file_here"},

-- TODO: add your new API here
--
--["CheckUName"] = {filename = "DBServer.dll/DBServer.API.Auth.CheckUName.cs",allow_anonymous = true,},
--
--["Logout"] = {filename = "DBServer.dll/DBServer.API.Auth.Logout.cs",},
--
--["VerifySession"] = {filename = "DBServer.dll/DBServer.API.Auth.VerifySession.cs",},
--
--["PublishActionToUser"] = {filename = "DBServer.dll/DBServer.API.ActionFeed.PublishActionToUser.cs",},
--
--["PublishItemToUser"] = {filename = "DBServer.dll/DBServer.API.ActionFeed.PublishItemToUser.cs",},
--
--["PublishMessageToUser"] = {filename = "DBServer.dll/DBServer.API.ActionFeed.PublishMessageToUser.cs",},
--
--["PublishRequestToUser"] = {filename = "DBServer.dll/DBServer.API.ActionFeed.PublishRequestToUser.cs",},
--
--["PublishStoryToUser"] = {filename = "DBServer.dll/DBServer.API.ActionFeed.PublishStoryToUser.cs",},
--
--["Friends.Add"] = {filename = "DBServer.dll/DBServer.API.Friends.Add.cs",},
--
--["Friends.Get"] = {filename = "DBServer.dll/DBServer.API.Friends.Get.cs",},
--
--["Friends.Remove"] = {filename = "DBServer.dll/DBServer.API.Friends.Remove.cs",},
--
--["Gift.Accept"] = {filename = "DBServer.dll/DBServer.API.Gift.AcceptGift.cs",},
--
--["Gift.Chuck"] = {filename = "DBServer.dll/DBServer.API.Gift.ChuckGift.cs",},
--
--["Gift.Donate"] = {filename = "DBServer.dll/DBServer.API.Gift.Donate.cs",},
--
--["Gift.Get"] = {filename = "DBServer.dll/DBServer.API.Gift.Get.cs",},
--
--["Gift.GetGifts"] = {filename = "DBServer.dll/DBServer.API.Gift.GetGifts.cs",},
--
--["Gift.GetHortation"] = {filename = "DBServer.dll/DBServer.API.Gift.GetHortation.cs",},
--
--["Gift.TakeHortation"] = {filename = "DBServer.dll/DBServer.API.Gift.TakeHortation.cs",},
--
--["Home.Get"] = {filename = "DBServer.dll/DBServer.API.Home.Get.cs",},
--
--["Home.SendFlower"] = {filename = "DBServer.dll/DBServer.API.Home.SendFlower.cs",},
--
--["Home.SendPug"] = {filename = "DBServer.dll/DBServer.API.Home.SendPug.cs",},
--
--["Home.Update"] = {filename = "DBServer.dll/DBServer.API.Home.Update.cs",},
--
--["Home.Visit"] = {filename = "DBServer.dll/DBServer.API.Home.Visit.cs",},
--
--["House.Depurate"] = {filename = "DBServer.dll/DBServer.API.House.Depurate.cs",},
--
--["House.Get"] = {filename = "DBServer.dll/DBServer.API.House.Get.cs",},
--
--["House.Grow"] = {filename = "DBServer.dll/DBServer.API.House.Grow.cs",},
--
--["Items.DestroyItem"] = {filename = "DBServer.dll/DBServer.API.Items.DestroyItem.cs",},
--
--["Items.EquipItem"] = {filename = "DBServer.dll/DBServer.API.Items.EquipItem.cs",},
--
--["Items.GetEquips"] = {filename = "DBServer.dll/DBServer.API.Items.GetEquips.cs",},
--
--["Items.GetItemsInBag"] = {filename = "DBServer.dll/DBServer.API.Items.GetItemsInBag.cs",},
--
--["Items.GetMyBags"] = {filename = "DBServer.dll/DBServer.API.Items.GetMyBags.cs",},
--
--["Items.MoveItems"] = {filename = "DBServer.dll/DBServer.API.Items.MoveItems.cs",},
--
--["Items.PurchaseItem"] = {filename = "DBServer.dll/DBServer.API.Items.PurchaseItem.cs",},
--
--["Items.read"] = {filename = "DBServer.dll/DBServer.API.Items.read.cs",},
--
--["Items.SetClientData"] = {filename = "DBServer.dll/DBServer.API.Items.SetClientData.cs",},
--
--["Items.UnEquipItem"] = {filename = "DBServer.dll/DBServer.API.Items.UnEquipItem.cs",},
--
--["Pet.Caress"] = {filename = "DBServer.dll/DBServer.API.Pet.Caress.cs",},
--
--["Pet.Get"] = {filename = "DBServer.dll/DBServer.API.Pet.Get.cs",},
--
--["Pet.GoGoGo"] = {filename = "DBServer.dll/DBServer.API.Pet.GoGoGo.cs",},
--
--["Pet.Update"] = {filename = "DBServer.dll/DBServer.API.Pet.Update.cs",},
--
--["Pet.UseItem"] = {filename = "DBServer.dll/DBServer.API.Pet.UseItem.cs",},
--
--["Plant.Debug"] = {filename = "DBServer.dll/DBServer.API.Plant.Debug.cs",},
--
--["Plant.GainFeeds"] = {filename = "DBServer.dll/DBServer.API.Plant.GainFeeds.cs",},
--
--["Plant.GetByIDs"] = {filename = "DBServer.dll/DBServer.API.Plant.GetByIDs.cs",},
--
--["Plant.GoGoGo"] = {filename = "DBServer.dll/DBServer.API.Plant.GoGoGo.cs",},
--
--["Plant.Grow"] = {filename = "DBServer.dll/DBServer.API.Plant.Grow.cs",},
--
--["Plant.Remove"] = {filename = "DBServer.dll/DBServer.API.Plant.Remove.cs",},
--
--["Plant.Water"] = {filename = "DBServer.dll/DBServer.API.Plant.Water.cs",},
--
--["Plant.GetMCML"] = {filename = "DBServer.dll/DBServer.API.Profile.GetMCML.cs",},
--
--["Plant.SetMCML"] = {filename = "DBServer.dll/DBServer.API.Profile.SetMCML.cs",},
--
--["Users.GetInfo"] = {filename = "DBServer.dll/DBServer.API.Users.GetInfo.cs",},
--
--["Users.Registration"] = {filename = "DBServer.dll/DBServer.API.Users.Registration.cs",},
--
--["Users.SetInfo"] = {filename = "DBServer.dll/DBServer.API.Users.SetInfo.cs",},
};

