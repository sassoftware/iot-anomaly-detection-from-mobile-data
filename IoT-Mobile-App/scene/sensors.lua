--====================================================================--
-- Main Sensors scene
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - show sensor data
  - 
--]]

 
local Widget = require( "widget" )
local Json   = require ("json")
local GGData = require( "lib.GGData" )
local Glb = require ( "lib.glbldata"  )
local Accel = require ( "lib.accelerate" )
local Gyroscope = require ( "lib.gyroscope" )
local Location = require ( "lib.location" )
local Spec  = require ( "scene.specifics.demodefinitions" )  -- style and page setup 
local SensorList  = require ( "scene.sensors.sensorlist" )  -- builds tableview of sensors 
local rgb = require ( "lib._rgb" )   -- colors 
local Timez  = require("lib.Timez")  -- since timers aren't attached to objects we need to track them.  
local RuntimeZ  = require("lib.runtimez")  -- we need a way to clear all runtime listeners on scene exit 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 
local MQTT = require("lib.mqtt_library")
MQTT.Utility.set_debug(true)



local composer = require "composer"   -- scene scheduler 


local M = {}  -- Module level scoped variables
local scene = composer.newScene()
composer.recycleOnSceneChange = true  -- everything in sceneGroup is removed on scene exit 

	------------------
	-- Constants
	------------------
	local _DW = display.contentWidth 
    local _DH = display.contentHeight
	
	---------------------------
	--  Functions 
	----------------------------
function M.broker_mark_not_connected()

        local found = misc:table_find_by_key("Connected",true,M.appstate.AppBrokers)
        if found then 
            M.appstate.AppBrokers[found]["Connected"] = false 
            M.appstate:save()  -- write newly created data to disk
        end 
return 
end 


function M.mqtt_handler()
    
    if Glb.MQTTSession then 
        if Glb.MQTTSession.connected then  
            local error_message  = Glb.MQTTSession:handler()
            if error_message ~= nil then 
                -- print error message 
                -- mark not connected. 
                Glb.MQTTSession = nil 
                M.broker_mark_not_connected()
            end 
        end 
    end 

return
end 

function M.mqtt_unsubscribe()
    
    if Glb.MQTTSession then 
        if Glb.MQTTSession.connected then  
            Glb.MQTTSession:unsubscribe({M.TopicSub})
        end 
    end 
            

return
end 

function M.msg_alert()
    if not M.alert then  
    
        local function alertnow() 
                M.alert = native.showAlert( "Connection Error", "Please check broker settings", { "OK" } )
        return 
        end 
        
        M.alert = true 
        timer.performWithDelay(1000, alertnow,1) 
    end 
return
end 


function M.publish()

    if Glb.MQTTSession then 
        if Glb.MQTTSession.connected then 
            local error_message = Glb.MQTTSession:publish(M.TopicPub, Json.encode(Glb.mqtt_pub))
            if error_message ~= nil then 
                -- print error message once 
                M.msg_alert()
                Glb.MQTTSession = nil 
                M.broker_mark_not_connected()  -- mark not connected
            end 
        else M.msg_alert()     
        end 
    else   M.msg_alert()     
    end 

return 
end 
    
    
function M.publish_by_freq()

    local mod_div = {10,9,8,7,6,5,4,3,2,1}
    local f = tonumber(M.Freq) or 0
    if f > 10 then f = 10 end 
    if f < 1 then f = 1 end 
    
    if ( M.currenttime100 % mod_div[f] == 0 ) then 
       M.publish() 
    end 
return 
end 


	
	
local create_new = function ( self, event )

	local currenttheme = Spec.themes.defaulttheme
	Glb.theme = Spec:loadtheme(currenttheme)
	local theme = Glb.theme 
		
	
	M.sceneGroup = self.view -- add display objects to this group
	local gameGroup = display.newGroup()
    gameGroup.myname = "gameGroup"
	
	
	------------------------------
	-- Build the UI  
	------------------------------
	local UI = require( "lib.appUI" )
	local UI_inst = UI:newUI( { title="Sensors", stage = M.sceneGroup } )
    M.sceneGroup.UI_inst = UI_inst
	------------------------------
	-- CONFIGURE STAGE
	------------------------------
	M.sceneGroup:insert( UI_inst.backGroup )
	M.sceneGroup:insert( gameGroup )
	M.sceneGroup:insert( UI_inst.frontGroup )	
	M.sceneGroup.timers = Timez:new()  -- add class to track timers
	M.sceneGroup.runtimez = RuntimeZ:new()  -- add class to track runtime listeners
	M.sceneGroup.accel = Accel:new( {stage = M.sceneGroup} )  -- grab accerometer data  
	M.sceneGroup.gyroscope = Gyroscope:new( {stage = M.sceneGroup} )  -- grab Gyroscope data  
	M.sceneGroup.location = Location:new( {stage = M.sceneGroup} )  -- grab location data  
    
    
    
    ------------------------------
	-- Build the Sensor List 
	------------------------------
    local SL_inst = SensorList:new( { title="Sensors", stage = M.sceneGroup } )
    gameGroup:insert( SL_inst.tableView2 )
	gameGroup:insert( SL_inst.spinner )
    
    
    -- SL_inst.tableView2:setIsLocked(true )
    -- SL_inst.tableView2:scrollToY({y=-100,time=600})

-- called by timer event 
local function timebump (event)  -- currently 10 times per second. 
	M.sceneGroup.timers:pop(event.source)
    
    M.currenttime100 = M.currenttime100 + 1 
    ----------------------------------------------
    --  things to do every 100 milliseconds     
    ----------------------------------------------
    Glb.mqtt_pub.deviceID = Glb.deviceID
    Glb.mqtt_pub.timestamp = M.currenttime100
    
    
    if M.sceneGroup.accel.isActive then 
        Glb.mqtt_pub.isShake =  M.sceneGroup.accel.data.isShake
        Glb.mqtt_pub.x_acc =    M.sceneGroup.accel.data.xGravity
        Glb.mqtt_pub.y_acc =	M.sceneGroup.accel.data.yGravity
        Glb.mqtt_pub.z_acc =	M.sceneGroup.accel.data.zGravity
    end 
    if M.sceneGroup.gyroscope.isActive then 
        Glb.mqtt_pub.x_gyro =   M.sceneGroup.gyroscope.data.xRotation
        Glb.mqtt_pub.y_gyro =	M.sceneGroup.gyroscope.data.yRotation
        Glb.mqtt_pub.z_gyro =	M.sceneGroup.gyroscope.data.zRotation
    end 
    if M.sceneGroup.location.isActive then 
        Glb.mqtt_pub.latitude       = M.sceneGroup.location.data.latitude  
        Glb.mqtt_pub.longitude      = M.sceneGroup.location.data.longitude 
        Glb.mqtt_pub.altitude       = M.sceneGroup.location.data.altitude  
        Glb.mqtt_pub.accuracy       = M.sceneGroup.location.data.accuracy  
        Glb.mqtt_pub.speed          = M.sceneGroup.location.data.speed     
        Glb.mqtt_pub.direction      = M.sceneGroup.location.data.direction 
        Glb.mqtt_pub.locationeventtime           = M.sceneGroup.location.data.time
    
    end 
    
    M.publish_by_freq()  -- publish events at requested rate. 
    
    
    ----------------------------------------------
    --  things to do every 500 milliseconds     
    ----------------------------------------------
    if ( M.currenttime100 % 5 == 0 ) then 
        -- M.mqtt_handler()  --  called to dequeue socket messages
    end 
    ----------------------------------------------
    --  things to do every 1000 milliseconds     
    ----------------------------------------------
    if ( M.currenttime100 % 10 == 0 ) then 
            SL_inst:reloadrows()  -- reload sensor table list 
            M.mqtt_handler()  --  called to dequeue socket messages
    end 

    
	
end 	
	
	M.sceneGroup.timers:push({name = "test", timer = timer.performWithDelay(100, timebump , -1)} , -1 )

	
	--====================================================================--
	-- INITIALIZE
	--====================================================================--
	
	local InitializeData = function () -- grab data from disk if needed. 
    
    
        M.currenttime100 = os.time()  -- # of seconds since 1970
        M.appstate = GGData:load("AppState")
        
        
        local found = misc:table_find_by_key("Connected",true,M.appstate.AppBrokers)
        if found then 
            M.Host = M.appstate.AppBrokers[found]["Host"]
            M.Port = tonumber(M.appstate.AppBrokers[found]["Port"])
            M.KeepAlive = tonumber(M.appstate.AppBrokers[found]["KeepAlive"])
            M.TopicPub = M.appstate.AppBrokers[found]["TopicPub"]
            M.TopicSub = M.appstate.AppBrokers[found]["TopicSub"]
            M.Freq = tonumber(M.appstate.AppBrokers[found]["Freq"])
        else 
            print ("ERROR: internal error,  no Connected broker found in AppBrokers table")
            M.Topic = 'error'
            Glb.MQTTSession = nil 
            
        end

        
				-- Host = "test.mosquitto.org",
				-- Port = 1883, 
                -- Topic = 'phonesensors',
				-- Freq = 20, 
				-- isEnabled = false ,  -- indicate the active broker in the list.  
				-- isDeletable = true,
				-- Connected = false,
                -- KeepAlive = 120, 
                -- Conntype = 'publish',  -- or subscribe
                -- Userid = '',
                -- Password = '

	    

	end	

	local function initVars ()
    
    
    if Glb.MQTTSession then 
        if Glb.MQTTSession.connected then 
            -- print ("sensors:  subscribe to topic  ",  M.Topic )
            Glb.MQTTSession:subscribe({M.TopicSub}) 
        end 
    end 
		
	-- M.title = display.newText( gameGroup, "M.sceneGroup.accel.xGravity", 200, 200, native.systemFont, 16 )
	-- M.title.anchorX = .5	; M.title.anchorY = .5
	-- M.title:setFillColor( unpack(theme.clr_text) )
		
	
	return
	end

	------------------
	-- Initiate variables
	------------------
	InitializeData()
	initVars()
return 
end 

local function sceneinfo ()

	local currScene = composer.getSceneName( "current" )
	local prevScene = composer.getSceneName( "previous" )
	local overlayScene = composer.getSceneName( "overlay" )
	
	print ("curr,prev,overlay", currScene, prevScene, overlayScene)	
	
return 
end 	
	
function scene:create( event )
	misc:sceneinfo("Create --")
	create_new(self,event)
	
end 	
	

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
  -- misc:printtableD(params, 2 )
	misc:sceneinfo("Show: will --")
	M.sceneGroup.runtimez:addall() 	 -- add runtime listeners
  elseif ( phase == "did" ) then
	misc:sceneinfo("Show: did  --")
    transition.to( M.sceneGroup , {time = 800 , delay = 0 , alpha = 1  } )
    system.setIdleTimer( false )
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
	misc:sceneinfo("Hide: will --")
     M.mqtt_unsubscribe()
  elseif ( phase == "did" ) then
	misc:sceneinfo("Hide: did  --")
	-- M.sceneGroup.timers:listem() 
	M.sceneGroup.timers:cancelall() 
	M.sceneGroup.runtimez:removeall()  -- remove runtime listeners 
    system.setIdleTimer( true )
  end
end

function scene:destroy( event )
	misc:sceneinfo("Destroy --")
	M = nil 
	
  
end	
	
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
	
