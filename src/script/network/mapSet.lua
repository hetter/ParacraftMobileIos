--
--*****this file is deprecated******
--
--
--
--NPL.load("(gl)script/ide/common_control.lua");
--local MapSet = {
	--name = "mapSet1",
	--maxLayerCount = 3,
	--fileInfo = {},
	--mapCache = {},
	--activeLayerIndex = 1,
	--rootMapPath = nil;
	--activeDimension = 1;
	--filefmt = "jpg";
	--
	--mapSize = {x = 0,y=0},
	--texSize = 512;
	--mapScale = 1;
	--maxMapCoord = { x = 2048,y = 2048},	
--}
--CommonCtrl.MapSet = MapSet;
--
--function MapSet:new (o)
	--o = o or {}   -- create object if user does not provide one
	--setmetatable(o, self)
	--self.__index = self
	--return o
--end
 --
--function MapSet:GetMapPath(x,y)
	--local index_x,index_y,filename;
	--index_x = math.floor(x / self.texSize) + 1;
	--index_y = math.floor(y / self.texSize) + 1;
	--if( index_x > self.activeDimension or index_y > self.activeDimension )then
		--return;
	--end
--
	--if(not self.fileInfo[self.activeLayerIndex])then 
		--self.fileInfo[self.activeLayerIndex] = {};
	--end
	--if(not self.fileInfo[self.activeLayerIndex][index_y])then
		--self.fileInfo[self.activeLayerIndex][index_y] = {};
	--end
	--if(not self.fileInfo[self.activeLayerIndex][index_y][index_x])then
		--self.fileInfo[self.activeLayerIndex][index_y][index_x] = {};
		--filename = self.rootMapPath.."/"..self.activeLayerIndex.."_"..index_y.."_"..index_x.."."..self.filefmt;
		--local i = 0;
		--local tempIndex_x = index_x;
		--local tempIndex_y = index_y;
		--local texRect = nil;
		--while(ParaIO.DoesFileExist(filename, true) == false)do
			--i = i + 1;		
			--tempIndex_y = math.floor((tempIndex_y + 1) / 2);
			--tempIndex_x = math.floor((tempIndex_x + 1) / 2);
			--filename = self.rootMapPath.."/"..self.activeLayerIndex-i.."_"..tempIndex_y.."_"..tempIndex_x.."."..self.filefmt;
		--end
		--
		--if( i > 0)then
			--local texOffset_x,texOffset_y,texWidth;
			--texWidth = self.texSize/math.pow(2,i);
			--texOffset_x = math.floor(  (x / math.pow(2,i) - self.texSize * (tempIndex_x-1)) / (self.texSize /  math.pow(2,i) ))*texWidth;
			--texOffset_y = math.floor(  (y / math.pow(2,i) - self.texSize * (tempIndex_y-1)) / (self.texSize /  math.pow(2,i) ))*texWidth;
			--texRect = string.format([[%s %s %s %s]],texOffset_x,texOffset_y,texWidth,texWidth);
		--end
				--
		--self.fileInfo[self.activeLayerIndex][index_y][index_x].texRect = texRect;
		--self.fileInfo[self.activeLayerIndex][index_y][index_x].path = filename;
		--
	--endD:\lxzsrc\paraengine\paraworld\script\test\TestHeadOnDisplay.lua
	--return self.fileInfo[self.activeLayerIndex][index_y][index_x];
--end
--
--function MapSet:GetMaps(x,y,width,height)
	--local _maps = {};
	--local i = 1;
	--for dy = -math.mod(y,self.texSize),height,self.texSize do 
		--local j = 1;
		--_maps[i] = {};
		--for dx = -math.mod(x,self.texSize),width,self.texSize do 	
			--_maps[i][j] = self:GetMapPath( x + self.texSize * (j-1), y + self.texSize * (i-1));
			--j = j + 1;
		--end
		--i = i + 1;
	--end
	--return _maps; 
--end
--
--function MapSet:GetLayerCount()
	--return self.maxLayerCount;
--end
--
--function MapSet:GetMaxCoord()
	--return self.maxMapCoord.x , self.maxMapCoord.y;
--end
--
--function MapSet:GetActiveLayerCount()
	--return self.activeLayerIndex;
--end
--
--function MapSet:SetActiveLayerIndex(layerIndex)
	--if( layerIndex > 0 and layerIndex < self.maxLayerCount + 1)then
		--self.activeLayerIndex = layerIndex;
		--self.activeDimension = math.pow( 2,self.activeLayerIndex-1);
		--return true;
	--end
	--return false;
--end
--
--function MapSet:GetTexSize()
	--return self.texSize;
--end
--
--function MapSet:GetMapSize()
	--return self.mapSize;
--end;
--
--function MapSet:GetDimension()
	--return self.activeDimension;
--end
--