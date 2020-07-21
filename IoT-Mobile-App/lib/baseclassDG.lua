--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  -- object oriented programming functions 
  -- support inheritence 
  
--]]
----------------------------------------------------------------------------------------------------
------------------
-- Modules
------------------
local M = {}
local M_mt = { __index = M }

local _DW = display.contentWidth 
local _DH = display.contentHeight

-- return new object
function M:new( )

    local self = {}
    self.DG = display.newGroup()  -- use DG as table to hold functions.  This allows for use of finalize function in destroy
	self.DG.antecedent = self 
    setmetatable( self, M_mt ) 
	
	self.DG.finalize = self.finalizeDG
	self.DG:addEventListener("finalize")

    return self

end

-- Create a new class that inherits from a base class
--
function M:inheritsFrom( baseClass )

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( M, { __index = baseClass } )
    end

    return M
end


-- If this DG was deleted by composer destroy can't be called.  
function M:finalizeDG()
	-- add code to delete timers 
	print ("baseClassDG finalize")
	transition.cancel(self) -- add code to cancel any transitions.  
	self = nil
return 	
end

--  delete this object 
function M:destroy()

	display.remove(self.DG)
	self = nil
	
return nil 
end

----------------------------
-- Object position Function
-- object to position 
-- percentages 
-- frame or display width and Height.
----------------------------

function M:setPosition( object , Xpercent, Ypercent , frameobj )

    if frameobj then 
		-- local framestartX = frameobj.x - ( frameobj.width / 2 ) 
		-- local framestartY = frameobj.y - ( frameobj.height / 2 )  
		local framestartX = frameobj.x 
		local framestartY = frameobj.y 
		object.x = ((Xpercent / 100 ) * frameobj.width ) + framestartX
		object.y = ((Ypercent / 100 ) * frameobj.height) + framestartY
	else 

		object.x = ((Xpercent / 100 ) * _DW)
		object.y = ((Ypercent / 100 ) * _DH)
	end 	
	
 return ( object )	
end




return M
