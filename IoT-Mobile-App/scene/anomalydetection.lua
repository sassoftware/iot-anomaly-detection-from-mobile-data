--====================================================================--
-- template for creating new scenes
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2020
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - template to show how to create a new scene to send and receive data to MQTT topics
  - This intent here is this template would be copied in order to create a new scene in the mobile application.
  
  -  To enable new scenes in the application simply edit the demodefinitions.lua file in the specifics directory 
  -  In the demodefinitions file add a new entry to the M.hamburger table which defines a new Nav item. 
  -  To support the new navigation scene create a new directory under the ../scene/ directory with the same name as the newly created module. 
  -  In that directly place any new modules that are called via this scene.  
  -  Common code is placed in the ./lib directory
  
--]]

 
local Widget = require( "widget" )
local Buttons = require ("lib.UIbutton")
local Json   = require ("json")
local GGData = require( "lib.GGData" )
local Glb = require ( "lib.glbldata"  )
local Accel = require ( "lib.accelerate" )
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

function M.initVars ()
    
    
    if Glb.MQTTSession then 
        if Glb.MQTTSession.connected then 
            -- print ("template:  subscribe to topic  ",  M.Topic )
            Glb.MQTTSession:subscribe({M.TopicSub} , M.mqtt_subCallback )
        end 
    end 
    --  
    M.Indicator = Buttons:new({buttonName = "IndicatorLight" , SupportRollover = "no" })
                        --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
                        
    M.Indicator:loadRectFromColors( M.sceneGroup.UI_inst.gameGroup, rgb.sasgreen ,rgb.sasyellow , rgb.sasred , rgb.sasgrey ,  Glb.bodyW * .8 , Glb.bodyH * .33 , 2 ) 
    M.Indicator.buttonGroup.anchorX = .5   --  newRect only supports .5 
    M.Indicator.buttonGroup.anchorY = .5
    M.Indicator:setPosition(M.Indicator.buttonGroup,50,0)
    M.Indicator.buttonGroup.y = M.Indicator.buttonGroup.y + Glb.bodycontenttop + (M.Indicator.buttonGroup.height / 2 )  -- add the offset for the UI
    M.Indicator:begin_inactive()
    
    M.title = display.newText( M.sceneGroup.UI_inst.gameGroup, "Calculating...", 200, 200, native.systemFont, 22 )
    Misc:setPosition( M.title ,60 , 80, M.Indicator.buttonGroup )  -- place text in button
	M.title.anchorX = .5	; M.title.anchorY = .5
	M.title:setFillColor( unpack(Glb.theme.clr_text) )
    
    M.summary = display.newText( M.sceneGroup.UI_inst.gameGroup, "Gravity Averages:", 200, 200, native.systemFont, 16 )
    Misc:setPosition( M.summary ,7 , 50 )  -- place text on screen
	M.summary.anchorX = 0	; M.summary.anchorY = .5
	M.summary:setFillColor( unpack(Glb.theme.clr_subtitle) )
    
    M.summary_values = display.newText( M.sceneGroup.UI_inst.gameGroup, "working...", 200, 200, native.systemFont, 16 )
    Misc:setPosition( M.summary_values ,7 , 55 )  -- place text on screen
	M.summary_values.anchorX = 0	; M.summary_values.anchorY = .5
	M.summary_values:setFillColor( unpack(Glb.theme.clr_text) )
		
    M.kmeans = display.newText( M.sceneGroup.UI_inst.gameGroup, "Kmeans Minumum Distance:", 200, 200, native.systemFont, 16 )
    Misc:setPosition( M.kmeans ,7 , 60 )  -- place text on screen
	M.kmeans.anchorX = 0    ; M.kmeans.anchorY = .5
	M.kmeans:setFillColor( unpack(Glb.theme.clr_subtitle) )
    
    M.kmeans_values = display.newText( M.sceneGroup.UI_inst.gameGroup, "working...", 200, 200, native.systemFont, 16 )
    Misc:setPosition( M.kmeans_values ,7 , 65 )  -- place text on screen
	M.kmeans_values.anchorX = 0	; M.kmeans_values.anchorY = .5
	M.kmeans_values:setFillColor( unpack(Glb.theme.clr_text) )
    
    M.sst = display.newText( M.sceneGroup.UI_inst.gameGroup, "SubSpace Tracking:", 200, 200, native.systemFont, 16 )
    Misc:setPosition( M.sst ,7 , 70 )  -- place text on screen
	M.sst.anchorX = 0; M.sst.anchorY = .5
	M.sst:setFillColor( unpack(Glb.theme.clr_subtitle) )
    
    M.sst_values = display.newText( M.sceneGroup.UI_inst.gameGroup, "working...", 200, 200, native.systemFont, 16 )
    Misc:setPosition( M.sst_values ,7 , 75 )  -- place text on screen
	M.sst_values.anchorX = 0	; M.sst_values.anchorY = .5
	M.sst_values:setFillColor( unpack(Glb.theme.clr_text) )
	
	return
	end


function M.InitializeData() -- grab data from disk if needed. 
    
    
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

-- func called when mqtt messages are received from the subscribed topics. 

function M.mqtt_subCallback(topic,payload)
            print( "AnomalyDetect:  M.mqtt_subCallback:")
    local decoded, pos, msg = Json.decode( payload )
    if not decoded then
        print( "AnomalyDetect:  M.mqtt_subCallback:  Decode failed at "..tostring(pos)..": "..tostring(msg) )
    else
        
        local table1 = decoded[1]
        local table2 = table1[1]
        -- only process messages for me. 
        if table2["deviceID"] == Glb.deviceID then 
            -- print("mqtt_subCallback:  payload", table2["deviceID"])
            -- misc:printtableD(table2)
            local xGavg =  string.format( "%1.3f", table2.xGravityAverage )
            local yGavg =  string.format( "%1.3f", table2.yGravityAverage )
            local zGavg =  string.format( "%1.3f", table2.zGravityAverage )
            local kmeans =  string.format( "%1.3f", table2.min_dist )
            local sst =  string.format( "%1.3f", table2.residualOut )
            
            M.summary_values.text = "X: " .. xGavg .. "  Y: " .. yGavg .. "  Z: " .. zGavg
            M.kmeans_values.text = kmeans
            M.sst_values.text = sst  -- sub space tracking 
            
            -- use kmeans to determine error status 
            
            if  table2.residualOut > .5 then 
                M.Indicator:begin_clicked()
                M.title.text = "Danger" 
            elseif  table2.residualOut > .2 then 
                M.Indicator:begin_rollover()
                M.title.text = "Warning" 
            elseif  table2.residualOut < .1 then 
                M.Indicator:begin_main()
                M.title.text = "Good"     
            end     
                
        end 
        
        
        -- here you may add logic to process incoming message
        
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

-- called by timer event 
function M.timebump (event)  -- currently 10 times per second. 
	M.sceneGroup.timers:pop(event.source)
    
    M.currenttime100 = M.currenttime100 + 1 
    ----------------------------------------------
    --  things to do every 100 milliseconds     
    ----------------------------------------------
    Glb.mqtt_pub.deviceID = Glb.deviceID
    Glb.mqtt_pub.timestamp = M.currenttime100
    
    
    if M.sceneGroup.accel.isActive then 
        Glb.mqtt_pub.isShake =  M.sceneGroup.accel.data.isShake
        Glb.mqtt_pub.x_acc  =   M.sceneGroup.accel.data.xGravity
        Glb.mqtt_pub.y_acc  =	M.sceneGroup.accel.data.yGravity
        Glb.mqtt_pub.z_acc  =	M.sceneGroup.accel.data.zGravity
        Glb.mqtt_pub.x_gyro =   M.sceneGroup.accel.data.xInstant 
        Glb.mqtt_pub.y_gyro =	M.sceneGroup.accel.data.yInstant
        Glb.mqtt_pub.z_gyro =	M.sceneGroup.accel.data.zInstant
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
            
            M.mqtt_handler()  --  called to dequeue socket messages
    end 

    
return 
end 

-- This func is called with the scene if first loaded by composer. 
	
local create_new = function ( self, event )

	local currenttheme = Spec.themes.defaulttheme
	Glb.theme = Spec:loadtheme(currenttheme)
	local theme = Glb.theme 
	
	M.sceneGroup = self.view -- add display objects to this group
	
	------------------------------
	-- Build the UI  
	------------------------------
	local UI = require( "lib.appUI" )
	M.sceneGroup.UI_inst = UI:newUI( { title="Anomaly Detection", stage = M.sceneGroup , navitem = 5 } )
	------------------------------
	-- CONFIGURE STAGE
	------------------------------
	M.sceneGroup:insert( M.sceneGroup.UI_inst.backGroup )  --  static background 
	M.sceneGroup:insert( M.sceneGroup.UI_inst.gameGroup )  --  items that make up appication 
	M.sceneGroup:insert( M.sceneGroup.UI_inst.frontGroup)  -- control buttons that lay over application
	M.sceneGroup.timers = Timez:new()  -- add class to track timers
	M.sceneGroup.runtimez = RuntimeZ:new()  -- add class to track runtime listeners
	M.sceneGroup.accel = Accel:new( {stage = M.sceneGroup} )  -- grab accerometer data  
	M.sceneGroup.location = Location:new( {stage = M.sceneGroup} )  -- grab location data  
    
	
	M.sceneGroup.timers:push({name = "endless100", timer = timer.performWithDelay(100, M.timebump , -1)} , -1 )

	------------------
	-- Initiate variables
	------------------
	M.InitializeData()
	M.initVars()
return 
end 

--  composer event when scene first initialized 
	
function scene:create( event )
	misc:sceneinfo("Create --")
	create_new(self,event)
	
end 	
	
--  composer event when scene is shown
function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
  -- misc:printtableD(params, 2 )
	misc:sceneinfo("Show: will --")
	M.sceneGroup.runtimez:addall() 	 -- add runtime listeners
  elseif ( phase == "did" ) then
	misc:sceneinfo("Show: did  --")
    transition.to( M.sceneGroup , {time = 800 , delay = 0 , alpha = 1  } )
    system.setIdleTimer( false )  -- disable phone sleep mode because data will stop flowing to MQTT in that case
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

--  composer event when scene is hidden.  
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
    system.setIdleTimer( true )  -- allow screen to dim and phone to sleep 
  end
end

--  composer event when scene is deleted
function scene:destroy( event )
	misc:sceneinfo("Destroy --")
	M = nil 
	
  
end	
	
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
	
