--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  -- misc helper functions
  
  
--]]
----------------------------------------------------------------------------------------------------
local Json   = require ("json")
local composer = require "composer"   -- scene scheduler 
------------------
-- Constants
------------------
local _DW = display.contentWidth 
local _DWsafe = display.safeActualContentWidth 
local _DH = display.contentHeight
local _DHsafe = display.safeActualContentHeight
------------------
-- Modules
------------------
local M = {}
local M_mt = { __index = M }

--------------------------
--  Local Functions
--------------------------

local function L_printtable (t)
			print("misc:printtable", t )
			if type(t) == "table" then 
				print ("===== printing table =====", t )
				for k,v in pairs (t) do
					print ("key is ", k ," value ===", v , type(v))
					if type(v) == "table" then 
						-- print ("key is ", k ," value ===", v , type(v))
						L_printtable(v)  -- try a little fun with recursion 
						print ("===== completed table =====" , v )
					end
					
				end 
			end 
return
end	


-- return new object
function M:new( )
	print ("misc functions")
    local self = {}
    setmetatable( self, M_mt )  --  new object inherits from RF 
    return self

end

--  delete this object 
function M:destroy()

	self = nil
    return

end

function M:destroy_all_from_table(t)

    for k,v in pairs (t) do
        v:removeSelf()
        t[k]= nil 
        
    end 

return 
end 



-- convenence function support multiple inheritence 

function M:builtfrom( classes )
    -- build new class which inherits from list of classes.  
	-- classes is an table of classes to build this new class from.  
	local newclass  = nil -- class to be returned 
	local required_modules = {}
	local working_classes  = {} 
	local classcount = #classes  -- 
	local ii = 0 
		
	    if classcount > 0 then
			for ii = 1 , classcount, 1 do
				required_modules[ii] = require (classes[ii])  -- bring in ref to external module 
				if  (ii == 1) 	then 
					working_classes[ii] = required_modules[ii] -- 1st class doesn't inherit 
				elseif (ii > 1) then  
					working_classes[ii] = required_modules[ii]:inheritsFrom(working_classes[ii-1])
				end 	
			end 
		newclass = working_classes[classcount]	
		end 	
	
    return newclass 
end

	
	
----------------------------
-- Object position Function
----------------------------
	
function M:position ( object , Xpercent, Ypercent )
	
		object.x = ((Xpercent / 100 ) * _DW)
		object.y = ((Ypercent / 100 ) * _DH)
		
return ( object )	
end

function M:positions_within_frame  (object, Xpercent, Ypercent , frameobj )

		local framestartX = frameobj.x - ( frameobj.width / 2 ) 
		local framestartY = frameobj.y - ( frameobj.height / 2 )  
		object.x = ((Xpercent / 100 ) * frameobj.width ) + framestartX
		object.y = ((Ypercent / 100 ) * frameobj.height) + framestartY

	return ( object )	
end
 
function M:printtable( t )
	L_printtable(t)
return 
end

--  hard code the depth to print. 
function M:printtableD( t , depth )
	local dep  = depth or 2 
	 -- what have I done? 
		for k1, v1 in pairs( t ) do
			print ("Table1 key ", k1 ," value is ", v1 , type(v1))
			if dep > 1 then 
				if type(v1) == "table" then 
					for k2,v2 in pairs (v1) do	
						print ("---Table2 key ", k2 ," value is ", v2 , type(v2))
						if dep > 2 then 
							if type(v2) == "table" then 
								for k3,v3 in pairs (v2) do	
									print ("-----Table3 key ", k3 ," value is ", v3 , type(v3))
									if dep > 3 then 
										if type(v3) == "table" then 
											for k4,v4 in pairs (v3) do	
												print ("-------Table4 key ", k4 ," value is ", v4 , type(v4))
											end 
										end 
									end
								end 
							end 
						end
						
					end 
				end 
			end 
			 
		end
	return 
	end 
	
--  list composer info, which scene are we on.
function M:sceneinfo ( text )
	local text2 = text or ""
	local currScene = composer.getSceneName( "current" )
	local prevScene = composer.getSceneName( "previous" )
	local overlayScene = composer.getSceneName( "overlay" )
	
	print ( text2 , " current: ",currScene ,"previous: ",prevScene,"overlay: ", overlayScene )	
		
return ( {currScene, prevScene, overlayScene} )	
end

----------------------------
-- Display Object position Function
-- object to position 
-- percentages 
-- frame or display width and Height.
----------------------------

function M:setPosition( object , Xpercent, Ypercent , frameobj )

    if frameobj then 
        -- adjust for image anchor point in frame object 
		local  framestartX = frameobj.x - ( frameobj.width * frameobj.anchorX ) 
		local  framestartY = frameobj.y - ( frameobj.height *  frameobj.anchorY )  
		
		object.x = ((Xpercent / 100 ) * frameobj.width ) + framestartX
		object.y = ((Ypercent / 100 ) * frameobj.height) + framestartY
	else 

		object.x = ((Xpercent / 100 ) * _DW  )
		object.y = ((Ypercent / 100 ) * _DH  )
	end 	
	-- print ("setPosition", self.buttonGroup.x, self.buttonGroup.y , self.buttonGroup.anchorX, self.buttonGroup.anchorY )
 return 
end


--  set all entries in table to value by key 
function M:table_set_by_key(
key,       -- key of table 
value,     -- value to set 
t)         -- table name 
-- return true or error message 

    local key = key 
    local value = value
    local t = t
	local tableCount = #t
    local success = true 
			if tableCount > 0 then
				for i = tableCount, 1, -1 do
                    t[i][key] = value 
                end
            else success = "Error,  table_set_by_key:  table was empty "    
			end

return (success)
end 

function M:table_delete_by_key(key,value,t)
    local key = key 
    local value = value
    local t = t
	local tableCount = #t
    local success = false 
			if tableCount > 0 then
				for i = tableCount, 1, -1 do
					local Tentry = t[i]  -- table entry
                    if Tentry[key] == value  then 
                        table.remove(t , i)  --  we don't need to clear it because at 0 it clears itself.
                        success = true 
                    end     
                end
			end

return (success)
end 

function M:table_delete_by_value(value,t)
    local value = value
    local t = t
	local tableCount = #t
    local success = false 
			if tableCount > 0 then
				for i = tableCount, 1, -1 do
					local Tentry = t[i]  -- table entry
                    if Tentry == value  then 
                        table.remove(t , i)  
                        success = true 
                    end     
                end
			end

return (success)
end 

function M:table_find_by_key(key,value,t)
    
    local key = key 
    local value = value
    local t = t
	local tableCount = #t
    local success = false 
			if tableCount > 0 then
				for i = tableCount, 1, -1 do
					local Tentry = t[i]  -- table entry
                    if Tentry[key] == value  then
                        success = i 
                    end     
                end
			end
-- print ("Misc: table_find_by_key", key,value,t, "isFound = ", success )
return (success)
end 
-- update existing or add entry to table  
-- if found just delete and add to the same spot in table 
-- inserts a new entry to front of table.  

-- returns  updated entry number or false for new entry 
function M:table_update_by_key(k,v,t,e)
    local key = k
    local value = v
    local tt = t
    local entry = e
    -- print ("Misc: table_update_by_key", key,value,tt,entry)
    -- print ("Misc: table_update_by_key", Json.prettify(tt))
    local found = self:table_find_by_key(key,value,tt)
    if found then 
        -- print ("Misc: table_update_by_key found " , found )
        self:table_delete_by_key(key,value,tt)
        table.insert(tt,found,entry)
    else 
        table.insert(tt,1,entry) 
    end 
    -- print ("Misc: table_update_by_key after insert ", Json.prettify(tt))
return found 
end

function  M:xyzFormat( value )
	return string.format( "%1.3f", value )
end

return M
