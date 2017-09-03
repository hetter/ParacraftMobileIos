--[[
Title: game objects list
Author(s): WangTian
Date: 2009/7/20
Desc: all NPCs avaiable and game objects
revised by LiXizhi 2010/8/18: game objects now belongs to a given world. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/Test/GameObjectList.obsoleted.lua");
-- MyCompany.Aries.Quest.GameObjectList.LoadGameObjectsInWorld("worlds/MyWorlds/61HaqiTown")
-- MyCompany.Aries.Quest.GameObjectList.GameObjects will contain the loaded npc list
MyCompany.Aries.Quest.GameObjectList.DumpInstances("61HaqiTown");
------------------------------------------------------------
]]
-- create class
local GameObjectList = commonlib.gettable("MyCompany.Aries.Quest.GameObjectList");

-- mapping from world name to NPC table list. 
local worlds_map = {};

worlds_map["61HaqiTown"] = {
	-- 靓靓屋
	[40011] = { 
		name = "时装购买杂志",
		position = { 20154.94921875, 10005.8046875, 19738.19921875 },
		rotation={y=-0.65077471733093,x=-0.21767964959145,w=0.69855862855911,z=-0.20278960466385,},
		facing = 0,
		scaling = 2,
		scaling_char = 0.8,
		scale_model = 3.1070475578308,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/FashionMagazine/FashionMagazine.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/FashionMagazine/FashionMagazine_v7.html",
	}, -- 时装购买杂志（靓靓屋）
	---- 杂货铺
	--[40021] = { 
		--name = "货架（杂货铺）",
		--position = { 19940.6875, 1.4999983310699, 19871.4921875 },
		--facing = 0.085084803402424,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_model = "model/06props/v5/03quest/GroceryShelf/GroceryShelf.x",
		--gameobj_type = "MCMLPage",
		--page_url = "script/apps/Aries/Inventory/SampleShopView.html?tab=throwable",
	--}, -- 货架（杂货铺）
	-- 爱家小铺
	[40031] = { 
		name = "家园物品购买杂志 - 室外",
		position = { 20107.787109375, 10005.623046875, 19697.380859375 },
		rotation={y=-0.11507891118526,x=-0.29533404111862,w=0.94775980710983,z=-0.035860028117895,},
		facing = 0,
		scaling = 2.5,
		scaling_char = 0.7,
		scale_model = 3.1070466041565,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/HomeDecoMagazine/HomeDecoMagazine.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/HomeDecoMagazine.html",
	}, -- 家园物品购买杂志（爱家小铺）
	[40032] = { 
		name = "家园物品购买杂志 - 室内",
		position = { 20108.599609375, 10005.653320313, 19698.634765625 },
		rotation={y=-0.68487495183945,x=-0.20727242529392,w=0.66516029834747,z=-0.21341563761234,},
		facing = 0,
		scaling = 2.5,
		scaling_char = 0.7,
		scale_model = 3.0759754180908,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/FitmentChoiceness/FitmentChoiceness.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/HomeIndoorMagazine.html",
	}, -- 家园物品购买杂志（爱家小铺）
	-- 抱抱龙商店
	[40041] = { 
		name = "抱抱龙物品购买杂志",
		--position = { 19970.908203125, 1.5164450407028, 19896.09765625 },
		--facing = -0.34610423445702,
		position = { 19977.447265625, 10002.499023438, 19895.8828125 },
		facing = -0.836571320146322,
		scaling = 2.0,
		scaling_char = 0.8,
		scaling_model = 2.0,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/DragonFoodMenu/DragonFoodMenu.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/DragonItemMagazine.html",
	}, -- 抱抱龙物品购买杂志（抱抱龙商店）
	[40042] = { 
		name = "抱抱龙食谱",
		position = { 19975.58984375, 10002.675664063, 19881.19140625 },
		facing = 2.336571320146322,
		scaling = 2.0,
		scaling_char = 0.8,
		scaling_model = 1.6406940460205,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/DragonFoodMenu/DragonFoodMenu2.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/DragonFoodMenu.html",
		
	}, -- 抱抱龙食谱（抱抱龙商店）
	--[40043] = { 
		--name = "抱抱龙百科全书",
		--position = { 20154.439453125, 1.4992876052856, 19855.400390625 },
		--facing = 0.50743579864502,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_model = "model/06props/v5/03quest/DragonEncyclopedia/DragonEncyclopedia.x",
		--gameobj_type = "MCMLPage",
		--page_url = "script/apps/Aries/Inventory/SampleShopView.html?tab=pet",
	--}, -- 抱抱龙百科全书（抱抱龙商店）
	-- 龙龙乐园
	[40051] = { 
		name = "医生手册",
		position = { 19976.224609375, 2.1026840209961, 19847.119140625 },
		facing = 0,
		rotation={y=0.95451432466507,x=0.0061865737661719,w=-0.019853364676237,z=0.29743894934654,},
		scaling = 2.593742609024,
		scaling_char = 0.8,
		scale_model = 2.593742609024,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/DoctorHandBook/DoctorHandbook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/DoctorHandbook.html",
	}, -- 医生手册（龙龙乐园）
	---- 农场
	--[40061] = { 
		--name = "种子购买杂志",
		--position = { 19815.037109375, 0.0016528439009562, 19911.9609375 },
		--facing = 0.67910236120224,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_model = "model/06props/v5/03quest/SeedMagazine/SeedMagazine.x",
		--gameobj_type = "MCMLPage",
		--page_url = "script/apps/Aries/Inventory/SampleShopView.html?tab=homeland",
	--}, -- 种子购买杂志（农场）
	-- 哈奇历史手册
	[40062] = { 
		name = "哈奇历史手册",
		position = { 20004.23, 8.62, 19551.03 },
		facing = -2.3724806308746,
		scaling = 2,
		scaling_char = 1,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/TownHistoryBook/TownHistoryBook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/TownHistoryBook.html",
	}, -- 哈奇历史手册（农场）
	-- 警察手册
	[40071] = { 
		name = "警察手册",
		position = { 20039.544921875, 10003.171875, 19866.830078125 },
		facing = -2.3724806308746,
		scaling = 2,
		scaling_char = 1,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/03tools/v5/01book/PoliceHandBook/PoliceHandBook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/PoliceHandBook.html",
	}, -- 警察手册
	
	-- 马场
	[40081] = { 
		name = "马场",
		position = { 20137.189453125, 1.8381499052048, 19916.6328125 },
		facing = -2.3724806308746,
		scaling = 2,
		scaling_char = 2,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		--assetfile_model = "model/03tools/v5/01book/PoliceHandBook/PoliceHandBook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/AquaHorse_Panel.html",
	}, -- 马场
	
	-- 蘑菇噜
	[40082] = { 
		name = "蘑菇噜",
		position = { 19920.0859375, 2.1352309465408, 20004.1015625 },
		facing = -2.3724806308746,
		scaling = 2,
		scaling_char = 2,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		--assetfile_model = "model/03tools/v5/01book/PoliceHandBook/PoliceHandBook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/LuluMushroom_Panel.html",
	}, -- 蘑菇噜
	
	-- 公告栏
	[40083] = { 
		name = "公告栏",
		position = { 20064.044921875, 4.500009536743, 19763.615234375 },
		facing = -2.3724806308746,
		scaling = 2,
		scaling_char = 1.5,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		--assetfile_model = "model/03tools/v5/01book/PoliceHandBook/PoliceHandBook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/Welcome_Panel.html",
		
	}, -- 公告栏
	
	-- 跳蚤鸡
	[40084] = { 
		name = "跳蚤鸡",
		position = { 19836.591796875, 2.2079529285431, 19888.515625 },
		facing = -1.2462887763977,
		scaling = 2,
		scaling_char = 2,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		--assetfile_model = "model/03tools/v5/01book/PoliceHandBook/PoliceHandBook.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/FleaChick_Panel.html",
	}, -- 跳蚤鸡
	
	-- 堆雪人
	[40085] = { 
		name = "堆雪人",
		position = { 19793.84765625, 24.728244781494, 20179.765625 },
		facing = 0,
		scaling = 0.8,
		scaling_char = 1.2,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/02street/WoodenEntrancePanel/WoodenEntrancePanel_SnowGame.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/Snowman_Panel.html",
	}, -- 堆雪人
	
	-- 堆雪人
	[40086] = { 
		name = "日光调节器纸条",
		position = { 20240.005859375, 1.4112162828445, 19650.30859375 },
		facing = -3.1168651580811,
		scaling = 2,
		scaling_char = 1,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		--assetfile_model = "model/01building/v5/01house/SunshineStation/Tips_Latter.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/NPCs/SunnyBeach/SkinBaker_DoctorNote.html",
	}, -- 堆雪人
	
	---------------- NOTE 2010/2/24: remove the snowball fighting related NPCs ----------------
	--[40088] = { 
		--copies = 2,
		--positions = {{ 20149.71875, 2.0837740421295, 19794.162109375 },
					--{ 20151.40625, 1.5719648599625, 19791.30078125 },
					--},
		--facings = {-0.47860702872276, 
					---0.40190896391869, 
					--},
		--scalings = {2, 
					--3, 
					--},
		--name = "雪球大赛海报",
		--position = { 20149.71875, 2.0837740421295, 19794.162109375 },
		--facing = -0.47860702872276,
		--scaling = 2,
		--scaling_char = 1,
		--scaling_model = 1,
		--isalwaysshowheadontext = false,
		--assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		----assetfile_model = "model/02furniture/v5/PoliceStationDeco/16NoticeBoard/NoticeBoard.x",
		--gameobj_type = "MCMLPage",
		--page_url = "script/apps/Aries/Books/Panels/SnowFightingPoster_Panel.html",
	--}, -- 雪球大赛海报
	---------------- NOTE 2010/2/24: remove the snowball fighting related NPCs ----------------
	
	[40089] = { 
		name = "课程表木板",
		position = { 20114.076171875, 1.3282980918884, 19843.513671875 },
		facing = 2.7437255382538,
		scaling = 1.5,
		scaling_char = 1.5,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		--assetfile_model = "model/01building/v5/01house/SunshineStation/Tips_Latter.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/NPCs/FriendshipPark/40089_DanceClassBoard.html",
	}, -- 课程表木板
	
	--[40090] = { 
		--name = "雪山警示牌",
		--position = { 19797.619140625, 77.246948242188, 20376.060546875 },
		--facing = 0.68093287944794,
		--scaling = 3,
		--scaling_char = 3,
		----scaling_model = 0.0001,
		--assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		----assetfile_model = "model/01building/v5/01house/SunshineStation/Tips_Latter.x",
		--gameobj_type = "MCMLPage",
		--page_url = "script/apps/Aries/Books/Panels/BlizzardWarning_Panel.html",
	--}, --  雪山警示牌
	[40091] = { 
		name = "过山车指示牌",
		position = { 20429.505859375, 0.71735620498657, 19898.3203125 },
		facing = 0.56781262159348,
		scaling = 2,
		--scaling_char = 3,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		--assetfile_model = "model/02furniture/v5/PoliceStationDeco/16NoticeBoard/NoticeBoard.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/BigDipper_Panel.html",
	}, --  过山车指示牌
	[40092] = { 
		name = "摩天轮指示牌",
		position = { 20384.212890625, 0.9462998509407, 19832.138671875 },
		facing = -1.6283574104309,
		scaling = 2,
		--scaling_char = 3,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		--assetfile_model = "model/02furniture/v5/PoliceStationDeco/16NoticeBoard/NoticeBoard.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/SkyWheel_Panel.html",
	}, --  摩天轮指示牌
	[40093] = { 
		name = "时空门 家园探险家大比拼木牌",
		position = { 20432.484375, -3.9816839694977, 19603.33203125 },
		facing = 0,
		scaling = 2,
		--scaling_char = 3,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		--assetfile_model = "model/02furniture/v5/PoliceStationDeco/16NoticeBoard/NoticeBoard.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/TimePortal_Panel.html",
	}, --  家园探险家大比拼木牌
	[40094] = { 
		name = "天气百叶箱",
		position = { 20023.669921875, 0.63824201822281, 19742.5078125 },
		facing = 1.6104999780655 + 3.14,
		scaling = 3,
		scaling_char = 3,
		scaling_model = 3,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/Blinds/Blinds.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/NPCs/TownSquare/30354_WeatherForcastBox_panel.html",
	}, --  天气百叶箱
	
	[40095] = { 
		name = "生肖花指示牌",
		position = { 19605.49609375, 7.4745769500732, 20182.43359375 },
		facing = 0,
		rotation={ w=0.62161016464233, x=0, y=-0.78332674503326, z=0 },
		scaling = 3,
		scaling_char = 2,
		scaling_model = 1,
		--scaling_model = 0.0001,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/02street/WoodenEntrancePanel/WoodenEntrancePanel_ZodiacAnimalFlower.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/ZodiacAnimalFlower_Panel.html",
	}, --  生肖花指示牌
	
	---- 休闲装
	--[40171] = { 
		--name = "白色红条短T恤",
		--position = { 19811.037109375, 0.0016528439009562, 19911.9609375 },
		--facing = 0.67910236120224,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_model = "model/common/ccs_unisex/shirt03.x",
		--gameobj_type = "GSItem",
		--gsid = 1005,
		--replaceabletextures_model = {
			--[1] = "character/v3/Item/TextureComponents/AriesCharShirtTexture/1005_WhiteRedStripTShirt_03_CS.dds",
			--[2] = "character/v3/Item/TextureComponents/AriesCharShirtTexture/1005_WhiteRedStripTShirt_03_CS.dds",
		--},
	--}, -- 白色红条短T恤
	---- 休闲装
	--[40172] = { 
		--name = "迷彩小短裤",
		--position = { 19809.037109375, 0.0016528439009562, 19911.9609375 },
		--facing = 0.67910236120224,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_model = "model/common/ccs_unisex/pants03.x",
		--gameobj_type = "GSItem",
		--gsid = 1006,
		--replaceabletextures_model = {
			--[1] = "character/v3/Item/TextureComponents/AriesCharPantTexture/1006_RedCamouflageShort_03_CP.dds",
			--[2] = "character/v3/Item/TextureComponents/AriesCharPantTexture/1006_RedCamouflageShort_03_CP.dds",
		--},
	--}, -- 白色红条短T恤
	---- 休闲装
	--[40173] = { 
		--name = "红色帆布鞋",
		--position = { 19807.037109375, 0.0016528439009562, 19911.9609375 },
		--facing = 0.67910236120224,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_model = "model/common/ccs_unisex/boots03.x",
		--gameobj_type = "GSItem",
		--gsid = 1007,
		--replaceabletextures_model = {
			--[1] = "character/v3/Item/TextureComponents/AriesCharFootTexture/1007_RedCanvasShoes_03_CF.dds",
			--[2] = "character/v3/Item/TextureComponents/AriesCharFootTexture/1007_RedCanvasShoes_03_CF.dds",
		--},
	--}, -- 白色红条短T恤
	[40121] = { 
		name = "喇叭花",
		position = { 20014.6953125, -0.64528197050095, 20040.50390625 },
		facing = 0.68796330690384,
		scaling = 4,
		scaling_char = 1,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/MorningGlory/MorningGlory.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		isshownifown = false,
		gsid = 21005,
		pick_count = 1,
		dialogstyle_antiindulgence = true,
		onpick_msg = "喇叭花已经放入你的背包里，快把它拿在手上你去盛生命泉水吧。",
	}, -- 喇叭花（生命之泉）
	
	[40122] = { 
		name = "气球串",
		position = { 20244.16015625, 10001.623046875, 19716.423828125 },
		facing = 0,
		scaling = 4,
		scaling_char = 1.5,
		scaling_model = 2.5937430858612,
		--assetfile_char = "character/common/headarrow/headarrow.x",
		assetfile_char = "character/common/dummy/double_elf_size/double_elf_size.x",
		assetfile_model = "model/06props/v5/03quest/MorningGlory/item_1H_Balloon.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		isshownifown = false,
		gsid = 17041,
		pick_count = 1,
		dialogstyle_antiindulgence = true,
		onpick_msg = "我是能飞的气球串，别看我轻飘飘，没准什么时候就能派上大用场，快把我捡走吧。",
	}, -- 气球串（图书馆）
	

	[40131] = { 
		name = "樱桃种子",
		position = { 20147.2034375, 5.5471259307861, 19695.1803125 },
		facing = 0,
		scaling = 2,
		scaling_char = 0.8,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/05plants/v5/08homelandPlant/CherryTree/CherryTreeSeed.x",
		gameobj_type = "GSItem",
		gsid = 30008,
	}, -- 樱桃种子
	[40132] = { 
		name = "竹子种子",
		position = { 20147.1734375, 5.5471259307861, 19696.253203125 },
		facing = 0,
		scaling = 2,
		scaling_char = 0.8,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/05plants/v5/08homelandPlant/Bamboo/BambooSeed.x",
		gameobj_type = "GSItem",
		gsid = 30010,
	}, -- 竹子种子
	[40133] = { 
		name = "紫藤萝种子",
		position = { 20147.2034375, 4.3471259307861, 19695.1603125 },
		facing = 0,
		scaling = 2,
		scaling_char = 0.8,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeSeed.x",
		gameobj_type = "GSItem",
		gsid = 30011,
	}, -- 紫藤萝种子
	[40134] = { 
		name = "菠萝种子",
		position = { 20147.1334375, 4.3471259307861, 19696.253203125 },
		facing = 0,
		scaling = 2,
		scaling_char = 0.8,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeSeed.x",
		gameobj_type = "GSItem",
		gsid = 30009,
	}, -- 菠萝种子
	[40141] = { 
		name = "炮竹",
		position = { 20153.5703125, 3.5, 19688.551953125 },
		facing = 0,
		scaling = 2,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		gameobj_type = "GSItem",
		gsid = 9503,
	}, -- 炮竹
	--[40142] = { 
		--name = "炮竹",
		--position = { 20126.421875, 3.5, 19694.666015625 },
		--facing = 1,
		--scaling = 2,
		--isalwaysshowheadontext = false,
		--assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		--gameobj_type = "GSItem",
		--gsid = 9503,
	--}, -- 炮竹2
	
	[40151] = { 
		name = "钉子",
		position = { 20158.765625, 3.5, 19688.65078125 },
		facing = 0,
		scaling = 2,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		gameobj_type = "GSItem",
		gsid = 17013,
	}, -- 钉子
	
	[40161] = { 
		name = "绳子",
		position = { 19996.736328125, 0.17351299524307, 19565.693359375 },
		facing = 4,
		scaling = 0.7,
		scaling_model = 3,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/05other/BrownRope/BrownRope.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17014,
	}, -- 绳子
	
	[40162] = { 
		name = "彩云结晶",
		position = { 19950.529296875, 0.54080402851105, 19900.376953125 },
		facing = 4.470348238945,
		scaling = 1.0,
		scaling_model = 1.2,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/ColourfulCrystal/ColourfulCrystal.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17015,
	}, -- 彩云结晶
	
	[40163] = { 
		name = "粘粘果",
		position = { 19838.23828125, 8.5886144638062, 20059.009765625 },
		facing = 4,
		scaling = 2,
		scaling_model = 3,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/05plants/v5/02grass/PasteGrass/PasteGrass.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17030,
	}, -- 粘粘果
	
	-- [40164] -- reserved for candybag
	
	[40165] = { 
		copies = 10,
		positions = {{ 19817.158203, 6.433462, 20002.181641, },
					{ 19801.255859, 6.423761, 19997.419922, },
					{ 19792.373047, 6.424254, 20004.001953, },
					{ 19778.642578, 6.460493, 20005.228516, },
					{ 19785.849609, 8.496851, 20018.402344, },
					{ 19802.789063, 8.755289, 20028.580078, },
					{ 19821.119141, 8.868071, 20054.007813, },
					{ 19807.960938, 8.840009, 20022.322266, },
					{ 19813.894531, 8.840683, 20037.750000, },
					{ 19790.265625, 8.734091, 20041.011719, },
					},
		facings = {-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					},
		name = "石头",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 2,
		scaling_model = 0.5,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/01stone/IceDarkBlueRock/IceDarkBlueRock.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17039,
	}, -- 石头

	-- [40166] -- reserved for plum seed
	
	[40167] = { 
		copies = 6,
		positions = {{ 19634.728515625, 7.0959038734436, 19968.814453125 },
					{ 19637.77734375, 7.0817108154297, 20009.8125 },
					{ 19615.056640625, 6.8115620613098, 20016.447265625 },
					{ 19623.4140625, 7.3738098144531, 20042.1796875 },
					{ 19587.47265625, 10.556800842285, 20047.08203125 },
					{ 19570.955078125, 14.055492401123, 20076.435546875 },
					},
		facings = {-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					},
		name = "小青草",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 1,
		scaling_model = 0.8,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/05plants/v5/02grass/LimeGreenLowGrass1/LimeGreenLowGrass_collect.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		respawn_interval = 300000,
		gsid = 17065, -- 17065_LittleGreenGrass
	}, -- 小青草
	
	[40168] = { 
		copies = 6,
		positions = {{ 19950.1796875, 8.897876739502, 20098.67578125},
					{ 19961.69921875, 8.702898979187, 20101.875 },
					{ 19954.685546875, 8.8557729721069, 20092.115234375 },
					{ 19929.265625, 8.8809967041016, 20109.34765625 },
					{ 19939.158203125, 8.8788118362427, 20121.71484375 },
					{ 19948.80859375, 8.855658531189, 20126.453125 },
					},
		facings = {-0.47860702872276, 
					-0.57439896391869, 
					-0.281060702872276, 
					-0.40190896391869, 
					-0.9430702872276, 
					-0.13890896391869, 
					},
		name = "铁皮",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 1,
		scaling_model = 0.5,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/SheetIron/SheetIron.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		respawn_interval = 300000,
		gsid = 17066, -- 17066_IronHide
	}, -- 铁皮
	
	[40169] = { 
		copies = 6,
		positions = {{ 19650.9375, 7.0800981521606, 20065.884765625 },
					{ 19677.359375, 6.4840888977051, 20090.134765625 },
					{ 19688.79296875, 5.9769940376282, 20067.06640625 },
					{ 19700.859375, 7.2344489097595, 20110.296875 },
					{ 19717.09375, 6.9317259788513, 20085.884765625 },
					{ 19716.37890625, 7.3040618896484, 20057.103515625},
					},
		facings = {-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					},
		name = "木块",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 1,
		scaling_model = 1.0,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/Wood/Wood.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		respawn_interval = 300000,
		gsid = 17067, -- 17067_WoodBlock
	}, -- 木块
	
	[40170] = { 
		name = "心形盒子",
		position = { 20090.255859375, 1.1122369766235, 19843.88671875  },
		facing = -0.59209656715393 + 1.57,
		scaling = 1,
		scaling_model = 1.3,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/GiftBox/StarGiftBox.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17068, -- 17068_HeartShapeBox
	}, -- 心形盒子
	
	[40171] = { 
		name = "缎带",
		position = { 20152.783203125, 10004.276367188, 19742.623046875  },
		facing = 0,
		scaling = 1,
		scaling_model = 1.2,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/Satin/Satin.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17069, -- 17069_SilkRibbon
	}, -- 缎带
	
	[40172] = { 
		name = "红纸盒",
		position = { 20256.544921875, 10003.16796875, 19711.439453125},
		facing = 2.2756774425507,
		scaling = 1,
		scaling_model = 1.2,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/GiftBox/PinkGiftBox.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17070, -- 17070_RedPaperBox
	}, -- 红纸盒
	
	[40173] = { 
		name = "弹簧",
		position = { 20101.19140625, 10004.157226563, 19695.435546875 },
		facing = 4,
		scaling = 1,
		scaling_model = 1.1,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/Spring/Spring.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17071, -- 17071_SteelSpring
	}, -- 弹簧
	
	[40174] = { 
		copies = 7,
		positions = {{ 19728.341796875, 7.6283369064331, 20084.7265625 },
					{ 19672.46484375, 6.9995398521423, 20112.75 },
					{ 19667.84765625, 6.4821939468384, 20069.09375 },
					{ 19656.978515625, 7.1760940551758, 20081.1328125 },
					{ 19644.09375, 7.4203472137451, 20068.0078125 },
					{ 19647.126953125, 7.4058470726013, 20089.759765625 },
					{ 19656.37890625, 7.0229721069336, 20104.568359375 },
					},
		facings = {-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					},
		name = "黏黏土",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 1,
		scaling_model = 1.5,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/Clay/Clay.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		respawn_interval = 300000,
		gsid = 17072, -- 17072_NianNianTu
	}, -- 黏黏土
	
	[40175] = { 
		copies = 6,
		positions = {{ 19680.021484375, 7.217227935791, 19984.107421875 },
					{ 19666.14453125, 6.8729510307312, 19963.37890625 },
					{ 19660.826171875, 8.2989845275879, 20005.33203125 },
					{ 19643.158203125, 7.0900630950928, 19991.9609375 },
					{ 19639.685546875, 7.0861511230469, 19965.072265625 },
					{ 19637.9296875, 6.941614151001, 20030.888671875 },
					},
		facings = {-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					},
		name = "灰石块",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 1,
		scaling_model = 0.5,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/01stone/EvngrayRock/EvngrayRock_collect.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		respawn_interval = 300000,
		gsid = 17073, -- 17073_GreyRock
	}, -- 灰石块
	
	[40176] = { 
		copies = 5,
		positions = {{ 19671.845703125, 8.4843034744263, 19999.673828125 },
					{ 19659.453125, 7.660315990448, 19978.564453125 },
					{ 19627.267578125, 7.1048669815063, 19974.396484375 },
					{ 19608.23828125, 7.080696105957, 20003.673828125 },
					{ 19631.7578125, 6.9637689590454, 20031.009765625 },
					},
		facings = {-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					-0.40190896391869, 
					-0.47860702872276, 
					},
		name = "雪堆",
		position = { 19840.9296875, 8.6923913955688, 20045.572265625 },
		facing = 4,
		scaling = 1,
		scaling_model = 0.5,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		assetfile_model = "model/06props/v5/03quest/SnowCaboodle/SnowCaboodle_collect.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 17074, -- 17074_SnowPile
	}, -- 雪堆
	
	--[40177] = { 
		--name = "智者火把",
		--position = { 20163.533203125, 0.20009227097034, 19813.416015625 },
		--facing = 0.68796330690384,
		--scaling = 1.5,
		--scaling_char = 1,
		----assetfile_char = "character/common/headarrow/headarrow.x",
		--assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
		--assetfile_model = "model/06props/v5/03quest/FireTorch/FireTorch.x",
		--gameobj_type = "FreeItem",
		--isdeleteafterpick = true,
		--isshownifown = false,
		--gsid = 1156, -- 1156_YuanXiaoTorch
		--pick_count = 1,
		--dialogstyle_antiindulgence = true,
		----onpick_msg = "喇叭花已经放入你的背包里，快把它拿在手上你去盛生命泉水吧。",
	--}, -- 智者火把
	[40178] = { 
		name = "西瓜田 提示牌",
		position = { 19766.61328125, 1, 19858.712890625 },
		facing = 0.5 + 1.6,
		scaling = 2,
		scaling_char = 2,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/Books/Panels/WatermelonField_Panel.html",
	}, -- 西瓜田 提示牌
	[40179] = { 
		name = "钓鱼 提示牌",
		position = { 20088.76953125, -4.7714042663574, 19573.50390625 },
		["rotation"]={ 
		["y"]=0.93203914165497, 
		["x"]=0, 
		["w"]=-0.36235749721527, 
		["z"]=0,
		} ,
		facing = 0,
		scaling_model = 1.2,
		scaling_char = 2,
		assetfile_model = "model/06props/v5/02street/WoodenEntrancePanel/WoodenEntrancePanel_Halieutics.x",
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/NPCs/TownSquare/30388_CatchFish_status.html",
	}, 
}; -- 61HaqiTown

GameObjectList.GameObjects = {}

-- dump all NPC instances in the current world to the default file. 
-- function only used at dev time. 
-- @param worldname: dump NPC in a given world (such as "FlamingPhoenixIsland"). If nil, the current is used. 
function GameObjectList.DumpInstances(worldname)
	NPL.load("(gl)script/ide/IPCBinding/Framework.lua");
	local EntityView = commonlib.gettable("IPCBinding.EntityView");
	local EntityHelperSerializer = commonlib.gettable("IPCBinding.EntityHelperSerializer");
	local EntityBase = commonlib.gettable("IPCBinding.EntityBase");

	local filename = "script/PETools/Aries/GameObject.entity.xml";
	local template = EntityView.LoadEntityTemplate(filename, false);
	if(template) then
		local objs
		if(worldname and worlds_map[worldname]) then
			if(worlds_map[worldname].filename) then
				objs = worlds_map[worldname].obj_list;
			else
				objs = worlds_map[worldname];
			end
		end
		objs = objs or GameObjectList.GetGameObjectList();
		local obj_id, obj
		for obj_id, obj in pairs(objs) do
			local obj_id = tonumber(obj_id)
			if(obj_id) then
				obj.obj_id = obj.obj_id or obj_id;
				-- forcing using existing uid
				obj.uid = obj.uid or ParaGlobal.GenerateUniqueID();
				local obj = EntityBase.IDECreateNewInstance(template, obj, nil);
				EntityHelperSerializer.SaveInstance(obj);
				LOG.std("", "debug", "GameObjectList", "dumping obj_id %s, uid %s", obj.obj_id, obj.uid);
			end
		end 
	end
end

-- load a NPC for a given world path. it will load the first npc lists whose name is contained in worldpath. 
-- @param worldpath: 
function GameObjectList.LoadGameObjectsInWorld(worldpath)
	local worldname, gameobjects_list
	for worldname, gameobjects_list in pairs(worlds_map) do
		if(worldpath:match(worldname)) then
			GameObjectList.GameObjects = gameobjects_list;
			return 
		end
	end
	GameObjectList.GameObjects = {}
end

function GameObjectList.GetGameObjectList()
	return GameObjectList.GameObjects;
end

function GameObjectList.GetGameObjectByID(gameobject_id)
	return GameObjectList.GameObjects[gameobject_id];
end
