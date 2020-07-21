--====================================================================--
-- Main Intro Page
-- Provide logins for personas
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - Main launching point for application
  - 
--]]

 
local Widget = require( "widget" )
local GGData = require( "lib.GGData" )
local Glb = require ( "lib.glbldata"  )
local Spec  = require ( "scene.specifics.demodefinitions" )  -- style and page setup 
local rgb = require ( "lib._rgb" )   -- colors 
local Timez  = require("lib.Timez")  -- since timers aren't attached to objects we need to track them.  
local RuntimeZ  = require("lib.runtimez")  -- we need a way to clear all runtime listeners on scene exit 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 



local composer = require "composer"   -- scene scheduler 
local Json = require( "json" )


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
	
	
	
	------------------
	-- Listeners
	------------------
    
  --  process events from touches
  --  To make the button class common code and not special for every button we are funneling all button pushes into this function. 
  --  This function will then check the buttonname to see what button was pressed.  
local  function onUIevent(event)
		local phase = event.phase
		local name = event.buttonName
		
		local t = event.target 
		if t then 
			local an = t.antecetant 
		end 	
		print ("UI event ", phase, name, t , an )
		if phase == "released" then
			-- audio.play(buttonSound)
			if name == "playbutton" then
				print ("playbutton was pressed" )
			elseif name == "help" then
				print ("helpbutton was pressed")
			elseif name == "back" then
				print ("backbutton was pressed")
			end
		end
return true	
end  
Glb.isBusy = false 
local function onKeyEvent( event )
		print ("Intro: onKeyEvent  event.keyName = ", event.keyName , event.phase , Glb.isBusy )
			if ( event.keyName == "back" ) then
				if event.phase == "up" and not Glb.isBusy then   -- released back key 
                    Glb.isBusy  = true 
                    
                    local prevScene = composer.getSceneName( "previous" )
                    local currScene = composer.getSceneName( "current" )
                    local overlayScene = composer.getSceneName( "overlay" )
                    if ( overlayScene ) then 
                        print ("Overlay onKeyEvent")
                        local options = {
                                effect = "fade",
                                time = 500,
                                    params = {
                                        someKey = "someValue",
                                        someOtherKey = 10
                                        }
                                    }
                        composer.hideOverlay("fade", 500 )
                        composer.gotoScene( currScene , options ) -- Go to current screen
                        
                    elseif (prevScene and currScene ~= "scene.intro" ) then 
                        local options = {
                                effect = "fade",
                                time = 500,
                                    params = {
                                        someKey = "someValue",
                                        someOtherKey = 10
                                        }
                                    }
                        composer.gotoScene( prevScene , options ) -- Go to Intro screen
                    end 
                timer.performWithDelay(600, function() Glb.isBusy  = false  end  )  -- we get lots of up in a row.  
                    -- local uiEvent = {name = "onUIevent", phase = "released", buttonName = "back" , target = nil }
                    -- Runtime:dispatchEvent(uiEvent)
				end 
				return true   -- true indicates to android that the app is taking over back function 
			end
	return false
end

	
	
local create_new = function ( self, event )

	local currenttheme = Spec.themes.defaulttheme
	Glb.theme = Spec:loadtheme(currenttheme)
	local theme = Glb.theme 
	Glb.navactive = Spec.defaultnavitem
	Glb.nav = Spec:loadnav(Glb.navactive)
	Glb.hamburger = Spec.hamburger
	
	
	M.sceneGroup = self.view -- add display objects to this group
	local gameGroup = display.newGroup()
	
	
------------------------------
-- Build the UI  
------------------------------
local UI = require( "lib.appUI" )
local UI_inst = UI:newUI( { title="Home", stage = M.sceneGroup } )

------------------------------
-- CONFIGURE STAGE
------------------------------
M.sceneGroup:insert( UI_inst.backGroup )
M.sceneGroup:insert( gameGroup )
M.sceneGroup:insert( UI_inst.frontGroup )	
M.sceneGroup.timers = Timez:new()  -- add class to track timers
M.sceneGroup.runtimez = RuntimeZ:new()  -- add class to track runtime listeners

local function timebump (event)
	M.sceneGroup.timers:pop(event.source)
end 	
	
M.sceneGroup.timers:push({name = "test", timer = timer.performWithDelay(2100, timebump , -1)} , -1 )	
	
	

	
	local function initVars ()
		
		
		
	local function networktest ()	
		------------------
		-- Network test
		------------------
		local json = require( "json" )
		
		local function networkListener( event )

			if ( event.isError ) then
				print( "Network error: ", event.response )
			else
				print ( "RESPONSE: " .. event.response )
				local decoded, pos, msg = json.decode( event.response, 2 )
				if not decoded then
					print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
				else
					print( decoded.message ) 
				end
			end
		end	

		local headers = {}

		headers["Content-Type"] = "application/xml" 
		headers["Accept-Language"] = "en-US"
		headers["Accept"] = "application/json"

		--  local body = '{"opcode":"i","timestamp":"888","readablename":"phone test 1","macaddress":"555","s1":"444"}'
		local body = '<events><event><opcode>i</opcode><timestamp>888</timestamp><readablename>phone test 1</readablename><macaddress>555</macaddress><s1>444</s1></event></events>'
		-- body[]
		print ("-------------->",body )

		local params = {}
		params.headers = headers
		params.body = body

		-- local requestID = network.request( "http://api.wunderground.com/api/3089ed8c6e32c679/conditions/q/CA/San_Francisco.json", "GET", networkListener, params )
		-- local requestID = network.request( "http://eeclxvm151.unx.sas.com:46100/SASESP/projects", "GET", networkListener, params )
		local requestID = network.request( "http://eeclxvm151.unx.sas.com:46100/SASESP/windows/simplesource/cq1/httpinput/state?value=injected", "PUT", networkListener, params )
	return 	
	end 	
		------------------
		-- Inserts
		------------------
		
	local body_width = display.contentWidth 
	local body_height = display.actualContentHeight - Glb.bodycontenttop
	
	
	local headerfl = display.newImageRect( gameGroup, "pictures/socialShareImage.jpg" , body_height * 2.0325 ,  body_height )
	headerfl.anchorX = .5 ; 	headerfl.anchorY = 0
	headerfl.y, headerfl.x = Glb.bodycontenttop , display.contentCenterX 

	local headerText = display.newText( gameGroup, "SAS Analytics for IoT", display.contentCenterX  , (180+ display.safeScreenOriginY)  * .62, useFont, 18 )
	headerText.anchorX = .5 ; 	headerText.anchorY = 0
	headerText:setFillColor( unpack(theme.clr_title) )
    
    -- Make AIoT title clickable
	
	if system.canOpenURL( "https://www.sas.com/en_us/software/analytics-iot.html" ) then
		headerText:addEventListener( "touch",
			function( event )
				if event.phase == "began" then
					system.openURL( "https://www.sas.com/en_us/software/analytics-iot.html" )
				end
				return true
			end )
	end
		
		
		
	
		
	end

	------------------
	-- Initiate variables
	------------------
	-- InitializeData()
	initVars()
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
	misc:sceneinfo("Intro: Show: will --")
	M.sceneGroup.runtimez:addall() 	 -- add runtime listeners
    if Glb.iskeyCapable  then Runtime:addEventListener( "key", onKeyEvent )  end   -- leave this running for every scene. 
  elseif ( phase == "did" ) then
    transition.to( M.sceneGroup , {time = 1000 , delay = 0 , alpha = 1  } )
	misc:sceneinfo("Intro:  Show: did  --")
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
	misc:sceneinfo("Intro:  Hide: will --")
	transition.cancel()	  -- Cancel all transitions 
  elseif ( phase == "did" ) then
	misc:sceneinfo("Intro: Hide: did  --")
	-- M.sceneGroup.timers:listem() 
	M.sceneGroup.timers:cancelall() 
	M.sceneGroup.runtimez:removeall()  -- remove runtime listeners 
  end
end

function scene:destroy( event )
	misc:sceneinfo("Intro:  Destroy --")
	M = nil 
	
  
end	
	
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
	
