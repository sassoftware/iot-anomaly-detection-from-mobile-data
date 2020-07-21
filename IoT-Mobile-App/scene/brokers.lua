--====================================================================--
-- Main Broker scene
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - List defined mqtt brokers
  - 
--]]

 
local Widget = require( "widget" )
local Json   = require ("json")
local GGData = require( "lib.GGData" )
local Glb = require ( "lib.glbldata"  )
local Spec  = require ( "scene.specifics.demodefinitions" )  -- style and page setup 
local BrokerList  = require ( "scene.brokers.brokerlist" )  -- builds tableview of brokers 
local Buttons = require ("lib.UIbutton")
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
function  M.hideOverlay()
        local overlayScene = composer.getSceneName( "overlay" )
        if ( overlayScene ) then 
            -- print ("if overlay", overlayScene )
            composer.hideOverlay("fade", 500 )
        end
        if M.BL_inst then M.BL_inst:reloadrows() end   -- reload list of brokers 
return 
end 

local function disable_other_entries (e , t )
    local key = "isEnabled" 
    local value = false 
    local t = t
    local e = e
	local tableCount = #t
			if tableCount > 0 then
				for i = tableCount, 1, -1 do
                    if i ~= e  then 
                        t[i][key] = value
                    end     
                end
			end
return 
end 

function M.InitTimers ()
    
        M.sceneGroup.timers:push({name = "test", timer = timer.performWithDelay(2000, M.timebump , -1)} , -1 )
    return 
    end 
    
function M.InitializeData () -- grab data from disk if needed. 
	
		M.appstate = GGData:load("AppState") 
        -- print ("M.appstate:", Json.prettify(M.appstate))
        
	    
end
	
function M.initVars ()
        
        ------------------------------
        -- Build the Sensor List 
        ------------------------------
        M.BL_inst = BrokerList:new( { title="Brokers", stage = M.sceneGroup } )
        M.sceneGroup.BL_inst = M.BL_inst
        
        M.sceneGroup.gameGroup:insert( M.BL_inst.tableView2 )
        M.sceneGroup.gameGroup:insert( M.BL_inst.spinner )
        
        ------------------------------
        -- Edit new button 
        ------------------------------
        M.addBrokerButton = Buttons:new({buttonName = "BrokerEdit"})
        M.addBrokerButton:loadimages( M.sceneGroup.UI_inst.frontGroup, "pictures/plusdblue.png" , "pictures/pluslblue.png", "pictures/pluslblue.png" , "pictures/plusdblue.png" ,  50 , 50 )  --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
        M.addBrokerButton:positions(85,90)
        M.addBrokerButton:addlistener()   -- add touch listener.
        
        
        

end

	------------------
	-- Listeners
	------------------
  --  process events from touches
  --  To make the button class common code and not special for every button we are funneling all button pushes into this function. 
  --  The functions will then check the button name to see what button was pressed.  
function M.onUIevent(event)
		local phase = event.phase
		local name = event.buttonName
		local t = event.target 
        local an = nil 
		if t then an = t.antecetant end
        local prevScene = composer.getSceneName( "previous" )  
        local currScene = composer.getSceneName( "current" )
        local overlayScene = composer.getSceneName( "overlay" )
		print ("Broker UI event ", phase, name, currScene,prevScene,overlayScene)
		M.appstate = GGData:load("AppState") 
		if phase == "released" then
			-- audio.play(buttonSound)
			if name == "BrokerEdit" then  -- create a new broker entry 
				print ("brokers:  Brokeradd" )
                local options = {
                        effect = "fromRight",
                        isModal = true,  -- disable main panel touches 
                        time = 500,
                            params = {
                                stage = M.sceneGroup,
                                inputdata = nil,
                                calltype = "add"
                                }
                            }
                composer.showOverlay( "scene.broker_edit" , options ) -- Go to Intro screen
            elseif name == "brokercheckbox" then  -- save data to data store
            local found = Misc:table_find_by_key("Nick", t.brokerNick , M.appstate.AppBrokers )
            
				-- print ("brokers: brokercheckbox",t.brokerNick , "enabled? --> ",t.isEnabled, M.appstate.AppBrokers )
                if t.isEnabled then 
                    -- make active broker 
                    if found then 
                        M.appstate.AppBrokers[found]["isEnabled"] = true 
                        disable_other_entries(found,M.appstate.AppBrokers)
                    else
                        M.appstate.AppBrokers[1]["isEnabled"] = true 
                        print ("ERROR:  broker not found when it should be there")
                    end 
                else -- disabled case  make sample active 
                    M.appstate.AppBrokers[found]["isEnabled"] = false
                    local found2 = Misc:table_find_by_key("Nick","sample",M.appstate.AppBrokers)
                    M.appstate.AppBrokers[found2]["isEnabled"] = true 
                end
                M.appstate:save()  -- write newly created data to disk    
                M.BL_inst:reloadrows()  -- reload list of brokers 
                -- print ("M.appstate:", Json.prettify(M.appstate))
            elseif name == "saveButton" then  -- save data to data store
				print ("brokers: savebutton",Glb.broker_edit_entry)
                print ("Nick",Glb.broker_edit_entry["Nick"],M.appstate.AppBrokers,Glb.broker_edit_entry)
                if Glb.broker_edit_entry["isDeletable"]  then
                    -- new nick?  
                    local isExisting = Misc:table_update_by_key("Nick",Glb.broker_edit_entry["Nick"],M.appstate.AppBrokers,Glb.broker_edit_entry)
                    if not isExisting then --  new entry case 
                        -- new entry should always be not Connected and Not the active broker entry 
                        M.appstate.AppBrokers[1]["Connected"] = false 
                        M.appstate.AppBrokers[1]["isEnabled"] = false 
                    end 
                    M.appstate:save()  -- write newly created data to disk
                end     
            elseif name == "deleteButton" then  -- delete broker entry
				print ("brokers:  deletebutton")
                if Glb.broker_edit_entry["isDeletable"] then   
                    local found = Misc:table_find_by_key("Nick",Glb.broker_edit_entry["Nick"],M.appstate.AppBrokers)
                    if found then 
                        if M.appstate.AppBrokers[found]["isEnabled"] == true then  -- is it the active one? 
                            local found2 = Misc:table_find_by_key("Nick","sample",M.appstate.AppBrokers)  -- make sample active if other active one deleted. 
                            if found2 then 
                                 M.appstate.AppBrokers[found2]["isEnabled"] = true 
                            else 
                                print ("ERROR:  sample broker not found when it should be there")
                                M.appstate.AppBrokers[1]["isEnabled"] = true 
                            end 
                        end 
                    end 
                    Misc:table_delete_by_key("Nick",Glb.broker_edit_entry["Nick"],M.appstate.AppBrokers)
                    M.appstate:set("AppBrokers", M.appstate.AppBrokers)
                    M.appstate:save()  -- write newly created data to disk
                    M.hideOverlay()  -- go back to prev scene if there is one. 
                    -- M.BL_inst:reloadrows()  -- reload list of brokers 
                end 
                -- print ("broker_edit_entry:", Json.prettify(Glb.broker_edit_entry))
            elseif name == "tableView" then  -- edit broker entry
				print ("brokers: Broker edit tableView")
                -- print ("parms:", Json.prettify(t))
                -- if t.isDeletable then  -- don't edit default entry 
                    local options = {
                            effect = "fromRight",
                            isModal = true,  -- disable main panel touches 
                            time = 500,
                                params = {
                                    stage = M.sceneGroup,
                                    inputdata = t,
                                    calltype = "edit"
                                    }
                                }
                    composer.showOverlay( "scene.broker_edit" , options ) -- Go to Intro screen            
                -- end     
			elseif name == "help" then  -- This is handled by listeners in AppUI because of sample code. 
				print ("helpbutton was released")
			elseif name == "back" then
				print ("brokers: backbutton was released")
                    M.hideOverlay()  -- go back to prev scene if there is one. 
                    -- M.BL_inst:reloadrows()  -- reload list of brokers 
            end  
        elseif phase == "pressed" then 
            
		end
     -- print ("Brokers:  M.appstate.AppBrokers:", Json.prettify(M.appstate.AppBrokers))   
return true	
end  


--  timer loop 
function M.timebump (event)
	M.sceneGroup.timers:pop(event.source)
    
    -- need to add something in here that issues the connection info for the broker we are sending to 
            
    --  find active broker 
        local isactiveBroker = Misc:table_find_by_key("isEnabled", true , M.appstate.AppBrokers )
        if isactiveBroker then  --  active broker found
            M.Host = M.appstate.AppBrokers[isactiveBroker]["Host"]
            M.Port = tonumber(M.appstate.AppBrokers[isactiveBroker]["Port"])
            M.KeepAlive = tonumber(M.appstate.AppBrokers[isactiveBroker]["KeepAlive"])
            M.Topic = M.appstate.AppBrokers[isactiveBroker]["Topic"]
            M.Freq = tonumber(M.appstate.AppBrokers[isactiveBroker]["Freq"])
            --  is active broker connected?        
            if M.appstate.AppBrokers[isactiveBroker]["Connected"] == false  then  -- not connected
            --  is there another active broker that needs disconnected?
                local isConnectedBroker = Misc:table_find_by_key("Connected", true , M.appstate.AppBrokers )
                if isConnectedBroker then -- need to disconnect this one. 
                    if Glb.MQTTSession then Glb.MQTTSession:destroy()  end 
                    Glb.MQTTSession = nil 
                    M.appstate.AppBrokers[isConnectedBroker]["Connected"] = false 
                    M.appstate:save()  -- write newly created data to disk
                end
            --  try and connect  
                Glb.MQTTSession = MQTT.client.create(M.Host, M.Port )
                Glb.MQTTSession.KEEP_ALIVE_TIME = M.KeepAlive
                local isConnected = Glb.MQTTSession:connect(system.getInfo( "deviceID" ))
                if isConnected == nil  then   -- success!
                    -- 
                    M.appstate.AppBrokers[isactiveBroker]["Connected"] = true 
                    M.appstate:save()  -- write newly created data to disk
                    M.BL_inst:reloadrows()  -- reload list of brokers  -- reload broker list to pick up new colors. 
                else 
                    Glb.MQTTSession = nil 
                end 
            else -- active and connected but are we really? 
                if Glb.MQTTSession then 
                    local error_message = Glb.MQTTSession:publish("nonsense", "Are we really connected")
                    if error_message ~= nil then 
                        print ("eerror:  broker not connected ")-- print error message 
                        Glb.MQTTSession = nil 
                        M.appstate.AppBrokers[isactiveBroker]["Connected"] = false
                        M.appstate:save()  -- write newly created data to disk
                    end     
                else M.appstate.AppBrokers[isactiveBroker]["Connected"] = false  -- if we have no session info we must not be connected     
                     M.appstate:save()  -- write newly created data to disk
                end 
                
            end 
        end 
    
    
    
    --  if not connected 
    
    
    
    -- Glb.MQTTSession = MQTT.client.create(M.Host, M.Port, mqtt_sub_callback)
            -- Glb.MQTTSession = MQTT.client.create(M.Host, M.Port )
            -- Glb.MQTTSession:connect(system.getInfo( "deviceID" ))
            -- Glb.MQTTSession.KEEP_ALIVE_TIME = M.KeepAlive
    --  if success then indicate connected in broker list.
   
    
    
	-- M.sceneGroup.mqtt_client:publish("test", Json.encode(Glb.mqtt_pub)) 
	--print ("mqtt string", Json.prettify(Glb.mqtt_pub)) 
	
end 	

local create_new = function ( self, event )

	
	M.sceneGroup = self.view -- add display objects to this group
	M.sceneGroup.gameGroup = display.newGroup()
    M.sceneGroup.gameGroup.myname = "gameGroup"
	
	
	------------------------------
	-- Build the UI  
	------------------------------
	local UI = require( "lib.appUI" )
	M.sceneGroup.UI_inst = UI:newUI( { title="Brokers", stage = M.sceneGroup , navitem = 3 } )
	------------------------------
	-- CONFIGURE STAGE
	------------------------------
	M.sceneGroup:insert( M.sceneGroup.UI_inst.backGroup )
	M.sceneGroup:insert( M.sceneGroup.gameGroup )
	M.sceneGroup:insert( M.sceneGroup.UI_inst.frontGroup )	
	M.sceneGroup.timers = Timez:new()  -- add class to track timers
	M.sceneGroup.runtimez = RuntimeZ:new()  -- add class to track runtime listeners
    M.sceneGroup.timers = Timez:new()  -- add class to track timers
    M.sceneGroup.runtimez:push({name="onUIevent", func=M.onUIevent})
    
	
	--====================================================================--
	-- INITIALIZE
	--====================================================================--
    
    
	M.InitializeData()
    M.InitTimers()
	M.initVars()
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
	misc:sceneinfo("Brokers:  Show: will --")
	M.sceneGroup.runtimez:addall() 	 -- add runtime listeners
    M.BL_inst:reloadrows()

    -- Runtime:addEventListener( "onUIevent", M.onUIevent)
  elseif ( phase == "did" ) then
	misc:sceneinfo("Show: did  --")
    transition.to( M.sceneGroup , {time = 800 , delay = 0 , alpha = 1  } )  -- just in case the screen is dimmed.
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
	misc:sceneinfo("Brokers: Hide: will --")
    -- Runtime:removeEventListener( "onUIevent", M.onUIevent)
  elseif ( phase == "did" ) then
	misc:sceneinfo("Brokers:  Hide: did  --")
	-- M.sceneGroup.timers:listem() 
	-- Cancel all transitions 
	 transition.cancel()
	M.sceneGroup.timers:cancelall() 
	M.sceneGroup.runtimez:removeall()  -- remove runtime listeners 
  end
end

function scene:destroy( event )
	misc:sceneinfo("Destroy --")
    -- Runtime:removeEventListener( "onUIevent", M.onUIevent)
    M.sceneGroup.runtimez:removeall()  -- remove runtime listeners 
	M = nil 
	
  
end	
	
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
	
