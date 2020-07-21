--====================================================================--
-- Standard UI Nav items every scene needs 
--====================================================================--
--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

    Set common Nav items: 
	  -  menu bar 
	  -  control display group
	  -  background diplay group 
	  -  hamburger 
	  -  swipping gesters handlers 
	  -  help button 
      -  support various buttons on top of menu
  
--]]

local widget = require( "widget" )
local composer = require( "composer" )
local rgb = require ( "lib._rgb" )
local Glb = require ( "lib.glbldata"  )
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 
local Ham   = require ( "scene.hamburger" )
local Buttons = require ("lib.UIbutton")
local Spec  = require ( "scene.specifics.demodefinitions" )  -- style and page setup 

local M = {}
local M_mt = { __index = M }



local infoShowing = false

function M:newUI( options )
    -- define new module 
	local self = {}
    setmetatable( self, M_mt )  --  new object inherits from M
    self.myclass = "UI"
    self.buttontbl = {}   --  table of active buttons in the UI.  I don't see where this is used. 
    ----------------------------------------------
    --- Variables
    ----------------------------------------------
    local scrollBounds
	local infoBoxState = "canOpen"
	local transComplete
	local theme = Glb.theme   -- colors of things
	local hamburger = Glb.hamburger   -- list of items for nav hamburger
    local navButton
    local leftButton
    local rightButton
    local rightMidButton
    
    
    -- Create table for initial object positions
	local objPos = { infoBoxOffY=0, infoBoxDestY=0 }
    
    ----------------------------------------------
    --- Process Options
    ----------------------------------------------
    self.sceneGroup = options.stage
    local input = {}  -- table to hold input options 
	input.sampleCodeTitle = options.title or "SAS IoT"
	input.Titlelocation = options.titlelocation or 50
	input.stageDG = options.stage  -- 
    input.rightButton=options.rightButton or "info"
    input.rightMidButton=options.rightMidButton or nil -- this button isn't always there. 
    input.leftButton=options.leftButton or "hamburger"
    input.navindex = options.navitem or 1 
    
    -- for sub menus there may be no nav item 
    local nav   = Spec:loadnav(input.navindex)  -- active nav element

	----------------------------------------------
    --- Display groups for scene
    --- background group, foreground group, 
    --- container for UI nav bar at top of screen 
    --- container for text info screen drop down 
    ----------------------------------------------
    local backGroup = display.newGroup()
    self.gameGroup = display.newGroup()
    self.gameGroup.myname = "gameGroup"
	local frontGroup = display.newGroup()
	local textGroupContainer = display.newContainer( 288, 240 ) ; frontGroup:insert( textGroupContainer )
	local barContainer = display.newContainer( display.actualContentWidth, 40 )
    self.barContainer = barContainer
	frontGroup:insert( barContainer )
	barContainer.anchorX = 0
	barContainer.anchorY = 0
	barContainer.anchorChildren = false
	barContainer.x = display.safeScreenOriginX
	barContainer.y = display.safeScreenOriginY
    
    Glb.bodycontenttop = barContainer.y + barContainer.contentHeight
    Glb.bodyW = display.actualContentWidth
    Glb.bodyH = display.actualContentHeight - Glb.bodycontenttop

	
	-- Read from the ReadMe.txt file
	local readMeText = "Create info.txt file in scene.xxxx to fill in this box."
	
	local readMeFilePath = system.pathForFile( nav.infotext, system.ResourceDirectory )
	if readMeFilePath then
		local readMeFile = io.open( readMeFilePath )
		local rt = readMeFile:read( "*a" )
		if string.len( rt ) > 0 then readMeText = rt end
		io.close( readMeFile ) ; readMeFile = nil ; rt = nil
	end

	-- Create background image by theme value
	local background = display.newRect( backGroup, 0,0, display.actualContentWidth, display.actualContentHeight )
	background.x, background.y = display.contentCenterX, display.contentCenterY
	background:setFillColor(unpack(theme.clr_background)  )

	local topBarOver = display.newRect( barContainer, 0, 0, barContainer.contentWidth, barContainer.contentHeight - 2 )
	topBarOver.anchorX = 0
	topBarOver.anchorY = 0
	topBarOver:setFillColor( unpack(rgb.bluesasdark ) )
	textGroupContainer:toBack()

	-- Check system for font selection
	local useFont = native.systemFont
	
	self.appFont = useFont
    ----------------------------------------------
    --- scene title in header bar
    ----------------------------------------------
	local title = display.newText( barContainer, input.sampleCodeTitle, barContainer.contentWidth / 2 , topBarOver.contentHeight / 2, useFont, 16 )
	title.anchorX = .5

	-- Create shade rectangle
	local screenShade = display.newRect( frontGroup, 0, 0, display.actualContentWidth, display.actualContentHeight )
	screenShade:setFillColor( 0,0,0 ) ; screenShade.alpha = 0
	screenShade.x, screenShade.y = display.contentCenterX, display.contentCenterY
	screenShade.isHitTestable = false ; screenShade:toBack()
    
    
    if input.rightMidButton == "delete" then 
    
        M.rightMidButton = Buttons:new({buttonName = "deleteButton"})
        --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
        M.rightMidButton:loadimages( barContainer, "pictures/trashwhite.png" , "pictures/trashblack.png", "pictures/trashblack.png" , "pictures/trashwhite.png" ,  20 , 20 )
        -- M.rightMidButton:positions_within_frame(94,50, barContainer)
        M.rightMidButton:addlistener()   -- add touch listener for rollover effects and ui events 
        M.rightMidButton.buttonGroup.anchorX = .5   
        M.rightMidButton.buttonGroup.anchorY = .5   
        rightMidButton = M.rightMidButton.buttonGroup
    end 

    ---------------------------------------
	-- Create Right button
    ---------------------------------------
    if input.rightButton == "save" then 
        M.rightButton = Buttons:new({buttonName = "saveButton"})
        --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
        M.rightButton:loadimages( barContainer, "pictures/savewhite.png" , "pictures/saveblack.png", "pictures/saveblack.png" , "pictures/savewhite.png" ,  20 , 20 )
        -- M.rightButton:positions_within_frame(94,50, barContainer)
        M.rightButton:addlistener()   -- add touch listener for rollover effects and ui events 
        M.rightButton.buttonGroup.anchorX = .5   
        M.rightButton.buttonGroup.anchorY = .5   
        rightButton = M.rightButton.buttonGroup
        
    else
        -- build info button
        input.rightButton = "info"
        M.rightButton = Buttons:new({buttonName = "infoButton"})
        --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
        M.rightButton:loadimages( barContainer, "pictures/infowhite.png" , "pictures/infoblack.png", "pictures/infoblack.png" , "pictures/infowhite.png" ,  20 , 20 )
        -- M.rightButton:positions_within_frame(85,100, barContainer)
        M.rightButton:addlistener()   -- add touch listener. 
        rightButton = M.rightButton.buttonGroup
        -- rightButton = display.newImageRect( barContainer, "pictures/infowhite.png", 20, 20 )
        -- rightButton.anchorX = 1
        -- rightButton.x = barContainer.contentWidth - 3
        -- rightButton.y = topBarOver.contentHeight / 2
        -- infoButton.isVisible = false
        rightButton.id = "infoButton"
        
        -- If there is ReadMe.txt content, create needed elements
	if readMeText ~= "" then

		-- Create the info box scrollview
		scrollBounds = widget.newScrollView
		{
			x = 160,
			y = objPos["infoBoxDestY"],
			width = 288,
			height = 240,
			horizontalScrollDisabled = true,
			hideBackground = true,
			hideScrollBar = true,
			topPadding = 0,
			bottomPadding = 0
		}
		scrollBounds:setIsLocked( true, "vertical" )
		scrollBounds.x, scrollBounds.y = display.contentCenterX, objPos["infoBoxOffY"]
		frontGroup:insert( scrollBounds )

		local infoBoxBack = display.newRect( 0, 0, 288, 240 )
		infoBoxBack:setFillColor(unpack(theme.clr_box) )
		textGroupContainer:insert( infoBoxBack )

		-- Create the info text group
		local infoTextGroup = display.newGroup()
		textGroupContainer:insert( infoTextGroup )

		-- Find and then sub out documentation links
		local docLinks = {}
		for linkTitle, linkURL in string.gmatch( readMeText, "%[([%w\%s\%p\%—]-)%]%(([%w\%p]-)%)" ) do
			docLinks[#docLinks+1] = { linkTitle, linkURL }
		end
		readMeText = string.gsub( readMeText, "%[([%w\%s\%p\%—]-)%]%(([%w\%p]-)%)", "" )

		-- Create the info text and anchoring box
		local infoText = display.newText( infoTextGroup, "", 0, 0, 260, 0, useFont, 12 )
		infoText:setFillColor( unpack(theme.clr_text) )
		local function trimString( s )
			return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
		end
		readMeText = trimString( readMeText )
		infoText.text = "\n" .. readMeText
		infoText.anchorX = 0
		infoText.anchorY = 0
		infoText.x = -130

		-- Add documentation links as additional clickable text objects below main text
		if #docLinks > 0 then
			for i = 1,#docLinks do
				local docLink = display.newText( docLinks[i][1], 0, 0, useFont, 12 )
				docLink:setFillColor( 0.9, 0.1, 0.2 )
				docLink.anchorX = 0
				docLink.anchorY = 0
				docLink.x = -130
				docLink.y = infoTextGroup.contentBounds.yMax + 5
				infoTextGroup:insert( docLink )
				if system.canOpenURL( docLinks[i][2] ) then
					docLink:addEventListener( "tap",
						function( event )
							system.openURL( docLinks[i][2] )
							return true
					end )
				end
			end
		end
		local spacer = display.newRect( infoTextGroup, 0, infoTextGroup.contentBounds.yMax, 10, 15 )
		spacer.anchorY = 0 ; spacer.isVisible = false

		local infoTextAnchorBox = display.newRect( infoTextGroup, 0, 0, 288, math.max( 240, infoTextGroup.height ) )
		infoTextAnchorBox.anchorY = 0
		infoTextAnchorBox.isVisible = false

		-- Set anchor point on info text group
		local anc = infoTextGroup.height/120
		infoTextGroup.anchorChildren = true
		infoTextGroup.anchorY = 1/anc

		-- Initially set info objects to invisible
		infoTextGroup.isVisible = false
		textGroupContainer.isVisible = false

		transComplete = function()

			if infoBoxState == "opening" then
				scrollBounds:insert( infoTextGroup )
				infoTextGroup.x = 144 ; infoTextGroup.y = 120
				scrollBounds:setIsLocked( false, "vertical" )
				scrollBounds.x, scrollBounds.y = display.contentCenterX, objPos["infoBoxDestY"]
				infoBoxState = "canClose"
				infoShowing = true
				if self.onInfoEvent then
					self.onInfoEvent( { action="show", phase="did" } )
				end
			elseif infoBoxState == "closing" then
				infoTextGroup.isVisible = false
				textGroupContainer.isVisible = false
				scrollBounds.x, scrollBounds.y = display.contentCenterX, objPos["infoBoxOffY"]
				screenShade.isHitTestable = false
				infoBoxState = "canOpen"
				infoShowing = false
				if self.onInfoEvent then
					self.onInfoEvent( { action="hide", phase="did" } )
				end
			end
		end

		local function controlInfoBox( event )
			if event.phase == "began" then
				if infoBoxState == "canOpen" then
					infoBoxState = "opening"
					infoShowing = true
					if self.onInfoEvent then
						self.onInfoEvent( { action="show", phase="will" } )
					end
					textGroupContainer.x = display.contentCenterX
					textGroupContainer.y = objPos["infoBoxOffY"]
					textGroupContainer:insert( infoTextGroup )
					infoTextGroup.isVisible = true
					textGroupContainer.isVisible = true
					textGroupContainer.xScale = 0.96 ; textGroupContainer.yScale = 0.96
					screenShade.isHitTestable = true
					transition.cancel( "infoBox" )
					transition.to( screenShade, { time=600, tag="infoBox", alpha=0.6, transition=easing.outQuad } )
					transition.to( textGroupContainer, { time=900, tag="infoBox", y=objPos["infoBoxDestY"], transition=easing.outCubic } )
					transition.to( textGroupContainer, { time=400, tag="infoBox", delay=750, xScale=1, yScale=1, transition=easing.outQuad, onComplete=transComplete } )

				elseif infoBoxState == "canClose" then
					infoBoxState = "closing"
					infoShowing = false
					if self.onInfoEvent then
						self.onInfoEvent( { action="hide", phase="will" } )
					end
					textGroupContainer:insert( infoTextGroup )
					local scrollX, scrollY = scrollBounds:getContentPosition()
					infoTextGroup.x = 0 ; infoTextGroup.y = scrollY
					scrollBounds:setIsLocked( true, "vertical" )
					transition.cancel( "infoBox" )
					transition.to( screenShade, { time=600, tag="infoBox", alpha=0, transition=easing.outQuad } )
					transition.to( textGroupContainer, { time=400, tag="infoBox", xScale=0.96, yScale=0.96, transition=easing.outQuad } )
					transition.to( textGroupContainer, { time=700, tag="infoBox", delay=200, y=objPos["infoBoxOffY"], transition=easing.inCubic, onComplete=transComplete } )
				end
			end
			return true
		end
    -- Set info button tap listener
		rightButton.isVisible = true
		rightButton:addEventListener( "touch", controlInfoBox )
		
		rightButton.listener = controlInfoBox
		screenShade:addEventListener( "touch", controlInfoBox )    
        
	end  -- readme non nil 
    
	end  -- else infoButton
    ----------------------------------------------
    --- left button
    -- Create a navigation hamburger or back for overlay case 
    ----------------------------------------------   
    if options.leftButton == "back" then 
        -- build back button
        M.addBackButton = Buttons:new({buttonName = "back"})
        --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
        M.addBackButton:loadimages( barContainer, "pictures/backwhite.png" , "pictures/backblack.png", "pictures/backblack.png" , "pictures/backwhite.png" ,  20 , 20 )
        M.addBackButton:positions_within_frame(17,50, barContainer)
        M.addBackButton:addlistener()   -- add touch listener. 
        leftButton = M.addBackButton.buttonGroup
        
	else 
        leftButton = display.newImageRect( barContainer, "pictures/hamburgerwhite.png", 20 , 20 )
        
        leftButton.anchorX = 0
        leftButton.x =  5
        leftButton.y = topBarOver.contentHeight / 2
        leftButton.isVisible = true 
        leftButton.id = "leftButton"
        
        local touch_leftButton_closed = function (index,params)
            print ("Ham  onClose : ", index , params )
            
            if index then 
                local options = {
                effect = "fromRight",
                time = 500,
                    params = {
                        someKey = "someValue",
                        someOtherKey = 10
                    }
                }
            
                composer.gotoScene( params.modulename , options ) -- Go to picked scene
            end 
        end 
        
        local touch_leftButton = function ( event )
            if event.phase == "ended" then
                -- transition.to( backGroup , {time = 800 , delay = 0 , alpha = .6 } )
                -- transition.to( frontGroup , {time = 800 , delay = 0 , alpha = .6 } )
                transition.to( input.stageDG , {time = 800 , delay = 0 , alpha = .6 } )
                --  construct rows for picker.
                
                -- misc:printtable(hamburger)
                
                            
                -- create popup to choose building choice.
                local options = {
                    isModal = true,  -- disable main panel touches 
                    -- effect = "fade",
                    effect = "fromLeft",
                    time = 500,
                        params = {
                            UIinst = self ,
                            items = hamburger ,
                            onClose = touch_leftButton_closed
                            }
                        }
                    print ("UIinst==== must not be nil here. --->  ",UIinst)	
                composer.showOverlay( "scene.hamburger", options ) -- create popup to choose nav 
            end
        end
        
        leftButton:addEventListener( "touch", touch_leftButton )
end  -- build hamburger    

	

	-- Resize change handler
	local function onResize( event )

		if display.contentHeight >= display.contentWidth then
			background.x, background.y, background.rotation = display.contentCenterX, display.contentCenterY, 0
		else
			background.x, background.y, background.rotation = display.contentCenterX, display.contentCenterY, 90
		end

		barContainer.x = display.safeScreenOriginX
		barContainer.y = display.safeScreenOriginY
        Glb.bodycontenttop = barContainer.y + barContainer.contentHeight
        Glb.bodyW = display.actualContentWidth
        Glb.bodyH = display.actualContentHeight - Glb.bodycontenttop
        
		barContainer.width = display.actualContentWidth
		topBarOver.width = barContainer.width
		title.x = barContainer.contentWidth  /2 
		-- rightButton.x = barContainer.contentWidth - 3
        M.rightButton.buttonGroup.anchorX =.5
        M.rightButton.buttonGroup.anchorY =.5
        M.rightButton:positions_within_frame(95,50, barContainer)
        if M.rightMidButton then  M.rightMidButton:positions_within_frame(80,50, barContainer) end 
        leftButton.anchorX = .5
		leftButton.x = 15
		leftButton.y = barContainer.contentHeight / 2
		screenShade.x = display.contentCenterX
		screenShade.y = display.contentCenterY
		screenShade.width = display.actualContentWidth
		screenShade.height = display.actualContentHeight
        textGroupContainer.x = display.contentCenterX
        
        if input.rightButton == "info" then 
            
            
            -- If info box is opening or already open, snap it entirely on screen
            objPos["infoBoxOffY"] = display.screenOriginY - 130
            objPos["infoBoxDestY"] = (barContainer.y + barContainer.contentHeight + 130)
            if ( infoBoxState == "opening" or infoBoxState == "canClose" ) then
                transition.cancel( "infoBox" )
                textGroupContainer.xScale, textGroupContainer.yScale = 1,1
                textGroupContainer.y = objPos["infoBoxDestY"]
                if scrollBounds then
                    scrollBounds.x, scrollBounds.y = display.contentCenterX, objPos["infoBoxDestY"]
                end
                transComplete()
            -- If info box is closing or already closed, snap it entirely off screen
            elseif ( infoBoxState == "closing" or infoBoxState == "canOpen" ) then
                transition.cancel( "infoBox" )
                textGroupContainer.y = objPos["infoBoxOffY"]
                if scrollBounds then
                    scrollBounds.x, scrollBounds.y = display.contentCenterX, objPos["infoBoxOffY"]
                end
                transComplete()
            end
        end     
	end
	-- Runtime:addEventListener( "resize", onResize )


	self.rightButton = rightButton
	self.leftButton = leftButton
	-- self.titleBarBottom = barContainer.y + barContainer.contentHeight - 2
	backGroup:toBack() ; self.backGroup = backGroup
	frontGroup:toFront() ; self.frontGroup = frontGroup
	onResize()
	return self
end

function M:isInfoShowing()
	return infoShowing
end

return M
