--====================================================================--
-- Main capture location values 
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2020
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - setup runtime listener for location data 
  - 
--]]
---------------------------------------------------------------------------------------

local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 

local M = {}
local M_mt = { __index = M }

-- return new object
function M:new(options)
	
    local self = {}
    setmetatable( self, M_mt )  --  new object inherits from M
	self:loadnew(options)  -- load location function 
    return self
end

function M:loadnew(options)

    -----------------------------------------------------------
    -- Hardware Events
    -----------------------------------------------------------
    local function onLocaiton( event )  -- Called for location events

        -- Format and display the Accelerator values
        if ( event.errorCode ) then
            native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
            print( "Location error: " .. tostring( event.errorMessage ) )
        else
            self.data.latitudeF          =  string.format('%.4f',event.latitude )
            self.data.latitude          =  event.latitude
            self.data.longitudeF         =  string.format('%.4f',event.longitude )
            self.data.longitude         =  event.longitude
            self.data.altitudeF          =  string.format('%.3f',event.altitude )
            self.data.altitude          =  event.altitude
            self.data.accuracyF          =  string.format('%.3f',event.accuracy )
            self.data.accuracy          =  event.accuracy 
            self.data.speedF             =  string.format('%.3f',event.speed )
            self.data.speed             =  event.speed / .447  --  mph 
            self.data.directionF         =  string.format('%.3f',event.direction )
            self.data.direction         =  event.direction
            self.data.timeF              =  string.format('%.0f',event.time ) 
            self.data.time              =  event.time
            self.isUpdate  = true 
        end 
    end
	--
	-- Check if accelerator is supported on this platform
	--
		if not system.hasEventSource( "location" ) and not system.getInfo("environment") == "simulator" then
			print ( "Location not supported on this device" )
			self.isActive = false
			return false 
			else
                self.stageDG = options.stage 
                self.data = {}  -- table for accelerator data
                self.data.latitudeF  = "n/a"   
                self.data.longitudeF = "n/a"   
                self.data.altitudeF  = "n/a"  
                self.data.accuracyF  = "n/a"  
                self.data.speedF     = "n/a"  
                self.data.directionF = "n/a"   
                self.data.timeF      = "n/a"   
                
                self.data.latitude  = 0   
                self.data.longitude = 0   
                self.data.altitude  = 0  
                self.data.accuracy  = 0  
                self.data.speed     = 0  
                self.data.direction = 0   
                self.data.time      = 0   
                self.stageDG.runtimez:push({name="location", func=onLocaiton})
                self.isActive = true 
		end

	if system.getInfo("environment") == "simulator" then
		print ( "Simulator Location only works on shake?????" )
        --native.showAlert( "Simulator Accelerometer only works on shake ", system.getInfo("environment") , {"OK"} )
	end



end



return M
