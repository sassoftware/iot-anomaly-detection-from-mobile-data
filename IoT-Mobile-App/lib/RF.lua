--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - Room Functions
  
--]]
----------------------------------------------------------------------------------------------------
------------------
-- Modules
------------------
local Widget = require( "widget" )
local GlblData = require ( "lib.glbldata" )

local RF = {}
local RF_mt = { __index = RF }

local _DW = display.contentWidth 
local _DH = display.contentHeight
-----------------------------------------------

--- Initiates a room object.
-- return new object
function RF:new()

    local self = {}
    setmetatable( self, RF_mt )  --  new object inherits from RF 
    return self

end
 
function RF:loadfields( RM , BLDG )
		--  room data
		for k, v in pairs( RM ) do
			-- print ("k is ", k ," value is ", v)
			if type( k ) ~= "function" then
				self[ k ] = RM[ k ]
			end
		end	
		-- bldg data
		for k, v in pairs( BLDG ) do
	-- print ("k is ", k ," value is ", v)
			if type( k ) ~= "function" then
				self[ k ] = BLDG[ k ]
			end
		end	
		-- floor data
		local floorentry = BLDG.floors[GlblData.currObject.floorentry]
		for k, v in pairs( floorentry ) do
			if type( k ) ~= "function" then
				self[ k ] = floorentry[ k ]
			end
		end	
		
	
	self.isBuilt		=  true
		-- for k, v in pairs( self ) do
			-- print ("k is ", k ," value is ", v)
		-- end 
   return 
end

function RF:highlight()

	transition.to( self.image , {time = 800 , delay = 1000 , xScale = 2 , yScale = 2 } )

end
function RF:lowlight()

	transition.to( self.image , {time = 800 , delay = 0 , xScale = 1 , yScale = 1 } )

end
-- need something about widgets in there.  So we can make these things clickable.  
--  create image listener function   
function RF:imagetouch( event )
local object = event.target ;
print ("imagetouch function", object.containerTable.roomname )
	if event.phase == "began" then
	    
        print( "You touched the object!" )
	elseif event.phase == "ended" then
		self.containerTable:highlight()
		GlblData.currObject.roomentry = object.containerTable.entrynum;
		for k, v in pairs( object.containerTable ) do
			-- print ("k is ", k ," value is ", v)
			if type( k ) ~= "function" then
				GlblData.currObject[ k ] = object.containerTable[ k ]
			end
		end	
		
	end
return true
end



--  create display image of self using file passed in. 
function RF:loadimage( parentgroup )

	local imagefile = self.imagename
	local Xs = self.sizeX
	local Ys = self.sizeY
	local imagetest  = display.newImageRect( parentgroup , imagefile , Xs , Ys)
	
    self.image = imagetest
	
	imagetest.touch = self.imagetouch
	
	-- self.image:addEventListener( "touch" , self.imagetouch )
	imagetest:addEventListener( "touch" , self.image )
	--  We need this because I can't add meta table info to a display object. 
	self.image.containerTable = self   -- in events we need the table the image is in so we can reference fields.
		
    return imagetest

end
--  create button widget  
function RF:loadbutton( )

	local imagefile = self.imagename
	local Xs = self.sizeX
	local Ys = self.sizeY
	--local imagetest  = display.newImageRect( parentgroup , imagefile , Xs , Ys)
	
    
	local button = Widget.newButton
		{
			defaultFile = imagefile,
			overFile = imagefile,
			label = "",
			emboss = true,
			onPress = self.buttonPress,
			onRelease = self.buttonRelease,
		}
	
	self.image = button
	--  We need this because I can't add meta table info to a display object. 
	self.image.containerTable = self   -- in events we need the table the image is in so we can reference fields.
		
    return imagetest

end



--- Clears this object.
function RF:clear()
	for k, v in pairs( self ) do
	-- print ("k is ", k ," value is ", v)
		--if k ~= "image"
			if type( k ) ~= "function" then
			self[ k ] = nil
		end
	end
end

--  delete this object 
function RF:destroy(isImage)

	--self.RGFgroup.currentcount = self.RGFgroup.currentcount - 1
	if isImage ~= "no image" then 
		self.image:removeEventListener( "touch" , self.image )
		self.image:removeSelf();	
	end 
    self:clear()
	self = nil
	
    return

end
--   return x and y location of self
function RF:loadlocation()
    
	local X = self.image.x
	local Y = self.image.y
	
    
    return X , Y 

end

function RF:setPosition(Xpercent, Ypercent )
	    -- this needs to change to set the position inside the picture of the floor plan.  not the whole screen.
		self.image.x = ((Xpercent / 100 ) * _DW)
		self.image.y = ((Ypercent / 100 ) * _DH)
		
 return 
end
--   return x and y location of self
function RF:setlocation( flrplanpic )
    
	
	self.image.x = flrplanpic.x +  (( self.positionX / 100 ) * flrplanpic.width ) 
	self.image.y = flrplanpic.y +  (( self.positionY / 100 ) * flrplanpic.height )
    
    return 

end

return RF
