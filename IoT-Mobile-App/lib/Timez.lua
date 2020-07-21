--[[

 - Version: 0.1
 - Made by Tom Tuning
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - Timer Functions:  Keeps track of timers in a table
  
		-----------------------
		--  Usage
		-----------------------
		local t1 = {} 
		t1.name = ".100 second counter"
		t1.timer = timer.performWithDelay(100, timebump , -1)
		allTimers:push(t1, -1 )
		-
		-
		-- in timer even handler 
		allTimers:pop(event.source)  -- need to pop these out of the table so that the table doesn't grow endlessly. 
		--  Handle case where timer count is non zero and we want to cancel anyway. 
		allTimers:Tcancel(gameGroup.isZoomingTrans) --  cancel timer and pop from table. 
--]]
----------------------------------------------------------------------------------------------------

local Timez = {}
local Timez_mt = { __index = Timez }


-----------------------------------------------
--- Clears this object. not used at the moment 
local function clearfields( Q )
	for k, v in pairs( Q ) do
	print ("k is ", k ," value is ", v,"type is ", type(v))
		if type (v) == "table" then clearfields (v) end
		if type( k ) ~= "function" then
			Q[ k ] = nil
		end
	end
	Q = nil
end

--- Initiates a new Bubble object.
-- return new object
function Timez:new()

    local self = {}
    --self = display.newImage()
    setmetatable( self, Timez_mt )  --  new object inherits from Timez

    return self

end

--  Add a new timer to the timer table
--  timer should have 3 values.   t.name ,t.id , t.howmany
--  name is just for readability during debug.  
function Timez:push(newtimer,howmany)
	-- print("Push newtimer = ", newtimer , howmany)
	newtimer.howmany = howmany 
    table.insert(self, newtimer) 
	
    return

end

--  Remove timer from table 
--  This is called from timer listener.  So it only has the timer id. 
function Timez:pop(oldtimer)
	local i = 0
	local counter = 666 
	timerfound = false 
	
		-- find oldtimer in timer table
		local allTimersCount = #self
		-- print ("allTimersCount ", allTimersCount)
			if allTimersCount > 0 then
				for i = allTimersCount, 1, -1 do
					local Tentry = self[i]  -- timer table entry
						if oldtimer == Tentry.timer then 
							counter = Tentry.howmany
							timerfound = true 
							if Tentry.howmany ~= -1 then -- -1 indicates an infinate timer
								-- print ("TimeZ:Pop - timer found in the table" , Tentry.name , Tentry.timer )
								if Tentry.howmany > 0 then Tentry.howmany = Tentry.howmany - 1 end  -- keep in sync with timer _iterations
								if Tentry.howmany <= 0 then 
									table.remove(self , i)  --  we don't need to clear it because at 0 it clears itself.
									-- clearfields(Tentry)
								end  -- howmany 0 so remove from list 
							end 
						end
				end
			end
		if not timerfound then print ("Timez:pop called but timer not found in table.", oldtimer ) end 
    return  counter
end

--  This will clear old timer and is called with AllTimers table entry.
function Timez:Tcancel(oldtimer)
	local i = 0
		-- find oldtimer in timer table
		local allTimersCount = #self
		-- print ("allTimersCount ", allTimersCount)
			if allTimersCount > 0 then
				for i = allTimersCount, 1, -1 do
					local Tentry = self[i]  -- timer table entry
						if oldtimer == Tentry then 
						-- print ("TimeZ:Tcancel - timer found in the table" , "name = ", Tentry.name )
							timer.cancel( Tentry.timer )
							table.remove(self , i)
						end
				end
			end
		
    return
end



--- print out timers for debug.
function Timez:listem()
	print ("number of timers is ", #self )
	for k, v in pairs( self ) do
		print ("name is ", k ," value is ", v)
		for l, m in pairs( v ) do
			print ("name is ", l ," value is ", m)
		end 
	end
end


--  delete this object 
function Timez:cancelall()

    -- self:clear()
	local allTimersCount = #self
	    if allTimersCount > 0 then
			for i = allTimersCount, 1, -1 do
				local child = self[i]
				timer.cancel( child.timer )
				table.remove(self , i)
			end
        end
	
    return

end


return Timez
