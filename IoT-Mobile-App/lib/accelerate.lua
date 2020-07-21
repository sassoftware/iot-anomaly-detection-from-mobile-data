--====================================================================--
-- Main capture accelerator values 
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - setup runtime listener for accelerometer data 
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
	self:loadnew(options)  -- load acceleration function 
    return self
end



function M:loadnew(options)
    -----------------------------------------------------------
    -- Hardware Events
    -----------------------------------------------------------
    local function onAccelerate( event )  -- Called for Accelerator events

        -- Format and display the Accelerator values
        --
        self.data.xGravityF        =  misc:xyzFormat( event.xGravity)
        self.data.yGravityF        =  misc:xyzFormat( event.yGravity)
        self.data.zGravityF        =  misc:xyzFormat( event.zGravity)
        self.data.xInstantF        =  misc:xyzFormat( event.xInstant)
        self.data.yInstantF        =  misc:xyzFormat( event.yInstant)	
        self.data.zInstantF        =  misc:xyzFormat( event.zInstant)	
        self.data.isShakeF          = event.isShake
        
        self.data.xGravity         =  event.xGravity
        self.data.yGravity         =  event.yGravity
        self.data.zGravity         =  event.zGravity
        self.data.xInstant         =  event.xInstant
        self.data.yInstant         =  event.yInstant
        self.data.zInstant         =  event.zInstant
        if event.isShake then 
            self.data.isShake      = 1
        else 
            self.data.isShake      = 0
        end 
        self.isUpdate  = true 
        
    end
	--
	-- Check if accelerator is supported on this platform
	--
		if not system.hasEventSource( "accelerometer" ) and not system.getInfo("environment") == "simulator" then
			print ( "Accelerometer not supported on this device" )
			self.isActive = false	
			return false 
			else
                -- Set up the accelerometer to provide measurements 20 times per second.
                -- Note that this matches the frame rate set in the "config.lua" file.
                system.setAccelerometerInterval( 10 )
                self.stageDG = options.stage 
                self.data = {}  -- table for accelerator data
                self.data.xGravityF = "n/a"   -- event.xGravity is the acceleration due to gravity in the x-direction
                self.data.yGravityF = "n/a"   -- event.yGravity is the acceleration due to gravity in the y-direction
                self.data.zGravityF = "n/a"  -- event.zGravity is the acceleration due to gravity in the z-direction
                self.data.xInstantF = "n/a"  -- event.xInstant is the instantaneous acceleration in the x-direction
                self.data.yInstantF = "n/a"  -- event.yInstant is the instantaneous acceleration in the y-direction
                self.data.zInstantF = "n/a"   -- event.zInstant is the instantaneous acceleration in the z-direction
                self.data.isShakeF  = false    -- event.isShake is true when the user shakes the device
                self.data.xGravity = 0   -- event.xGravity is the acceleration due to gravity in the x-direction
                self.data.yGravity = 0   -- event.yGravity is the acceleration due to gravity in the y-direction
                self.data.zGravity = 0  -- event.zGravity is the acceleration due to gravity in the z-direction
                self.data.xInstant = 0  -- event.xInstant is the instantaneous acceleration in the x-direction
                self.data.yInstant = 0  -- event.yInstant is the instantaneous acceleration in the y-direction
                self.data.zInstant = 0   -- event.zInstant is the instantaneous acceleration in the z-direction
                self.data.isShake  = 0    -- event.isShake is true when the user shakes the device
                self.stageDG.runtimez:push({name="accelerometer", func=onAccelerate})
                self.isActive = true 
		end

	if system.getInfo("environment") == "simulator" then
		print ( "Simulator Accelerometer only works on shake" )
        --native.showAlert( "Simulator Accelerometer only works on shake ", system.getInfo("environment") , {"OK"} )
	end


end



return M
