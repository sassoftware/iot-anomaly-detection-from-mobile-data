--[[

 - Version: 0.1
 - Made by Tom Tuning
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - runTimez Functions:  Keeps track of runtimer listeners in a table
  
		-----------------------
		--  Usage
		-----------------------
		
		
--]]
----------------------------------------------------------------------------------------------------

local M = {}
local M_mt = { __index = M }

-- return new object
function M:new()
    local self = {}
    setmetatable( self, M_mt )  --  new object inherits from M
    return self
end

--  Add a new runtime listener to the table.
--  timer should have 3 values.   t.name ,t.func optional t.tag 
function M:push(t)
	local t2 = {}
	t2.name = t.name 
	t2.func = t.func 
	t2.tag = t.tag or "" 
    table.insert(self, t2 ) 
    return
end

--  Remove listener from table 
--  If the listener has a unique tag give the option to remove it from the table. 
function M:pop(tag)
	local i = 0
	tfound = false 
	
		-- find tag in timer table
		local allTimersCount = #self
		-- print ("allTimersCount ", allTimersCount)
			if allTimersCount > 0 then
				for i = allTimersCount, 1, -1 do
					local Tentry = self[i]  -- table entry
						if tag == Tentry.tag and tag ~="" then  -- ignore if tag not set 
							tfound = true 
							Runtime:removeEventListener(Tentry.name , Tentry.func)
							table.remove(self , i)  
						end
				end
			end
		if not tfound then print ("M:pop called but timer not found in table.  tag ---> ", tag ) end 
    return  
end


--- print out t for debug.
function M:listem()
	print ("number of listeners is ", #self )
	for k, v in pairs( self ) do
		print ("name is ", k ," value is ", v)
		for l, m in pairs( v ) do
			print ("name is ", l ," value is ", m)
		end 
	end
end


--  add runtimelisteners
function M:addall()
	local Count = #self
	    if Count > 0 then
			for i = Count, 1, -1 do
				local t2 = self[i]
				Runtime:addEventListener(t2.name , t2.func)
			end
        end
    return
end

--  add runtimelisteners
function M:removeall()
	local Count = #self
	    if Count > 0 then
			for i = Count, 1, -1 do
				local t2 = self[i]
				Runtime:removeEventListener(t2.name , t2.func)
			end
        end
    return
end

return M
