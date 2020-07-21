--====================================================================--
-- Main Broker scene
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2019
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - List add or edit a broker entry 
  - 
--]]

 
local Widget = require( "widget" )
local Json   = require ("json")
local GGData = require( "lib.GGData" )
local Glb = require ( "lib.glbldata"  )
local Spec  = require ( "scene.specifics.demodefinitions" )  -- style and page setup 
local BrokerEditList  = require ( "scene.brokers.broker_edit_list" )  -- tableview of parms
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
    
function M.fieldHandler( textField )
return function( event )
            local index , field = textField()
            -- print( index, field.text )
            local element 
            if (field.inputType == "number" ) then 
                element = tonumber(field.text)
            else element = field.text
            end 
            
            
            if ( "began" == event.phase ) then
                -- This is the "keyboard has appeared" event
                -- In some cases you may want to adjust the interface when the keyboard appears.
            
            elseif ( "ended" == event.phase ) then
                -- This event is called when the user stops editing a field: for example, when they touch a different field
                
            elseif ( "editing" == event.phase ) then  -- currently typing 
                print( element , "editted")
                timer.performWithDelay(6, function() Glb.broker_edit_entry[index] = element  end  )
            
            elseif ( "submitted" == event.phase ) then
                -- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
                print( element , "submitted  ---  field type ==  ",  field.inputType )
                
                timer.performWithDelay(6, function() Glb.broker_edit_entry[index] = element  end  )
                
                if Glb.environment == "device" then native.setKeyboardFocus( nil )  end       -- Hide keyboard
            end
        end  -- anonymous function
end  -- fieldHandler
	
	------------------
	-- Listeners
	------------------
  --  process events from touches
  --  To make the button class common code and not special for every button we are funneling all button pushes into this function. 
  --  This function will then check the buttonname to see what button was pressed.  
-- function M.onSceneEvent(event)
		-- local phase = event.phase
		-- local name = event.buttonName
		
		-- local t = event.target 
		-- if t then 
			-- local an = t.antecetant 
		-- end 	
		-- print ("UI event ", phase, name, t , an )
		-- if phase == "released" then
			-- -- audio.play(buttonSound)
			-- if name == "BrokerEdit" then
				-- print ("BrokerEdit was released" )
			-- elseif name == "help" then
				-- print ("helpbutton was pressed")
			-- elseif name == "back" then
				-- print ("broker edit backbutton was pressed")
            -- end  
        -- elseif phase == "pressed" then 
            -- if name == "BrokerEdit" then
				-- print ("BrokerEdit was pressed" )
			-- end
		-- end
-- return true	
-- end  


local create_new = function ( self, event )

	local theme = Glb.theme 
	
	M.sceneGroup = self.view -- add display objects to this group
	local gameGroup = display.newGroup()
    gameGroup.myname = "gameGroup"
    
    ----------------------------------------------
    --- Process input Options
    ----------------------------------------------
    
    M.input = {}  -- table to hold input options 
	M.input.calltype = event.params.calltype or "add"
	M.input.inputdata = event.params.inputdata or nil 
	M.input.parentstage = event.params.stage
	
	
	------------------------------
	-- Build the UI  
	------------------------------
	local UI = require( "lib.appUI" )
	local UI_inst = UI:newUI( { title="Broker Edit", stage = M.sceneGroup , leftButton = "back", rightButton = "save", rightMidButton="delete"} )
    M.sceneGroup.UI_inst = UI_inst
    -- local BRUI_inst = BrokerEditUI:newUI( { title="Broker Edit UI", stage = M.sceneGroup } )
    -- M.sceneGroup.BRUI_inst = BRUI_inst
	------------------------------
	-- CONFIGURE STAGE
	------------------------------
	M.sceneGroup:insert( UI_inst.backGroup )
	M.sceneGroup:insert( gameGroup )
	M.sceneGroup:insert( UI_inst.frontGroup )
	M.sceneGroup.timers = Timez:new()  -- add class to track timers
	M.sceneGroup.runtimez = RuntimeZ:new()  -- add class to track runtime listeners
    -- M.sceneGroup.runtimez:push({name="onSceneEvent", func=M.onSceneEvent})
    
    M.sceneGroup.fieldHandler = M.fieldHandler  -- needed by broker_edit_list
    
    
    
    
local function timebump (event)
	M.sceneGroup.timers:pop(event.source)
	
    
    
	M.sceneGroup.mqtt_client:publish("test", Json.encode(Glb.mqtt_pub)) 
	--print ("mqtt string", Json.prettify(Glb.mqtt_pub)) 
	
end 	
	
	
	
	--====================================================================--
	-- INITIALIZE
	--====================================================================--
	
	local InitializeData = function () -- grab data from disk if needed. 
    
        M.appstate = GGData:load("AppState") -- grab gamestate from disk
        print ("broker_edit:  InitializeData", Json.prettify(M.appstate.AppBrokers), M.appstate.AppBrokers) 
      if  M.input.calltype == "add"  then -- new entry 
         
         -- set defaults 
            for k,v in pairs (M.appstate.AppBrokerDefaults) do
                Glb.broker_edit_entry[k] = v 
                
                
            end 
        print ("moving data over", type (Glb.broker_edit_entry["Freq"]))    
        Glb.broker_edit_entry["Nick"] = "NickNameField"
      else  -- edit move values over from input data. 
        for k,v in pairs (M.input.inputdata) do
                Glb.broker_edit_entry[k] = v 
            end 
      end 
	-- print ("broker_edit:  InitializeData", Json.prettify(M.appstate.AppBrokers), M.appstate.AppBrokers,Glb.broker_edit_entry ) 
		
	    
	end	
    
    
	
	local function initVars ()
		
        
        ------------------------------
        -- Build the Sensor List 
        ------------------------------
        M.BEL_inst = BrokerEditList:new( { title="Brokers Entry", stage = M.sceneGroup } )
        gameGroup:insert( M.BEL_inst.tableView2 )
        gameGroup:insert( M.BEL_inst.spinner )
        
       
        -- NickNameLabel = display.newText(gameGroup, "Nick Name", 0, 0, native.systemFont, 18 )
        -- NickNameLabel:setFillColor(unpack(theme.clr_text))
        -- NickNameLabel.anchorX = 0
        -- NickNameLabel.anchorY = .5
        -- misc:position(NickNameLabel,5,20)
        
        -- local fieldWidth = display.contentWidth - 150
		-- if fieldWidth > 250 then
			-- fieldWidth = 250
		-- end

		-- NickNameField = native.newTextField(gameGroup, 130, NickNameLabel.y, 30 , 30 )
		-- NickNameField:addEventListener( "userInput", fieldHandler( function() return "Nick" ,NickNameField end ) ) 
		-- NickNameField.anchorX = NickNameLabel.anchorX
		-- NickNameField.anchorY = NickNameLabel.anchorY
		-- NickNameField.placeholder = Glb.broker_edit_entry["Nick"]
		-- NickNameField.isVisible = false
        
        -- misc:position(NickNameField,55,20)
		-- NickNameField.text = params.user.firstName
        

		
		
	
		
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
	misc:sceneinfo("Broker_Edit: Create --")
    -- print ("parms:", Json.prettify(event))
	create_new(self,event)
	
end 	
	

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
  
  
	misc:sceneinfo("Broker_edit: Show: will --")
	M.sceneGroup.runtimez:addall() 	 -- add runtime listeners
    -- Runtime:addEventListener( "onUIevent", M.onUIevent)
  elseif ( phase == "did" ) then
	misc:sceneinfo("Show: did  --")
    transition.to( M.sceneGroup , {time = 800 , delay = 0 , alpha = 1  } )  -- just in case the screen is dimmed.
    -- NickNameField.isVisible = true
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
	misc:sceneinfo("Broker_edit: Hide: will --")
    misc:destroy_all_from_table(M.BEL_inst.textFields)
    -- NickNameField:removeSelf()
    -- NickNameField = nil
  elseif ( phase == "did" ) then
	misc:sceneinfo("Broker_edit: Hide: did  --")

	 transition.cancel()  	-- Cancel all transitions 
	M.sceneGroup.timers:cancelall() 
	M.sceneGroup.runtimez:removeall()  -- remove runtime listeners 
  end
end

function scene:destroy( event )
	misc:sceneinfo("Broker_edit: Destroy --")
    -- Runtime:removeEventListener( "onUIevent", M.onUIevent)
    M.sceneGroup.runtimez:removeall()  -- remove runtime listeners 
	M = nil 
	
  
end	
	
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
	
