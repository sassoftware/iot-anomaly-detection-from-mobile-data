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


-- return new object
function M:new( )
	print ("simpleclass new function")
    local self = {}
    setmetatable( self, M_mt )  --  new object inherits from RF 
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

function M:classname()
	print ("simpleclass:  classname function  ")
return 
end 

function M:classname2()
	print ("simpleclass:  classname2 function  ")
return 
end 


--  delete this object 
function M:destroy()

	display.remove(self.DG)
	self = nil
	
    return

end

return M
