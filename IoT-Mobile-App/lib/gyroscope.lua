--====================================================================--
-- Main capture gyroscope values 
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2020
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - setup runtime listener for gyroscope data 
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
    self.stageDG = options.stage 
	self:loadnew(options)  -- load gyroscope function 
    return self
end



function M:loadnew(options)
    -----------------------------------------------------------
    -- Hardware Events
    -----------------------------------------------------------
    local function onGyroscope( event )  -- Called for events

        -- Format and display the Accelerator values
		local PI = math.pi 
		local PI180 = 180/PI
        local deltaXradians = event.xRotation * event.deltaTime 
		local deltaXdegrees = deltaXradians * PI180
        local deltaYradians = event.yRotation * event.deltaTime 
		local deltaYdegrees = deltaYradians * PI180
        local deltaZradians = event.zRotation * event.deltaTime 
		local deltaZdegrees = deltaZradians * PI180
        self.data.xRotationF        =  misc:xyzFormat( deltaXradians )
        self.data.yRotationF        =  misc:xyzFormat( deltaYradians )
        self.data.zRotationF        =  misc:xyzFormat( deltaZradians )
        self.data.xRotation        =   deltaXradians 
        self.data.yRotation        =   deltaYradians 
        self.data.zRotation        =   deltaZradians 
        
        self.isUpdate  = true 
      return   
    end
            
	--
	-- Check if gyroscope is supported on this platform
	--
		if not system.hasEventSource( "gyroscope" ) and not system.getInfo("environment") == "simulator" then
			print ( "Gyroscope not supported on this device" )
			self.isActive = false	
			return false 
			else
                -- Set up the accelerometer to provide measurements 20 times per second.
                -- Note that this matches the frame rate set in the "config.lua" file.
                system.setGyroscopeInterval( 10 )
                self.stageDG = options.stage 
                self.data = {}  -- table for gyroscope data
				self.data.xRotationF        =  "n/a"
				self.data.yRotationF        =  "n/a"
				self.data.zRotationF        =  "n/a"
                self.data.xRotation        =   0
                self.data.yRotation        =   0
                self.data.zRotation        =   0
                
                self.stageDG.runtimez:push({name="gyroscope", func=onGyroscope})
                self.isActive = true 
		end



end



return M
