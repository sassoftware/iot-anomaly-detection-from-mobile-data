--[[
- Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************


  - Room Group Functions
  - This will track room metrics
  
--]]
----------------------------------------------------------------------------------------------------

local RGF = {}
local RGF_mt = { __index = RGF }


-----------------------------------------------

-- return new object
function RGF:new()

    local self = {}
    setmetatable( self, RGF_mt )  --  new object inherits from RGF
    return self

end

function RGF:loadfields( LD , BLDG )
	 
		for k, v in pairs( LD ) do
	-- print ("k is ", k ," value is ", v)
			if type( k ) ~= "function" then
				self[ k ] = LD[ k ]
			end
		end	
		
		-- Add floor stuff?
		
		for k, v in pairs( BLDG ) do
	-- print ("k is ", k ," value is ", v)
			if type( k ) ~= "function" then
				self[ k ] = BLDG[ k ]
			end
		end	
    
return 
end

--- Clears this object.
function RGF:clear()
    -- print ("RGF clear", self.myname )
	for k, v in pairs( self ) do
		if k ~= "image"
			and type( k ) ~= "function" then
			self[ k ] = nil
		end
	end
end

--  delete this object 
function RGF:destroy()

    self:clear()
	self = nil
	
    return

end

return RGF
