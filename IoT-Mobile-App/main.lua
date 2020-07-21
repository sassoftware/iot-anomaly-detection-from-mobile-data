--====================================================================--
-- IoT Demo Client 
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - Main launching point for application
  
  
--]]

--====================================================================--
--  Required modules
--====================================================================--

local composer = require( "composer" )
local Glb = require ( "lib.glbldata" )  -- store global data between modules. 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local GGData = require( "lib.GGData" )

-- display.setStatusBar( display.HiddenStatusBar )  -- Removes status bar

-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
	native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

local M = {}  -- Module level scoped variables

--====================================================================--
	-- INITIALIZE
--====================================================================--
function M.initialize1()
		-- initialize1 runs the first time the app is started. 
        ---------------------
		--  Variables 
		---------------------
		print ("Main:  initialize1")
		--  Totals
		local Appversion = 100
		local Appsound = true 
		local Appmusic = true 
		Glb.Appsound = true 
		Glb.Appmusic = true 
		
		
		
		--  Brokers
		local AppBrokers = {
				{
				Nick = "sample", 
				Host = "test.mosquitto.org",
				Port = 1883, 
                TopicPub = 'PhoneSensors',
                TopicSub = 'Outcomes',
                Topic = 'phonesensors',
				Freq = 10, 
				isEnabled = true ,  -- indicate the active broker in the list.  
				isDeletable = false,
				Connected = false,
                KeepAlive = 120, 
                Conntype = 'publish',  -- or subscribe
                Userid = '',
                Password = ''
                }
		}
        
        --  Brokers default values
		local AppBrokerDefaults = {
				Nick = "NickNameField", 
				Host = "test.mosquitto.org",
				Port = 1883, 
                TopicPub = 'PhoneSensors',
                TopicSub = 'Outcomes',
				Freq = 10, 
				isEnabled = false ,  -- indicate the active broker in the list.  
				isDeletable = true,
				Connected = false,
                KeepAlive = 120, 
                Conntype = 'publish',  -- or subscribe
                Userid = '',
                Password = ''
		}
		
        ---------------------
		--  save to appstate
		---------------------		
		M.appstate:set("Appsound", Appsound)
		M.appstate:set("Appmusic", Appmusic)
		M.appstate:set("Appversion", Appversion)
		M.appstate:set("AppBrokers", AppBrokers)
		M.appstate:set("AppBrokerDefaults", AppBrokerDefaults)
return                                         
end

function M.InitializeData() 
	    -- if first time init arrays
		-- create new box
		-- store values in box
		print ("Main:  InitializeData  "  )
		M.appstate = GGData:new( "AppState" )
		 if M.appstate.Appversion == nil then 
		   -- First time in or game has been reset. 
		   M.initialize1()
		 end 
		 if M.appstate.GSsound then    -- sound effects 
			Glb.GSsound = true
		 else 
			Glb.GSsound = false
		 end
		 if M.appstate.GSmusic then    -- music playing 
			Glb.GSmusic = true
		 else
			Glb.GSmusic = false
		 end
        
         M.appstate:save()  -- write newly created data to disk
return 
end	

--====================================================================--
-- MAIN FUNCTION
--====================================================================--

local main = function ()

     -- Fresh load reset MQTT connection
     -- loop thru broker list and change all to Connected = false 
     Misc:table_set_by_key("Connected", false , M.appstate.AppBrokers )   --  key,value,t

	
	local options = {
		effect = "fade",
		time = 500,
			params = {
				someKey = "someValue",
				someOtherKey = 10
			}
		}
	
	composer.gotoScene( "scene.intro", options ) -- Go to Intro screen
	
	------------------
	-- Return
	------------------
	
	return true
end
-- local devicetype = function ()
	-- if string.sub(system.getInfo("model"),1,4) == "iPad" then 
		-- GlblData.Dtype = "ipad" 
	-- elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then  -- Iphone 5 
		-- GlblData.Dtype = "iphone5" 
	-- elseif string.sub(system.getInfo("model"),1,2) == "iP" then  -- iphone 3 and 4 
		-- GlblData.Dtype = "iphone4" 
	-- elseif display.pixelHeight / display.pixelWidth > 1.72 then --  adroid phone
		-- GlblData.Dtype = "aphone" 
	-- else GlblData.Dtype = "atablet"  -- Andriod tablet 
	-- end
-- end

--====================================================================--
-- BEGIN
--====================================================================--
M.InitializeData()
main()

